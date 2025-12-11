#!/bin/bash
set -e

apt update -y
apt install -y docker.io
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

docker network create strapi-network || true

docker run -d \
  --name strapi-postgres \
  --network strapi-network \
  -e POSTGRES_DB=strapi \
  -e POSTGRES_USER=strapi \
  -e POSTGRES_PASSWORD=strapi123 \
  -v postgres_data:/var/lib/postgresql/data \
  postgres:15

docker run -d \
  --name strapi-app \
  --network strapi-network \
  -e DATABASE_CLIENT=postgres \
  -e DATABASE_NAME=strapi \
  -e DATABASE_HOST=strapi-postgres \
  -e DATABASE_PORT=5432 \
  -e DATABASE_USERNAME=strapi \
  -e DATABASE_PASSWORD=strapi123 \
  -p 1337:1337 \
  ${docker_image}

docker run -d \
  --name strapi-nginx \
  --network strapi-network \
  -p 80:80 \
  nginx:stable
