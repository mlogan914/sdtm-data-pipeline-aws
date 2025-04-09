# =============================================================
# Terraform Configuration
# =============================================================
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.83"
    }
  }
}

# =============================================================
# Provider Configuration
# =============================================================
provider "aws" {
  region = var.region
}