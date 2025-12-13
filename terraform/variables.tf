variable "instance_type" {
  default = "t3.micro"
}

variable "ec2_ami" {
  description = "Amazon Linux 2023 AMI (ap-south-1)"
  default     = "ami-0f5ee92e2d63afc18"
}
