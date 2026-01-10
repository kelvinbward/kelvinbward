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
    # Ensure subdirectories exist
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
echo "   ✅ Core Services Configured."

# 5. Component: Gateway Automation Script
# ------------------------------------------------------------------------------
GATEWAY_SCRIPT="$TARGET_DIR/scripts/configure_gateway.sh"
mkdir -p "$TARGET_DIR/scripts"

if [ -f "$GATEWAY_SCRIPT" ]; then
    echo "   ⚠️  Gateway Automation script exists. Skipping."
else
    echo "   📝 Generating Gateway Automation script..."
    cat <<'EOF' > "$GATEWAY_SCRIPT"
#!/bin/bash
set -e

# Configuration
NPM_HOST="localhost"
NPM_ADMIN_PORT="81"
NPM_URL="http://$NPM_HOST:$NPM_ADMIN_PORT"
DEFAULT_EMAIL="admin@example.com"
DEFAULT_PASSWORD="changeme"

echo "🔧 Configuring Nginx Proxy Manager at $NPM_URL..."

# 1. Wait for API to be ready
echo "   Waiting for NPM API..."
until curl -s "$NPM_URL/api" > /dev/null; do
    sleep 2
done

# 2. Get Authentication Token
echo "   Authenticating..."
TOKEN=$(curl -s -X POST "$NPM_URL/api/tokens" \
  -H "Content-Type: application/json" \
  -d "{\"identity\":\"$DEFAULT_EMAIL\",\"secret\":\"$DEFAULT_PASSWORD\"}" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "   ❌ Authentication failed. Default credentials may have changed."
    echo "      Skipping auto-configuration."
    exit 0
fi

# Function to create a proxy host if it doesn't exist
create_proxy_host() {
    local DOMAIN=$1
    local FORWARD_HOST=$2
    local FORWARD_PORT=$3

    echo "   Checking host: $DOMAIN..."
    
    # Check if host exists
    EXISTING=$(curl -s -X GET "$NPM_URL/api/nginx/proxy-hosts" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" | grep -o "\"$DOMAIN\"" || true)

    if [ -n "$EXISTING" ]; then
        echo "      ✅ Host '$DOMAIN' already exists. Skipping."
    else
        echo "      Creating host '$DOMAIN' -> $FORWARD_HOST:$FORWARD_PORT..."
        curl -s -o /dev/null -X POST "$NPM_URL/api/nginx/proxy-hosts" \
          -H "Authorization: Bearer $TOKEN" \
          -H "Content-Type: application/json" \
          -d "{
            \"domain_names\": [\"$DOMAIN\"],
            \"forward_scheme\": \"http\",
            \"forward_host\": \"$FORWARD_HOST\",
            \"forward_port\": $FORWARD_PORT,
            \"access_list_id\": 0,
            \"certificate_id\": 0,
            \"meta\": {
                \"letsencrypt_agree\": false,
                \"dns_challenge\": false
            },
            \"advanced_config\": \"\",
            \"locations\": [],
            \"block_exploits\": false,
            \"caching_enabled\": false,
            \"allow_websocket_upgrade\": true,
            \"http2_support\": false,
            \"hsts_enabled\": false,
            \"hsts_subdomains\": false
          }"
        echo "      ✅ Created."
    fi
}

# 3. Create Proxy Hosts
create_proxy_host "resume.localhost" "resume-frontend-1" 80
create_proxy_host "cms.localhost" "shared-cms-1" 8055
create_proxy_host "audio.localhost" "creativeaudio-app-1" 5173
create_proxy_host "goobface.localhost" "goobface-app-1" 4321

echo "✨ Gateway configuration complete."
EOF
    chmod +x "$GATEWAY_SCRIPT"
fi

# 6. Component: Seeding Script
# ------------------------------------------------------------------------------
SEED_SCRIPT="$TARGET_DIR/scripts/seed_container.js"
if [ -f "$SEED_SCRIPT" ]; then
    echo "   ⚠️  Seeding script exists. Skipping."
else
    echo "   📝 Generating Seeding script..."
    cat <<'EOF' > "$SEED_SCRIPT"
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASSWORD,
    port: 5432,
});

// In container, resume.json is in current working directory (/app)
const resumePath = path.join(__dirname, 'resume.json');

async function seed() {
    try {
        console.log('Reading resume data from:', resumePath);
        if (!fs.existsSync(resumePath)) {
            console.error('File not found:', resumePath);
            process.exit(1);
        }
        const resumeData = JSON.parse(fs.readFileSync(resumePath, 'utf8'));

        const query = `
            INSERT INTO resume (name, title, email, phone, location, objective, about, experience, skills, certifications, education, links)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
            RETURNING id;
        `;
        
        const values = [
            resumeData.name,
            resumeData.title,
            resumeData.contact.email,
            resumeData.contact.phone,
            resumeData.contact.location,
            resumeData.objective,
            resumeData.about,
            JSON.stringify(resumeData.experience),
            JSON.stringify(resumeData.skills),
            JSON.stringify(resumeData.certifications),
            JSON.stringify(resumeData.education),
            JSON.stringify(resumeData.links)
        ];

        console.log('Inserting data...');
        const res = await pool.query(query, values);
        console.log('✅ Seed successful! Inserted ID:', res.rows[0].id);

    } catch (err) {
        console.error('❌ Error seeding database:', err);
    } finally {
        await pool.end();
    }
}

seed();
EOF
fi

# 7. Component: Orchestration Script (setup.sh)
# ------------------------------------------------------------------------------
SETUP_SCRIPT="$TARGET_DIR/setup.sh"
if [ -f "$SETUP_SCRIPT" ]; then
    echo "   ⚠️  Setup script exists. Skipping."
else
    echo "   📝 Generating setup.sh..."
    cat <<'EOF' > "$SETUP_SCRIPT"
#!/bin/bash
set -e

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for Docker
if ! command_exists docker; then
    echo "Error: Docker is not installed."
    exit 1
fi

# Create web_gateway network if it doesn't exist
if ! docker network ls | grep -q "web_gateway"; then
    echo "Creating web_gateway network..."
    docker network create web_gateway
else
    echo "web_gateway network already exists."
fi

# Get the absolute path of the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Start Gateway
echo "Starting Gateway..."
cd "$SCRIPT_DIR/gateway"
docker compose up -d
cd "$SCRIPT_DIR"

# Wait for Gateway Network
echo "Waiting for web_gateway network..."
until docker network ls | grep -q "web_gateway"; do sleep 1; done

# Start Core Services
echo "Starting Core Services (DB + CMS)..."
cd "$SCRIPT_DIR/core-services"
docker compose up -d
cd "$SCRIPT_DIR"

# Start Resume App
echo "Starting Resume App..."
cd "$SCRIPT_DIR/apps/resume"
if [ ! -f .env ]; then
    echo "Warning: .env file not found. Copying from .env.template..."
    cp .env.template .env
    echo "Please update apps/resume/.env with actual production secrets."
fi
docker compose up -d
cd "$SCRIPT_DIR"

echo "Infrastructure setup complete."
echo "Nginx Proxy Manager should be available at http://<your-pi-ip>:81"

# Configure Gateway
echo "Running Gateway Auto-Configuration..."
if [ -f "$SCRIPT_DIR/scripts/configure_gateway.sh" ]; then
    "$SCRIPT_DIR/scripts/configure_gateway.sh"
else
    echo "Warning: scripts/configure_gateway.sh not found. Skipping auto-config."
fi
EOF
    chmod +x "$SETUP_SCRIPT"
fi

# 8. Bootstrap Instructions
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