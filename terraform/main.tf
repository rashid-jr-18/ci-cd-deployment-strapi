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

# Default VPC
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Existing RDS
data "aws_db_instance" "strapi_db" {
  db_instance_identifier = "database-razeeth"
}

# EXISTING SECURITY GROUP (REUSED)
data "aws_security_group" "existing_sg" {
  name = "security-rashid-group"
}

# EC2 Instance
resource "aws_instance" "strapi_ec2" {
  ami                         = var.ec2_ami
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [data.aws_security_group.existing_sg.id]
  key_name                    = "strapi-rashid"
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/user_data.sh", {
    db_host     = data.aws_db_instance.strapi_db.address
    db_port     = data.aws_db_instance.strapi_db.port
    db_name     = data.aws_db_instance.strapi_db.db_name
    db_username = "postgresrazeeth"
    db_password = "strapi1234"
  })

  tags = {
    Name = "strapi-ec2"
  }
}
