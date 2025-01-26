# =============================================================
# ECR/ECS Configuration
# This provisions ECS resources for running transformation and compliance scripts.
# =============================================================

# ---------------------------------------
# Create an ECR Repository
# ---------------------------------------
resource "aws_ecr_repository" "ecs_repo" {
  name = "ecs-repo-520120"
}

# ---------------------------------------
# Create an ECS cluster
# ---------------------------------------
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster-5201201"
}

# ---------------------------------------
# ECS Task Definition(s)
# ---------------------------------------
resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "sdtm-task-5201201"
  container_definitions    = jsonencode([{
    name      = "sdtm-container-5201201",
    image     = "${aws_ecr_repository.ecs_repo.repository_url}:latest",
    memory    = 512,
    cpu       = 256,
    essential = true,
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
  
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  memory                   = "512"
  cpu                      = "256"
}

# ---------------------------------------
# Create and ECS Service
# ---------------------------------------
resource "aws_ecs_service" "ecs_service" {
  name            = "ecs-service-5201201"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = ["subnet-xxxxxxx", "subnet-yyyyyyy"] # Replace with your subnets
    security_groups = [aws_security_group.example.id]
    assign_public_ip = true
  }
}

# ---------------------------------------
# Create a Security Group
# ---------------------------------------
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg-5201201"
  description = "Allow inbound traffic to ECS containers"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
