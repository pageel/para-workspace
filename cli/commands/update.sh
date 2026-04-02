#!/bin/bash

# PARA Workspace Update Script (v1.7.3)
# Safely updates templates without overwriting user data
# Usage: para update [--dry-run]

set -e

# === Resolve paths ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIB_DIR="$SCRIPT_DIR/../lib"

# === Load libraries ===
if [ -f "$LIB_DIR/validator.sh" ]; then
  source "$LIB_DIR/validator.sh"
fi

# === Ensure WORKSPACE_ROOT is set ===
if [ -z "$WORKSPACE_ROOT" ]; then
  if [ -f "$REPO_ROOT/../../.para-workspace.yml" ]; then
    WORKSPACE_ROOT="$(cd "$REPO_ROOT/../.." && pwd)"
    export WORKSPACE_ROOT
  else
    echo "⚠️  WORKSPACE_ROOT not set. Run via ./para update for best results."
  fi
fi

# For self-update detection
get_hash() {
    if command -v sha256sum &>/dev/null; then
        sha256sum "$1" | awk '{print $1}'
    elif command -v shasum &>/dev/null; then
        shasum -a 256 "$1" | awk '{print $1}'
    else
        stat -c %Y "$1" 2>/dev/null || date +%s
    fi
}
OLD_SCRIPT_HASH=$(get_hash "$SCRIPT_DIR/update.sh")

# Parse arguments
DRY_RUN=false
PASSTHROUGH_ARGS=()
for arg in "$@"; do
  case "$arg" in
    --help|-h)
      echo "Usage: para update [--dry-run]"
      echo ""
      echo "Pulls the latest PARA Workspace repo from GitHub and re-syncs"
      echo "the workspace (kernel, workflows, rules, skills, CLI wrapper)."
      echo ""
      echo "This command:"
      echo "  1. Runs 'git pull' on the repo"
      echo "  2. Detects changes via git commit hash (accurate for hotfixes)"
      echo "  3. Runs version-gated migrations (if kernel version changed)"
      echo "  4. Re-runs 'para install' to sync all libraries"
      echo ""
      echo "Options:"
      echo "  --dry-run   Preview all changes without applying"
      echo ""
      echo "Existing files are backed up to .bak before overwriting."
      exit 0
      ;;
    --dry-run)
      DRY_RUN=true
      PASSTHROUGH_ARGS+=("--dry-run")
      ;;
  esac
done

echo "🔄 Updating PARA Workspace Template from GitHub..."

# === Get current version from WORKSPACE only (not repo/VERSION) ===
# This prevents comparing the same file before/after git pull (BUG-20 fix)
if [ -n "$WORKSPACE_ROOT" ] && [ -f "$WORKSPACE_ROOT/.para-workspace.yml" ]; then
    CURRENT_VER=$(grep '^kernel_version:' "$WORKSPACE_ROOT/.para-workspace.yml" | sed 's/kernel_version:[[:space:]]*//; s/"//g')
else
    CURRENT_VER="0.0.0"  # Force full migration on first run
fi

echo "📍 Repo root: $REPO_ROOT"

# Check if it's a git repo
if [ ! -d "$REPO_ROOT/.git" ]; then
    echo "❌ Error: $REPO_ROOT is not a git repository."
    echo ""
    echo "💡 Hint: The para-workspace repo should be at:"
    echo "   $REPO_ROOT"
    echo ""
    echo "If you cloned it elsewhere, make sure the CLI is running from the repo."
    exit 1
fi

# === Capture commit hash BEFORE pull (for accurate change detection) ===
OLD_COMMIT=$(cd "$REPO_ROOT" && git rev-parse HEAD 2>/dev/null || echo "unknown")

echo "📍 Current Version: $CURRENT_VER"

# Pull latest (skip in dry-run mode)
if [ "$DRY_RUN" = true ]; then
  echo "🔍 DRY RUN: Skipping git pull (preview only)..."
else
  echo "📥 Pulling latest changes..."
  cd "$REPO_ROOT"

  # On Windows, git pull might fail to update the running script.
  if git pull origin main; then
      NEW_SCRIPT_HASH=$(get_hash "$SCRIPT_DIR/update.sh")
      if [ "$OLD_SCRIPT_HASH" != "$NEW_SCRIPT_HASH" ]; then
          echo "🔄 CLI scripts updated. Restarting update process..."
          exec bash "$SCRIPT_DIR/update.sh" "$@"
      fi
  else
      echo "⚠️  Git pull failed or was partial."
      if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
          echo "💡 Windows detected: This is often caused by the script file being locked while running."
          echo "   Please try closing all terminals and running the update again."
      fi
      exit 1
  fi
fi

# === Capture state AFTER pull ===
NEW_COMMIT=$(cd "$REPO_ROOT" && git rev-parse HEAD 2>/dev/null || echo "unknown")
NEW_VER=$(cat "$REPO_ROOT/VERSION" 2>/dev/null || echo "Unknown")

# === Change detection: git commit hash (accurate for hotfixes) ===
COMMIT_COUNT=0
if [ "$OLD_COMMIT" == "$NEW_COMMIT" ]; then
    echo "✅ No new changes from remote."
else
    COMMIT_COUNT=$(cd "$REPO_ROOT" && git log --oneline "$OLD_COMMIT..$NEW_COMMIT" 2>/dev/null | wc -l | tr -d ' ')
    echo "📥 Pulled $COMMIT_COUNT new commit(s)"
fi

# === Version detection: only used for migration gating ===
if [ "$CURRENT_VER" != "$NEW_VER" ] && [ "$CURRENT_VER" != "0.0.0" ] && [ "$CURRENT_VER" != "Unknown" ]; then
    # Direction detection (v1.6.5 — BUG-22 fix)
    if command -v semver_gte &>/dev/null && semver_gte "$CURRENT_VER" "$NEW_VER" 2>/dev/null; then
        echo "⏬ Downgrade detected: $CURRENT_VER → $NEW_VER"
        echo "   ⚠️  Workspace kernel is newer than repo. Skipping migration."
    else
        echo "⏫ Upgrade: $CURRENT_VER → $NEW_VER"
        echo "🏗️ Running auto-migration process..."
        if ! bash "$SCRIPT_DIR/migrate.sh" --from="$CURRENT_VER" --to="$NEW_VER" "${PASSTHROUGH_ARGS[@]}"; then
          echo "⚠️  Migration encountered issues. Continuing with install..."
        fi
    fi
elif [ "$CURRENT_VER" == "0.0.0" ]; then
    echo "📦 First install detected (no workspace version). Skipping migration."
fi

# ALWAYS re-run installation to sync (idempotent — handles hotfixes without version bump)
echo "⚙️ Re-installing to sync workspace..."
bash "$SCRIPT_DIR/install.sh" "${PASSTHROUGH_ARGS[@]}"

# === System KI Upgrade Sync (v1.7.1, improved v1.7.3) ===
# After install (which only creates NEW KIs), upgrade EXISTING system KIs
# when templates have changed. Runs on every update — content-aware comparison
# ensures idempotency (no-op when templates haven't changed).
KI_TMPL_SRC="$REPO_ROOT/templates/knowledge"
KI_STORE="${HOME}/.gemini/antigravity/knowledge"

if [ -d "$KI_TMPL_SRC" ]; then
  ki_upgraded=0

  for tmpl_dir in "$KI_TMPL_SRC"/para_*/; do
    [ -d "$tmpl_dir" ] || continue
    slug=$(basename "$tmpl_dir")
    ki_dest="$KI_STORE/$slug"

    # Only upgrade existing KIs (new ones handled by install.sh)
    if [ -d "$ki_dest" ] && [ -f "$tmpl_dir/metadata.json" ] && [ -f "$ki_dest/metadata.json" ]; then
      needs_upgrade=false

      # Check 1: para_version mismatch
      tmpl_pv=$(grep -o '"para_version": "[^"]*"' "$tmpl_dir/metadata.json" 2>/dev/null | sed 's/.*"para_version": "//;s/"$//')
      ki_pv=$(grep -o '"para_version": "[^"]*"' "$ki_dest/metadata.json" 2>/dev/null | sed 's/.*"para_version": "//;s/"$//')

      if [ -n "$tmpl_pv" ] && [ "$tmpl_pv" != "$ki_pv" ]; then
        needs_upgrade=true
      fi

      # Check 2: content hash mismatch (catches same-version hotfixes)
      if [ "$needs_upgrade" = false ]; then
        tmpl_hash=$(get_hash "$tmpl_dir/metadata.json")
        ki_hash=$(get_hash "$ki_dest/metadata.json")
        if [ "$tmpl_hash" != "$ki_hash" ]; then
          needs_upgrade=true
        fi
      fi

      if [ "$needs_upgrade" = true ]; then
        # Override metadata.json from template
        cp "$tmpl_dir/metadata.json" "$ki_dest/metadata.json"

        # Override template artifacts (matching filenames only)
        if [ -d "$tmpl_dir/artifacts" ]; then
          for art_file in "$tmpl_dir/artifacts"/*; do
            [ -f "$art_file" ] && cp "$art_file" "$ki_dest/artifacts/"
          done
        fi

        ki_upgraded=$((ki_upgraded + 1))
      fi
    fi
  done

  if [ "$ki_upgraded" -gt 0 ]; then
    echo "🔄 System KI upgrade: $ki_upgraded KI(s) synced"
  fi
fi

# Audit log
if [ -n "$WORKSPACE_ROOT" ] && [ -f "$WORKSPACE_ROOT/.para/audit.log" ]; then
  echo "$(date -Iseconds 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S%z") | CLI | para update | from=$CURRENT_VER to=$NEW_VER commits=$COMMIT_COUNT | OK" >> "$WORKSPACE_ROOT/.para/audit.log"
fi

echo "✨ Update complete!"
