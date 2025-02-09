# ================================================================
# SNS Module - Outputs
# 
# This file defines outputs from the SNS module.
# ===============================================================

output "sns_topic_arn" {
  value = aws_sns_topic.sns_topic.arn
}