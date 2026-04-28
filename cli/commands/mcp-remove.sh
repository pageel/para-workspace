#!/bin/bash
# PARA Workspace — MCP Remove
# Usage: ./para mcp-remove <tool-name> [--ide=<name>]
#
# Removes an MCP server entry from IDE config file.

set -e

# === Resolve paths ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLI_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -z "$WORKSPACE_ROOT" ]; then
  echo "❌ Error: WORKSPACE_ROOT not set. Run this via './para mcp-remove'."
  exit 1
fi

# Source shared library
source "$CLI_DIR/lib/mcp-config.sh"

# === Parse arguments ===
TOOL_INPUT=""
IDE_TARGET=""

for arg in "$@"; do
  case "$arg" in
    --ide=*)
      IDE_TARGET="${arg#--ide=}"
      ;;
    --help|-h)
      echo "Usage: para mcp-remove <tool-name> [--ide=<name>]"
      echo ""
      echo "  <tool-name>   Tool name (e.g., 'para-graph' or 'graph')"
      echo "  --ide=<name>  Target IDE: antigravity, claude, cursor"
      echo ""
      echo "Removes the MCP server entry from the IDE config file."
      exit 0
      ;;
    -*)
      echo "❌ Error: Unknown option '$arg'"
      exit 1
      ;;
    *)
      if [ -z "$TOOL_INPUT" ]; then
        TOOL_INPUT="$arg"
      else
        echo "❌ Error: Too many arguments."
        exit 1
      fi
      ;;
  esac
done

if [ -z "$TOOL_INPUT" ]; then
  echo "❌ Error: Missing tool name."
  echo "Usage: para mcp-remove <tool-name> [--ide=<name>]"
  exit 1
fi

# === Normalize tool name ===
if echo "$TOOL_INPUT" | grep -q "^para-"; then
  TOOL_NAME="${TOOL_INPUT#para-}"
  PARA_TOOL_NAME="$TOOL_INPUT"
else
  TOOL_NAME="$TOOL_INPUT"
  PARA_TOOL_NAME="para-$TOOL_INPUT"
fi

# Determine server_name (same as tool short name or from manifest)
SERVER_NAME="$PARA_TOOL_NAME"

# Try to read from manifest for exact server_name
for manifest in \
  "$WORKSPACE_ROOT/Projects/$PARA_TOOL_NAME/repo/tool.manifest.yml" \
  "$WORKSPACE_ROOT/.para/tools/$TOOL_NAME/tool.manifest.yml"; do
  if [ -f "$manifest" ] && grep -q "^mcp:" "$manifest" 2>/dev/null; then
    local_name=$(sed -n '/^mcp:/,/^[a-z]/p' "$manifest" | grep '  server_name:' | head -1 | sed 's/.*server_name: *//; s/^ *"//; s/" *$//')
    if [ -n "$local_name" ]; then
      SERVER_NAME="$local_name"
      break
    fi
  fi
done

# === IDE selection ===
if [ -z "$IDE_TARGET" ]; then
  DETECTED_IDES=$(detect_installed_ides)
  if [ -z "$DETECTED_IDES" ]; then
    echo "⚠️  No supported IDE configs detected."
    exit 1
  fi

  echo "Detected IDEs:"
  idx=1
  for ide in $DETECTED_IDES; do
    config_path=$(resolve_ide_config_path "$ide")
    echo "  [$idx] $ide → $config_path"
    idx=$((idx + 1))
  done
  echo ""
  printf "Select IDE (number): "
  read -r ide_choice

  idx=1
  for ide in $DETECTED_IDES; do
    if [ "$idx" = "$ide_choice" ]; then
      IDE_TARGET="$ide"
      break
    fi
    idx=$((idx + 1))
  done

  if [ -z "$IDE_TARGET" ]; then
    echo "❌ Invalid selection."
    exit 1
  fi
fi

# === Remove from config ===
CONFIG_PATH=$(resolve_ide_config_path "$IDE_TARGET")

if [ ! -f "$CONFIG_PATH" ]; then
  echo "⚠️  Config file not found: $CONFIG_PATH"
  echo "   Nothing to remove."
  exit 0
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
  echo "⚠️  jq is not installed — cannot auto-remove."
  echo ""
  echo "   Please manually remove the '$SERVER_NAME' entry from:"
  echo "   $CONFIG_PATH"
  exit 1
fi

# Check if server exists in config
if ! jq -e ".mcpServers.\"$SERVER_NAME\"" "$CONFIG_PATH" &>/dev/null; then
  echo "⚠️  Server '$SERVER_NAME' not found in config."
  echo "   File: $CONFIG_PATH"
  exit 0
fi

# Confirm removal
echo ""
echo "🔌 Remove MCP server '$SERVER_NAME' from $IDE_TARGET?"
echo "   File: $CONFIG_PATH"
printf "   Confirm? (y/n): "
read -r confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
  echo "   Cancelled."
  exit 0
fi

# Backup before removal
backup_config "$CONFIG_PATH"

# Remove using jq — atomic write
tmp_file=$(mktemp)
if jq "del(.mcpServers.\"$SERVER_NAME\")" "$CONFIG_PATH" > "$tmp_file" 2>/dev/null; then
  if jq empty "$tmp_file" 2>/dev/null; then
    mv "$tmp_file" "$CONFIG_PATH"
    echo ""
    echo "✅ Removed '$SERVER_NAME' from $IDE_TARGET config."
  else
    echo "❌ Error: Result is invalid JSON — aborting."
    rm -f "$tmp_file"
    exit 1
  fi
else
  echo "❌ Error: jq removal failed."
  rm -f "$tmp_file"
  exit 1
fi
