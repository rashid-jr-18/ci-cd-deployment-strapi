terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# -------------------------
# Provider (Using IAM Profile)
# -------------------------
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# -------------------------
# 1. Use existing default VPC & Subnet
# -------------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }

  filter {
    name   = "availability-zone"
    values = ["ap-south-1a"]
  }
}

# -------------------------
# 2. Security Group (SSH + Strapi + HTTP)
# -------------------------
resource "aws_security_group" "strapi_sg" {
  name        = "strapi-rashid-group"   # <<< Updated Name
  description = "Allow Strapi (1337), HTTP (80), SSH (22)"
  vpc_id      = data.aws_vpc.default.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Strapi (Port 1337)
  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Nginx / HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "strapi-security-group"
  }
}

# -------------------------
# 3. EC2 Instance (Ubuntu + Docker + Strapi)
# -------------------------
resource "aws_instance" "strapi_server" {
  ami                         = var.ec2_ami
  instance_type               = var.ec2_type

  subnet_id                   = data.aws_subnet.default.id
  vpc_security_group_ids      = [aws_security_group.strapi_sg.id]

  key_name                    = var.key_name   # Existing AWS Key Pair Name
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 16
    volume_type           = "gp2"
    delete_on_termination = true
    encrypted             = true
  }

  user_data = templatefile(
    "${path.module}/user_data_docker.sh",
    {
      docker_image = var.docker_image
    }
  )

  user_data_replace_on_change = true

  tags = {
    Name = "rashid"
  }
}
