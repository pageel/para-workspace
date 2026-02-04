#!/bin/bash

# PARA Workspace Update Script
# Safely updates templates without overwriting user data

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
WORKSPACE_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
REPO_URL="https://github.com/pageel/para-workspace.git"

echo "🔄 Checking for updates from $REPO_URL..."

# Check if git is initialized
if [ ! -d "$WORKSPACE_ROOT/.git" ]; then
    echo "⚠️ Not a git repository. Cannot update."
    exit 1
fi

# Fetch upstream
echo "Fetching latest changes..."
git fetch origin main

# Define safe paths to update (templates, cli, docs)
# We avoid updating root files that user might have customized heavily, 
# unless they are strictly structural (like .agent)
SAFE_PATHS=(
    ".agent"
    "Areas/infra/cli"
    "Areas/agent/workflows"
    "Areas/agent/rules"
)

echo "Updating core components..."
git checkout origin/main -- "${SAFE_PATHS[@]}"

echo "✅ Update complete!"
echo "The following components were updated: ${SAFE_PATHS[*]}"
