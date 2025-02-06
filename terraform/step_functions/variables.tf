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