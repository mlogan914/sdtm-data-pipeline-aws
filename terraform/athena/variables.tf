# ================================================================
# Athena - Variables
# 
# This file defines input variables for the Athena module.
# ================================================================
variable "query_results_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for Athena query results"
}

variable "query_results_bucket_id" {
  type        = string
  description = "ID for the Athena query results S3 bucket"
}