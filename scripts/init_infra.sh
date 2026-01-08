#!/bin/bash

# Define the root directory name
REPO_NAME="pi-cluster-configs"

echo "🚀 Initializing $REPO_NAME structure..."

# Create the main directory
mkdir -p $REPO_NAME
cd $REPO_NAME

# 1. Create Gateway (Reverse Proxy) structure
mkdir -p gateway/data gateway/letsencrypt

# 2. Create Application structures (e.g., Resume)
mkdir -p apps/resume

# 3. Create placeholder configuration files
touch gateway/docker-compose.yml
touch apps/resume/docker-compose.yml
touch apps/resume/.env

# 4. Create a specialized .gitignore for the private repo
cat <<EOF > .gitignore
# Ignore actual SSL certs and dynamic proxy data
gateway/data/*
gateway/letsencrypt/*

# Ignore local environment secrets
*.env
.DS_Store
EOF

# 5. Create the internal README
cat <<EOF > README.md
# 🔐 Pi Cluster Configs (Private)

This repository contains the production orchestration and secrets for the Raspberry Pi 5.

## 🛠 Setup Instructions
1. Create the external network: 'docker network create web_gateway'
2. Navigate to 'gateway/' and run 'docker-compose up -d'
3. Navigate to 'apps/resume/' and run 'docker-compose up -d'
EOF

echo "✅ Structure created successfully."