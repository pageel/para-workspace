#!/bin/bash

# PARA Workspace Installer
# Syncs kernel, workflows, rules, skills, and governance from repo to workspace
# Usage: para install [--force]

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

# === Parse arguments (help first, before env check) ===
FORCE=false
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    --help|-h)
      echo "Usage: para install [--force]"
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
      echo "  --force   Overwrite all files, even if local is newer"
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

# === Helper: backup file before overwriting ===
backup_file() {
  local file="$1"
  if [ -f "$file" ]; then
    local bak="${file}.bak"
    cp "$file" "$bak"
  fi
}

# === Helper: sync file if newer, with .bak backup ===
sync_file() {
  local src="$1"
  local dest="$2"

  local dest_dir
  dest_dir="$(dirname "$dest")"
  mkdir -p "$dest_dir"

  # Skip if same file (same inode)
  if [ -f "$src" ] && [ -f "$dest" ]; then
    local src_real dest_real
    src_real="$(cd "$(dirname "$src")" && pwd)/$(basename "$src")"
    dest_real="$(cd "$(dirname "$dest")" && pwd)/$(basename "$dest")"
    [ "$src_real" = "$dest_real" ] && return 0
  fi

  if [ "$FORCE" = true ] || [ ! -f "$dest" ] || [ "$src" -nt "$dest" ]; then
    if [ -f "$dest" ]; then
      if ! cmp -s "$src" "$dest"; then
        backup_file "$dest"
      fi
    fi
    cp "$src" "$dest"
    return 0
  fi
  return 1
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
    # Sync markdown files and subdirectories
    for item in "$src_dir"/*; do
      if [ -f "$item" ] && [[ "$item" == *.md ]]; then
        local fname="$(basename "$item")"
        count=$((count + 1))

        # Sync to catalog (read-only snapshot)
        sync_file "$item" "$catalog_dest/$fname" || true

        # Sync to active directory (user may customize)
        if sync_file "$item" "$active_dest/$fname"; then
          updated=$((updated + 1))
        fi
      elif [ -d "$item" ]; then
        local dname="$(basename "$item")"
        count=$((count + 1))
        mkdir -p "$catalog_dest/$dname"
        mkdir -p "$active_dest/$dname"
        
        for sub_item in "$item"/*; do
          if [ -f "$sub_item" ]; then
            local sub_fname="$(basename "$sub_item")"
            sync_file "$sub_item" "$catalog_dest/$dname/$sub_fname" || true
            if sync_file "$sub_item" "$active_dest/$dname/$sub_fname"; then
              updated=$((updated + 1))
            fi
          fi
        done
      fi
    done

    # Sync catalog.yml (v1.4.1)
    if [ -f "$src_dir/catalog.yml" ]; then
      sync_file "$src_dir/catalog.yml" "$catalog_dest/catalog.yml" || true
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
echo "  Mode:      $( [ "$FORCE" = true ] && echo "FORCE (overwrite all)" || echo "Smart (newer only)")"
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

echo "🧩 Syncing skills..."
sync_library "skills" \
  "$LIB_SRC/skills" \
  "$WS_ROOT/Resources/ai-agents/skills" \
  "$WS_ROOT/.agent/skills"

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
  sed -i "s/^kernel_version:.*/kernel_version: \"$KERNEL_VERSION\"/" "$WS_ROOT/.para-workspace.yml"
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
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Install & sync complete!"
echo ""
echo "  Kernel:    v$KERNEL_VERSION"
echo "  Libraries: workflows + rules + skills (with catalog.yml)"
echo "  State:     .para/ (audit.log active)"
echo ""
echo "💾 Backed-up files saved as .bak (if any were changed)."
echo "   To restore: mv <file>.bak <file>"
echo ""
echo "Try: ./para status"
