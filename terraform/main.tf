# =============================================================
# Root Module Configuration
# Configures resources and inputs for the SDTM data pipeline.
# =============================================================
#---------------------------------------------------------------
# S3 Module: 
# Handles S3 buckets for raw data and scripts storage
#---------------------------------------------------------------
module "s3" {
  source                             = "./s3"
  region                             = var.region
  raw_bucket_name                    = var.raw_bucket_name
  scripts_bucket_name                = var.scripts_bucket_name
  oper_bucket_name                   = var.oper_bucket_name
  audit_bucket_name                  = var.audit_bucket_name
  output_bucket_name                 = var.output_bucket_name
  appdata_bucket_name                = var.appdata_bucket_name
  query_results_bucket_name          = var.query_results_bucket_name
  s3_access_point_name               = var.s3_access_point_name
  s3_object_lambda_access_point_name = var.s3_object_lambda_access_point_name
  s3_object_lambda_access_point_arn  = var.s3_object_lambda_access_point_arn
  tags                               = var.tags

  # Inputs from Lambda Module
  lambda_function_name = module.lambda.process_raw_data_function_name
  lambda_function_arn  = module.lambda.process_raw_data_arn

  # Inputs from ECS Module
  ecs_task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
}

#---------------------------------------------------------------
# Lambda Module: 
# Handles the Lambda functions for processing raw data
#---------------------------------------------------------------
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

#---------------------------------------------------------------
# Step Functions Module: 
# Coordinates the data pipeline workflow
#---------------------------------------------------------------
module "step_functions" {
  source = "./step_functions"

  # Inputs from Lambda module
  lambda_function_arn = module.lambda.process_raw_data_arn

  # Inputs from the Glue module
  glue_crawler_arn = module.glue.glue_crawler_arn
  glue_job_arn     = module.glue.glue_job_arn

  # Inputs from SNS module
  sns_topic_arn = module.sns.sns_topic_arn

  # Inputs form ECS module
  ecs_task_transform_arn      = module.ecs.ecs_task_transform_arn
  ecs_task_validate_arn       = module.ecs.ecs_task_validate_arn
  ecs_task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
  ecs_cluster_arn             = module.ecs.ecs_cluster_arn

  # Inputs from VPC module
  private_subnets = join(",", [for subnet in module.vpc.private_subnets : "\"${subnet}\""])
  public_subnets  = join(",", [for subnet in module.vpc.public_subnets : "\"${subnet}\""])
  ecs_sg_id       = module.ecs.ecs_sg_id
}

#---------------------------------------------------------------
# SNS Module: 
# Manages SNS for notifications
#---------------------------------------------------------------
module "sns" {
  source = "./sns"
}

module "vpc" {
  source = "./vpc"
}

#---------------------------------------------------------------
# ECS Module: 
# Orchestrates containers for main data processing
#---------------------------------------------------------------
module "ecs" {
  source = "./ecs"
  region = var.region

  # Inputs from VPC module
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets

  # Inputs from the S3 module
  oper_bucket_arn   = module.s3.oper_bucket_arn
  audit_bucket_arn  = module.s3.audit_bucket_arn
  output_bucket_arn = module.s3.output_bucket_arn
}

#---------------------------------------------------------------
# Athena Module: 
# Athena setup for querying results
#---------------------------------------------------------------
module "athena" {
  source = "./athena"

  # Inputs from the S3 module
  query_results_bucket_name = var.query_results_bucket_name
  query_results_bucket_id   = module.s3.query_results_bucket_id
}