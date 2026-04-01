#!/bin/bash

# PARA Workspace Installer
# Syncs kernel, workflows, rules, skills, and governance from repo to workspace
# Usage: para install [--force] [--dry-run]

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

# === Load libraries ===
if [ -f "$LIB_DIR/logger.sh" ]; then
  source "$LIB_DIR/logger.sh"
fi
if [ -f "$LIB_DIR/rollback.sh" ]; then
  source "$LIB_DIR/rollback.sh"
fi

# === Parse arguments (help first, before env check) ===
FORCE=false
DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    --dry-run) DRY_RUN=true ;;
    --help|-h)
      echo "Usage: para install [--force] [--dry-run]"
      echo ""
      echo "Syncs kernel, workflows, rules, skills, and governance from repo to workspace."
      echo ""
      echo "What gets installed:"
      echo "  🧠 Kernel snapshot    → Resources/ai-agents/kernel/"
      echo "  📑 Workflows + catalog→ Resources/ai-agents/workflows/ + .agent/workflows/"
      echo "  📏 Rules + catalog    → Resources/ai-agents/rules/ + .agent/rules/"
      echo "  🧩 Skills + catalog   → Resources/ai-agents/skills/ + .agent/skills/"
      echo "  🔒 System state       → .para/ (audit.log, migrations/, backups/)"
      echo "  📦 CLI wrapper        → ./para"
      echo ""
      echo "Options:"
      echo "  --force     Overwrite all files, even if local is newer"
      echo "  --dry-run   Preview changes without applying"
      echo ""
      echo "Existing files are backed up to .bak before overwriting."
      exit 0
      ;;
  esac
done

if [ -n "$WORKSPACE_ROOT" ]; then
  WS_ROOT="$(normalize_path "$WORKSPACE_ROOT")"
else
  echo "❌ Error: WORKSPACE_ROOT not set."
  exit 1
fi

# === Rollback & error handling ===
cleanup_on_error() {
  local exit_code=$?
  if [ $exit_code -ne 0 ]; then
    echo ""
    echo "❌ Install failed (exit $exit_code). Rolling back changes..."
    if command -v rollback_execute &>/dev/null; then
      rollback_execute
    fi
    if command -v log_audit &>/dev/null; then
      log_audit "CLI" "para install" "kernel=${KERNEL_VERSION:-unknown}" "ROLLBACK"
    fi
    echo ""
    echo "⚠️  All modified files have been restored to their previous state."
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
      echo "💡 Windows: If restore failed, close all terminals and re-run: para install"
    fi
  fi
}

if [ "$DRY_RUN" = false ]; then
  if command -v rollback_init &>/dev/null; then
    rollback_init
  fi
  trap cleanup_on_error EXIT
fi

# === Helper: backup file before overwriting ===
backup_file() {
  local file="$1"
  if [ -f "$file" ]; then
    local today
    today="$(date +%Y-%m-%d)"
    local backup_dir="$WS_ROOT/.para/backups/$today"
    mkdir -p "$backup_dir"
    # Flatten path: remove workspace prefix, replace / with _
    local flat_name
    flat_name="$(echo "$file" | sed "s|^$WS_ROOT/||; s|/|_|g")"
    if ! cp "$file" "$backup_dir/$flat_name" 2>/dev/null; then
      echo "   ⚠️  Could not backup $file (file may be locked)"
    fi
  fi
}

# === Helper: sync file if newer, with .bak backup ===
sync_file() {
  local src="$1"
  local dest="$2"

  local dest_dir
  dest_dir="$(dirname "$dest")"
  if [ "$DRY_RUN" = true ]; then
    [ ! -d "$dest_dir" ] && echo "     → Would create: $dest_dir"
  else
    mkdir -p "$dest_dir"
  fi

  # Skip if same file (same inode)
  if [ -f "$src" ] && [ -f "$dest" ]; then
    local src_real dest_real
    src_real="$(cd "$(dirname "$src")" && pwd)/$(basename "$src")"
    dest_real="$(cd "$(dirname "$dest")" && pwd)/$(basename "$dest")"
    [ "$src_real" = "$dest_real" ] && return 0
  fi

  if [ "$FORCE" = true ] || [ ! -f "$dest" ] || [ "$src" -nt "$dest" ]; then
    if [ "$DRY_RUN" = true ]; then
      echo "     → Would sync: $(basename "$src")"
      return 0
    fi
    if [ -f "$dest" ]; then
      if ! cmp -s "$src" "$dest"; then
        # Register for atomic rollback before backup
        if command -v rollback_register &>/dev/null; then
          rollback_register "$dest"
        fi
        backup_file "$dest"
      fi
    fi
    cp "$src" "$dest"
    return 0
  fi
  return 1
}

# === Helper: recursively sync all files within a directory tree ===
# Handles arbitrarily nested subdirectories (v1.6.4)
# Skips catalog.yml (handled separately by sync_library caller)
# NOTE: `count` and `updated` variables are accessed via bash dynamic scoping
# from the parent sync_library() function which declares them as `local`.
sync_directory_recursive() {
  local src_dir="$1"
  local catalog_dest="$2"
  local active_dest="$3"

  for item in "$src_dir"/*; do
    [ -e "$item" ] || continue  # guard against empty glob

    if [ -f "$item" ]; then
      local fname
      fname="$(basename "$item")"
      # Skip catalog.yml — handled separately in sync_library()
      [[ "$fname" == "catalog.yml" ]] && continue
      count=$((count + 1))
      sync_file "$item" "$catalog_dest/$fname" || true
      if sync_file "$item" "$active_dest/$fname"; then
        updated=$((updated + 1))
      fi
    elif [ -d "$item" ]; then
      local dname
      dname="$(basename "$item")"
      mkdir -p "$catalog_dest/$dname" "$active_dest/$dname"
      # Recurse into subdirectory
      sync_directory_recursive "$item" "$catalog_dest/$dname" "$active_dest/$dname"
    fi
  done
}

# === Helper: sync a governed library (workflows/rules/skills) ===
sync_library() {
  local lib_name="$1"    # e.g. "workflows"
  local src_dir="$2"     # e.g. "$REPO_ROOT/templates/common/agent/workflows"
  local catalog_dest="$3" # e.g. "$WS_ROOT/Resources/ai-agents/workflows"
  local active_dest="$4"  # e.g. "$WS_ROOT/.agent/workflows"

  mkdir -p "$catalog_dest"
  mkdir -p "$active_dest"

  local count=0
  local updated=0

  if [ -d "$src_dir" ]; then
    # Recursively sync all files and subdirectories (v1.6.4)
    sync_directory_recursive "$src_dir" "$catalog_dest" "$active_dest"

    # Sync catalog.yml to catalog only (not to active — it's metadata)
    if [ -f "$src_dir/catalog.yml" ]; then
      sync_file "$src_dir/catalog.yml" "$catalog_dest/catalog.yml" || true
    fi

    # === Orphan cleanup (BUG-27, v1.7.0) ===
    # Remove governed files that no longer exist in repo templates.
    # Strategy: catalog_dest (Resources/ai-agents/X/) is 100% repo-managed.
    # If a file exists there but NOT in repo → it's an orphan from a previous sync.
    # Then also clean the matching file from active_dest (.agent/X/) if it exists
    # AND is not user-created.
    local orphan_count=0
    for catalog_file in "$catalog_dest"/*.md; do
      [ -f "$catalog_file" ] || continue
      local cf_name
      cf_name="$(basename "$catalog_file")"

      # Skip if file still exists in repo template → not orphan
      [ -f "$src_dir/$cf_name" ] && continue

      # Orphan found in catalog_dest → remove
      if [ "$DRY_RUN" = true ]; then
        echo "     → Would remove orphan: $cf_name (catalog)"
      else
        backup_file "$catalog_file"
        rm "$catalog_file"
      fi

      # Also clean from active_dest, but ONLY if not user-created
      local active_file="$active_dest/$cf_name"
      if [ -f "$active_file" ]; then
        # Skip if user-created (has source: user header)
        if grep -q 'source:[[:space:]]*user' "$active_file" 2>/dev/null; then
          continue
        fi
        if [ "$DRY_RUN" = true ]; then
          echo "     → Would remove orphan: $cf_name (active)"
        else
          backup_file "$active_file"
          rm "$active_file"
        fi
      fi

      orphan_count=$((orphan_count + 1))
    done

    if [ "$orphan_count" -gt 0 ]; then
      echo "   🧹 $orphan_count orphan(s) cleaned from $lib_name"
    fi
  fi

  echo "   ✓ $count $lib_name synced ($updated updated)"
}

KERNEL_VERSION="$(cat "$REPO_ROOT/VERSION" 2>/dev/null || echo "1.4.1")"

echo "🚀 PARA Workspace Install (v$KERNEL_VERSION)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Repo:      $REPO_ROOT"
echo "  Workspace: $WS_ROOT"
echo "  Kernel:    v$KERNEL_VERSION"
if [ "$DRY_RUN" = true ]; then
  echo "  Mode:      DRY RUN (preview only)"
elif [ "$FORCE" = true ]; then
  echo "  Mode:      FORCE (overwrite all)"
else
  echo "  Mode:      Smart (newer only)"
fi
echo ""

# === 1. Make all CLI scripts executable ===
echo "🔧 Setting permissions..."
for f in "$SCRIPT_DIR"/*.sh; do
  [ -f "$f" ] && chmod +x "$f"
done
chmod +x "$SCRIPT_DIR/../para" 2>/dev/null || true
chmod +x "$REPO_ROOT/para" 2>/dev/null || true
echo "   ✓ CLI scripts executable"

# === 2. Install kernel snapshot ===
echo "🧠 Syncing kernel..."
KERNEL_SRC="$REPO_ROOT/kernel"
KERNEL_DEST="$WS_ROOT/Resources/ai-agents/kernel"
mkdir -p "$KERNEL_DEST"

kernel_updated=0
kernel_total=0
if [ -d "$KERNEL_SRC" ]; then
  while IFS= read -r src_file; do
    rel_path="${src_file#$KERNEL_SRC/}"
    dest_file="$KERNEL_DEST/$rel_path"
    kernel_total=$((kernel_total + 1))
    if sync_file "$src_file" "$dest_file"; then
      kernel_updated=$((kernel_updated + 1))
    fi
  done < <(find "$KERNEL_SRC" -type f)
fi

echo "$KERNEL_VERSION" > "$WS_ROOT/Resources/ai-agents/VERSION"
echo "   ✓ Kernel v$KERNEL_VERSION synced ($kernel_updated/$kernel_total files updated)"

# === 3. Sync governed libraries (v1.4.1) ===
LIB_SRC="$REPO_ROOT/templates/common/agent"

echo "📑 Syncing workflows..."
sync_library "workflows" \
  "$LIB_SRC/workflows" \
  "$WS_ROOT/Resources/ai-agents/workflows" \
  "$WS_ROOT/.agent/workflows"

echo "📏 Syncing rules..."
sync_library "rules" \
  "$LIB_SRC/rules" \
  "$WS_ROOT/Resources/ai-agents/rules" \
  "$WS_ROOT/.agent/rules"

# Sync workspace rules index (rules.md sits OUTSIDE rules/ directory)
if [ -f "$LIB_SRC/rules.md" ]; then
  if sync_file "$LIB_SRC/rules.md" "$WS_ROOT/.agent/rules.md"; then
    echo "   ✓ Workspace rules index synced (.agent/rules.md)"
  fi
fi

echo "🧩 Syncing skills..."
sync_library "skills" \
  "$LIB_SRC/skills" \
  "$WS_ROOT/Resources/ai-agents/skills" \
  "$WS_ROOT/.agent/skills"

# Sync workspace skills index (skills.md sits OUTSIDE skills/ directory)
if [ -f "$LIB_SRC/skills.md" ]; then
  if sync_file "$LIB_SRC/skills.md" "$WS_ROOT/.agent/skills.md"; then
    echo "   ✓ Workspace skills index synced (.agent/skills.md)"
  fi
fi

# === 4. Sync governance file ===
# (Luật governance.md giờ đã được cấp phát qua catalog thư viện rules ở Bước 3. Không cần sync cứng nữa).

# === 5. Initialize .para/ system state (v1.4.1) ===
echo "🔒 Initializing system state..."
PARA_STATE="$WS_ROOT/.para"
mkdir -p "$PARA_STATE/migrations"
mkdir -p "$PARA_STATE/backups"
if [ ! -f "$PARA_STATE/audit.log" ]; then
  echo "$(date -Iseconds 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S%z") | SYSTEM | para install | kernel=$KERNEL_VERSION | INIT" > "$PARA_STATE/audit.log"
  echo "   ✓ .para/ created (audit.log, migrations/, backups/)"
else
  echo "$(date -Iseconds 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S%z") | SYSTEM | para install | kernel=$KERNEL_VERSION | SYNC" >> "$PARA_STATE/audit.log"
  echo "   ✓ .para/ exists (audit.log updated)"
fi

if [ -f "$WS_ROOT/.para-workspace.yml" ]; then
  sed "s/^kernel_version:.*/kernel_version: \"$KERNEL_VERSION\"/" "$WS_ROOT/.para-workspace.yml" > "$WS_ROOT/.para-workspace.yml.tmp" && mv "$WS_ROOT/.para-workspace.yml.tmp" "$WS_ROOT/.para-workspace.yml"
  echo "   ✓ .para-workspace.yml updated to v$KERNEL_VERSION"
fi

# === 6. Validate kernel compatibility (v1.4.1) ===
if [ -f "$LIB_DIR/validator.sh" ]; then
  echo "🔍 Validating library compatibility..."
  source "$LIB_DIR/validator.sh"
  validate_all_catalogs "$LIB_SRC" "$KERNEL_VERSION" || true
fi

# === 7. Install root 'para' wrapper ===
# Skip if workspace is the repo itself (prevents para.bak and overwriting dev para)
if [ "$WS_ROOT" = "$REPO_ROOT" ]; then
  echo "📦 Skipping workspace wrapper (Repo mode)..."
  echo "   (Detected dev repo as workspace, keeping original 'para' executable)"
else
  echo "📦 Installing workspace 'para' wrapper..."

  # Generate content to a temp file first for atomic-like movement
  TEMP_WRAPPER=$(mktemp 2>/dev/null || echo "$WS_ROOT/para.tmp")
  cat > "$TEMP_WRAPPER" <<'WRAPPER'
#!/bin/bash
# PARA Workspace CLI Wrapper (Auto-generated)
# Usage: ./para [command] [args...]

WS_ROOT="$(cd "$(dirname "$0")" && pwd)"
export WORKSPACE_ROOT="$WS_ROOT"

# Find repo location from known paths
REPO_CLI=""
for candidate in \
  "$WS_ROOT/Resources/references/para-workspace/cli/para" \
  "$WS_ROOT/Projects/para-workspace/repo/cli/para" \
  "$WS_ROOT/.para-repo/cli/para" \
  "$(command -v para 2>/dev/null)"; do
  if [ -f "$candidate" ] && [ -x "$candidate" ]; then
    REPO_CLI="$candidate"
    break
  fi
done

if [ -z "$REPO_CLI" ]; then
  echo "❌ Error: Could not find PARA CLI."
  echo "Make sure the para-workspace repo is available at:"
  echo "  $WS_ROOT/Resources/references/para-workspace/"
  exit 1
fi

"$REPO_CLI" "$@"
WRAPPER

  if [ -f "$WS_ROOT/para" ]; then
    # Only backup and overwrite if content is actually different
    if ! cmp -s "$WS_ROOT/para" "$TEMP_WRAPPER"; then
      # On Windows, overwriting a running script is tricky. 
      # We try to backup first. If cp fails, the script continues.
      backup_file "$WS_ROOT/para"
      if cp "$TEMP_WRAPPER" "$WS_ROOT/para" 2>/dev/null; then
        chmod +x "$WS_ROOT/para"
        echo "   ✓ Wrapper updated at $WS_ROOT/para"
      else
        echo "   ⚠️  Could not update running wrapper (File locked). Please run 'para install' again later."
      fi
    else
      echo "   ✓ Wrapper is already up to date"
    fi
  else
    cp "$TEMP_WRAPPER" "$WS_ROOT/para"
    chmod +x "$WS_ROOT/para"
    echo "   ✓ Wrapper installed at $WS_ROOT/para"
  fi
  rm "$TEMP_WRAPPER" 2>/dev/null || true
fi

# === Done ===

# Remove error trap and commit rollback session (success path)
if [ "$DRY_RUN" = false ]; then
  trap - EXIT
  if command -v rollback_commit &>/dev/null; then
    rollback_commit
  fi
  if command -v log_audit &>/dev/null; then
    log_audit "CLI" "para install" "kernel=$KERNEL_VERSION" "OK"
  fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ "$DRY_RUN" = true ]; then
  echo "🔍 Dry run complete. No changes were made."
  echo "   Remove --dry-run to apply the installation."
else
  echo "🎉 Install & sync complete!"
  echo ""
  echo "  Kernel:    v$KERNEL_VERSION"
  echo "  Libraries: workflows + rules + skills (with catalog.yml)"
  echo "  State:     .para/ (audit.log active)"
  echo ""
  echo "💾 Backups saved to .para/backups/ (if any files were changed)."
  echo "   Run './para cleanup' to remove old backups."
  echo ""
  echo "Try: ./para status"
fi
