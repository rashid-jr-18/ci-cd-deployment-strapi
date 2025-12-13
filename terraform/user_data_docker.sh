#!/bin/bash
set -e

dnf update -y
dnf install -y docker unzip
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip
./aws/install

aws ecr get-login-password --region ap-south-1 \
| docker login --username AWS --password-stdin 301782007642.dkr.ecr.ap-south-1.amazonaws.com

docker pull 301782007642.dkr.ecr.ap-south-1.amazonaws.com/rashid:latest

docker stop strapi-app || true
docker rm strapi-app || true

docker run -d \
  --name strapi-app \
  -p 1337:1337 \
  -e DATABASE_CLIENT=postgres \
  -e DATABASE_HOST=${db_host} \
  -e DATABASE_PORT=${db_port} \
  -e DATABASE_NAME=${db_name} \
  -e DATABASE_USERNAME=${db_username} \
  -e DATABASE_PASSWORD=${db_password} \
  301782007642.dkr.ecr.ap-south-1.amazonaws.com/rashid:latest
