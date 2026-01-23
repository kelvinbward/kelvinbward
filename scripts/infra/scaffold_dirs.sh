#!/bin/bash
set -e

# Scaffolds the directory structure for pi-cluster-configs
TARGET_DIR=$1

echo "📂 Scaffolding Directory Structure: $TARGET_DIR"

if [ -d "$TARGET_DIR" ]; then
    echo "   ⚠️  Directory exists. Ensuring subdirectories exist..."
    mkdir -p "$TARGET_DIR/gateway"
    mkdir -p "$TARGET_DIR/management"
    mkdir -p "$TARGET_DIR/core-services/postgres"
else
    echo "   ✨ Creating fresh directory structure..."
    mkdir -p "$TARGET_DIR/gateway/data"
    mkdir -p "$TARGET_DIR/gateway/letsencrypt"
    mkdir -p "$TARGET_DIR/management/data"
    mkdir -p "$TARGET_DIR/core-services/postgres/data"
fi

# Load Registry for Dynamic Scaffolding
CONFIG_FILE="$TARGET_DIR/apps.config"
if [ -f "$CONFIG_FILE" ]; then
    echo "   📚 Loading App Registry..."
    source "$CONFIG_FILE"
    
    for APP_ID in "${REGISTERED_APPS[@]}"; do
        # Indirect expansion to get variables
        VAR_ENABLED="APP_${APP_ID}_ENABLED"
        VAR_DIR="APP_${APP_ID}_DIR"
        
        IS_ENABLED="${!VAR_ENABLED}"
        TARGET_SUBDIR="${!VAR_DIR}"

        if [ "$IS_ENABLED" = "true" ] && [ -n "$TARGET_SUBDIR" ]; then
            echo "   📂 Scaffolding $APP_ID..."
            mkdir -p "$TARGET_DIR/$TARGET_SUBDIR"
        fi
    done
else
    echo "   ⚠️  No apps.config found. Creating default app directories..."
    # Fallback for initial run before config exists
    mkdir -p "$TARGET_DIR/apps/middleware"
    mkdir -p "$TARGET_DIR/apps/kelvinbward"
fi
