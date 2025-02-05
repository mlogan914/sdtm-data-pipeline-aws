# =============================================================
# ECR/ECS Configuration
# This provisions ECS resources for running transformation and compliance scripts.
# =============================================================

# ---------------------------------------
# Create an ECR Repository
# ---------------------------------------
resource "aws_ecr_repository" "ecr_repo_transform" {
  name = "ecr-repo-520120-transform"
}

resource "aws_ecr_repository" "ecr_repo_validate" {
  name = "ecr-repo-520120-validate"
}

# ---------------------------------------
# Create an ECS cluster
# ---------------------------------------
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster-5201201"
}

# ---------------------------------------
# Create CloudWatch Log Groups
# ---------------------------------------
resource "aws_cloudwatch_log_group" "ecs_log_group_transform" {
  name = "/ecs/sdtm-task-5201201-transform"

  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "ecs_log_group_validate" {
  name = "/ecs/sdtm-task-5201201-validate"

  retention_in_days = 30
}

# ---------------------------------------
# ECS Task Definition(s)
# This defines the transform and validation containers.
# ---------------------------------------

resource "aws_ecs_task_definition" "ecs_task_transform" {
  family                   = "sdtm-task-transform"
  container_definitions    = jsonencode([
    {
      name      = "sdtm-container-5201201-transform",
      image     = "${aws_ecr_repository.ecr_repo_transform.repository_url}:latest",
      memory    = 512,
      cpu       = 256,
      essential = true,
      portMappings = [{
        containerPort = 80
        hostPort      = 80
      }],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.ecs_log_group_transform.name}"
          awslogs-region        = "us-west-1" # Change to your region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  memory                   = "1024"
  cpu                      = "512"
}

resource "aws_ecs_task_definition" "ecs_task_validate" {
  family                   = "sdtm-task-validate"
  container_definitions    = jsonencode([
    {
      name      = "sdtm-container-5201201-validate",
      image     = "${aws_ecr_repository.ecr_repo_validate.repository_url}:latest",  # If different images, specify here
      memory    = 512,
      cpu       = 256,
      essential = true,
      portMappings = [{
        containerPort = 8080  # Different port if needed for the validation task
        hostPort      = 8080
      }],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.ecs_log_group_validate.name}"
          awslogs-region        = "us-west-1" # Change to your region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  memory                   = "1024"  
  cpu                      = "512" 
}

# ---------------------------------------
# Create a Security Group
# ---------------------------------------
# Adjust if needed
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg-5201201"
  description = "Allow inbound traffic to ECS containers"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Adjust if you want specific IPs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Needed for ECR, S3, Logs, etc.
  }
}

# ---------------------------------------
# Create and ECS Service
# ---------------------------------------
# resource "aws_ecs_service" "ecs_service_transform" {
#   name            = "ecs-service-5201201-transform"
#   cluster         = aws_ecs_cluster.ecs_cluster.id
#   task_definition = aws_ecs_task_definition.ecs_task_transform.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"

#   network_configuration {
#     subnets         = var.private_subnets
#     security_groups = [aws_security_group.ecs_sg.id]
#     assign_public_ip = false
#   }
# }

# resource "aws_ecs_service" "ecs_service_validate" {
#   name            = "ecs-service-5201201-validate"
#   cluster         = aws_ecs_cluster.ecs_cluster.id
#   task_definition = aws_ecs_task_definition.ecs_task_validate.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"

#   network_configuration {
#     subnets         = var.private_subnets
#     security_groups = [aws_security_group.ecs_sg.id]
#     assign_public_ip = false
#   }
# }