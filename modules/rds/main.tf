# main.tf

provider "aws" {
  region = "your_aws_region"
}

# RDS for Frontend Microservice
resource "aws_db_instance" "frontend_db" {
  identifier            = "frontend-db"
  allocated_storage     = 20
  storage_type          = "gp2"
  engine                = "postgres"
  engine_version        = "your_postgres_version"
  instance_class        = "db.t2.micro"
  name                  = "frontenddb"
  username              = "your_db_username"
  password              = "your_db_password"
  parameter_group_name  = "default.postgres9.6"
  publicly_accessible   = false
  multi_az              = false
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  subnet_group_name     = aws_db_subnet_group.db_subnet_group.name
}

# RDS for Backend Microservice
resource "aws_db_instance" "backend_db" {
  identifier            = "backend-db"
  allocated_storage     = 20
  storage_type          = "gp2"
  engine                = "postgres"
  engine_version        = "your_postgres_version"
  instance_class        = "db.t2.micro"
  name                  = "backenddb"
  username              = "your_db_username"
  password              = "your_db_password"
  parameter_group_name  = "default.postgres9.6"
  publicly_accessible   = false
  multi_az              = false
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  subnet_group_name     = aws_db_subnet_group.db_subnet_group.name
}

# Security Group for RDS
resource "aws_security_group" "db_security_group" {
  name        = "db-security-group"
  description = "Security group for RDS instances"
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
