#!/bin/bash
set -e

command_exists() {
    command -v "$1" >/dev/null 2>&1
}
# Check if docker is installed
if ! command_exists docker; then
    echo "Error: Docker is not installed OR is not running."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 0. Load Configuration
CONFIG_FILE="$SCRIPT_DIR/apps.config"
if [ -f "$CONFIG_FILE" ]; then
    echo "📜 Loading configuration from apps.config..."
    source "$CONFIG_FILE"
else
    echo "⚠️  apps.config not found. Using defaults (All Apps Enabled)."
    ENABLE_KELVINBWARD=true
    ENABLE_MIDDLEWARE=true
fi

# 🔐 Load/Generate Secrets
echo "🔐 Loading Secrets..."
if [ -f "$SCRIPT_DIR/scripts/generate_secrets.sh" ]; then
    "$SCRIPT_DIR/scripts/generate_secrets.sh"
    # Enable auto-export of variables in secrets.env
    set -a
    source "$SCRIPT_DIR/secrets.env"
    # Disable auto-export of variables in secrets.env
    set +a
else
    echo "❌ Error: scripts/generate_secrets.sh not found."
    exit 1
fi

# Check if web_gateway network exists
if ! docker network ls | grep -q "web_gateway"; then
    echo "Creating web_gateway network..."
    docker network create web_gateway
else
    echo "web_gateway network already exists."
fi

echo "Starting Gateway..."
cd "$SCRIPT_DIR/gateway"
docker compose up -d
cd "$SCRIPT_DIR"

echo "Waiting for web_gateway network..."
until docker network ls | grep -q "web_gateway"; do sleep 1; done

echo "Starting Core Services (DB + CMS)..."
cd "$SCRIPT_DIR/core-services"
docker compose up -d
cd "$SCRIPT_DIR"

echo "Starting Management Services (Portainer)..."
cd "$SCRIPT_DIR/management"
docker compose up -d
cd "$SCRIPT_DIR"

# --- Application Loop ---
if [ -n "${REGISTERED_APPS[*]}" ]; then
    echo "🔄 Processing Registered Apps..."
    for APP_ID in "${REGISTERED_APPS[@]}"; do
        VAR_ENABLED="APP_${APP_ID}_ENABLED"
        VAR_REPO="APP_${APP_ID}_REPO"
        VAR_DIR="APP_${APP_ID}_DIR"
        
        IS_ENABLED="${!VAR_ENABLED}"
        REPO_URL="${!VAR_REPO}"
        TARGET_SUBDIR="${!VAR_DIR}"
        
        APP_NAME_LOWER=$(echo "$APP_ID" | tr '[:upper:]' '[:lower:]')
        FULL_PATH="$SCRIPT_DIR/$TARGET_SUBDIR"

        if [ "$IS_ENABLED" = "true" ]; then
            echo "👉 Processing $APP_ID..."
            
            # 1. Clone / Recover / Pull
            if [ ! -d "$FULL_PATH/.git" ]; then
                if [ ! -d "$FULL_PATH" ]; then
                     echo "   📦 Cloning $APP_ID..."
                     mkdir -p "$(dirname "$FULL_PATH")"
                     git clone "$REPO_URL" "$FULL_PATH"
                else
                     echo "   ⚠️  $APP_ID dir exists but no .git found. Recovering..."
                     cd "$FULL_PATH"
                     git init
                     git remote add origin "$REPO_URL"
                     git fetch
                     if git checkout main -f; then
                         echo "   ✅ Recovered repo."
                     else
                         echo "   ❌ Recovery failed for $APP_ID."
                         exit 1
                     fi
                     cd "$SCRIPT_DIR"
                fi
            else
                echo "   🔄 Updating $APP_ID..."
                cd "$FULL_PATH" && git pull && cd "$SCRIPT_DIR"
            fi
            
            # 2. Configure Environment
            cd "$FULL_PATH"
            if [ ! -f .env ]; then
                if [ -f .env.template ]; then
                    echo "   📝 Creating .env from template..."
                    cp .env.template .env
                else
                    echo "   ⚠️  .env.template not found. Creating empty .env..."
                    touch .env
                fi
            fi
            
            # 3. Start Service
            # Only start if mode is "cluster" (to be safe/explicit), or just default behavior
            # Assuming docker-compose.yml exists
            if [ -f "docker-compose.yml" ]; then
                 echo "   🚀 Starting $APP_ID..."
                 docker compose up -d
            else
                 echo "   ⚠️  No docker-compose.yml found for $APP_ID. Skipping start."
            fi
            cd "$SCRIPT_DIR"
        else
            echo "   ⏭️  Skipping $APP_ID (Disabled)"
        fi
    done
else
    echo "⚠️  No applications registered in apps.config"
fi

echo "Infrastructure setup complete."
echo "Nginx Proxy Manager should be available at http://<your-pi-ip>:81"

echo "Running Gateway Auto-Configuration..."
# Check if configure_gateway.sh exists
if [ -f "$SCRIPT_DIR/scripts/configure_gateway.sh" ]; then
    "$SCRIPT_DIR/scripts/configure_gateway.sh"
else
    echo "Warning: scripts/configure_gateway.sh not found. Skipping auto-config."
fi
