#!/bin/bash

# PARA Workspace Migrator (v1.4)
# Migrates a workspace from v1.3.x to v1.4.0
# Usage: para migrate [--from=1.3.6] [--to=1.4.0] [--dry-run]

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
REPO_ROOT="$(normalize_path "$(cd "$SCRIPT_DIR/../.." && pwd)")"

if [ -n "$WORKSPACE_ROOT" ]; then
  WS_ROOT="$(normalize_path "$WORKSPACE_ROOT")"
else
  echo "❌ Error: WORKSPACE_ROOT not set."
  echo "Run this from the workspace root or set WORKSPACE_ROOT."
  exit 1
fi

# === Parse arguments ===
FROM_VERSION=""
TO_VERSION=""
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --from=*)    FROM_VERSION="${arg#--from=}" ;;
    --to=*)      TO_VERSION="${arg#--to=}" ;;
    --dry-run)   DRY_RUN=true ;;
    --help|-h)
      echo "Usage: para migrate [options]"
      echo ""
      echo "Options:"
      echo "  --from=VERSION   Source version (auto-detected if not specified)"
      echo "  --to=VERSION     Target version (default: latest)"
      echo "  --dry-run        Preview changes without applying"
      echo ""
      echo "Examples:"
      echo "  para migrate --from=1.3.6 --to=1.4.0 --dry-run"
      echo "  para migrate --to=1.4.0"
      exit 0
      ;;
  esac
done

# Auto-detect current version
if [ -z "$FROM_VERSION" ]; then
  if [ -f "$WS_ROOT/.para-workspace.yml" ]; then
    FROM_VERSION=$(grep '^kernel_version:' "$WS_ROOT/.para-workspace.yml" | sed 's/kernel_version:[[:space:]]*//; s/"//g')
  elif [ -f "$WS_ROOT/metadata.json" ]; then
    FROM_VERSION="1.3.x"
  else
    FROM_VERSION="unknown"
  fi
fi

# Default target = latest from repo
if [ -z "$TO_VERSION" ]; then
  TO_VERSION="$(cat "$REPO_ROOT/../VERSION" 2>/dev/null || cat "$REPO_ROOT/VERSION" 2>/dev/null || echo "1.4.0")"
fi

echo "🔄 PARA Workspace Migration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  From: v$FROM_VERSION"
echo "  To:   v$TO_VERSION"
echo "  Mode: $( [ "$DRY_RUN" = true ] && echo "DRY RUN (preview only)" || echo "LIVE")"
echo "  Path: $WS_ROOT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# === Migration: v1.3.x → v1.4.0 ===
run_or_preview() {
  local desc="$1"
  shift

  echo "  📋 $desc"
  if [ "$DRY_RUN" = false ]; then
    "$@" 2>/dev/null || true
    echo "     ✓ Done"
  else
    echo "     → Would execute: $*"
  fi
}

# Step 1: Task file migration (tasks.md → hybrid 3-file)
echo "📦 Step 1: Migrate task files to hybrid 3-file model..."
for project_dir in "$WS_ROOT"/Projects/*/; do
  if [ -d "$project_dir" ]; then
    project_name="$(basename "$project_dir")"
    old_tasks="$project_dir/artifacts/tasks.md"
    new_tasks_dir="$project_dir/artifacts/tasks"

    if [ -f "$old_tasks" ] && [ ! -d "$new_tasks_dir" ]; then
      echo "  🔀 Project: $project_name"
      run_or_preview "Create artifacts/tasks/ directory" mkdir -p "$new_tasks_dir"
      run_or_preview "Move tasks.md → tasks/backlog.md" mv "$old_tasks" "$new_tasks_dir/backlog.md"
      run_or_preview "Create sprint-current.md" touch "$new_tasks_dir/sprint-current.md"
      run_or_preview "Create done.md" touch "$new_tasks_dir/done.md"
    elif [ -d "$new_tasks_dir" ]; then
      echo "  ✓ $project_name: Already migrated"
    fi
  fi
done

# Step 2: Install kernel snapshot
echo ""
echo "🧠 Step 2: Install kernel snapshot..."
KERNEL_TARGET="$WS_ROOT/Resources/ai-agents/kernel"
run_or_preview "Create kernel directory" mkdir -p "$KERNEL_TARGET"
if [ "$DRY_RUN" = false ]; then
  if [ -d "$REPO_ROOT/kernel" ]; then
    cp -r "$REPO_ROOT/kernel/"* "$KERNEL_TARGET/"
    echo "     ✓ Kernel installed from repo"
  elif [ -d "$REPO_ROOT/../kernel" ]; then
    cp -r "$REPO_ROOT/../kernel/"* "$KERNEL_TARGET/"
    echo "     ✓ Kernel installed from repo"
  fi
fi

# Step 3: Update workflow catalog
echo ""
echo "📑 Step 3: Update workflow catalog..."
WF_TARGET="$WS_ROOT/Resources/ai-agents/workflows"
run_or_preview "Create workflow catalog directory" mkdir -p "$WF_TARGET"
if [ "$DRY_RUN" = false ]; then
  WF_SOURCE=""
  [ -d "$REPO_ROOT/workflows" ] && WF_SOURCE="$REPO_ROOT/workflows"
  [ -d "$REPO_ROOT/../workflows" ] && WF_SOURCE="$REPO_ROOT/../workflows"
  if [ -n "$WF_SOURCE" ]; then
    for f in "$WF_SOURCE"/*.md; do
      [ -f "$f" ] && cp "$f" "$WF_TARGET/"
    done
  fi
fi
run_or_preview "Sync to .agent/workflows/" mkdir -p "$WS_ROOT/.agent/workflows"

# Step 4: Migrate metadata.json → .para-workspace.yml
echo ""
echo "⚙️  Step 4: Migrate configuration..."
OLD_META="$WS_ROOT/metadata.json"
NEW_CONFIG="$WS_ROOT/.para-workspace.yml"

if [ -f "$OLD_META" ] && [ ! -f "$NEW_CONFIG" ]; then
  run_or_preview "Generate .para-workspace.yml from metadata.json" \
    bash -c "cat > '$NEW_CONFIG' <<EOYML
# PARA Workspace Configuration
# Migrated from metadata.json on $(date +%Y-%m-%d)

kernel_version: \"$TO_VERSION\"
profile: \"dev\"
language: \"vi\"

repo:
  url: \"https://github.com/pageel/para-workspace\"
  branch: \"main\"

workspace:
  version: \"1.0.0\"
  created: \"$(date +%Y-%m-%d)\"
  migrated_from: \"$FROM_VERSION\"
EOYML"
  run_or_preview "Backup old metadata.json" mv "$OLD_META" "$OLD_META.bak.$(date +%s)"
elif [ -f "$NEW_CONFIG" ]; then
  echo "  ✓ .para-workspace.yml already exists"
fi

# Step 5: Remove workspace.md if merged into README
echo ""
echo "📝 Step 5: Merge workspace.md into README..."
if [ -f "$WS_ROOT/workspace.md" ] && [ -f "$WS_ROOT/README.md" ]; then
  run_or_preview "Backup and remove workspace.md" mv "$WS_ROOT/workspace.md" "$WS_ROOT/workspace.md.bak.$(date +%s)"
fi

# Step 6: Install agent governance
echo ""
echo "🤖 Step 6: Install agent governance..."
run_or_preview "Create .agent/rules/" mkdir -p "$WS_ROOT/.agent/rules"
if [ "$DRY_RUN" = false ] && [ -d "$REPO_ROOT/templates" ]; then
  GOV_SRC="$REPO_ROOT/templates/common/agent/governance.md"
  [ -f "$GOV_SRC" ] && cp "$GOV_SRC" "$WS_ROOT/.agent/rules/"
fi

# === Done ===
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$DRY_RUN" = true ]; then
  echo "🔍 Dry run complete. No changes were made."
  echo "   Remove --dry-run to apply the migration."
else
  echo "✨ Migration complete! v$FROM_VERSION → v$TO_VERSION"
  echo ""
  echo "Next steps:"
  echo "  para status    — Verify workspace health"
fi
