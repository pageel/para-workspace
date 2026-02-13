#!/bin/bash

# PARA Project Scaffolder (v1.4)
# Creates new projects, areas, or resources
# Usage: para scaffold {project|area|resource} <name>

set -e

# === Cross-platform path normalization ===
normalize_path() {
  local p="$1"
  p="${p//\\//}"
  p="${p%/}"
  echo "$p"
}

# === Resolve paths ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(normalize_path "$(cd "$SCRIPT_DIR/.." && pwd)")"

if [ -n "$WORKSPACE_ROOT" ]; then
  WS_ROOT="$(normalize_path "$WORKSPACE_ROOT")"
elif [ -f ".para-workspace.yml" ]; then
  WS_ROOT="$(normalize_path "$(pwd)")"
else
  echo "❌ Error: Not in a PARA workspace."
  exit 1
fi

# === Parse arguments ===
TYPE="${1:-}"
NAME="${2:-}"

if [ -z "$TYPE" ] || [ -z "$NAME" ]; then
  echo "Usage: para scaffold {project|area|resource} <name>"
  echo ""
  echo "Examples:"
  echo "  para scaffold project my-saas-app"
  echo "  para scaffold area infrastructure"
  echo "  para scaffold resource web-development"
  exit 1
fi

# Validate kebab-case naming (Invariant I3)
if echo "$NAME" | grep -qE '[A-Z_ ]'; then
  echo "❌ Error: Name must be kebab-case (lowercase, hyphens only)."
  echo "   Got: $NAME"
  echo "   Try: $(echo "$NAME" | tr '[:upper:]' '[:lower:]' | tr ' _' '-')"
  exit 1
fi

case "$TYPE" in
  project)
    TARGET="$WS_ROOT/Projects/$NAME"

    if [ -d "$TARGET" ]; then
      echo "❌ Error: Project '$NAME' already exists."
      exit 1
    fi

    echo "🚀 Creating project: $NAME"

    # Create v1.4 project structure
    mkdir -p "$TARGET/sessions"
    mkdir -p "$TARGET/artifacts/tasks"
    mkdir -p "$TARGET/artifacts/plans"
    mkdir -p "$TARGET/artifacts/para-decisions"
    mkdir -p "$TARGET/artifacts/outputs"
    mkdir -p "$TARGET/.beads"
    mkdir -p "$TARGET/.agent/rules"
    mkdir -p "$TARGET/.agent/workflows"

    # Copy templates
    TMPL="$REPO_ROOT/templates/common"

    # project.md with substitutions
    if [ -f "$TMPL/project.md" ]; then
      sed "s/<project-name>/$NAME/g; s/YYYY-MM-DD/$(date +%Y-%m-%d)/g" "$TMPL/project.md" > "$TARGET/project.md"
    else
      cat > "$TARGET/project.md" <<EOL
---
name: "$NAME"
version: "0.1.0"
status: "active"
created: "$(date +%Y-%m-%d)"
goal: ""
deadline: ""
dod: ""
tags: []
---

# Project: $NAME

## Goal

_Define the goal of this project._
EOL
    fi

    # Task files (hybrid 3-file model)
    if [ -d "$TMPL/tasks" ]; then
      for tf in "$TMPL/tasks/"*.md; do
        [ -f "$tf" ] && sed "s/<project-name>/$NAME/g; s/<project-slug>/$NAME/g; s/YYYY-MM-DD/$(date +%Y-%m-%d)/g" "$tf" > "$TARGET/artifacts/tasks/$(basename "$tf")"
      done
    fi

    # Seeds file
    cat > "$TARGET/.beads/seeds.md" <<EOL
# Seeds — $NAME

> Raw ideas, hypotheses, context fragments for this project.
> These are NOT tasks — they inform task/plan generation.

---
EOL

    # README
    cat > "$TARGET/README.md" <<EOL
# $NAME

Created: $(date +%Y-%m-%d)

## Description

_Project description goes here._

## Structure

- \`sessions/\` — Daily work logs
- \`artifacts/\` — Tasks, plans, decisions, outputs
- \`.beads/\` — Ideas and raw notes
EOL

    echo "✅ Project '$NAME' created at $TARGET"
    echo ""
    echo "Next steps:"
    echo "  1. Edit $TARGET/project.md to set your goal"
    echo "  2. Add tasks to $TARGET/artifacts/tasks/backlog.md"
    ;;

  area)
    TARGET="$WS_ROOT/Areas/$NAME"

    if [ -d "$TARGET" ]; then
      echo "❌ Error: Area '$NAME' already exists."
      exit 1
    fi

    echo "📁 Creating area: $NAME"
    mkdir -p "$TARGET"

    cat > "$TARGET/README.md" <<EOL
# Area: $NAME

> Ongoing responsibility — stable knowledge, SOPs, and standards.

Created: $(date +%Y-%m-%d)
EOL

    echo "✅ Area '$NAME' created at $TARGET"
    ;;

  resource)
    TARGET="$WS_ROOT/Resources/$NAME"

    if [ -d "$TARGET" ]; then
      echo "❌ Error: Resource '$NAME' already exists."
      exit 1
    fi

    echo "📚 Creating resource: $NAME"
    mkdir -p "$TARGET"

    cat > "$TARGET/README.md" <<EOL
# Resource: $NAME

> Reference material, tools, or templates.

Created: $(date +%Y-%m-%d)
EOL

    echo "✅ Resource '$NAME' created at $TARGET"
    ;;

  *)
    echo "❌ Error: Unknown type '$TYPE'."
    echo "Valid types: project, area, resource"
    exit 1
    ;;
esac
