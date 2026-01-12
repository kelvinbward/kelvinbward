#!/bin/bash
set -e

# Scaffolds the directory structure for pi-cluster-configs
TARGET_DIR=$1

echo "📂 Scaffolding Directory Structure: $TARGET_DIR"

if [ -d "$TARGET_DIR" ]; then
    echo "   ⚠️  Directory exists. Ensuring subdirectories exist..."
    mkdir -p "$TARGET_DIR/gateway"
    mkdir -p "$TARGET_DIR/apps/middleware"
    mkdir -p "$TARGET_DIR/core-services/postgres"
else
    echo "   ✨ Creating fresh directory structure..."
    mkdir -p "$TARGET_DIR/gateway/data"
    mkdir -p "$TARGET_DIR/gateway/letsencrypt"
    mkdir -p "$TARGET_DIR/core-services/postgres/data"
fi
