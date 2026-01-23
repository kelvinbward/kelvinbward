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

# --- Kelvinbward Hub ---
if [ "$ENABLE_KELVINBWARD" = "true" ]; then
    echo "   Checking 'kelvinbward'..."
    if [ ! -d "apps/kelvinbward/.git" ]; then
        if [ ! -d "apps/kelvinbward" ]; then
             echo "   Cloning kelvinbward..."
             git clone https://github.com/kelvinbward/kelvinbward.git apps/kelvinbward
        else
             echo "   ⚠️  kelvinbward exists but no .git found. Recovering..."
             cd apps/kelvinbward
             git init
             git remote add origin https://github.com/kelvinbward/kelvinbward.git
             git fetch
             if git checkout main -f; then
                 echo "   ✅ Recovered repo."
             else
                 echo "   ❌ Recovery failed."
                 exit 1
             fi
             cd ../..
        fi
    else
        echo "   Pulling latest kelvinbward..."
        cd apps/kelvinbward && git pull && cd ../..
    fi
     
    echo "   Starting kelvinbward..."
    cd apps/kelvinbward
    if [ ! -f .env ]; then
        if [ -f .env.template ]; then
           cp .env.template .env
        else
           touch .env
        fi
    fi
    docker compose up -d
    cd ../..
else
    echo "   ⏭️  Skipping KelvinBward Hub (Disabled in apps.config)"
fi

# --- Middleware ---
if [ "$ENABLE_MIDDLEWARE" = "true" ]; then
    echo "Starting Middleware API..."
    MIDDLEWARE_DIR="$SCRIPT_DIR/apps/middleware"

    # Ensure repo is present
    if [ ! -d "$MIDDLEWARE_DIR/.git" ]; then
        echo "   📦 Cloning Middleware repository..."
        if [ -z "$(ls -A $MIDDLEWARE_DIR 2>/dev/null)" ]; then
            git clone https://github.com/kelvinbward/middleware.git "$MIDDLEWARE_DIR"
        else
            echo "   ⚠️  Directory not empty but no .git found. Attempting to recover..."
            cd "$MIDDLEWARE_DIR"
            git init
            git remote add origin https://github.com/kelvinbward/middleware.git
            git fetch
            # Checkout main, discarding local changes to tracked files, but keeping untracked (like data/)
            if git checkout main -f; then
                 echo "   ✅ Recovered repo."
            else
                 echo "   ❌ Recovery failed. Please delete '$MIDDLEWARE_DIR' and re-run."
                 exit 1
            fi
            cd "$SCRIPT_DIR"
        fi
    else
        echo "   🔄 Updating Middleware repository..."
        cd "$MIDDLEWARE_DIR" && git pull && cd "$SCRIPT_DIR"
    fi
    # Create .env from .env.template if not exists
    cd "$MIDDLEWARE_DIR"
    if [ ! -f .env ]; then
        if [ -f .env.template ]; then
            echo "   📝 Creating .env from template..."
            cp .env.template .env
        else
            echo "   ⚠️  .env.template not found. Creating empty .env..."
            touch .env
        fi
    fi
    docker compose up -d
    cd "$SCRIPT_DIR"
else
    echo "   ⏭️  Skipping Middleware API (Disabled in apps.config)"
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
