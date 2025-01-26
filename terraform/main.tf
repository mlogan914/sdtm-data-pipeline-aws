# =============================================================
# Root Module Configuration
# Configures resources and inputs for the SDTM data pipeline.
# =============================================================

# S3 Module: Handles S3 buckets for raw data and scripts storage
module "s3" {
  source              = "./s3"
  raw_bucket_name     = "raw-prd-5201201"
  scripts_bucket_name = "scripts-5201201"

  tags = {
    "Project"     = "SDTM-52012-01"
    "Description" = "SDTM Data Pipeline with CI/CD Integration"
  }

  # Inputs from Lambda Module
  lambda_function_name = module.lambda.process_raw_data_function_name
  lambda_function_arn  = module.lambda.process_raw_data_arn
}

# Lambda Module: Handles the Lambda functions for processing raw data
module "lambda" {
  source = "./lambda"
}

# Glue Module: Manages AWS Glue resources (crawlers and jobs)
module "glue" {
  source = "./glue"

  # Inputs from the S3 module
  raw_bucket_name     = module.s3.raw_bucket_name
  scripts_bucket_name = module.s3.scripts_bucket_name
  raw_bucket_arn      = module.s3.raw_bucket_arn
  scripts_bucket_arn  = module.s3.scripts_bucket_arn
}

# Step Functions Module: Coordinates the data pipeline workflow
module "step_functions" {
  source = "./step_functions"

  # Inputs from the Glue module
  glue_crawler_arn = module.glue.glue_crawler_arn
  glue_job_arn     = module.glue.glue_job_arn
}

# SNS Module: Manages SNS for notifications
module "sns" {
  source = "./sns"
}

# ECS Module: Orchestrates containers for main data processing
# module "ecs" {
#   source = "./ecs"
# }

# module "vpc" {
#   source = "./vpc"
# }