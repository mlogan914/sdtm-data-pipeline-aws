output "glue_crawler_arn" {
  value = aws_glue_crawler.glue_crawler.arn
}

output "glue_job_arn" {
  value = aws_glue_job.data_quality_job.arn
}