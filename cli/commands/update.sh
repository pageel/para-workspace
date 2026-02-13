#!/bin/bash

# PARA Workspace Update Script
# Safely updates templates without overwriting user data

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
# This script is in cli/commands/ - Repo root is 3 levels up
REPO_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"

echo "🔄 Updating PARA Workspace Template from GitHub..."

# Get current version
if [ -f "VERSION" ]; then
    CURRENT_VER=$(cat VERSION)
else
    CURRENT_VER="Unknown"
fi

cd "$REPO_ROOT"

# Check if it's a git repo
if [ ! -d ".git" ]; then
    echo "❌ Error: $REPO_ROOT is not a git repository."
    exit 1
fi

echo "📍 Current Version: $CURRENT_VER"

# Pull latest
echo "📥 Pulling latest changes..."
git pull origin main

# Get new version
if [ -f "VERSION" ]; then
    NEW_VER=$(cat VERSION)
else
    NEW_VER="Unknown"
fi

if [ "$CURRENT_VER" == "$NEW_VER" ] && [ "$CURRENT_VER" != "Unknown" ]; then
    echo "✅ Already on latest version ($CURRENT_VER)."
else
    echo "⏫ Upgraded: $CURRENT_VER -> $NEW_VER"
fi

# Re-run installation to sync rules, workflows and CLI wrapper
echo "⚙️ Re-installing to sync workspace root..."
bash "$SCRIPT_DIR/install.sh"

echo "✨ Update complete!"
