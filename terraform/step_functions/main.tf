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
  "Comment": "A description of my state machine",
  "StartAt": "Lambda Invoke",
  "States": {
    "Lambda Invoke": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "QueryLanguage": "JSONata",
      "Output": "{% $states.result.Payload %}",
      "Arguments": {
        "FunctionName": "arn:aws:lambda:us-west-1:525425830681:function:process_raw_data:$LATEST",
        "Payload": "{% $states.input %}"
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
          "BackoffRate": 2,
          "JitterStrategy": "FULL"
        }
      ],
      "Next": "StartCrawler"
    },
    "StartCrawler": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:glue:startCrawler",
      "QueryLanguage": "JSONata",
      "Arguments": {
        "Name": "crawler-5201201"
      },
      "Next": "Glue StartJobRun"
    },
    "Glue StartJobRun": {
      "Type": "Task",
      "Resource": "arn:aws:states:::glue:startJobRun",
      "QueryLanguage": "JSONata",
      "Arguments": {
        "JobName": "data-quality-job-5201201"
      },
      "Next": "Choice"
    },
    "Choice": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.SdkHttpMetadata.HttpStatusCode",
          "NumericEquals": 200,
          "Next": "CheckGlueJobStatus"
        }
      ],
      "Default": "SNS Publish"
    },
    "CheckGlueJobStatus": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:glue:getJobRun",
      "Parameters": {
        "JobName.$": "$.JobName",
        "RunId.$": "$.JobRunId"
      },
      "Next": "EvaluateJobStatus"
    },
    "EvaluateJobStatus": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.JobRun.JobRunState",
          "StringEquals": "SUCCEEDED",
          "Next": "ECS RunTask"
        },
        {
          "Variable": "$.JobRun.JobRunState",
          "StringEquals": "FAILED",
          "Next": "SNS Publish"
        }
      ],
      "Default": "SNS Publish"
    },
    "ECS RunTask": {
      "Type": "Task",
      "Resource": "arn:aws:states:::ecs:runTask",
      "QueryLanguage": "JSONata",
      "Arguments": {
        "LaunchType": "FARGATE",
        "Cluster": "arn:aws:ecs:REGION:ACCOUNT_ID:cluster/MyECSCluster",
        "TaskDefinition": "arn:aws:ecs:REGION:ACCOUNT_ID:task-definition/MyTaskDefinition:1"
      },
      "End": true
    },
    "SNS Publish": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "QueryLanguage": "JSONata",
      "Arguments": {
        "TopicArn": "arn:aws:sns:us-west-1:525425830681:sns-glue-5201201",
        "Subject": "Glue Job Failure Notification",
        "Message": "{% $states.input %}"
      },
      "End": true
    }
  }
}
ASL
}
