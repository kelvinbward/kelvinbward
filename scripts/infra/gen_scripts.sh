#!/bin/bash
set -e

# Generates helper scripts for Gateway automation and DB seeding
TARGET_DIR=$1

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
create_proxy_host "middleware.localhost" "middleware-app-1" 5000

echo "✨ Gateway configuration complete."
EOF
    chmod +x "$GATEWAY_SCRIPT"
fi

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

SETUP_SCRIPT="$TARGET_DIR/setup.sh"
if [ -f "$SETUP_SCRIPT" ]; then
    echo "   ⚠️  Setup script exists. Skipping."
else
    echo "   📝 Generating setup.sh..."
    cat <<'EOF' > "$SETUP_SCRIPT"
#!/bin/bash
set -e

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

if ! command_exists docker; then
    echo "Error: Docker is not installed."
    exit 1
fi

if ! docker network ls | grep -q "web_gateway"; then
    echo "Creating web_gateway network..."
    docker network create web_gateway
else
    echo "web_gateway network already exists."
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

    # --- KelvinBward Hub ---
echo "   Checking 'kelvinbward'..."
if [ ! -d "apps/kelvinbward" ]; then
    echo "   Cloning kelvinbward..."
    git clone https://github.com/kelvinbward/kelvinbward.git apps/kelvinbward
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

# --- Middleware ---
echo "Starting Middleware API..."
MIDDLEWARE_DIR="$SCRIPT_DIR/apps/middleware"

# Ensure repo is present
if [ ! -d "$MIDDLEWARE_DIR/.git" ]; then
    echo "   📦 Cloning Middleware repository..."
    # If directory exists and is empty, clone works. If not empty, it fails.
    # Scaffold ensures it exists.
    if [ -z "$(ls -A $MIDDLEWARE_DIR 2>/dev/null)" ]; then
        git clone https://github.com/kelvinbward/middleware.git "$MIDDLEWARE_DIR"
    else
        echo "   ⚠️  Directory not empty but no .git found. Skipping clone."
    fi
else
    echo "   🔄 Updating Middleware repository..."
    cd "$MIDDLEWARE_DIR" && git pull && cd "$SCRIPT_DIR"
fi

cd "$MIDDLEWARE_DIR"
if [ ! -f .env ]; then
    echo "Warning: .env file not found. Copying from .env.template..."
    cp .env.template .env
fi
docker compose up -d
cd "$SCRIPT_DIR"

echo "Infrastructure setup complete."
echo "Nginx Proxy Manager should be available at http://<your-pi-ip>:81"

echo "Running Gateway Auto-Configuration..."
if [ -f "$SCRIPT_DIR/scripts/configure_gateway.sh" ]; then
    "$SCRIPT_DIR/scripts/configure_gateway.sh"
else
    echo "Warning: scripts/configure_gateway.sh not found. Skipping auto-config."
fi
EOF
    chmod +x "$SETUP_SCRIPT"
fi
