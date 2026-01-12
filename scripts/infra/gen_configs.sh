#!/bin/bash
set -e

# Generates Docker Compose configurations for Gateway and Core Services
TARGET_DIR=$1

GATEWAY_COMPOSE="$TARGET_DIR/gateway/docker-compose.yml"
if [ -f "$GATEWAY_COMPOSE" ]; then
    echo "   ⚠️  Gateway config exists. Skipping."
else
    echo "   📝 Generating Gateway docker-compose.yml..."
    cat <<EOF > "$GATEWAY_COMPOSE"
version: '3.8'
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80'
      - '81:81'
      - '443:443'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
    networks:
      - web_gateway

networks:
  web_gateway:
    external: true
EOF
fi

CORE_COMPOSE="$TARGET_DIR/core-services/docker-compose.yml"
if [ -f "$CORE_COMPOSE" ]; then
    echo "   ⚠️  Core Services config exists. Skipping."
else
    echo "   📝 Generating Core Services docker-compose.yml..."
    cat <<EOF > "$CORE_COMPOSE"
version: '3.8'
services:
  db:
    image: postgres:15-alpine
    restart: unless-stopped
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
      POSTGRES_DB: resume_db
    volumes:
      - ./postgres/data:/var/lib/postgresql/data
    networks:
      - web_gateway

  cms:
    image: directus/directus:latest
    restart: unless-stopped
    environment:
      KEY: 'secret-key-replace-me'
      SECRET: 'secret-key-replace-me'
      ADMIN_EMAIL: 'admin@example.com'
      ADMIN_PASSWORD: 'password'
      DB_CLIENT: 'pg'
      DB_HOST: 'db'
      DB_PORT: '5432'
      DB_DATABASE: 'resume_db'
      DB_USER: 'postgres'
      DB_PASSWORD: 'password'
      PUBLIC_URL: 'http://cms.localhost'
    depends_on:
      - db
    networks:
      - web_gateway

networks:
  web_gateway:
    external: true
EOF
fi
