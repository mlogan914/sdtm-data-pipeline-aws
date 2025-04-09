# =============================================================
# Datadog Lambda Forwarder
# Use the Datadog Forwarder to ship logs from S3 and CloudWatch, as well as observability data from Lambda functions to Datadog. 
# 
# Documentation: https://github.com/DataDog/datadog-serverless-functions/tree/master/aws/logs_monitoring
# Note: Subscription filters are not created automatically by the DatadogForwarder. Create them directly on a Log Group.
# ============================================================

resource "aws_cloudformation_stack" "datadog_forwarder" {
  name         = "datadog-forwarder"
  capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]
  parameters   = {

    DdApiKeySecretArn  = aws_secretsmanager_secret.datadog_api_key.arn,
    DdApiKey  = var.datadog_api_key
    DdSite             = "datadoghq.com",
    FunctionName       = "datadog-forwarder"
  }
  template_url = "https://datadog-cloudformation-template.s3.amazonaws.com/aws/forwarder/latest.yaml"
}

# Log Group Subscription FIlters to Datadog Forwarder
resource "aws_cloudwatch_log_subscription_filter" "datadog_lambda_process_raw_subscription" {
  name            = "datadog-process-raw-subscription"
  log_group_name  = "/aws/lambda/process_raw_data"
  filter_pattern  = "" 
  destination_arn = var.datadog_forwarder_arn
}

# resource "aws_cloudwatch_log_subscription_filter" "datadog_stepfunctions_subscription" {
#   name            = "datadog-stepfunctions-subscription"
#   log_group_name  = "/aws/stepfunctions/state-machine-5201201"
#   filter_pattern  = ""
#   destination_arn = var.datadog_forwarder_arn
# }

resource "aws_cloudwatch_log_subscription_filter" "datadog_crawler_subscription" {
  name            = "datadog-crawler-subscription"
  log_group_name  = "/aws-glue/crawlers"
  filter_pattern  = "" 
  destination_arn = var.datadog_forwarder_arn
}

resource "aws_cloudwatch_log_subscription_filter" "datadog_glue_subscription" {
  name            = "datadog-glue-subscription"
  log_group_name  = "/aws-glue/jobs/output"
  filter_pattern  = "" 
  destination_arn = var.datadog_forwarder_arn
}

resource "aws_cloudwatch_log_subscription_filter" "datadog_ecs_transform_subscription" {
  name            = "datadog-ecs-transform-subscription"
  log_group_name  = "/ecs/sdtm-task-5201201-transform"
  filter_pattern  = "" 
  destination_arn = var.datadog_forwarder_arn
}

resource "aws_cloudwatch_log_subscription_filter" "datadog_ecs_validate_subscription" {
  name            = "datadog-ecs-validate-subscription"
  log_group_name  = "/ecs/sdtm-task-5201201-validate"
  filter_pattern  = "" 
  destination_arn = var.datadog_forwarder_arn
}




