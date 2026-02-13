#!/bin/bash

# PARA Workflow Manager
# Usage: ./cli/commands/workflow.sh [list | install <name>]

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
# Use exported WORKSPACE_ROOT if available, otherwise guess from script location
if [ -z "$WORKSPACE_ROOT" ]; then
    WORKSPACE_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
fi
CATALOG_DIR="$WORKSPACE_ROOT/.agent/workflows"
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
    if [ -f "$DEST" ]; then
      
      echo "❌ Error: Workflow '$FINAL_NAME.md' already exists."
      echo "💡 To update/merge/overwrite, please use the Agentic Workflow:"
      echo ""
      echo "   @[/install] type=work name=$NAME"
      echo ""
      exit 1
    else
      mkdir -p "$AGENT_DIR"
      cp "$SOURCE" "$DEST"
      echo "✅ Workflow '$NAME' installed as '$FINAL_NAME.md'"
    fi
    ;;
  *)
    echo "Usage: $0 [list | install <name>]"
    exit 1
    ;;
esac
