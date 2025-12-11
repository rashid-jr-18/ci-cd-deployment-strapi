output "public_ip" {
  description = "Public IP of the Strapi EC2 server"
  value       = aws_instance.strapi_server.public_ip
}

output "ssh_command" {
  description = "Use this command to SSH"
  value       = "ssh -i C:/Users/RASHID/Downloads/strapi-rashid.pem ubuntu@${aws_instance.strapi_server.public_ip}"
}
