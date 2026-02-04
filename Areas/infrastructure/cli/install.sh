#!/bin/bash

# PARA Workspace Installer
# Sets up aliases and permissions

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
 # Path: Areas/infrastructure/cli -> Root is 3 levels up
WORKSPACE_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"

echo "🚀 Installing PARA Workspace CLI..."

# Ensure all scripts are executable
chmod +x "$SCRIPT_DIR/scaffold.sh"
chmod +x "$SCRIPT_DIR/update.sh"

echo "✅ Scripts made executable."

# Usage instructions
echo ""
echo "🎉 Installation complete!"
echo "To create a new project, run:"
echo "  ./Areas/infrastructure/cli/scaffold.sh <project-name>"
echo ""
echo "To update workspace template:"
echo "  ./Areas/infrastructure/cli/update.sh"
