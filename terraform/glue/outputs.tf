# ================================================================
# Glue Module - Outputs
# 
# This file defines outputs from the Glue module.
# ===============================================================

output "glue_crawler_arn" {
  value = aws_glue_crawler.glue_crawler.arn
}

output "output_crawler_arn" {
  value = aws_glue_crawler.output_crawler.arn
}

output "glue_job_arn" {
  value = aws_glue_job.data_quality_job.arn
}