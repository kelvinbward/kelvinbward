#!/bin/bash
set -e

# Generates helper scripts for Gateway automation and DB seeding
TARGET_DIR=$1

# --- 1. Secret Generation Script ---
SECRETS_SCRIPT="$TARGET_DIR/scripts/generate_secrets.sh"
mkdir -p "$TARGET_DIR/scripts"

if [ -f "$SECRETS_SCRIPT" ]; then
    echo "   ⚠️  Secret Generator script exists. Skipping."
else
    echo "   📝 Generating Secret Generator script..."
    cat <<'EOF' > "$SECRETS_SCRIPT"
#!/bin/bash
set -e

# Define the secrets file and config override file
SECRETS_FILE="$(dirname "$0")/../secrets.env"
CONFIG_FILE="$(dirname "$0")/../config.env"

# Function to generate a random 32-character alphanumeric string
generate_secret() {
    < /dev/urandom tr -dc 'A-Za-z0-9' | head -c 32
}

# Load manual config overrides if present
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

echo "🔐 Checking secrets..."

# Read existing secrets if valid (simple grep check)
if [ -f "$SECRETS_FILE" ]; then
    source "$SECRETS_FILE"
fi

# Helper to check and set secret
ensure_secret() {
    local VAR_NAME=$1
    local CURRENT_VAL=${!VAR_NAME}
    local TYPE=$2 # "string" or "email" or "user"
    
    if [ -z "$CURRENT_VAL" ]; then
        local NEW_SECRET=""
        if [ "$TYPE" == "email" ]; then
            # Generate random email: admin_<random>@local.host
            local RAND=$(< /dev/urandom tr -dc 'a-z0-9' | head -c 8)
            NEW_SECRET="admin_${RAND}@internal.local"
        elif [ "$TYPE" == "user" ]; then
             # Generate random user: user_<random>
            local RAND=$(< /dev/urandom tr -dc 'a-z0-9' | head -c 8)
            NEW_SECRET="user_${RAND}"
        else
            # Default 32-char string
            NEW_SECRET=$(< /dev/urandom tr -dc 'A-Za-z0-9' | head -c 32)
        fi
        
        echo "$VAR_NAME=$NEW_SECRET" >> "$SECRETS_FILE"
        echo "   + Generated $VAR_NAME"
        export "$VAR_NAME"="$NEW_SECRET"
    else
        echo "   . $VAR_NAME exists"
    fi
}

# Ensure secrets.env exists
touch "$SECRETS_FILE"

# List of required secrets
ensure_secret "POSTGRES_USER" "user"
ensure_secret "POSTGRES_PASSWORD" "string"

ensure_secret "NPM_ADMIN_EMAIL" "email"
ensure_secret "NPM_ADMIN_PASSWORD" "string"

# Secure the file
chmod 600 "$SECRETS_FILE"
echo "✅ Secrets ready at $SECRETS_FILE"
EOF
    chmod +x "$SECRETS_SCRIPT"
fi

# --- 1.5 Config Template ---
CONFIG_TEMPLATE="$TARGET_DIR/config.env.template"
if [ -f "$CONFIG_TEMPLATE" ]; then
    echo "   ⚠️  Config Template exists. Skipping."
else
    echo "   📝 Generating Config Template..."
    cat <<'EOF' > "$CONFIG_TEMPLATE"
# Configuration Overrides
# Copy this file to config.env to override specific secrets or settings.
# Note: Variables defined here will take precedence over generated secrets.

# --- Database ---
# POSTGRES_USER=admin_custom
# POSTGRES_PASSWORD=my_secure_password


# --- Nginx Proxy Manager ---
# NPM_ADMIN_EMAIL=admin@custom.domain
# NPM_ADMIN_PASSWORD=secure_password
EOF
fi

# --- 1.6 Apps Config Template ---
APPS_CONFIG_TEMPLATE="$TARGET_DIR/apps.config"
TEMPLATE_SOURCE="$(dirname "$0")/templates/apps.config.template"

if [ -f "$APPS_CONFIG_TEMPLATE" ]; then
    echo "   ⚠️  Apps Config exists. Skipping."
else
    echo "   📝 Copying Apps Config Template..."
    if [ -f "$TEMPLATE_SOURCE" ]; then
        cp "$TEMPLATE_SOURCE" "$APPS_CONFIG_TEMPLATE"
        echo "      ✅ Copied apps.config"
    else
        echo "      ❌ Error: Template not found at $TEMPLATE_SOURCE"
    fi
fi

# --- 2. Gateway Automation Script ---
GATEWAY_SCRIPT="$TARGET_DIR/scripts/configure_gateway.sh"

if [ -f "$GATEWAY_SCRIPT" ]; then
    echo "   ⚠️  Gateway Automation script exists. Skipping."
else
    echo "   📝 Generating Gateway Automation script..."
    cat <<'EOF' > "$GATEWAY_SCRIPT"
#!/bin/bash
set -e

# Load Secrets
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_FILE="$SCRIPT_DIR/../secrets.env"
if [ -f "$SECRETS_FILE" ]; then
    source "$SECRETS_FILE"
else
    echo "❌ Error: secrets.env not found. Run ./setup.sh first."
    exit 1
fi

# Configuration
NPM_HOST="localhost"
NPM_ADMIN_PORT="81"
NPM_URL="http://$NPM_HOST:$NPM_ADMIN_PORT"
DEFAULT_EMAIL="admin@example.com"
DEFAULT_PASSWORD="changeme"
SECURE_EMAIL="${NPM_ADMIN_EMAIL}"
SECURE_PASSWORD="${NPM_ADMIN_PASSWORD}"

if [ -z "$SECURE_PASSWORD" ] || [ -z "$SECURE_EMAIL" ]; then
    echo "❌ Error: NPM_ADMIN_PASSWORD or NPM_ADMIN_EMAIL is empty in secrets.env"
    exit 1
fi

echo "🔧 Configuring Nginx Proxy Manager at $NPM_URL..."

# 1. Wait for API to be ready
echo "   Waiting for NPM API..."
until curl -s "$NPM_URL/api" > /dev/null; do
    sleep 2
done

# 2. Authenticate (Try Default First, then Secure)
echo "   Authenticating..."
OBTAINED_TOKEN=""

# Try with default
TOKEN_DEFAULT=$(curl -s -X POST "$NPM_URL/api/tokens" \
  -H "Content-Type: application/json" \
  -d "{\"identity\":\"$DEFAULT_EMAIL\",\"secret\":\"$DEFAULT_PASSWORD\"}" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -n "$TOKEN_DEFAULT" ]; then
    echo "   ⚠️  Logged in with DEFAULT credentials. Hardening..."
    
    # Change Password and Email
    # Note: We must change password first or together.
    
    echo "      Updating Admin User (Email & Password)..."
    curl -s -X PUT "$NPM_URL/api/users/1" \
      -H "Authorization: Bearer $TOKEN_DEFAULT" \
      -H "Content-Type: application/json" \
      -d "{
        \"name\": \"Administrator\",
        \"email\": \"$SECURE_EMAIL\",
        \"roles\": [\"admin\"],
        \"permissions\": {},
        \"groups\": []
      }" > /dev/null
    
    # Change Password
    curl -s -X PUT "$NPM_URL/api/users/1/password" \
      -H "Authorization: Bearer $TOKEN_DEFAULT" \
      -H "Content-Type: application/json" \
      -d "{\"current\":\"$DEFAULT_PASSWORD\",\"new\":\"$SECURE_PASSWORD\"}" > /dev/null
      
    echo "   ✅ Admin hardened: $SECURE_EMAIL"
    OBTAINED_TOKEN=$TOKEN_DEFAULT
else
    # Try with Secure
    TOKEN_SECURE=$(curl -s -X POST "$NPM_URL/api/tokens" \
      -H "Content-Type: application/json" \
      -d "{\"identity\":\"$SECURE_EMAIL\",\"secret\":\"$SECURE_PASSWORD\"}" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
      
    if [ -n "$TOKEN_SECURE" ]; then
        echo "   ✅ Logged in with SECURE credentials."
        OBTAINED_TOKEN=$TOKEN_SECURE
    else
        echo "   ❌ Authentication failed with both Default and Secure credentials."
        exit 1
    fi
fi

TOKEN=$OBTAINED_TOKEN

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

# 3. Create Proxy Hosts (Dynamic based on Registry)

# Load configuration if not already present (it should be)
APPS_CONFIG_FILE="$SCRIPT_DIR/../apps.config"
if [ -f "$APPS_CONFIG_FILE" ]; then
    source "$APPS_CONFIG_FILE"
fi

# Resume App
if [ "$APP_RESUME_ENABLED" = "true" ]; then
    create_proxy_host "resume.localhost" "resume-frontend-1" 80
fi

# CreativeAudioJS
if [ "$APP_CREATIVEAUDIOJS_ENABLED" = "true" ]; then
    create_proxy_host "audio.localhost" "creativeaudio-app-1" 5173
fi

# Goobface
if [ "$APP_GOOBFACE_ENABLED" = "true" ]; then
    create_proxy_host "goobface.localhost" "goobface-app-1" 4321
fi

# Middleware
if [ "$APP_MIDDLEWARE_ENABLED" = "true" ]; then
    create_proxy_host "middleware.localhost" "middleware-app-1" 5000
fi

# KelvinBward (Adding explicit support if needed, assuming port 3000)
if [ "$APP_KELVINBWARD_ENABLED" = "true" ]; then
    create_proxy_host "kelvinbward.localhost" "kelvinbward-app-1" 3000
fi

# Management (Always Enabled)
create_proxy_host "portainer.localhost" "portainer_management" 9000

echo "✨ Gateway configuration complete."
EOF
    chmod +x "$GATEWAY_SCRIPT"
fi

# --- 3. Seed Script (Unchanged) ---
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
    password: process.env.POSTGRES_PASSWORD,
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

# --- 4. Setup Script ---
# --- 4. Setup Script ---
SETUP_SCRIPT="$TARGET_DIR/setup.sh"
SETUP_TEMPLATE_SOURCE="$(dirname "$0")/templates/setup.sh"

if [ -f "$SETUP_SCRIPT" ]; then
    echo "   ⚠️  Setup script exists. Skipping."
else
    echo "   📝 Installing setup.sh..."
    if [ -f "$SETUP_TEMPLATE_SOURCE" ]; then
        cp "$SETUP_TEMPLATE_SOURCE" "$SETUP_SCRIPT"
        chmod +x "$SETUP_SCRIPT"
        echo "      ✅ Installed setup.sh"
    else
         echo "      ❌ Error: Setup template not found at $SETUP_TEMPLATE_SOURCE"
         # Fallback or exit?
         exit 1
    fi
fi
