# =============================================================
# SNS Configuration
# This configures SNS resources for the pipeline.
# =============================================================

# Create SNS Topic
 resource "aws_sns_topic" "glue_job_notification" {
   name = "sns-glue-5201201"
 }

# Create Subscription
 resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.glue_job_notification.arn
  protocol  = "email"
  endpoint  = "gypsyelder7231@gmail.com" # Replace with your email address
}

