# main.tf

provider "aws" {
  region = "your_aws_region"
}

# Generate a random password for the database
resource "random_password" "db_password" {
  length = 16
  special = true
}

# RDS for Frontend Microservice
resource "aws_db_instance" "frontenddb" {
  identifier = "my-postgres-db"
  engine = "postgres"
  engine_version = "13.4"
  instance_class = "db.t3.micro"
  username = "postgres"
  password = random_password.db_password.result
  skip_final_snapshot = true
}

# RDS for Backend Microservice
resource "aws_db_instance" "frontenddb" {
  identifier = "my-postgres-db"
  engine = "postgres"
  engine_version = "13.4"
  instance_class = "db.t3.micro"
  username = "postgres"
  password = random_password.db_password.result
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
  subnet_ids = [aws_subnet.private_subnet.id]
}
