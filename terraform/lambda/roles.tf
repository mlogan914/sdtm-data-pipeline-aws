# Lambda Execution Role
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach basic execution, AWS managed policy to Lambda execution role
resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "lambda-basic-execution"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  roles      = [aws_iam_role.lambda_execution_role.name]
}

# Attach s3 read-only, customer managed policy to Lambda execution role
resource "aws_iam_policy_attachment" "lambda_s3_read_only_attachment" {
  name       = "lambda-s3-access-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  roles      = [aws_iam_role.lambda_execution_role.name]
}

# Attach Step Functions managed policy to Lambda execution role
resource "aws_iam_policy_attachment" "lambda_step_functions_attachment" {
  name       = "lambda-step-functions-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AWSStepFunctionsFullAccess"
  roles      = [aws_iam_role.lambda_execution_role.name]
}