#!/bin/bash
# PARA Workspace — MCP Setup
# Usage: ./para mcp-setup <tool-name> [--ide antigravity|claude|cursor] [--print-only]
#
# Configures MCP server for a tool in the specified IDE config.
# Reads mcp: block from tool.manifest.yml and generates IDE-specific JSON config.

set -e

# === Resolve paths ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLI_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
COMMANDS_DIR="$SCRIPT_DIR"

# Workspace Root (inherited from parent CLI)
if [ -z "$WORKSPACE_ROOT" ]; then
  echo "❌ Error: WORKSPACE_ROOT not set. Run this via './para mcp-setup'."
  exit 1
fi

TOOLS_DIR="$WORKSPACE_ROOT/.para/tools"

# Source shared library
source "$CLI_DIR/lib/mcp-config.sh"

# === Parse arguments ===
TOOL_INPUT=""
IDE_TARGET=""
PRINT_ONLY=false

for arg in "$@"; do
  case "$arg" in
    --ide=*)
      IDE_TARGET="${arg#--ide=}"
      ;;
    --print-only)
      PRINT_ONLY=true
      ;;
    --help|-h)
      echo "Usage: para mcp-setup <tool-name> [--ide=<name>] [--print-only]"
      echo ""
      echo "  <tool-name>        Tool name (e.g., 'para-graph' or 'graph')"
      echo "  --ide=<name>       Target IDE: antigravity, claude, cursor"
      echo "  --print-only       Print JSON snippet without modifying config"
      echo ""
      echo "Examples:"
      echo "  para mcp-setup graph"
      echo "  para mcp-setup para-graph --ide=antigravity"
      echo "  para mcp-setup graph --print-only"
      exit 0
      ;;
    -*)
      echo "❌ Error: Unknown option '$arg'"
      echo "Run 'para mcp-setup --help' for usage."
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
  echo "Usage: para mcp-setup <tool-name> [--ide=<name>] [--print-only]"
  exit 1
fi

# === Normalize tool name ===
PARA_TOOL_NAME="$TOOL_INPUT"
if echo "$TOOL_INPUT" | grep -q "^para-"; then
  TOOL_NAME="${TOOL_INPUT#para-}"
else
  TOOL_NAME="$TOOL_INPUT"
  PARA_TOOL_NAME="para-$TOOL_INPUT"
fi

# === Locate manifest ===
# 2-Tier: Dev path first, then Prod path
MANIFEST_FILE=""
DEV_MANIFEST="$WORKSPACE_ROOT/Projects/$PARA_TOOL_NAME/repo/tool.manifest.yml"
PROD_MANIFEST="$TOOLS_DIR/$TOOL_NAME/tool.manifest.yml"

if [ -f "$DEV_MANIFEST" ]; then
  MANIFEST_FILE="$DEV_MANIFEST"
elif [ -f "$PROD_MANIFEST" ]; then
  MANIFEST_FILE="$PROD_MANIFEST"
else
  echo "❌ Error: Tool '$PARA_TOOL_NAME' not found."
  echo "   Checked: $DEV_MANIFEST"
  echo "   Checked: $PROD_MANIFEST"
  exit 1
fi

# === Parse mcp: block from manifest ===
parse_manifest_mcp() {
  local manifest="$1"
  
  MCP_SERVER_NAME=""
  MCP_TRANSPORT=""
  MCP_SERVE_ARGS=()
  MCP_DESCRIPTION=""

  local start_line
  start_line=$(grep -n "^mcp:" "$manifest" 2>/dev/null | head -1 | cut -d: -f1)
  if [ -z "$start_line" ]; then
    return 1
  fi

  # Read mcp: block fields
  tail -n +"$start_line" "$manifest" | while IFS= read -r line; do
    # Stop at next top-level key
    case "$line" in
      mcp:) continue ;;
      [a-z]*) break ;;
      "") continue ;;
    esac
  done

  # Simple field extraction using sed
  MCP_SERVER_NAME=$(sed -n '/^mcp:/,/^[a-z]/p' "$manifest" | grep '  server_name:' | head -1 | sed 's/.*server_name: *//; s/^ *"//; s/" *$//')
  MCP_TRANSPORT=$(sed -n '/^mcp:/,/^[a-z]/p' "$manifest" | grep '  transport:' | head -1 | sed 's/.*transport: *//; s/^ *"//; s/" *$//')
  MCP_DESCRIPTION=$(sed -n '/^mcp:/,/^[a-z]/p' "$manifest" | grep '  description:' | head -1 | sed 's/.*description: *//; s/^ *"//; s/" *$//')
  
  # Parse serve_args array: ["arg1", "arg2"]
  local args_raw
  args_raw=$(sed -n '/^mcp:/,/^[a-z]/p' "$manifest" | grep '  serve_args:' | head -1 | sed 's/.*serve_args: *//')
  # Strip brackets and quotes, split by comma
  args_raw=$(echo "$args_raw" | sed 's/^\[//; s/\]$//; s/"//g; s/,/ /g; s/^ *//; s/ *$//')
  
  MCP_SERVE_ARGS=()
  for arg in $args_raw; do
    # Replace ${WORKSPACE_ROOT} placeholder
    arg=$(echo "$arg" | sed "s|\${WORKSPACE_ROOT}|$WORKSPACE_ROOT|g")
    MCP_SERVE_ARGS+=("$arg")
  done

  if [ -z "$MCP_SERVER_NAME" ]; then
    return 1
  fi
  return 0
}

# Parse manifest
if ! parse_manifest_mcp "$MANIFEST_FILE"; then
  echo "❌ Error: No mcp: block found in manifest."
  echo "   File: $MANIFEST_FILE"
  exit 1
fi

# === Resolve tool runtime and entry path ===
# Get runtime from manifest
TOOL_RUNTIME=$(grep '^runtime:' "$MANIFEST_FILE" | head -1 | sed 's/runtime: *//; s/^ *"//; s/" *$//')
TOOL_ENTRY=$(grep '^entry:' "$MANIFEST_FILE" | head -1 | sed 's/entry: *//; s/^ *"//; s/" *$//')

# Check runtime availability
case "$TOOL_RUNTIME" in
  node)
    if ! command -v node &> /dev/null; then
      echo "⚠️  Node.js is required but not installed."
      echo "   Install Node.js first, then re-run: ./para mcp-setup $PARA_TOOL_NAME"
      exit 1
    fi
    RUNTIME_CMD="node"
    ;;
  python)
    if command -v python3 &> /dev/null; then
      RUNTIME_CMD="python3"
    elif command -v python &> /dev/null; then
      RUNTIME_CMD="python"
    else
      echo "⚠️  Python is required but not installed."
      exit 1
    fi
    ;;
  binary)
    RUNTIME_CMD=""
    ;;
  *)
    echo "❌ Error: Unknown runtime '$TOOL_RUNTIME'"
    exit 1
    ;;
esac

# Resolve entry path (2-Tier)
ENTRY_PATH=$(resolve_tool_entry_path "$TOOL_NAME" "$TOOL_ENTRY")
if [ $? -ne 0 ] || [ -z "$ENTRY_PATH" ]; then
  echo "❌ Error: Could not resolve entry path for $PARA_TOOL_NAME"
  exit 1
fi

# Windows/Git Bash compatibility for JSON output paths
if command -v cygpath >/dev/null 2>&1; then
  ENTRY_PATH=$(cygpath -m "$ENTRY_PATH")
  for i in "${!MCP_SERVE_ARGS[@]}"; do
    if [[ "${MCP_SERVE_ARGS[$i]}" == /* ]]; then
      MCP_SERVE_ARGS[$i]=$(cygpath -m "${MCP_SERVE_ARGS[$i]}")
    fi
  done
fi

# === Generate config snippet ===
SNIPPET=$(generate_mcp_snippet "$MCP_SERVER_NAME" "$RUNTIME_CMD" "$ENTRY_PATH" "${MCP_SERVE_ARGS[@]}")

echo ""
echo "🔌 MCP Server: $MCP_SERVER_NAME"
echo "   Transport:  $MCP_TRANSPORT"
echo "   Command:    $RUNTIME_CMD"
echo "   Entry:      $ENTRY_PATH"
echo "   Args:       ${MCP_SERVE_ARGS[*]}"
if [ -n "$MCP_DESCRIPTION" ]; then
  echo "   Desc:       $MCP_DESCRIPTION"
fi
echo ""

# === Print-only mode ===
if [ "$PRINT_ONLY" = true ]; then
  echo "📋 JSON snippet (copy to your IDE config under \"mcpServers\"):"
  echo ""
  echo "$SNIPPET"
  exit 0
fi

# === IDE selection ===
if [ -z "$IDE_TARGET" ]; then
  # Auto-detect installed IDEs
  DETECTED_IDES=$(detect_installed_ides)
  
  if [ -z "$DETECTED_IDES" ]; then
    echo "⚠️  No supported IDE configs detected."
    echo "   Use --print-only to get the JSON snippet."
    exit 1
  fi

  echo "Detected IDEs:"
  local_idx=1
  for ide in $DETECTED_IDES; do
    config_path=$(resolve_ide_config_path "$ide")
    echo "  [$local_idx] $ide → $config_path"
    local_idx=$((local_idx + 1))
  done
  echo ""
  printf "Select IDE (number): "
  read -r ide_choice

  # Convert choice to IDE name
  local_idx=1
  for ide in $DETECTED_IDES; do
    if [ "$local_idx" = "$ide_choice" ]; then
      IDE_TARGET="$ide"
      break
    fi
    local_idx=$((local_idx + 1))
  done

  if [ -z "$IDE_TARGET" ]; then
    echo "❌ Invalid selection."
    exit 1
  fi
fi

# === Helper: check if IDE directory exists ===
is_ide_directory_exists() {
  local path="$1"
  local ide="$2"
  case "$ide" in
    antigravity-ide)
      [ -d "$HOME/.gemini/antigravity-ide" ]
      ;;
    antigravity-v1)
      [ -d "$HOME/.gemini/antigravity" ]
      ;;
    antigravity)
      if [[ "$path" == *"/config/"* ]]; then
        [ -d "$HOME/.gemini/antigravity-ide" ]
      elif [[ "$path" == *"/antigravity/"* ]]; then
        [ -d "$HOME/.gemini/antigravity" ]
      else
        [ -d "$(dirname "$path")" ]
      fi
      ;;
    *)
      [ -d "$(dirname "$path")" ]
      ;;
  esac
}

# === Configure IDE ===
CONFIG_PATHS=$(resolve_ide_config_path "$IDE_TARGET")
if [ $? -ne 0 ]; then
  echo "❌ Error: Unknown IDE '$IDE_TARGET'"
  exit 1
fi

local_success=false
for path in $CONFIG_PATHS; do
  if ! is_ide_directory_exists "$path" "$IDE_TARGET"; then
    continue
  fi

  echo "Target: $path"

  # Backup existing config
  if [ -f "$path" ]; then
    backup_config "$path"
  fi

  # Merge config
  if merge_mcp_config "$path" "$MCP_SERVER_NAME" "$SNIPPET"; then
    echo "✅ MCP server '$MCP_SERVER_NAME' configured for $IDE_TARGET ($path)."
    local_success=true
  else
    echo "⚠️  Failed to merge config into $path"
  fi
done

if [ "$local_success" = false ]; then
  echo "❌ Error: No valid/installed IDE config paths found to write configuration."
  exit 1
fi
