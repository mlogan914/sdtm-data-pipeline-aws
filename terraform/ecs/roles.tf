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

#Attach AWS Managed policy for ECS Task Execution
resource "aws_iam_policy_attachment" "ecs_task_execution_attachment" {
  name       = "ecs-task-execution-policy"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Create a custom policy for S3 write access
resource "aws_iam_policy" "ecs_s3_write_policy" {
  name        = "ecsS3WritePolicy"
  description = "Policy to allow ECS tasks to write to a specific S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = "s3:PutObject"
        Resource = "${var.oper_bucket_arn}/*"
      }
    ]
  })
}

# Attach the custom S3 write policy to the ECS Task Execution Role
resource "aws_iam_policy_attachment" "ecs_s3_write_attachment" {
  name       = "ecs-s3-write-policy-attachment"
  roles      = [aws_iam_role.ecs_task_execution_role.name]
  policy_arn = aws_iam_policy.ecs_s3_write_policy.arn
}