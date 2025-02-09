# ================================================================
# Lambda Module - Outputs
# 
# This file defines outputs from the Lambda module.
# ===============================================================

output "process_raw_data_function_name" {
  value = aws_lambda_function.process_raw_data.function_name
}

output "process_raw_data_arn" {
  value = aws_lambda_function.process_raw_data.arn
}