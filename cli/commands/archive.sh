#!/bin/bash

# PARA Archive Tool (v1.4)
# Moves Projects/Areas/Resources to Archive/
# Usage: para archive <type>/<name> [--force]

set -e

# === Load Libraries ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../lib"

if [ -f "$LIB_DIR/fs.sh" ]; then
  source "$LIB_DIR/fs.sh"
fi

# === Cross-platform path normalization ===
normalize_path() {
  local p="$1"
  p="${p//\\//}"
  p="${p%/}"
  echo "$p"
}

# === Resolve workspace ===
if [ -n "$WORKSPACE_ROOT" ]; then
  WS_ROOT="$(normalize_path "$WORKSPACE_ROOT")"
elif [ -f ".para-workspace.yml" ]; then
  WS_ROOT="$(normalize_path "$(pwd)")"
else
  echo "❌ Error: Not in a PARA workspace."
  exit 1
fi

export WORKSPACE_ROOT="$WS_ROOT"

# Resolve pillar names
P_PROJECTS=$(get_para_dir projects)
P_AREAS=$(get_para_dir areas)
P_RESOURCES=$(get_para_dir resources)
P_ARCHIVE=$(get_para_dir archive)

# === Parse arguments ===
TARGET_PATH="${1:-}"
FORCE=false

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    --help|-h)
      echo "Usage: para archive <type>/<name> [--force]"
      echo ""
      echo "Moves the specified item to $P_ARCHIVE/."
      echo ""
      echo "Examples:"
      echo "  para archive $P_PROJECTS/my-old-app"
      echo "  para archive $P_AREAS/deprecated-sop"
      echo "  para archive $P_PROJECTS/done-project --force"
      exit 0
      ;;
  esac
done

if [ -z "$TARGET_PATH" ] || [[ "$TARGET_PATH" == --* ]]; then
  echo "Usage: para archive <type>/<name> [--force]"
  exit 1
fi

# Normalize the target path
TARGET_PATH="$(normalize_path "$TARGET_PATH")"

# Extract type and name
TYPE="$(dirname "$TARGET_PATH")"
NAME="$(basename "$TARGET_PATH")"

# Validate type
case "$TYPE" in
  "$P_PROJECTS"|"$P_AREAS"|"$P_RESOURCES") ;;
  *)
    echo "❌ Error: Can only archive from $P_PROJECTS/, $P_AREAS/, or $P_RESOURCES/."
    echo "   Got: $TYPE/$NAME"
    exit 1
    ;;
esac

SOURCE="$WS_ROOT/$TYPE/$NAME"
DEST="$WS_ROOT/$P_ARCHIVE/$TYPE/$NAME"

if [ ! -d "$SOURCE" ]; then
  echo "❌ Error: '$TYPE/$NAME' not found."
  exit 1
fi

if [ -d "$DEST" ]; then
  if [ "$FORCE" = true ]; then
    echo "⚠️  Archive destination exists. Overwriting (--force)."
    rm -rf "$DEST"
  else
    echo "❌ Error: '$TYPE/$NAME' already exists in $P_ARCHIVE."
    echo "   Use --force to overwrite."
    exit 1
  fi
fi

# Graduation review reminder (Invariant I7 — Beads lifecycle)
if [ -d "$SOURCE/.beads" ]; then
  BEADS_COUNT=$(find "$SOURCE/.beads" -type f -name "*.md" 2>/dev/null | wc -l)
  if [ "$BEADS_COUNT" -gt 0 ]; then
    echo ""
    echo "⚠️  Graduation Review Reminder!"
    echo "   This project has $BEADS_COUNT bead file(s) in .beads/"
    echo "   Consider extracting valuable knowledge to $P_AREAS/ or $P_RESOURCES/"
    echo "   before archiving."
    echo ""
    if [ "$FORCE" != true ]; then
      echo "   Use --force to skip this warning."
      exit 1
    fi
  fi
fi

echo "📦 Archiving: $TYPE/$NAME"

# Create archive directory
mkdir -p "$(dirname "$DEST")"

# Move to archive (Invariant I6 — Archive is cold storage)
mv "$SOURCE" "$DEST"

# Add archived date marker
echo "archived: $(date +%Y-%m-%d)" >> "$DEST/.archived"

echo "✅ Archived: $TYPE/$NAME → $P_ARCHIVE/$TYPE/$NAME"
echo ""
echo "Note: $P_ARCHIVE is cold storage (Invariant I6)."
echo "      Contents should not be modified after archiving."
