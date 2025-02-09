# ================================================================
# S3 Module - Outputs
# 
# This file defines outputs from the s3 module.
# ===============================================================

output "raw_bucket_name" {
  value = aws_s3_bucket.raw-prd-bucket.bucket
}

output "scripts_bucket_name" {
  value = aws_s3_bucket.scripts-bucket.bucket
}

output "oper_bucket_name" {
  value = aws_s3_bucket.oper-bucket.bucket
}

output "audit_bucket_name" {
  value = aws_s3_bucket.audit-bucket.bucket
}

output "output_bucket_name" {
  value = aws_s3_bucket.output-bucket.bucket
}

output "raw_bucket_arn" {
  value = aws_s3_bucket.raw-prd-bucket.arn
}

output "scripts_bucket_arn" {
  value = aws_s3_bucket.scripts-bucket.arn
}

output "oper_bucket_arn" {
  value = aws_s3_bucket.oper-bucket.arn
}

output "audit_bucket_arn" {
  value = aws_s3_bucket.audit-bucket.arn
}

output "output_bucket_arn" {
  value = aws_s3_bucket.output-bucket.arn
}