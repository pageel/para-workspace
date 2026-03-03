#!/bin/bash

# PARA Workspace Initializer (v1.4.1)
# Creates a new workspace from repo + profile + language
# Usage: para init [--profile=dev] [--lang=en] [--path=./my-workspace]

set -e

# === Cross-platform path normalization ===
# Fix Windows/PowerShell backslash paths and trailing separators
normalize_path() {
  local p="$1"
  # Convert backslashes to forward slashes (Windows/PowerShell compat)
  p="${p//\\//}"
  # Remove trailing slash (except root /)
  p="${p%/}"
  echo "$p"
}

# === Resolve script and repo locations ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(normalize_path "$(cd "$SCRIPT_DIR/../.." && pwd)")"

# === Parse arguments ===
PROFILE="general"
LANG_PREF="en"
TARGET_PATH=""

for arg in "$@"; do
  case "$arg" in
    --profile=*)  PROFILE="${arg#--profile=}" ;;
    --lang=*)     LANG_PREF="${arg#--lang=}" ;;
    --path=*)     TARGET_PATH="$(normalize_path "${arg#--path=}")" ;;
    --help|-h)
      echo "Usage: para init [options]"
      echo ""
      echo "Options:"
      echo "  --profile=NAME   Workspace profile (general, dev, marketer, ceo)"
      echo "  --lang=CODE      Language preference (en, vi)"
      echo "  --path=DIR       Target directory (default: current dir)"
      echo ""
      echo "Examples:"
      echo "  para init --profile=dev --lang=en"
      echo "  para init --profile=dev --path=./my-workspace"
      exit 0
      ;;
  esac
done

# Default target path
if [ -z "$TARGET_PATH" ]; then
  TARGET_PATH="$(pwd)"
fi

# Ensure target is absolute
case "$TARGET_PATH" in
  /*) ;; # Already absolute
  *)  TARGET_PATH="$(pwd)/$TARGET_PATH" ;;
esac
TARGET_PATH="$(normalize_path "$TARGET_PATH")"

# === Validate profile ===
PROFILE_DIR="$REPO_ROOT/templates/profiles/$PROFILE"
if [ ! -f "$PROFILE_DIR/preset.yaml" ]; then
  echo "❌ Error: Profile '$PROFILE' not found."
  echo "Available profiles:"
  for p in "$REPO_ROOT/templates/profiles"/*/; do
    pname="$(basename "$p")"
    echo "  - $pname"
  done
  exit 1
fi

# === Safety check ===
if [ -f "$TARGET_PATH/.para-workspace.yml" ]; then
  echo "⚠️  A PARA workspace already exists at $TARGET_PATH"
  echo "Use 'para install' to update, or remove .para-workspace.yml to reinitialize."
  exit 1
fi

echo "🚀 Initializing PARA Workspace"
echo "   Profile: $PROFILE"
echo "   Language: $LANG_PREF"
echo "   Path: $TARGET_PATH"
echo ""

# === Create workspace structure ===
mkdir -p "$TARGET_PATH"

# Create PARA directories from profile
echo "📁 Creating directory structure..."
# Parse 'creates:' from preset.yaml (simple line-by-line parser, no yq dependency)
while IFS= read -r line; do
  # Match lines like "  - Areas/infra/" or "  - Projects/"
  if echo "$line" | grep -qE '^\s*-\s+'; then
    dir="$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*//')"
    dir="$(normalize_path "$dir")"
    if [ -n "$dir" ]; then
      mkdir -p "$TARGET_PATH/$dir"
      echo "   ✓ $dir"
    fi
  fi
done < <(sed -n '/^creates:/,/^[a-z]/p' "$PROFILE_DIR/preset.yaml" | sed '$d')

# Fallback: ensure PARA dirs always exist (invariant I1)
mkdir -p "$TARGET_PATH/Projects"
mkdir -p "$TARGET_PATH/Areas"
mkdir -p "$TARGET_PATH/Resources"
mkdir -p "$TARGET_PATH/Archive"
mkdir -p "$TARGET_PATH/_inbox"

# === Set executable permissions on all CLI scripts (BUG-01 fix) ===
echo "🔧 Setting CLI permissions..."
for f in "$SCRIPT_DIR"/*.sh; do
  [ -f "$f" ] && chmod +x "$f"
done
chmod +x "$SCRIPT_DIR/../para" 2>/dev/null || true
echo "   ✓ CLI scripts are executable"

KERNEL_VERSION="$(cat "$REPO_ROOT/VERSION" 2>/dev/null || echo "1.4.0")"

# === Generate .para-workspace.yml ===
echo "⚙️  Generating .para-workspace.yml..."
cat > "$TARGET_PATH/.para-workspace.yml" <<EOL
# PARA Workspace Configuration
# Generated: $(date +%Y-%m-%d)

kernel_version: "$KERNEL_VERSION"
profile: "$PROFILE"
language: "$LANG_PREF"

# Repo source for updates
repo:
  url: "https://github.com/pageel/para-workspace"
  branch: "main"

# Workspace metadata
workspace:
  version: "1.0.0"
  created: "$(date +%Y-%m-%d)"
EOL
echo "   ✓ .para-workspace.yml created"

# === Create .para/ system state (v1.4.1) ===
echo "🔒 Creating system state..."
mkdir -p "$TARGET_PATH/.para/migrations"
mkdir -p "$TARGET_PATH/.para/backups"
echo "$(date -Iseconds 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S%z") | SYSTEM | para init | profile=$PROFILE kernel=$KERNEL_VERSION | INIT" > "$TARGET_PATH/.para/audit.log"
echo "   ✓ .para/ initialized"

# === Run full install (kernel, workflows, rules, skills, para wrapper) ===
echo ""
echo "📦 Running full install..."
export WORKSPACE_ROOT="$TARGET_PATH"
bash "$SCRIPT_DIR/install.sh"

# === Done ===
echo ""
echo "🎉 PARA Workspace initialized successfully!"
echo ""
echo "   📂 Location: $TARGET_PATH"
echo "   🎭 Profile:  $PROFILE"
echo "   🌐 Language: $LANG_PREF"
echo "   🧠 Kernel:   v$KERNEL_VERSION"
echo ""
echo "Next steps:"
echo "  cd $(basename "$TARGET_PATH")"
echo "  ./para scaffold project my-first-project"
