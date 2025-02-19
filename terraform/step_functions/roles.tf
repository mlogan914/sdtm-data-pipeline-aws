# ================================================================
# Step Functions Module - IAM Roles and Policies
# 
# This file defines roles and policies for the Step Functions module.
# ===============================================================

# Step Functions Service Role
resource "aws_iam_role" "step_function_role" {
  name = "step-function-role"

  assume_role_policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
JSON
}

resource "aws_iam_policy" "step_function_policy" {
  name        = "step-function-policy"
  description = "Policy for Step Functions to interact with Lambda, Glue, X-Ray, SNS, and ECS"

  policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "glue:StartCrawler",
        "glue:GetCrawler"
    ],
      "Resource": [
        "${var.glue_crawler_arn}",
        "${var.output_crawler_arn}"
    ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "glue:StartJobRun",
        "glue:GetJobRun"
      ],
      "Resource": "${var.glue_job_arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords",
        "xray:GetSamplingRules",
        "xray:GetSamplingTargets"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "lambda:InvokeFunction",
      "Resource": [
        "${var.lambda_function_arn}:$LATEST"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "SNS:Publish",
      "Resource": "${var.sns_topic_arn}"
    },
    {
      "Effect": "Allow",
      "Action": "ecs:RunTask",
      "Resource": [
        "${var.ecs_cluster_arn}",
        "${var.ecs_task_transform_arn}",
        "${var.ecs_task_validate_arn}"
    ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecs:RunTask",
        "ecs:DescribeTasks"
      ],
      "Resource": [
        "${var.ecs_task_transform_arn}",
        "${var.ecs_task_validate_arn}",
        "arn:aws:ecs:us-west-2:525425830681:task/*"
    ]
    },
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "${var.ecs_task_execution_role_arn}"
    }
  ]
}
JSON
}

# Attach ECS Custom Policy
resource "aws_iam_role_policy_attachment" "step_function_policy_attachment" {
  policy_arn = aws_iam_policy.step_function_policy.arn
  role       = aws_iam_role.step_function_role.name
}

# Attach AWS managed ECS Task Execution Policy
# resource "aws_iam_role_policy_attachment" "ecs_task_execution_attachment" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
#   role       = aws_iam_role.step_function_role.name
# }
