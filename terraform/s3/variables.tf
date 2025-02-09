# ================================================================
# S3 - Variables
# 
# This file defines input variables for the s3 module.
# ================================================================

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

variable "audit_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for audit files"
}

 variable "output_bucket_name" {
   type        = string
   description = "The name of the S3 bucket for output"
 }

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

variable "ecs_task_execution_role_arn" {
  type        = string
  description = "ARN of the ecs task execution role"
}
