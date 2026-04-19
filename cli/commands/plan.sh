#!/bin/bash

# PARA Plan Generator
# Usage: ./cli/plan.sh <project-name> <description>

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
LIB_DIR="$SCRIPT_DIR/../lib"

# === Load Libraries ===
if [ -f "$LIB_DIR/fs.sh" ]; then
  source "$LIB_DIR/fs.sh"
fi

# Use environment variable if provided by 'para' wrapper
if [ -z "$WORKSPACE_ROOT" ]; then
  WORKSPACE_ROOT="$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")")")"
fi
export WORKSPACE_ROOT

PROJECT_NAME=$1
DESCRIPTION=$2

if [ -z "$PROJECT_NAME" ] || [ -z "$DESCRIPTION" ]; then
  echo "❌ Error: Project name and description required."
  echo "Usage: ./para plan <project-name> \"<description>\""
  exit 1
fi

P_PROJECTS=$(get_para_dir projects)
PROJECT_PATH="$WORKSPACE_ROOT/$P_PROJECTS/$PROJECT_NAME"

if [ ! -d "$PROJECT_PATH" ]; then
  echo "❌ Error: Project '$PROJECT_NAME' does not exist."
  exit 1
fi

PLAN_DIR="$PROJECT_PATH/artifacts/plans"
mkdir -p "$PLAN_DIR"

DATE=$(date +%Y-%m-%d)
CLEAN_DESC=$(echo "$DESCRIPTION" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '-' | tr -cd '[:alnum:]-')
PLAN_FILE="$PLAN_DIR/plan-$DATE-$CLEAN_DESC.md"

cat > "$PLAN_FILE" <<EOL
# Implementation Plan: $DESCRIPTION
Date: $DATE
Project: $PROJECT_NAME

## 🎯 Objective
Briefly describe what we are trying to achieve.

## 🛠 Technical Steps
- [ ] Step 1: ...
- [ ] Step 2: ...

## ✅ Verification Checklist
- [ ] Verify X works
- [ ] Check Y output

## ⚠️ Rollback Strategy
How to undo these changes if something goes wrong.
EOL

echo "✅ Created plan: $PLAN_FILE"
