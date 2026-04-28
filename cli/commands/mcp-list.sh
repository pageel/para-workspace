#!/bin/bash
# PARA Workspace — MCP List
# Usage: ./para mcp-list [--json]
#
# Lists all installed tools that have MCP server capabilities.

set -e

# === Resolve paths ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLI_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -z "$WORKSPACE_ROOT" ]; then
  echo "❌ Error: WORKSPACE_ROOT not set. Run this via './para mcp-list'."
  exit 1
fi

TOOLS_DIR="$WORKSPACE_ROOT/.para/tools"

# Source shared library
source "$CLI_DIR/lib/mcp-config.sh"

# === Parse arguments ===
JSON_OUTPUT=false

for arg in "$@"; do
  case "$arg" in
    --json)
      JSON_OUTPUT=true
      ;;
    --help|-h)
      echo "Usage: para mcp-list [--json]"
      echo ""
      echo "  --json    Output as JSON array"
      echo ""
      echo "Lists all tools with MCP server capabilities."
      exit 0
      ;;
  esac
done

# === Scan for MCP-capable tools ===
# Check both Dev paths (Projects/para-*/repo/) and Prod paths (.para/tools/)
MCP_TOOLS=()
MCP_NAMES=()
MCP_TRANSPORTS=()
MCP_DESCRIPTIONS=()
MCP_PATHS=()

# Helper: check a single manifest file
check_manifest_mcp() {
  local manifest="$1"
  local tool_name="$2"
  local path_type="$3"
  
  if grep -q "^mcp:" "$manifest" 2>/dev/null; then
    local server_name
    server_name=$(sed -n '/^mcp:/,/^[a-z]/p' "$manifest" | grep '  server_name:' | head -1 | sed 's/.*server_name: *//; s/^ *"//; s/" *$//')
    local transport
    transport=$(sed -n '/^mcp:/,/^[a-z]/p' "$manifest" | grep '  transport:' | head -1 | sed 's/.*transport: *//; s/^ *"//; s/" *$//')
    local description
    description=$(sed -n '/^mcp:/,/^[a-z]/p' "$manifest" | grep '  description:' | head -1 | sed 's/.*description: *//; s/^ *"//; s/" *$//')

    if [ -n "$server_name" ]; then
      MCP_TOOLS+=("$tool_name")
      MCP_NAMES+=("$server_name")
      MCP_TRANSPORTS+=("${transport:-stdio}")
      MCP_DESCRIPTIONS+=("${description:-}")
      MCP_PATHS+=("$path_type")
    fi
  fi
}

# Scan Dev paths
for project_dir in "$WORKSPACE_ROOT"/Projects/para-*/repo; do
  if [ -f "$project_dir/tool.manifest.yml" ]; then
    local_name=$(basename "$(dirname "$project_dir")")
    check_manifest_mcp "$project_dir/tool.manifest.yml" "$local_name" "dev"
  fi
done

# Scan Prod paths (skip if already found via Dev)
for tool_dir in "$TOOLS_DIR"/*/; do
  if [ -f "$tool_dir/tool.manifest.yml" ]; then
    local_name="para-$(basename "$tool_dir")"
    # Skip if already found in Dev
    already_found=false
    for existing in "${MCP_TOOLS[@]}"; do
      if [ "$existing" = "$local_name" ]; then
        already_found=true
        break
      fi
    done
    if [ "$already_found" = false ]; then
      check_manifest_mcp "$tool_dir/tool.manifest.yml" "$local_name" "prod"
    fi
  fi
done

# === Output ===
if [ ${#MCP_TOOLS[@]} -eq 0 ]; then
  echo "No MCP-capable tools found."
  echo ""
  echo "Install a tool with MCP support:"
  echo "  ./para install-tool para-graph"
  exit 0
fi

if [ "$JSON_OUTPUT" = true ]; then
  # JSON output
  echo "["
  for i in "${!MCP_TOOLS[@]}"; do
    comma=""
    if [ "$i" -lt $((${#MCP_TOOLS[@]} - 1)) ]; then
      comma=","
    fi
    cat <<EOF
  {
    "tool": "${MCP_TOOLS[$i]}",
    "server_name": "${MCP_NAMES[$i]}",
    "transport": "${MCP_TRANSPORTS[$i]}",
    "path_type": "${MCP_PATHS[$i]}",
    "description": "${MCP_DESCRIPTIONS[$i]}"
  }${comma}
EOF
  done
  echo "]"
else
  # Table output
  echo ""
  echo "🔌 MCP-Capable Tools"
  echo ""
  printf "  %-20s %-15s %-8s %-6s %s\n" "Server Name" "Tool" "Transport" "Path" "Description"
  printf "  %-20s %-15s %-8s %-6s %s\n" "───────────" "────" "─────────" "────" "───────────"
  for i in "${!MCP_TOOLS[@]}"; do
    printf "  %-20s %-15s %-8s %-6s %s\n" \
      "${MCP_NAMES[$i]}" \
      "${MCP_TOOLS[$i]}" \
      "${MCP_TRANSPORTS[$i]}" \
      "${MCP_PATHS[$i]}" \
      "${MCP_DESCRIPTIONS[$i]}"
  done
  echo ""
  echo "Configure: ./para mcp-setup <tool-name> [--ide=<name>]"
fi
