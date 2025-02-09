# =============================================================
# SNS Configuration
# This configures SNS resources for the pipeline.
# =============================================================

# Create SNS Topic for Notifications
resource "aws_sns_topic" "sns_topic" {
  name = "sns-topic-5201201"
}

# Create Subscription for Notifications
resource "aws_sns_topic_subscription" "sns_email_subscription" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = "gypsyelder7231@gmail.com" # Replace with your email address
}
