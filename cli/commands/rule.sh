#!/bin/bash

# PARA Rule Manager
# Usage: ./cli/commands/rule.sh [list | install <name>]

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
# Use exported WORKSPACE_ROOT if available, otherwise guess from script location
if [ -z "$WORKSPACE_ROOT" ]; then
    WORKSPACE_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
fi
CATALOG_DIR="$WORKSPACE_ROOT/.agents/rules"
AGENT_DIR="$WORKSPACE_ROOT/.agents/rules"

case "$1" in
  list)
    echo "📜 Available Rules in Catalog:"
    if [ -d "$CATALOG_DIR" ]; then
        ls -1 "$CATALOG_DIR" | grep ".md" | sed 's/\.md//'
    else
        echo "  (Catalog directory not found)"
    fi
    ;;
  install)
    NAME=$2
    
    if [ -z "$NAME" ]; then
      echo "❌ Error: Rule name required."
      exit 1
    fi
    
    SOURCE="$CATALOG_DIR/$NAME.md"
    DEST="$AGENT_DIR/$NAME.md"
    
    if [ ! -f "$SOURCE" ]; then
      echo "❌ Error: Rule '$NAME' not found in catalog."
      exit 1
    fi
    
    if [ -f "$DEST" ]; then
      echo "⚠️ Warning: Rule '$NAME' already exists in .agents/rules/."
      read -p "Do you want to overwrite it? (y/N) " -n 1 -r
      echo ""
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
          echo "🚫 Installation cancelled."
          exit 0
      fi
    fi
    
    mkdir -p "$AGENT_DIR"
    cp "$SOURCE" "$DEST"
    echo "✅ Rule '$NAME' installed to .agents/rules/"
    ;;
  *)
    echo "Usage: $0 [list | install <name>]"
    exit 1
    ;;
esac
