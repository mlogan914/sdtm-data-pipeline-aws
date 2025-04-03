# =============================================================
# AWS Step Functions Configuration
# This provisions a Step Function workflow for Lambda, Glue Crawler,
# Data Quality Checks, and ECS Tasks.
#
# NOTE:
# - ECS network and task inputs are parameterized to allow dynamic input during deployment.
# - ARN and resource IDs are parameterized to avoid hardcoding values that change per deployment.
# ============================================================

# Create a CloudWatch log group
resource "aws_cloudwatch_log_group" "step_functions_log_group" {
  name              = "/aws/stepfunctions/state-machine-5201201"
  retention_in_days = 30
}

# ---------------------------------------
# State Function State Machine
# ---------------------------------------
resource "aws_sfn_state_machine" "my_state_machine" {
  name     = "state-machine-5201201"
  role_arn = aws_iam_role.step_function_role.arn

  definition = <<ASL
{
  "Comment": "Step Functions workflow for Lambda, Glue Crawler, Data Quality Checks, and ECS Task",
  "StartAt": "LambdaInvoke",
  "States": {
    "LambdaInvoke": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "arn:aws:lambda:us-west-2:525425830681:function:process_raw_data:$LATEST",
        "Payload.$": "$" 
      },
      "Retry": [
        {
          "ErrorEquals": [
            "Lambda.ServiceException",
            "Lambda.AWSLambdaException",
            "Lambda.SdkClientException",
            "Lambda.TooManyRequestsException"
          ]
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
          "Next": "GlueStartJobRun"
        }
      ],
      "Default": "WaitForCrawler"
    },
    "GlueStartJobRun": {
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
          "Next": "ECSRunTaskTRANSFORM"
        },
        {
          "Variable": "$.GetJobRunResponse.JobRun.JobRunState",
          "StringEquals": "FAILED",
          "Next": "SNSPublish"
        },
        {
          "Variable": "$.GetJobRunResponse.JobRun.JobRunState",
          "StringEquals": "RUNNING",
          "Next": "WaitBeforeRecheckingJobStatus"
        }
      ],
      "Default": "SNSPublish"
    },
    "WaitBeforeRecheckingJobStatus": {
      "Type": "Wait",
      "Seconds": 5,
      "Next": "GetJobRunStatus"
    },
    "ECSRunTaskTRANSFORM": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask",
      "Parameters": {
        "LaunchType": "FARGATE",
        "Cluster": "arn:aws:ecs:us-west-2:525425830681:cluster/ecs-cluster-5201201",
        "TaskDefinition": "${var.ecs_task_transform_arn}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "Subnets": [
              ${var.private_subnets},
              ${var.public_subnets}
            ],
            "SecurityGroups": [
              "${var.ecs_sg_id}"
            ],
            "AssignPublicIp": "ENABLED"
          }
        }
      },
      "Next": "WaitForTransformTask",
      "Catch": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "SNSPublish"
        }
      ]
    },
    "WaitForTransformTask": {
      "Type": "Wait",
      "Seconds": 120,
      "Next": "ECSRunTaskVALIDATE"
    },
    "ECSRunTaskVALIDATE": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask",
      "Parameters": {
        "LaunchType": "FARGATE",
        "Cluster": "arn:aws:ecs:us-west-2:525425830681:cluster/ecs-cluster-5201201",
        "TaskDefinition": "${var.ecs_task_validate_arn}",
        "NetworkConfiguration": {
          "AwsvpcConfiguration": {
            "Subnets": [
              ${var.private_subnets},
              ${var.public_subnets}
            ],
            "SecurityGroups": [
              "${var.ecs_sg_id}"
            ],
             "AssignPublicIp": "ENABLED"
          }
        }
      },
      "Next": "WaitForValidateTask",
      "Catch": [
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "SNSPublish"
        }
      ]
    },
    "WaitForValidateTask": {
      "Type": "Wait",
      "Seconds": 120,
      "Next": "StartOutputCrawler"
    },
    "StartOutputCrawler": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:glue:startCrawler",
      "Parameters": {
        "Name": "output-crawler-5201201"
      },
      "Next": "WaitForOutputCrawler"
    },
    "WaitForOutputCrawler": {
      "Type": "Wait",
      "Seconds": 5,
      "Next": "CheckOutputCrawlerStatus"
    },
    "CheckOutputCrawlerStatus": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:glue:getCrawler",
      "Parameters": {
        "Name": "output-crawler-5201201"
      },
      "Next": "EvaluateOutputCrawlerStatus"
    },
    "EvaluateOutputCrawlerStatus": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.Crawler.State",
          "StringEquals": "READY",
          "Next": "WorkflowComplete"
        }
      ],
      "Default": "WaitForOutputCrawler"
    },
    "WorkflowComplete": {
      "Type": "Succeed"
    },
    "SNSPublish": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "TopicArn": "arn:aws:sns:us-west-2:525425830681:sns-topic-5201201",
        "Subject": "ECS Task Failure Notification",
        "Message.$": "$"
      },
      "End": true
    }
  }
}
ASL

logging_configuration {
  log_destination        = "${aws_cloudwatch_log_group.step_functions_log_group.arn}:*"
  include_execution_data = true
  level                  = "ALL"
}
}