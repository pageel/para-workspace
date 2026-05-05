#!/bin/bash

# PARA Workspace Update Script (v1.8.5)
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

# === Detect Consumer vs Contributor mode (v1.8.5 — BUG-34 fix) ===
# Consumer repos (Resources/references/) use fetch+reset to avoid Windows file lock.
# Contributor repos (Projects/) keep standard git pull to preserve local work.
is_consumer_repo() {
  case "$REPO_ROOT" in
    */Resources/references/*) return 0 ;;
    */.para-repo)             return 0 ;;
    *)                        return 1 ;;
  esac
}

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
      echo "  1. Runs 'git pull' on the repo (always, even in dry-run)"
      echo "  2. Detects changes via git commit hash (accurate for hotfixes)"
      echo "  3. Runs version-gated migrations (if kernel version changed)"
      echo "  4. Re-runs 'para install' to sync all libraries"
      echo ""
      echo "Options:"
      echo "  --dry-run   Pull latest, then preview install without applying"
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

# === ALWAYS sync latest from remote ===
echo "📥 Pulling latest changes..."
cd "$REPO_ROOT"

if is_consumer_repo; then
    # Consumer mode: fetch + reset (BUG-34 fix — avoids Windows file lock)
    echo "📦 Consumer mode: fetch + reset..."
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        echo "⚠️  Local changes detected (will be overwritten — consumer is read-only mirror)."
    fi

    git fetch origin main

    if git reset --hard origin/main; then
        git clean -fd 2>/dev/null || true
        echo "✅ Consumer repo synced to latest."
        # Self-restart if update.sh changed
        if [ "$DRY_RUN" = false ]; then
            NEW_SCRIPT_HASH=$(get_hash "$SCRIPT_DIR/update.sh")
            if [ "$OLD_SCRIPT_HASH" != "$NEW_SCRIPT_HASH" ]; then
                echo "🔄 CLI scripts updated. Restarting update process..."
                exec bash "$SCRIPT_DIR/update.sh" "$@"
            fi
        fi
    else
        echo "⚠️  git reset failed (possible Windows file lock)."
        echo "💡 Fetch succeeded — .git/ has latest code."
        echo "   After closing this terminal, run:"
        echo "   cd $REPO_ROOT && git reset --hard origin/main && cd - && ./para install"
        # CONTINUE — fetch succeeded, install can still run with current code
    fi
else
    # Contributor mode: standard pull (preserves local work)
    if git pull origin main; then
        # Self-restart only in live mode (dry-run doesn't need restart)
        if [ "$DRY_RUN" = false ]; then
            NEW_SCRIPT_HASH=$(get_hash "$SCRIPT_DIR/update.sh")
            if [ "$OLD_SCRIPT_HASH" != "$NEW_SCRIPT_HASH" ]; then
                echo "🔄 CLI scripts updated. Restarting update process..."
                exec bash "$SCRIPT_DIR/update.sh" "$@"
            fi
        fi
    else
        echo "⚠️  Git pull failed or was partial."
        case "$OSTYPE" in
            msys|cygwin)
                echo "💡 Windows detected: script file may be locked while running."
                echo "   Please close all terminals and run the update again."
                ;;
        esac
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

# === System KI Upgrade Sync (v1.7.1, improved v1.7.3, v1.7.6 template vars) ===
# After install (which only creates NEW KIs), upgrade EXISTING system KIs
# when templates have changed. Runs on every update — content-aware comparison
# ensures idempotency (no-op when templates haven't changed).
KI_TMPL_SRC="$REPO_ROOT/templates/knowledge"
KI_STORE="${HOME}/.gemini/antigravity/knowledge"

# Read workspace config for template variables (v1.7.6)
WS_CFG="$WORKSPACE_ROOT/.para-workspace.yml"
TMPL_KERNEL_VERSION="$NEW_VER"
TMPL_LANGUAGE="en"
TMPL_PROFILE="dev"
TMPL_WORKSPACE_CREATED=""
TMPL_REPO_URL=""
if [ -f "$WS_CFG" ]; then
  TMPL_LANGUAGE=$(grep '^language:' "$WS_CFG" | sed 's/language:[[:space:]]*//; s/"//g' | tr -d '[:space:]')
  TMPL_PROFILE=$(grep '^profile:' "$WS_CFG" | sed 's/profile:[[:space:]]*//; s/"//g' | tr -d '[:space:]')
  TMPL_WORKSPACE_CREATED=$(grep '^  created:' "$WS_CFG" | sed 's/.*created:[[:space:]]*//; s/"//g' | tr -d '[:space:]')
  TMPL_REPO_URL=$(grep '^  url:' "$WS_CFG" | head -1 | sed 's/.*url:[[:space:]]*//; s/"//g' | tr -d '[:space:]')
  [ -z "$TMPL_LANGUAGE" ] && TMPL_LANGUAGE="en"
  [ -z "$TMPL_PROFILE" ] && TMPL_PROFILE="dev"
fi

render_ki_template() {
  local src="$1"
  local dest="$2"
  sed \
    -e "s|{{KERNEL_VERSION}}|${TMPL_KERNEL_VERSION}|g" \
    -e "s|{{LANGUAGE}}|${TMPL_LANGUAGE}|g" \
    -e "s|{{PROFILE}}|${TMPL_PROFILE}|g" \
    -e "s|{{WORKSPACE_CREATED}}|${TMPL_WORKSPACE_CREATED}|g" \
    -e "s|{{REPO_URL}}|${TMPL_REPO_URL}|g" \
    "$src" > "$dest"
}

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
      # v1.7.6: Compare RENDERED template (with vars substituted) vs KI store
      # to avoid false-positives from {{VAR}} vs rendered value differences
      if [ "$needs_upgrade" = false ]; then
        rendered_tmp=$(mktemp)
        render_ki_template "$tmpl_dir/metadata.json" "$rendered_tmp"
        tmpl_hash=$(get_hash "$rendered_tmp")
        ki_hash=$(get_hash "$ki_dest/metadata.json")
        rm -f "$rendered_tmp"
        if [ "$tmpl_hash" != "$ki_hash" ]; then
          needs_upgrade=true
        fi
      fi

      if [ "$needs_upgrade" = true ]; then
        # Override metadata.json from template (with variable substitution)
        render_ki_template "$tmpl_dir/metadata.json" "$ki_dest/metadata.json"

        # Override template artifacts (matching filenames only, with variable substitution)
        if [ -d "$tmpl_dir/artifacts" ]; then
          for art_file in "$tmpl_dir/artifacts"/*; do
            [ -f "$art_file" ] && render_ki_template "$art_file" "$ki_dest/artifacts/$(basename "$art_file")"
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
