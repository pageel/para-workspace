#!/bin/bash

# PARA Project Scaffolder
# Usage: ./cli/scaffold.sh <project-name>

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
WORKSPACE_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECT_NAME=$1

if [ -z "$PROJECT_NAME" ]; then
  echo "❌ Error: Project name required."
  echo "Usage: ./cli/scaffold.sh <project-name>"
  exit 1
fi

PROJECT_PATH="$WORKSPACE_ROOT/Projects/$PROJECT_NAME"

if [ -d "$PROJECT_PATH" ]; then
  echo "❌ Error: Project '$PROJECT_NAME' already exists."
  exit 1
fi

echo "🚀 Scaffolding project: $PROJECT_NAME"

# Create directory structure
mkdir -p "$PROJECT_PATH/repo"
mkdir -p "$PROJECT_PATH/sessions"
mkdir -p "$PROJECT_PATH/docs"
mkdir -p "$PROJECT_PATH/.beads"
mkdir -p "$PROJECT_PATH/.agent"

# Create .gitignore in repo
cat > "$PROJECT_PATH/repo/.gitignore" <<EOL
node_modules/
.DS_Store
dist/
.env
EOL

# Create project.md (Required by PARA Spec)
cat > "$PROJECT_PATH/project.md" <<EOL
# Project: $PROJECT_NAME

## 🎯 Goal
Define the specific goal of this project.

## 🚦 Status
- [ ] Active
- [ ] On Hold
- [ ] Completed

## 🔑 Key Decisions
- [YYYY-MM-DD] Initialized project.

## 📦 Dependencies
- None

## ✅ Done Condition
- [ ] Feature X implemented
- [ ] Deployed to production
EOL

# Create README.md
cat > "$PROJECT_PATH/repo/README.md" <<EOL
# $PROJECT_NAME

Created: $(date +%Y-%m-%d)

## Description
Project description goes here.

## Structure
- \`repo/\`: Source code
- \`sessions/\`: Work logs
- \`docs/\`: Documentation
EOL

# Update metadata.json (requires jq)
if command -v jq &> /dev/null; then
  METADATA_FILE="$WORKSPACE_ROOT/metadata.json"
  TEMP_FILE="$WORKSPACE_ROOT/metadata.tmp.json"
  
  # Check if metadata.json exists
  if [ -f "$METADATA_FILE" ]; then
      echo "Updating metadata.json..."
      jq --arg name "$PROJECT_NAME" \
         --arg path "./Projects/$PROJECT_NAME/repo" \
         --arg date "$(date +%Y-%m-%d)" \
         '.products[$name] = {
           "name": $name,
           "path": $path,
           "type": "internal",
           "version": "0.1.0",
           "status": "active",
           "created": $date
         }' "$METADATA_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$METADATA_FILE"
      echo "✅ Registered in metadata.json"
  else
      echo "⚠️ metadata.json not found, skipping registration."
  fi
else
  echo "⚠️ 'jq' not installed. Skipping metadata.json update."
fi

echo "✅ Project '$PROJECT_NAME' created successfully!"
echo "Path: $PROJECT_PATH"
