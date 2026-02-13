#!/bin/bash

# PARA Workspace Update Script (v1.4)
# Safely updates templates without overwriting user data
# Usage: para update

set -e

# === Resolve paths ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "🔄 Updating PARA Workspace Template from GitHub..."

# Get current version
if [ -f "$REPO_ROOT/VERSION" ]; then
    CURRENT_VER=$(cat "$REPO_ROOT/VERSION")
else
    CURRENT_VER="Unknown"
fi

echo "📍 Repo root: $REPO_ROOT"

# Check if it's a git repo
if [ ! -d "$REPO_ROOT/.git" ]; then
    echo "❌ Error: $REPO_ROOT is not a git repository."
    echo ""
    echo "💡 Hint: The para-workspace repo should be at:"
    echo "   $REPO_ROOT"
    echo ""
    echo "If you cloned it elsewhere, make sure the CLI is running from the repo."
    exit 1
fi

echo "📍 Current Version: $CURRENT_VER"

# Pull latest
echo "📥 Pulling latest changes..."
cd "$REPO_ROOT"
git pull origin main

# Get new version
if [ -f "$REPO_ROOT/VERSION" ]; then
    NEW_VER=$(cat "$REPO_ROOT/VERSION")
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
