# =============================================================
# AWS Lambda Configuration
# This configures Lambda resources for the pipeline.
# =============================================================

resource "aws_lambda_function" "process_raw_data" {
  function_name    = "process_raw_data"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  filename         = "./lambda/lambda_function.zip"
  source_code_hash = filebase64sha256("./lambda/lambda_function.zip")
}

output "process_raw_data_function_name" {
  value = aws_lambda_function.process_raw_data.function_name
}

output "process_raw_data_arn" {
  value = aws_lambda_function.process_raw_data.arn
}

