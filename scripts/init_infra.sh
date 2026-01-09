#!/bin/bash
set -e

# ==============================================================================
# 🏗️  Private Cloud Bootstrapper
# ==============================================================================
# This script initializes the shared infrastructure required by the public
# repositories. It scaffolds the 'pi-cluster-configs' directory with Nginx 
# and PostgreSQL if they don't exist.
# ==============================================================================

# 1. Network Setup
# ------------------------------------------------------------------------------
echo "🔌 Checking Docker Network..."
if ! docker network ls | grep -q "web_gateway"; then
    echo "   Creating 'web_gateway' network..."
    docker network create web_gateway
else
    echo "   ✅ 'web_gateway' network exists."
fi

# 2. Directory Setup
# ------------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$SCRIPT_DIR/../../pi-cluster-configs"

echo "📂 Target Directory: $TARGET_DIR"

if [ -d "$TARGET_DIR" ]; then
    echo "   ⚠️  Directory exists. Skipping full scaffold to prevent overwrite."
    # We still want to ensure subdirectories exist if the folder is empty/partial
    mkdir -p "$TARGET_DIR/gateway"
    mkdir -p "$TARGET_DIR/core-services/postgres"
else
    echo "   ✨ Creating directory structure..."
    mkdir -p "$TARGET_DIR/gateway/data"
    mkdir -p "$TARGET_DIR/gateway/letsencrypt"
    mkdir -p "$TARGET_DIR/core-services/postgres/data"
fi

# 3. Component: Web Gateway (Nginx Proxy Manager)
# ------------------------------------------------------------------------------
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

# 4. Component: Core Services (PostgreSQL)
# ------------------------------------------------------------------------------
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

networks:
  web_gateway:
    external: true
EOF
fi

# 5. Bootstrap Instructions
# ------------------------------------------------------------------------------
echo ""
echo "✅ Bootstrap Complete!"
echo "========================================================================"
echo "To start your Private Cloud infrastructure:"
echo ""
echo "1. Start the Gateway (Nginx Proxy Manager):"
echo "   cd $TARGET_DIR/gateway"
echo "   docker compose up -d"
echo "   -> Admin UI: http://localhost:81 (Default: admin@example.com / changeme)"
echo ""
echo "2. Start Core Services (Database):"
echo "   cd $TARGET_DIR/core-services"
echo "   docker compose up -d"
echo ""
echo "Your environment is now ready to support the public apps!"
echo "========================================================================"