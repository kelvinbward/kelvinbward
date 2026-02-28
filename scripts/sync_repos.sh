#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/.venv_sync"

# Setup python venv if it doesn't exist
if [ ! -d "$VENV_DIR" ]; then
    echo "📦 Creating Python virtual environment for sync_repos..."
    python3 -m venv "$VENV_DIR"
fi

# Execute the python script inside the venv
"$VENV_DIR/bin/python" "$SCRIPT_DIR/sync_repos.py"
