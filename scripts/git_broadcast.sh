#!/bin/bash
set -e
echo "⚠️  NOTICE: This script is deprecated. Use 'kelvin-cli git' instead."
echo ""

# Generic Git Broadcast Utility
# Runs the specified command in every registered repository

if [ -z "$1" ]; then
  echo "Usage: $0 \"<command>\""
  echo "Example: $0 \"git status -s\""
  exit 1
fi

CMD="$1"

# Load Repo List
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/repos.sh"

echo "📢 Broadcasting command: '$CMD'"
echo "--------------------------------"

for REPO in "${REPOS[@]}"; do
  echo "📂 $REPO"
  if [ -d "$REPO" ]; then
    (
      cd "$REPO"
      eval "$CMD"
    ) || echo "❌ Command failed in $REPO"
  else
    echo "⚠️  Directory not found"
  fi
  echo "--------------------------------"
done

echo "✅ Broadcast Complete."
