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
    if [ -z "$NAME" ]; then
      echo "❌ Error: Workflow name required."
      exit 1
    fi
    SOURCE="$CATALOG_DIR/$NAME.md"
    DEST="$AGENT_DIR/$NAME.md"
    
    if [ ! -f "$SOURCE" ]; then
      echo "❌ Error: Workflow '$NAME' not found in catalog."
      exit 1
    fi
    
    mkdir -p "$AGENT_DIR"
    cp "$SOURCE" "$DEST"
    echo "✅ Workflow '$NAME' installed to .agent/workflows/"
    ;;
  *)
    echo "Usage: $0 [list | install <name>]"
    exit 1
    ;;
esac
