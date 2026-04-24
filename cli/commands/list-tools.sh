#!/bin/bash
# PARA Workspace — List Installed Tools
# Usage: ./para list-tools [--json]
#
# Scans .para/tools/ for installed tool plugins and displays status.

set -e

# === Resolve paths ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Workspace Root (inherited from parent CLI)
if [ -z "$WORKSPACE_ROOT" ]; then
  echo "❌ Error: WORKSPACE_ROOT not set. Run this via './para list-tools'."
  exit 1
fi

TOOLS_DIR="$WORKSPACE_ROOT/.para/tools"

# === Parse arguments ===
JSON_MODE=false

for arg in "$@"; do
  case "$arg" in
    --json)
      JSON_MODE=true
      ;;
    --help|-h)
      echo "Usage: para list-tools [--json]"
      echo ""
      echo "  --json    Output as JSON array"
      echo ""
      echo "Lists all installed PARA tool plugins."
      exit 0
      ;;
  esac
done

# === Scan installed tools ===
if [ ! -d "$TOOLS_DIR" ]; then
  if [ "$JSON_MODE" = true ]; then
    echo "[]"
  else
    echo "📦 No tools installed."
    echo ""
    echo "To install a tool:"
    echo "  ./para install-tool <name>"
    echo ""
    echo "Example:"
    echo "  ./para install-tool para-graph"
  fi
  exit 0
fi

# Find all manifests
MANIFESTS="$(find "$TOOLS_DIR" -maxdepth 2 -name "tool.manifest.yml" 2>/dev/null || true)"

if [ -z "$MANIFESTS" ]; then
  if [ "$JSON_MODE" = true ]; then
    echo "[]"
  else
    echo "📦 No tools installed."
    echo ""
    echo "To install a tool:"
    echo "  ./para install-tool <name>"
  fi
  exit 0
fi

# === Parse and display ===
parse_manifest_field() {
  local file="$1"
  local field="$2"
  grep "^${field}:" "$file" 2>/dev/null \
    | head -1 \
    | sed "s/^${field}: *//; s/^ *\"//; s/\" *$//; s/^ *'//; s/' *$//"
}

if [ "$JSON_MODE" = true ]; then
  # JSON output
  echo "["
  FIRST=true
  echo "$MANIFESTS" | while read -r manifest; do
    if [ "$FIRST" = true ]; then
      FIRST=false
    else
      echo ","
    fi
    NAME="$(parse_manifest_field "$manifest" "name")"
    VERSION="$(parse_manifest_field "$manifest" "version")"
    RUNTIME="$(parse_manifest_field "$manifest" "runtime")"
    printf '  {"name":"%s","version":"%s","runtime":"%s"}' "$NAME" "$VERSION" "$RUNTIME"
  done
  echo ""
  echo "]"
else
  # Table output
  echo "📦 Installed PARA Tools"
  echo ""
  printf "  %-20s %-12s %-10s %s\n" "Name" "Version" "Runtime" "Status"
  printf "  %-20s %-12s %-10s %s\n" "────────────────────" "────────────" "──────────" "──────"

  echo "$MANIFESTS" | while read -r manifest; do
    NAME="$(parse_manifest_field "$manifest" "name")"
    VERSION="$(parse_manifest_field "$manifest" "version")"
    RUNTIME="$(parse_manifest_field "$manifest" "runtime")"
    ENTRY="$(parse_manifest_field "$manifest" "entry")"

    # Check Dev path
    TOOL_SHORT="${NAME#para-}"
    DEV_PATH="$WORKSPACE_ROOT/Projects/$NAME/repo/$ENTRY"
    if [ -f "$DEV_PATH" ]; then
      STATUS="🟢 Dev"
    else
      STATUS="📦 Prod"
    fi

    printf "  %-20s %-12s %-10s %s\n" "$NAME" "v$VERSION" "$RUNTIME" "$STATUS"
  done

  echo ""
fi
