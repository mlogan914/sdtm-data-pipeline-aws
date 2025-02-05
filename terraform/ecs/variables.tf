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

