#!/bin/bash

# PARA Workspace Installer (v1.4)
# Syncs kernel, workflows, and governance from repo to workspace
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
REPO_ROOT="$(normalize_path "$(cd "$SCRIPT_DIR/.." && pwd)")"

if [ -n "$WORKSPACE_ROOT" ]; then
  WS_ROOT="$(normalize_path "$WORKSPACE_ROOT")"
else
  echo "❌ Error: WORKSPACE_ROOT not set."
  exit 1
fi

# === Parse arguments ===
FORCE=false
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    --help|-h)
      echo "Usage: para install [--force]"
      echo ""
      echo "Syncs kernel, workflows, and governance from repo to workspace."
      echo ""
      echo "Options:"
      echo "  --force   Overwrite all files, even if local is newer"
      exit 0
      ;;
  esac
done

# === Helper: sync file if newer ===
sync_file() {
  local src="$1"
  local dest="$2"

  # Skip if same file
  if [ -f "$src" ] && [ -f "$dest" ]; then
    local src_real dest_real
    src_real="$(cd "$(dirname "$src")" && pwd)/$(basename "$src")"
    dest_real="$(cd "$(dirname "$dest")" && pwd)/$(basename "$dest")"
    [ "$src_real" = "$dest_real" ] && return 0
  fi

  if [ "$FORCE" = true ] || [ ! -f "$dest" ] || [ "$src" -nt "$dest" ]; then
    cp "$src" "$dest"
    return 0
  fi
  return 1
}

echo "🚀 PARA Workspace Install (v1.4)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Repo:      $REPO_ROOT"
echo "  Workspace: $WS_ROOT"
echo "  Mode:      $( [ "$FORCE" = true ] && echo "FORCE (overwrite all)" || echo "Smart (newer only)")"
echo ""

# === 1. Make all CLI scripts executable ===
echo "🔧 Setting permissions..."
for f in "$SCRIPT_DIR"/*.sh; do
  [ -f "$f" ] && chmod +x "$f"
done
chmod +x "$REPO_ROOT/para" 2>/dev/null || true
echo "   ✓ CLI scripts executable"

# === 2. Install kernel snapshot ===
echo "🧠 Syncing kernel..."
KERNEL_SRC="$REPO_ROOT/kernel"
KERNEL_DEST="$WS_ROOT/Resources/ai-agents/kernel"
mkdir -p "$KERNEL_DEST"

updated=0
if [ -d "$KERNEL_SRC" ]; then
  # Sync all kernel files recursively
  find "$KERNEL_SRC" -type f | while read -r src_file; do
    rel_path="${src_file#$KERNEL_SRC/}"
    dest_file="$KERNEL_DEST/$rel_path"
    dest_dir="$(dirname "$dest_file")"
    mkdir -p "$dest_dir"
    if sync_file "$src_file" "$dest_file"; then
      updated=$((updated + 1))
    fi
  done
fi

KERNEL_VERSION="$(cat "$REPO_ROOT/VERSION" 2>/dev/null || echo "1.4.0")"
echo "$KERNEL_VERSION" > "$WS_ROOT/Resources/ai-agents/VERSION"
echo "   ✓ Kernel v$KERNEL_VERSION synced"

# === 3. Install workflow catalog ===
echo "📑 Syncing workflows..."
WF_SRC="$REPO_ROOT/workflows"
WF_CATALOG="$WS_ROOT/Resources/ai-agents/workflows"
WF_ACTIVE="$WS_ROOT/.agent/workflows"
mkdir -p "$WF_CATALOG"
mkdir -p "$WF_ACTIVE"

wf_count=0
if [ -d "$WF_SRC" ]; then
  for f in "$WF_SRC"/*.md; do
    if [ -f "$f" ]; then
      fname="$(basename "$f")"
      sync_file "$f" "$WF_CATALOG/$fname"
      sync_file "$f" "$WF_ACTIVE/$fname"
      wf_count=$((wf_count + 1))
    fi
  done
fi
echo "   ✓ $wf_count workflows synced"

# === 4. Install agent governance ===
echo "🤖 Syncing governance rules..."
mkdir -p "$WS_ROOT/.agent/rules"
GOV_SRC="$REPO_ROOT/templates/common/agent/governance.md"
if [ -f "$GOV_SRC" ]; then
  sync_file "$GOV_SRC" "$WS_ROOT/.agent/rules/governance.md"
fi
echo "   ✓ Governance rules synced"

# === 5. Install root 'para' wrapper ===
echo "📦 Installing workspace 'para' wrapper..."
cat > "$WS_ROOT/para" <<'WRAPPER'
#!/bin/bash
# PARA Workspace CLI Wrapper (Auto-generated)
# Usage: ./para [command] [args...]

WS_ROOT="$(cd "$(dirname "$0")" && pwd)"
export WORKSPACE_ROOT="$WS_ROOT"

# Find repo location from .para-workspace.yml or known locations
REPO_CLI=""
for candidate in \
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
  echo "  $WS_ROOT/Projects/para-workspace/repo/"
  exit 1
fi

"$REPO_CLI" "$@"
WRAPPER
chmod +x "$WS_ROOT/para"
echo "   ✓ Wrapper installed at $WS_ROOT/para"

# === Done ===
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Install & sync complete!"
echo ""
echo "  Kernel:    v$KERNEL_VERSION"
echo "  Workflows: $wf_count files"
echo ""
echo "Try: ./para status"
