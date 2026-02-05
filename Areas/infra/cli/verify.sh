#!/bin/bash

# PARA Verification Helper
# Usage: ./cli/verify.sh <project-name> <description>

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
# Use environment variable if provided by 'para' wrapper
if [ -z "$WORKSPACE_ROOT" ]; then
  WORKSPACE_ROOT="$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")")")"
fi
PROJECT_NAME=$1
DESCRIPTION=$2

if [ -z "$PROJECT_NAME" ]; then
  echo "❌ Error: Project name required."
  echo "Usage: ./para verify <project-name> [\"description\"]"
  exit 1
fi

PROJECT_PATH="$WORKSPACE_ROOT/Projects/$PROJECT_NAME"

if [ ! -d "$PROJECT_PATH" ]; then
  echo "❌ Error: Project '$PROJECT_NAME' does not exist."
  exit 1
fi

WALK_DIR="$PROJECT_PATH/artifacts/walkthroughs"
mkdir -p "$WALK_DIR"

if [ -z "$DESCRIPTION" ]; then
    echo "🔍 Existing Walkthroughs for $PROJECT_NAME:"
    ls -1 "$WALK_DIR" || echo "None found."
    exit 0
fi

DATE=$(date +%Y-%m-%d)
CLEAN_DESC=$(echo "$DESCRIPTION" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '-' | tr -cd '[:alnum:]-')
WALK_FILE="$WALK_DIR/walkthrough-$CLEAN_DESC.md"

cat > "$WALK_FILE" <<EOL
# Walkthrough: $DESCRIPTION
Date: $DATE
Project: $PROJECT_NAME

## 📋 Summary of Changes
- Described what was implemented.

## 🧪 Verification Steps
1. [ ] Step 1: Run command ...
2. [ ] Step 2: Check result ...

## 🏁 Result
- [ ] SUCCESS
- [ ] FAILURE (Reason: ...)
EOL

echo "✅ Created walkthrough: $WALK_FILE"
