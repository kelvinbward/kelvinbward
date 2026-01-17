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
    container_name: resume-db-1
    restart: unless-stopped
    environment:
      - POSTGRES_USER=\${POSTGRES_USER}
      - POSTGRES_PASSWORD=\${POSTGRES_PASSWORD}
      - POSTGRES_DB=resume_db
    expose:
      - "5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - web_gateway

  cms:
    image: directus/directus:latest
    container_name: shared-cms-1
    restart: unless-stopped
    environment:
      KEY: '\${CMS_KEY}'
      SECRET: '\${CMS_SECRET}'
      ADMIN_EMAIL: '\${CMS_ADMIN_EMAIL}'
      ADMIN_PASSWORD: '\${CMS_ADMIN_PASSWORD}'
      DB_CLIENT: 'pg'
      DB_HOST: 'db'
      DB_PORT: '5432'
      DB_DATABASE: 'resume_db'
      DB_USER: '\${POSTGRES_USER}'
      DB_PASSWORD: '\${POSTGRES_PASSWORD}'
      PUBLIC_URL: 'http://cms.localhost'
    depends_on:
      - db
    networks:
      - web_gateway

volumes:
  postgres_data:


networks:
  web_gateway:
    external: true
EOF
fi

MGMT_COMPOSE="$TARGET_DIR/management/docker-compose.yml"
if [ -f "$MGMT_COMPOSE" ]; then
    echo "   ⚠️  Management config exists. Skipping."
else
    echo "   📝 Generating Management docker-compose.yml..."
    cat <<EOF > "$MGMT_COMPOSE"
version: '3.8'

services:
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer_management
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./data:/data
    ports:
      - 9000:9000
    networks:
      - web_gateway

networks:
  web_gateway:
    external: true
EOF
fi
