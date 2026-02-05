#!/bin/bash

# PARA Workspace Update Script
# Safely updates templates without overwriting user data

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
# This script is in Areas/infra/cli/ - Repo root is 3 levels up
REPO_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"

echo "🔄 Updating PARA Workspace Template from GitHub..."

cd "$REPO_ROOT"

# Check if it's a git repo
if [ ! -d ".git" ]; then
    echo "❌ Error: $REPO_ROOT is not a git repository."
    exit 1
fi

# Pull latest
echo "📥 Pulling latest changes..."
git pull origin main

# Re-run installation to sync rules, workflows and CLI wrapper
echo "⚙️ Re-installing to sync workspace root..."
bash "$SCRIPT_DIR/install.sh"

echo "✨ Update complete!"
