output "raw_bucket_name" {
  value = aws_s3_bucket.raw-prd-bucket.bucket
}

output "scripts_bucket_name" {
  value = aws_s3_bucket.scripts-bucket.bucket
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