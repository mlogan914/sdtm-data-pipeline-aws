# =============================================================
# Datadog KMS Resource for API Key Encryption
#
# Datadog recommends creating separate Terraform configurations:
#
#    1. Use the first one to store the Datadog API key in the AWS Secrets Manager, and note down the secrets ARN from the output of apply.
#    2. Then, create a configuration for the forwarder and supply the secrets ARN through the DdApiKeySecretArn parameter.
#    3. Finally, create a configuration to set up triggers on the Forwarder.
# 
# Documentation: https://docs.datadoghq.com/logs/guide/forwarder/?tab=terraform
# =============================================================

resource "aws_secretsmanager_secret" "datadog_api_key" {
  name        = "datadog_api_key"
  description = "Encrypted Datadog API Key"
}

resource "aws_secretsmanager_secret_version" "datadog_api_key" {
  secret_id     = aws_secretsmanager_secret.datadog_api_key.id
  secret_string = var.datadog_api_key
}

output "datadog_api_key" {
  value = aws_secretsmanager_secret.datadog_api_key.arn
}