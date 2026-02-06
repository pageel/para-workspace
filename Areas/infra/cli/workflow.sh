#!/bin/bash

# PARA Workflow Manager
# Usage: ./Areas/infra/cli/workflow.sh [list | install <name>]

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
# Use exported WORKSPACE_ROOT if available, otherwise guess from script location
if [ -z "$WORKSPACE_ROOT" ]; then
    WORKSPACE_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
fi
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
    MERGE=false
    if [ "$3" == "-m" ] || [ "$5" == "-m" ]; then MERGE=true; fi
    
    if [ ! -f "$SOURCE" ]; then
      echo "❌ Error: Workflow '$NAME' not found in catalog."
      exit 1
    fi
    
    if [ -f "$DEST" ]; then
      if [ "$MERGE" == "true" ]; then
        echo "🔄 Merging catalog workflow '$NAME' into existing '$FINAL_NAME.md'..."
        # Create a backup
        cp "$DEST" "$DEST.bak"
        # Append new content but wrap it in a 'New Version' section
        echo -e "\n\n---" >> "$DEST"
        echo -e "## 🆕 [PARA Update] Recommended Changes\n" >> "$DEST"
        cat "$SOURCE" >> "$DEST"
        echo "✅ Merged. Please review '$FINAL_NAME.md' to combine logic."
        exit 0
      fi
      
      echo "⚠️ Warning: Workflow '$FINAL_NAME.md' already exists."
      read -p "Choose action: [o]verwrite, [m]erge, [r]ename, [c]ancel? " -n 1 -r
      echo ""
      if [[ $REPLY =~ ^[Oo]$ ]]; then
         cp "$SOURCE" "$DEST"
         echo "✅ Overwritten '$FINAL_NAME.md'."
      elif [[ $REPLY =~ ^[Mm]$ ]]; then
         # Merge logic
         cp "$DEST" "$DEST.bak"
         echo -e "\n\n---" >> "$DEST"
         echo -e "## 🆕 [PARA Update] Recommended Changes\n" >> "$DEST"
         cat "$SOURCE" >> "$DEST"
         echo "✅ Merged into '$FINAL_NAME.md'. (Backup: '$FINAL_NAME.md.bak')"
      elif [[ $REPLY =~ ^[Rr]$ ]]; then
         # Rename logic (Auto-suggest p- prefix)
         SUGGESTED="p-$FINAL_NAME"
         read -p "Enter new alias (default: $SUGGESTED): " NEW_ALIAS
         NEW_ALIAS=${NEW_ALIAS:-$SUGGESTED}
         cp "$SOURCE" "$AGENT_DIR/$NEW_ALIAS.md"
         echo "✅ Installed as '$NEW_ALIAS.md' (Original '$FINAL_NAME.md' preserved)."
      else
          echo "🚫 Installation cancelled."
      fi
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
