#!/bin/bash
set -e

# Default Mode: SAFE
# SAFE = Keeps untracked files (secrets.env, gateway/data, etc.)
# FORCE = Removes EVERYTHING untracked (git clean -fdx)
CLEAN_MODE="SAFE"

# Parse Flags
while getopts "f" opt; do
  case $opt in
    f)
      CLEAN_MODE="FORCE"
      ;;
    *)
      echo "Usage: $0 [-f]"
      echo "  -f: Force clean (removes untracked files including secrets and data)"
      exit 1
      ;;
  esac
done

echo "🧹 Git Cleanup Utility"
echo "----------------------"
echo "Mode: $CLEAN_MODE"
echo "⚠️  WARNING: This script FORCE DELETES (-D) all local branches other than main."
echo "   Ensure you have PUSHED your work to origin before proceeding."
echo "   Stashed changes are saved, but branch context will be lost."
echo ""

# Load Repo List
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/repos.sh"

for REPO in "${REPOS[@]}"; do
  echo "Processing $REPO..."
  if [ -d "$REPO" ]; then
    cd "$REPO"
    
    # Check if this is the Sandbox (pi-cluster-configs)
    REPO_NAME=$(basename "$REPO")
    
    if [ "$REPO_NAME" == "pi-cluster-configs" ]; then
        echo "  🏝️  Sandbox Environment Detected."
        # Fetch latest
        git fetch origin

        # Checkout Main
        CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
        if [ "$CURRENT_BRANCH" != "main" ]; then
            echo "  switched to main..."
            git checkout main
        fi

        # Aggressive Reset to match Origin Main exactly
        echo "  🔄 Resetting to origin/main..."
        git reset --hard origin/main

        # Clean Untracked Files
        if [ "$CLEAN_MODE" == "FORCE" ]; then
            echo "  🔥 [FORCE] Nuking untracked files..."
            git clean -fd
        else
            echo "  🛡️ [SAFE] Cleaning but preserving configuration/data..."
            # Exclude known operational files/dirs from deletion
            git clean -fd \
                -e secrets.env \
                -e config.env \
                -e gateway/data \
                -e gateway/letsencrypt \
                -e core-services/postgres_data \
                -e management/data \
                -e .vscode \
                -e .idea
        fi
        
        # Hard Delete all local branches except main
        echo "  ✂️  Pruning local branches..."
        git branch | grep -v "main" | xargs -r git branch -D

    else
        # Standard Repo Logic
        # Stash changes if any (just in case)
        if [[ -n $(git status -s) ]]; then
            echo "  📦 Stashing local changes..."
            git stash
        fi

        # Checkout main
        CURRENT_BRANCH=$(git symbolic-ref --short HEAD)
        if [ "$CURRENT_BRANCH" != "main" ]; then
            echo "  switched to main..."
            git checkout main
        fi

        # Pull Rebase
        echo "  ⬇️  Pulling origin main..."
        git pull --rebase origin main

        # Delete merged/local branches
        echo "  ✂️  Pruning local branches..."
        git branch | grep -v "main" | xargs -r git branch -D
    fi
    
    echo "  ✅ Done."
    echo "--------------------------------"
  else
    echo "❌ Directory $REPO not found. Skipping."
  fi
done

echo "🎉 Workspace Cleanup Complete!"
