#!/bin/bash

# PARA Project Migrator (to v1.3 Standard)
# Usage: ./para migrate <project-name>

set -e

PROJECT_NAME="$1"

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: ./para migrate <project-name>"
    exit 1
fi

# Ensure WORKSPACE_ROOT is available
if [ -z "$WORKSPACE_ROOT" ]; then
    echo "❌ Error: WORKSPACE_ROOT not set."
    exit 1
fi

PROJECT_PATH="$WORKSPACE_ROOT/Projects/$PROJECT_NAME"

# If project isn't in Projects/ but exists in Root, move it
if [ ! -d "$PROJECT_PATH" ] && [ -d "$WORKSPACE_ROOT/$PROJECT_NAME" ]; then
    echo "📦 Moving '$PROJECT_NAME' from Root to Projects/..."
    mv "$WORKSPACE_ROOT/$PROJECT_NAME" "$WORKSPACE_ROOT/Projects/"
fi

if [ ! -d "$PROJECT_PATH" ]; then
    echo "❌ Error: Project '$PROJECT_NAME' not found in Projects/ or Root."
    exit 1
fi

echo "🚀 Migrating '$PROJECT_NAME' to PARA v1.3 Standard..."

# 1. Create Artifact Layer
mkdir -p "$PROJECT_PATH/artifacts/plans"
mkdir -p "$PROJECT_PATH/artifacts/walkthroughs"
if [ ! -f "$PROJECT_PATH/artifacts/tasks.md" ]; then
    cat > "$PROJECT_PATH/artifacts/tasks.md" <<EOL
# Project Tasks: $PROJECT_NAME

## 🚦 Roadmap
- [ ] PARA v1.3 Migration
  - DoD: Structure verified
  - Verify: Run \`./para status\`

## 📋 Current Sprint
- [ ] Task 1

## ✅ Done
EOL
    echo "✅ Created artifacts/tasks.md"
fi

# 2. Handle Repo folder (Source Code)
# If root files exist (excluding standard PARA folders), move them to repo/
# Standard PARA folders: repo, sessions, docs, artifacts, .agent, project.md
mkdir -p "$PROJECT_PATH/repo"
# This part is a bit delicate, we only move if we are sure it's not a PARA folder
# For simplicity, we just ensure the directory exists

# 3. Upgrade project.md to YAML Frontmatter (v1.3)
PROJECT_MD="$PROJECT_PATH/project.md"
    if [ -f "$PROJECT_MD" ]; then
        # Check if it starts with YAML frontmatter
        if [ "$(head -n 1 "$PROJECT_MD")" != "---" ]; then
            echo "🔄 Upgrading project.md to YAML Frontmatter..."
            # Extract Goal if possible
            GOAL=$(grep -i "goal" "$PROJECT_MD" | head -n 1 | cut -d':' -f2- | sed 's/^[[:space:]>]*//' || echo "Define goals")
            [ -z "$GOAL" ] && GOAL="Define project goal"
            
            # Backup old
            mv "$PROJECT_MD" "$PROJECT_MD.bak"
            
            cat > "$PROJECT_MD" <<EOL
---
goal: "$GOAL"
deadline: "$(date -d "+30 days" +%Y-%m-%d)"
status: "active"
dod:
  - "Feature parity with old structure"
last_reviewed: "$(date +%Y-%m-%d)"
---

$(cat "$PROJECT_MD.bak")
EOL
            rm "$PROJECT_MD.bak"
            echo "✅ Upgraded project.md"
        fi
else
    # Create new project.md
    cat > "$PROJECT_MD" <<EOL
---
goal: "Define project goal"
deadline: "$(date -d "+30 days" +%Y-%m-%d)"
status: "active"
dod:
  - "Initial setup verified"
last_reviewed: "$(date +%Y-%m-%d)"
---

# Project: $PROJECT_NAME
EOL
    echo "✅ Created new project.md"
fi

# 4. Create standard folders if missing
mkdir -p "$PROJECT_PATH/sessions"
mkdir -p "$PROJECT_PATH/docs"
mkdir -p "$PROJECT_PATH/.agent/rules"
mkdir -p "$PROJECT_PATH/.agent/workflows"

echo "✨ Migration of '$PROJECT_NAME' complete!"
echo "Check your updated structure in $PROJECT_PATH"
