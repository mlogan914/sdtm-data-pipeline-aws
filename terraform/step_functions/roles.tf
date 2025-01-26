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
  description = "Policy for Step Functions to interact with Lambda, Glue, and X-Ray"

  policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "glue:StartCrawler",
      "Resource": "${var.glue_crawler_arn}"
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
        "arn:aws:lambda:us-west-1:525425830681:function:process_raw_data:*",
        "arn:aws:lambda:us-west-1:525425830681:function:process_raw_data"
      ]
    }
  ]
}
JSON
}

resource "aws_iam_role_policy_attachment" "step_function_policy_attachment" {
  policy_arn = aws_iam_policy.step_function_policy.arn
  role       = aws_iam_role.step_function_role.name
}
