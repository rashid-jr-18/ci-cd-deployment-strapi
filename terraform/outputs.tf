output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.strapi_ec2.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.strapi_ec2.public_ip
}

output "strapi_url" {
  description = "Strapi application URL"
  value       = "http://${aws_instance.strapi_ec2.public_ip}:1337"
}

output "ssh_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i strapi-rashid.pem ec2-user@${aws_instance.strapi_ec2.public_ip}"
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = data.aws_db_instance.strapi_db.endpoint
}

output "rds_address" {
  description = "RDS PostgreSQL address"
  value       = data.aws_db_instance.strapi_db.address
}
