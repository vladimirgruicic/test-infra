# main.tf

provider "aws" {
  region = "eu-north-1"
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "MyVPC"
  }
}

# Create public and private subnets
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-north-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "PrivateSubnet"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}


# # Attach the internet gateway to the VPC
# resource "aws_internet_gateway_attachment" "my_vpc_attachment" {
#   vpc_id          = aws_vpc.my_vpc.id
#   internet_gateway_id = aws_internet_gateway.my_igw.id
# }

# ECS Cluster
resource "aws_ecs_cluster" "my_cluster" {
  name = "MyEcsCluster"
}


#Task Definitions
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

# # ECS Service for frontend
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

# # ECS Service for backend
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

# # Security Group for ECS
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

# Generate a random password for the database
resource "random_password" "db_password" {
  length = 16
  special = true
}

# RDS for Frontend Microservice
resource "aws_db_instance" "frontenddb" {
  allocated_storage = 10
  identifier = "my-postgres-db-frontend"
  engine = "postgres"
  engine_version = "13.12"
  instance_class = "db.t3.micro"
  username = "foo"
  password = "foobarfront"
  skip_final_snapshot = true
}

# RDS for Backend Microservice
resource "aws_db_instance" "backenddb" {
  allocated_storage = 10
  identifier = "my-postgres-db-backend"
  engine = "postgres"
  engine_version = "13.12"
  instance_class = "db.t3.micro"
  username = "foo"
  password = "foobarback"
  skip_final_snapshot = true
}

# Security Group for RDS - Frontend
resource "aws_security_group" "db_frontend_security_group" {
  name        = "db-frontend-security-group"
  description = "Security group for RDS - Frontend"
  vpc_id      = aws_vpc.my_vpc.id
  ingress {
    from_port   = 5432
    to_port     = 5432
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

# Security Group for RDS - Backend
resource "aws_security_group" "db_backend_security_group" {
  name        = "db-backend-security-group"
  description = "Security group for RDS - Backend"
  vpc_id      = aws_vpc.my_vpc.id
  ingress {
    from_port   = 5432
    to_port     = 5432
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

# DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids  = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]
}

# S3 Bucket for Frontend
resource "aws_s3_bucket" "test_vg_frontend_bucket" {
  bucket = "test-vg-frontend-bucket"
  acl    = "private"  # Adjust based on your access requirements

  versioning {
    enabled = true
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    enabled = true

    transition {
      days          = 30
      storage_class = "ONEZONE_IA"
    }

    expiration {
      days = 365
    }
  }

  tags = {
    Name = "FrontendBucket"
  }
}

# # ElastiCache Redis Cluster
# resource "aws_elasticache_cluster" "redis_cluster" {
#   cluster_id               = "my-redis-cluster"
#   engine                   = "redis"
#   engine_version           = "5.0.6"
#   node_type                = "cache.t3.micro"
#   num_cache_nodes          = 1
#   subnet_group_name        = aws_elasticache_subnet_group.redis_subnet_group.name
#   security_group_ids       = [aws_security_group.redis_security_group.id]
#   parameter_group_name     = "default.redis5.0"
#   port                     = 6379
# }

# # Security Group for Redis
# resource "aws_security_group" "redis_security_group" {
#   name        = "redis-security-group"
#   description = "Security group for ElastiCache Redis"
#   vpc_id      = aws_vpc.my_vpc.id
#   ingress {
#     from_port   = 6379
#     to_port     = 6379
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# # ElastiCache Subnet Group
# resource "aws_elasticache_subnet_group" "redis_subnet_group" {
#   name       = "redis-subnet-group"
#   subnet_ids = [aws_subnet.private_subnet.id]
# }

# Application Load Balancer
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_group.id]
  subnets            = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]

  enable_deletion_protection = false

  enable_cross_zone_load_balancing = true

  enable_http2 = true
}

# Target Group for ECS
resource "aws_lb_target_group" "ecs_target_group" {
  name     = "ecs-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id

  health_check {
    path     = "/"
    protocol = "HTTP"
  }
}

# Listener for ALB
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
  }
}

# Security Group for ALB
resource "aws_security_group" "alb_security_group" {
  name        = "alb-security-group"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.my_vpc.id
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

# Auto Scaling Policy
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/MyEcsCluster/frontend-service"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}


resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "my_cloudfront" {
  origin {
    domain_name = aws_s3_bucket.test_vg_frontend_bucket.bucket_regional_domain_name
    origin_id   = "S3Origin"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id = "S3Origin"

    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl      = 0
    default_ttl  = 3600
    max_ttl      = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  aliases = ["your-custom-domain.com"]  # Add your custom domain here if you have one

  # Additional configuration options can be added here
}
