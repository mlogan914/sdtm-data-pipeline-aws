# ================================================================
# Root Module - Variables
# 
# This file defines input variables for the Root module.
# ================================================================
variable "region" {}
variable "raw_bucket_name" {}
variable "scripts_bucket_name" {}
variable "oper_bucket_name" {}
variable "audit_bucket_name" {}
variable "output_bucket_name" {}
variable "appdata_bucket_name" {}
variable "query_results_bucket_name" {}
variable "s3_access_point_name" {}
variable "s3_object_lambda_access_point_name" {}
variable "s3_object_lambda_access_point_arn" {}
variable "tags" {
  type = map(string)
}