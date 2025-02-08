variable glue_crawler_arn {
  type        = string
  description = "ARN of the Glue Crawler"
}
variable glue_job_arn {
  type        = string
  description = "ARN of the Glue Data Quality Job"
}

variable lambda_function_arn {
  type        = string
  description = "ARN of the TRIGGER lambda Function"
}

variable sns_topic_glue_arn {
  type        = string
  description = "ARN of the Glue Topic"
}

variable ecs_task_transform_arn {
  type        = string
  description = "ARN of the ECS transform task"
}

variable ecs_task_execution_role_arn {
  type        = string
  description = "ARN of the ECS task execution role"
}

variable ecs_cluster_arn {
  type        = string
  description = "ARN of the ECS cluster"
}