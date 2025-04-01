# =============================================================
# Terraform Configuration
# =============================================================
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.83"
    }
    datadog = {
      source = "DataDog/datadog"
    }
  }
}

# =============================================================
# AWS Provider Configuration
# =============================================================
provider "aws" {
  region = var.region
}

provider "datadog" {
  api_key = var.datadog_api_key
}