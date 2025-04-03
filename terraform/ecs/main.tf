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
    # Transform Container
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
          awslogs-region        = var.region
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
    # Validation Container
    {
      name      = "sdtm-container-5201201-validate",
      image     = "${aws_ecr_repository.ecr_repo_validate.repository_url}:latest",
      memory    = 512,
      cpu       = 256,
      essential = true,
      portMappings = [{
        containerPort = 8080
        hostPort      = 8080
      }],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.ecs_log_group_validate.name}"
          awslogs-region        = var.region
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