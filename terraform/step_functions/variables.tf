# ================================================================
# Step Functions Module - Variables
# 
# This file defines input variables for the Step Functions module.
# ================================================================

variable glue_crawler_arn {
  type        = string
  description = "ARN of the Glue Raw bucket Glue crawler"
}

variable output_crawler_arn {
  type        = string
  description = "ARN of the Output bucket Glue crawler"
}

variable glue_job_arn {
  type        = string
  description = "ARN of the Glue Data Quality Job"
}

variable lambda_function_arn {
  type        = string
  description = "ARN of the TRIGGER lambda Function"
}

variable sns_topic_arn {
  type        = string
  description = "ARN of the SNS Topic"
}

variable ecs_task_transform_arn {
  type        = string
  description = "ARN of the ECS transform task"
}

variable ecs_task_validate_arn {
  type        = string
  description = "ARN of the ECS validate task"
}

variable ecs_task_execution_role_arn {
  type        = string
  description = "ARN of the ECS task execution role"
}

variable ecs_cluster_arn {
  type        = string
  description = "ARN of the ECS cluster"
}

variable private_subnets {
    type  = string
    description = "List of private subnet IDs"
}

variable public_subnets {
    type  = string
    description = "List of public subnet IDs"
}

variable ecs_sg_id {
    type  = string
    description = "ECS security group"
}