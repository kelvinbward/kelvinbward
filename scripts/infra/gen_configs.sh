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


# Load Registry for Dynamic Env Templates
CONFIG_FILE="$TARGET_DIR/apps.config"
if [ -f "$CONFIG_FILE" ]; then
    echo "   📚 Loading App Registry for Config Generation..."
    source "$CONFIG_FILE"
    
    for APP_ID in "${REGISTERED_APPS[@]}"; do
        VAR_ENABLED="APP_${APP_ID}_ENABLED"
        VAR_DIR="APP_${APP_ID}_DIR"
        
        IS_ENABLED="${!VAR_ENABLED}"
        TARGET_SUBDIR="${!VAR_DIR}"
        FULL_PATH="$TARGET_DIR/$TARGET_SUBDIR"

        if [ "$IS_ENABLED" = "true" ] && [ -d "$FULL_PATH" ]; then
             echo "   ⚙️  Checking configs for $APP_ID..."
             # Here we could generate specific .env templates if we knew the schema.
             # For now, we ensure a base template exists if missing, or specific logic per app.
             
             TEMPLATE_FILE="$FULL_PATH/.env.template"
             if [ ! -f "$TEMPLATE_FILE" ]; then
                 echo "      📝 Generating default .env.template for $APP_ID..."
                 # Generic fallback or specific logic based on APP_ID
                 if [ "$APP_ID" == "MIDDLEWARE" ]; then
                     echo "PORT=5000" > "$TEMPLATE_FILE"
                     echo "DATABASE_URL=postgres://\${POSTGRES_USER}:\${POSTGRES_PASSWORD}@db:5432/middleware_db" >> "$TEMPLATE_FILE"
                 elif [ "$APP_ID" == "KELVINBWARD" ]; then
                      echo "NODE_ENV=production" > "$TEMPLATE_FILE"
                 else
                     echo "# Auto-generated template" > "$TEMPLATE_FILE"
                 fi
             fi
        fi
    done
fi
