terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# -------------------------
# Default VPC & Subnet
# -------------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# -------------------------
# Existing RDS
# -------------------------
data "aws_db_instance" "strapi_db" {
  db_instance_identifier = "database-razeeth"
}

# -------------------------
# Security Group (CREATED BY TERRAFORM)
# -------------------------
resource "aws_security_group" "strapi_sg" {
  name        = "strapi-rashid-sg"
  description = "Allow SSH, Strapi, HTTP, PostgreSQL"
  vpc_id      = data.aws_vpc.default.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Strapi
  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # PostgreSQL (RDS)
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # OK for demo, restrict later
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "strapi-rashid-sg"
  }
}

# -------------------------
# EC2 Instance
# -------------------------
resource "aws_instance" "strapi_ec2" {
  ami                         = var.ec2_ami
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.strapi_sg.id]
  key_name                    = "strapi-rashid"
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data_docker.sh", {
    db_host     = data.aws_db_instance.strapi_db.address
    db_port     = data.aws_db_instance.strapi_db.port
    db_name     = data.aws_db_instance.strapi_db.db_name
    db_username = "postgresrazeeth"
    db_password = "strapi1234"
  })

  tags = {
    Name = "strapi-ec2-razeeth"
  }
}
