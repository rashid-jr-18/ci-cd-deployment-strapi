variable "aws_profile" {
  description = "AWS CLI profile name"
  type        = string
  default     = "my-iam-user"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "key_name" {
  description = "Existing AWS Key Pair name"
  type        = string
  default     = "strapi-rashid"   # <-- You said this is your uploaded key
}

variable "ec2_type" {
  description = "EC2 instance type"
  type        = string
  default     = "m7i-flex.large"
}

variable "ec2_ami" {
  description = "Ubuntu AMI for ap-south-1"
  type        = string
  default     = "ami-0e742cca61fb65051"
}

variable "docker_image" {
  description = "Docker Image for Strapi"
  type        = string
  default     = "rashid18/strapi-ap:latest"
}
