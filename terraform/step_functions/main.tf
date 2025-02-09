# =============================================================
# AWS Step Functions Configuration
# This provisions Step Function workflow.
# ============================================================

# ---------------------------------------
# State Function State Machine
# ---------------------------------------
resource "aws_sfn_state_machine" "my_state_machine" {
  name     = "state-machine-5201201"
  role_arn = aws_iam_role.step_function_role.arn

  definition = <<ASL
{
  "Comment": "Step Functions workflow for Lambda, Glue Crawler, Data Quality Checks, and ECS Task",
  "StartAt": "Lambda Invoke",
  "States": {
    "Lambda Invoke": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "arn:aws:lambda:us-west-1:525425830681:function:process_raw_data:$LATEST",
        "Payload.$": "$"
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ],
          "IntervalSeconds": 1,
          "MaxAttempts": 3,
          "BackoffRate": 2
        }
      ],
      "Next": "StartCrawler"
    },
    "StartCrawler": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:glue:startCrawler",
      "Parameters": {
        "Name": "crawler-5201201"
      },
      "Next": "WaitForCrawler"
    },
    "WaitForCrawler": {
      "Type": "Wait",
      "Seconds": 5,
      "Next": "CheckCrawlerStatus"
    },
    "CheckCrawlerStatus": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:glue:getCrawler",
      "Parameters": {
        "Name": "crawler-5201201"
      },
      "Next": "EvaluateCrawlerStatus"
    },
    "EvaluateCrawlerStatus": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.Crawler.State",
          "StringEquals": "READY",
          "Next": "Glue StartJobRun"
        }
      ],
      "Default": "WaitForCrawler"
    },
    "Glue StartJobRun": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:glue:startJobRun",
      "Parameters": {
        "JobName": "data-quality-job-5201201"
      },
      "ResultPath": "$.JobRunResult",
      "Next": "GetJobRunStatus"
    },
    "GetJobRunStatus": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:glue:getJobRun",
      "Parameters": {
        "JobName": "data-quality-job-5201201",
        "RunId.$": "$.JobRunResult.JobRunId"
      },
      "ResultPath": "$.GetJobRunResponse",
      "Next": "EvaluateJobStatus"
    },
    "EvaluateJobStatus": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.GetJobRunResponse.JobRun.JobRunState",
          "StringEquals": "SUCCEEDED",
          "Next": "ECS RunTask"
        },
        {
          "Variable": "$.GetJobRunResponse.JobRun.JobRunState",
          "StringEquals": "FAILED",
          "Next": "SNS Publish"
        },
        {
          "Variable": "$.GetJobRunResponse.JobRun.JobRunState",
          "StringEquals": "RUNNING",
          "Next": "WaitBeforeRecheckingJobStatus"
        }
      ],
      "Default": "SNS Publish"
    },
    "WaitBeforeRecheckingJobStatus": {
      "Type": "Wait",
      "Seconds": 5,
      "Next": "GetJobRunStatus"
    },
    "ECS RunTask": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask",
      "Parameters": {
        "LaunchType": "FARGATE",
        "Cluster": "arn:aws:ecs:us-west-1:525425830681:cluster/ecs-cluster-5201201",
        "TaskDefinition": "${var.ecs_task_transform_arn}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "Subnets": [
              ${var.private_subnets},
              ${var.public_subnets}
            ],
            "SecurityGroups": [
              "sg-02071dac5218410e0"
            ],
            "AssignPublicIp": "ENABLED"
          }
        }
      },
      "End": true
    },
    "SNS Publish": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "arn:aws:sns:us-west-1:525425830681:sns-glue-5201201",
        "Subject": "Glue Job Failure Notification",
        "Message.$": "$"
      },
      "End": true
    }
  }
}
ASL
}
