#!/bin/bash

# PARA Workspace Migrator (v1.4.1)
# Migrates a workspace between versions
# Usage: para migrate [--from=1.4.0] [--to=1.4.1] [--dry-run]

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
LIB_DIR="$SCRIPT_DIR/../lib"

# === Load Libraries ===
if [ -f "$LIB_DIR/logger.sh" ]; then
  source "$LIB_DIR/logger.sh"
fi
if [ -f "$LIB_DIR/fs.sh" ]; then
  source "$LIB_DIR/fs.sh"
fi

# === Parse arguments (help first) ===
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
      echo "Migrates a PARA workspace between versions."
      echo ""
      echo "Supported migration paths:"
      echo "  v1.3.x → v1.4.0   Task model, metadata, kernel snapshot"
      echo "  v1.4.0 → v1.4.1   Governed libraries, .para/ state, catalog.yml"
      echo ""
      echo "Options:"
      echo "  --from=VERSION   Source version (auto-detected if not specified)"
      echo "  --to=VERSION     Target version (default: latest)"
      echo "  --dry-run        Preview changes without applying"
      echo ""
      echo "Examples:"
      echo "  para migrate --from=1.4.0 --to=1.4.1 --dry-run"
      echo "  para migrate --to=1.4.1"
      exit 0
      ;;
  esac
done

if [ -n "$WORKSPACE_ROOT" ]; then
  WS_ROOT="$(normalize_path "$WORKSPACE_ROOT")"
else
  echo "❌ Error: WORKSPACE_ROOT not set."
  echo "Run this from the workspace root or set WORKSPACE_ROOT."
  exit 1
fi

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
  TO_VERSION="$(cat "$REPO_ROOT/VERSION" 2>/dev/null || echo "1.4.0")"
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
if [ "$DRY_RUN" = false ] && [ -d "$REPO_ROOT/kernel" ]; then
  cp -r "$REPO_ROOT/kernel/"* "$KERNEL_TARGET/"
  echo "     ✓ Kernel installed from repo"
fi

# Step 3: Update workflow catalog
echo ""
echo "📑 Step 3: Update workflow catalog..."
WF_TARGET="$WS_ROOT/Resources/ai-agents/workflows"
CATALOG_SRC="$REPO_ROOT/templates/common/agent/workflows"

run_or_preview "Create workflow catalog directory" mkdir -p "$WF_TARGET"
if [ "$DRY_RUN" = false ] && [ -d "$CATALOG_SRC" ]; then
  for f in "$CATALOG_SRC"/*.md; do
    [ -f "$f" ] && cp "$f" "$WF_TARGET/"
  done
  echo "     ✓ Workflows updated from templates"
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

# Step 6: Install agent governance & rules
echo ""
echo "🤖 Step 6: Install agent governance & rules..."
run_or_preview "Create .agent/rules/" mkdir -p "$WS_ROOT/.agent/rules"

if [ "$DRY_RUN" = false ]; then
  # Governance
  GOV_SRC="$REPO_ROOT/templates/common/agent/governance.md"
  [ -f "$GOV_SRC" ] && cp "$GOV_SRC" "$WS_ROOT/.agent/rules/"
  
  # Rules Library
  RULE_SRC="$REPO_ROOT/templates/common/agent/rules"
  if [ -d "$RULE_SRC" ]; then
    for f in "$RULE_SRC"/*.md; do
      cp "$f" "$WS_ROOT/.agent/rules/"
    done
    echo "     ✓ Governance & Rules installed"
  fi
fi

# ============================================================
# Migration: v1.4.0 → v1.4.1 (Governed Libraries & Runtime)
# ============================================================

echo ""
echo "━━━ v1.4.0 → v1.4.1 Migration ━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 7: Create .para/ system state
echo "🔒 Step 7: Initialize .para/ system state..."
PARA_STATE="$WS_ROOT/.para"
if [ ! -d "$PARA_STATE" ]; then
  run_or_preview "Create .para/" mkdir -p "$PARA_STATE"
  run_or_preview "Create migrations/" mkdir -p "$PARA_STATE/migrations"
  run_or_preview "Create backups/" mkdir -p "$PARA_STATE/backups"
  if [ "$DRY_RUN" = false ]; then
    echo "$(date -Iseconds 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S%z") | SYSTEM | para migrate | from=$FROM_VERSION to=$TO_VERSION | INIT" > "$PARA_STATE/audit.log"
    echo "     ✓ .para/ created with audit.log"
  fi
else
  echo "  ✓ .para/ already exists"
fi

# Step 8: Create Resources/ai-agents/rules/ & skills/
echo ""
echo "📏 Step 8: Create governed library snapshots..."
LIB_SRC="$REPO_ROOT/templates/common/agent"

for lib in rules skills; do
  SNAPSHOT_DIR="$WS_ROOT/Resources/ai-agents/$lib"
  ACTIVE_DIR="$WS_ROOT/.agent/$lib"
  SRC_DIR="$LIB_SRC/$lib"
  
  run_or_preview "Create Resources/ai-agents/$lib/" mkdir -p "$SNAPSHOT_DIR"
  run_or_preview "Create .agent/$lib/" mkdir -p "$ACTIVE_DIR"

  if [ "$DRY_RUN" = false ] && [ -d "$SRC_DIR" ]; then
    for f in "$SRC_DIR"/*.md "$SRC_DIR"/catalog.yml; do
      [ -f "$f" ] && cp "$f" "$SNAPSHOT_DIR/"
    done
    for f in "$SRC_DIR"/*.md; do
      [ -f "$f" ] && cp "$f" "$ACTIVE_DIR/"
    done
    echo "     ✓ $lib library synced"
  fi
done

# Step 9: Sync catalog.yml for workflows
echo ""
echo "📑 Step 9: Sync catalog.yml files..."
for lib in workflows rules skills; do
  CATALOG_SRC="$LIB_SRC/$lib/catalog.yml"
  CATALOG_DEST="$WS_ROOT/Resources/ai-agents/$lib/catalog.yml"
  if [ -f "$CATALOG_SRC" ]; then
    run_or_preview "Copy $lib/catalog.yml" cp "$CATALOG_SRC" "$CATALOG_DEST"
  fi
done
if [ "$DRY_RUN" = false ]; then
  echo "     ✓ All catalog.yml files synced"
fi

# Step 10: Update kernel_version in .para-workspace.yml
echo ""
echo "⚙️  Step 10: Update workspace config..."
if [ -f "$WS_ROOT/.para-workspace.yml" ]; then
  if [ "$DRY_RUN" = false ]; then
    sed -i "s/^kernel_version:.*/kernel_version: \"$TO_VERSION\"/" "$WS_ROOT/.para-workspace.yml"
    echo "     ✓ kernel_version updated to $TO_VERSION"
  else
    echo "     → Would update kernel_version to $TO_VERSION"
  fi
fi

# ============================================================
# Migration: v1.4.5 → v1.4.6 (Smart Archive)
# ============================================================

echo ""
echo "━━━ v1.4.5 → v1.4.6 Migration ━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 11: Cleanup old manual migration docs (Smart Archive)
echo "🧹 Step 11: Smart Archive obsolete files..."

# Ensure we have a target directory setup done mostly by archive_file
if [ "$DRY_RUN" = false ]; then
  # Archive old migration guide if it exists in docs
  archive_file "$WS_ROOT/docs/migration.md" "$TO_VERSION"
  
  # Archive old migration plan if it exists
  archive_file "$WS_ROOT/artifacts/plans/smart-archive-migration-plan.md" "$TO_VERSION"

  echo "     ✓ Obsolete files archived to .para/archive/${TO_VERSION}-orphans/"
else
  echo "     → Would archive obsolete files to .para/archive/${TO_VERSION}-orphans/"
fi

# === Record migration ===
if [ "$DRY_RUN" = false ] && [ -d "$WS_ROOT/.para/migrations" ]; then
  echo "$FROM_VERSION → $TO_VERSION | $(date -Iseconds 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S%z")" >> "$WS_ROOT/.para/migrations/history.log"
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
