# main.tf

provider "aws" {
  region = "your_aws_region"
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
  availability_zone       = "your_az"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "your_az"
  map_public_ip_on_launch = false
  tags = {
    Name = "PrivateSubnet"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Attach the internet gateway to the VPC
resource "aws_vpc_attachment" "my_vpc_attachment" {
  vpc_id          = aws_vpc.my_vpc.id
  internet_gateway_id = aws_internet_gateway.my_igw.id
}
