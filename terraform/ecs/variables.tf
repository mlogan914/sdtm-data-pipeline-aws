variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
  default = []
}

variable "oper_bucket_arn" {
  description = "The ARN of the oper S3 bucket"
  type        = string
}

variable "audit_bucket_arn" {
  description = "The ARN of the audit S3 bucket"
  type        = string
}

variable "output_bucket_arn" {
  description = "The ARN of the output S3 bucket"
  type        = string
}


