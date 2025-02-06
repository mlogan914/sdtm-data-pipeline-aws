output "sns_topic_glue_arn" {
  value = aws_sns_topic.glue_job_notification.arn
}