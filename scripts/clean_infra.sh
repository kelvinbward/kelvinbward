#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$SCRIPT_DIR/../../pi-cluster-configs"

echo "🧹 Infrastructure Cleanup Utility"
echo "⚠️  WARNING: This will stop and remove the local cluster services provisioned by init_infra.sh."
echo "   It will not delete configuration files."
echo "   Are you sure you want to proceed? (y/N)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "🛑 Stopping services in pi-cluster-configs..."
    
    if [ -d "$TARGET_DIR/gateway" ]; then
        echo "   Stopping Gateway..."
        (cd "$TARGET_DIR/gateway" && docker compose down) || true
    fi
    
    if [ -d "$TARGET_DIR/core-services" ]; then
        echo "   Stopping Core Services..."
        (cd "$TARGET_DIR/core-services" && docker compose down) || true
    fi
    
    if [ -d "$TARGET_DIR/management" ]; then
        echo "   Stopping Management..."
        (cd "$TARGET_DIR/management" && docker compose down) || true
    fi
    
    echo "🕸️  Removing web_gateway network..."
    docker network rm web_gateway 2>/dev/null || true
    
    echo "✅ Infrastructure cleanup complete."
else
    echo "🛑 Aborted."
fi
