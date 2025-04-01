# ================================================================
# ECS Module - IAM Roles and Policies
# 
# This file defines roles and policies for the ECS module.
# ===============================================================

# ------------------------------------------------------
# ECS Task Execution Role (for pulling images & logging)
# ------------------------------------------------------

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

# Attach AWS managed policy for ECS Task Execution Role
resource "aws_iam_policy_attachment" "ecs_task_execution_attachment" {
  name       = "ecs-task-execution-policy"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ------------------------------------------------------
# Custom policies: s3, Datadog
# ------------------------------------------------------

# -- S3 --

# Add custom S3 access policy to ECS Execution Role
resource "aws_iam_policy" "ecs_s3_policy" {
  name        = "ecsS3Policy"
  description = "Policy to allow ECS tasks to read and write to S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${var.oper_bucket_arn}/*",
          "${var.audit_bucket_arn}/*"
        ]
      }
    ]
  })
}

# Attach the custom S3 policy to ECS Execution Role
resource "aws_iam_policy_attachment" "ecs_s3_policy_attachment" {
  name       = "ecs-s3-policy-attachment"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = aws_iam_policy.ecs_s3_policy.arn
}

# -- Datadog --

# Add custom policy for Datadog permissions
resource "aws_iam_policy" "ecs_datadog_policy" {
  name        = "ecsDatadogPolicy"
  description = "Permissions for Datadog to interact with ECS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ecs:ListClusters",
          "ecs:ListContainerInstances",
          "ecs:DescribeContainerInstances"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the custom Datadog policy to ECS Execution Role
resource "aws_iam_policy_attachment" "ecs_datadog_policy_attachment" {
  name       = "ecs-datadog-policy-attachment"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = aws_iam_policy.ecs_datadog_policy.arn
}