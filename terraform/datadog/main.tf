# ==================================================
#   Datadog AWS Integration
# ==================================================
#
#   NOTE: If using prebuilt Lambda functions, deploy them first, 
#         then provide the function ARN in root module.
#
#   Documentation:
#   - AWS Integration w/ Terraform: https://docs.datadoghq.com/integrations/guide/aws-terraform-setup/
#   - Datadog IAM Role Permissions: https://docs.datadoghq.com/integrations/amazon_web_services/?tab=manual#aws-iam-permissions
#   - Log forwarding: https://docs.datadoghq.com/logs/guide/send-aws-services-logs-with-the-datadog-lambda-function/?tab=awsconsole
#   - Datadog Forwarder lambda Function Terraform: https://docs.datadoghq.com/logs/guide/forwarder/?tab=terraform
#   - Obervability in Event Driven Architechtures: https://www.datadoghq.com/architecture/observability-in-event-driven-architecture/
# ==================================================

resource "datadog_integration_aws_account" "datadog_integration" {
  account_tags   = []
  aws_account_id = "${var.aws_account_id}"
  aws_partition  = "aws"
  aws_regions {
    include_all = true
  }
  auth_config {
    aws_auth_config_role {
      role_name = "DatadogIntegrationRole"
    }
  }
    resources_config {
    cloud_security_posture_management_collection = true
    extended_collection                          = true
  }
  traces_config {
    xray_services {
    }
  }
    logs_config {
        lambda_forwarder {
            lambdas = ["${var.datadog_forwarder_arn}"] 
            sources =["s3"]
        }
  }
  metrics_config {
    namespace_filters {
    }
  }
}


