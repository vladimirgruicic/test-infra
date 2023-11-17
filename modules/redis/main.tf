# main.tf

provider "aws" {
  region = "your_aws_region"
}

# ElastiCache Redis Cluster
resource "aws_elasticache_cluster" "redis_cluster" {
  cluster_id               = "my-redis-cluster"
  engine                   = "redis"
  engine_version           = "6.x"
  node_type                = "cache.t2.micro"
  num_cache_nodes          = 1
  subnet_group_name        = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids       = [aws_security_group.redis_security_group.id]
  parameter_group_name     = "default.redis6.x"
  port                     = 6379
}

# Security Group for Redis
resource "aws_security_group" "redis_security_group" {
  name        = "redis-security-group"
  description = "Security group for ElastiCache Redis"
  vpc_id      = aws_vpc.my_vpc.id
  ingress {
    from_port   = 6379
    to_port     = 6379
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

# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group"
  subnet_ids = [aws_subnet.private_subnet.id]
}
