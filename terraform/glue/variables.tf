# ================================================================
# Glue - Variables
# 
# This file defines input variables for the Glue module.
# ================================================================

variable "raw_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for raw data"
}

variable "scripts_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for scripts"
}

#  variable "output_bucket_name" {
#    type        = string
#    description = "The name of the S3 bucket for output"
#  }

variable "raw_bucket_arn" {
  description = "The ARN of the raw S3 bucket"
  type        = string
}

variable "scripts_bucket_arn" {
  description = "The ARN of the scripts S3 bucket"
  type        = string
}

