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
# AWS Provider Configuration
# =============================================================
provider "aws" {
  region = "us-west-1"
}
