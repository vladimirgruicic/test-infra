# main.tf

provider "aws" {
  region = "your_aws_region"
}

# ECS Cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = "MyEcsCluster"
}

# Task Definitions
resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  container_definitions = <<EOF
[
  {
    "name": "frontend-container",
    "image": "your_frontend_docker_image:latest",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
EOF
}

resource "aws_ecs_task_definition" "backend_task" {
  family                   = "backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  container_definitions = <<EOF
[
  {
    "name": "backend-container",
    "image": "your_backend_docker_image:latest",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ]
  }
]
EOF
}

# IAM Role for ECS Execution
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      }
    }
  ]
}
EOF
}

# ECS Service for frontend
resource "aws_ecs_service" "frontend_service" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  launch_type     = "FARGATE"
  desired_count   = 2
  network_configuration {
    subnets = [aws_subnet.public_subnet.id]
    security_groups = [aws_security_group.ecs_security_group.id]
  }
}

# ECS Service for backend
resource "aws_ecs_service" "backend_service" {
  name            = "backend-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  launch_type     = "FARGATE"
  desired_count   = 2
  network_configuration {
    subnets = [aws_subnet.private_subnet.id]
    security_groups = [aws_security_group.ecs_security_group.id]
  }
}

# Security Group for ECS
resource "aws_security_group" "ecs_security_group" {
  name        = "ecs-security-group"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.my_vpc.id
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

