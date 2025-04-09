# NOTE:
# This is needed because provider source mappings are not inherited
# from the root module. Without this, Terraform will look for
# hashicorp/datadog (which doesn’t exist).

# =============================================================
# Terraform Configuration
# =============================================================
terraform {
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = ">= 3.0.0, < 4.0.0"
    }
  }
}

# =============================================================
# Provider Configuration
# =============================================================

# NOTE: This can also be set via the DD_API_KEY environment variable.
provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}