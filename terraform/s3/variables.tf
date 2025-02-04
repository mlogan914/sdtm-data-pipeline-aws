variable "raw_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for raw data"
}

variable "scripts_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for scripts"
}

variable "oper_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for operational files"
}

#  variable "output_bucket_name" {
#    type        = string
#    description = "The name of the S3 bucket for output"
#  }

variable "tags" {
  type        = map(string)
  description = "Tags for the resources"
}

variable "lambda_function_name" {
  type        = string
  description = "Name of the Lambda function to be triggered by S3 events"
}

variable "lambda_function_arn" {
  type        = string
  description = "ARN of the Lambda function to be triggered by S3 events"
}

