terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# Create VPC
resource "aws_vpc" "dev_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev_vpc"
  }
}

# Create subnet
resource "aws_subnet" "dev_public_subnet" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "dev_public_subnet"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "dev_igw"
  }
}

# Create route table
resource "aws_route_table" "dev_route" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_igw.id
  }

  tags = {
    Name = "dev_route"
  }
}

## Associate subnet with route table
resource "aws_route_table_association" "dev_public_subnet_association" {
  subnet_id      = aws_subnet.dev_public_subnet.id
  route_table_id = aws_route_table.dev_route.id
}

# Create security group
resource "aws_security_group" "dev_sg" {
  name        = "dev_sg"
  description = "dev security group"
  vpc_id      = aws_vpc.dev_vpc.id

  dynamic "ingress" {
    for_each = [22, 80, 443, 8081,9090,9100,3000]
    iterator = port
    content {
      description = "TLS from VPC"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev_sg"
  }
}

locals {
  instance_config = {
    "test-server" = {
      ami       = "ami-02eb7a4783e7e9317"
      private_ip = "10.0.0.50"
    }
    "prod-server" = {
      ami       = "ami-02eb7a4783e7e9317"
      private_ip = "10.0.0.51"
    }
  }
}

# Create EC2 instance
resource "aws_instance" "web_server" {
  for_each = local.instance_config
  ami           = each.value.ami
  instance_type = "t2.micro"
  key_name      = "web-server"
  private_ip    = each.value.private_ip

  subnet_id                   = aws_subnet.dev_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.dev_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = each.key
  }
}
