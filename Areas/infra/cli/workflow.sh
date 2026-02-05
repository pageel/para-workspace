#!/bin/bash

# PARA Workflow Manager
# Usage: ./Areas/infra/cli/workflow.sh [list | install <name>]

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
WORKSPACE_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
CATALOG_DIR="$WORKSPACE_ROOT/Resources/ai-agents/workflows"
AGENT_DIR="$WORKSPACE_ROOT/.agent/workflows"

case "$1" in
  list)
    echo "📋 Available Workflows in Catalog:"
    ls -1 "$CATALOG_DIR" | grep ".md" | sed 's/\.md//'
    ;;
  install)
    NAME=$2
    ALIAS=$4 # Usage: install <name> as <alias>
    
    if [ -z "$NAME" ]; then
      echo "❌ Error: Workflow name required."
      exit 1
    fi
    
    FINAL_NAME=${ALIAS:-$NAME}
    SOURCE="$CATALOG_DIR/$NAME.md"
    DEST="$AGENT_DIR/$FINAL_NAME.md"
    
    if [ ! -f "$SOURCE" ]; then
      echo "❌ Error: Workflow '$NAME' not found in catalog."
      exit 1
    fi
    
    if [ -f "$DEST" ]; then
      echo "⚠️ Warning: Workflow '$FINAL_NAME' already exists in .agent/workflows/."
      read -p "Do you want to overwrite it? (y/N) " -n 1 -r
      echo ""
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
          echo "🚫 Installation cancelled."
          exit 0
      fi
    fi
    
    mkdir -p "$AGENT_DIR"
    cp "$SOURCE" "$DEST"
    echo "✅ Workflow '$NAME' installed to .agent/workflows/ as '$FINAL_NAME.md'"
    ;;
  *)
    echo "Usage: $0 [list | install <name>]"
    exit 1
    ;;
esac
