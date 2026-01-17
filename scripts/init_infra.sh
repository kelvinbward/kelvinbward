#!/bin/bash
set -e

# ==============================================================================
# 🏗️  Private Cloud Bootstrapper (Orchestrator)
# ==============================================================================
# This script initializes the shared infrastructure required by the public
# repositories by calling modular sub-scripts.
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$SCRIPT_DIR/../../pi-cluster-configs"
INFRA_SCRIPTS_DIR="$SCRIPT_DIR/infra"

echo "🚀 Starting Private Cloud Bootstrap..."
echo "📂 Target Directory: $TARGET_DIR"

# 1. Network Setup
echo "🔌 [Step 1] Checking Docker Network..."
if ! docker network ls | grep -q "web_gateway"; then
    echo "   Creating 'web_gateway' network..."
    docker network create web_gateway
else
    echo "   ✅ 'web_gateway' network exists."
fi

# 2. Scouting & Scaffolding
echo "📁 [Step 2] Scaffolding Directories..."
"$INFRA_SCRIPTS_DIR/scaffold_dirs.sh" "$TARGET_DIR"

# 3. Generating Configurations
echo "📝 [Step 3] Generating Docker Configs..."
"$INFRA_SCRIPTS_DIR/gen_configs.sh" "$TARGET_DIR"

# 4. Generating Automation Scripts
echo "⚙️ [Step 4] Generating Helper Scripts..."
"$INFRA_SCRIPTS_DIR/gen_scripts.sh" "$TARGET_DIR"

# 5. Bootstrap Instructions
echo ""
echo "✅ Bootstrap Complete!"
echo "========================================================================"
echo "To start your Private Cloud infrastructure:"
echo ""
echo "1. Start the Gateway (Nginx Proxy Manager):"
echo "   cd $TARGET_DIR/gateway"
echo "   docker compose up -d"
echo ""
echo "2. Start Core Services (Database):"
echo "   cd $TARGET_DIR/core-services"
echo "   docker compose up -d"
echo ""
echo "3. Start Management Services (Portainer):"
echo "   cd $TARGET_DIR/management"
echo "   docker compose up -d"
echo ""
echo "4. Run the orchestration setup:"
echo "   cd $TARGET_DIR"
echo "   ./setup.sh"
echo ""
echo "Your environment is now ready to support the public apps!"
echo "========================================================================"