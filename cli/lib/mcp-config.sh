#!/usr/bin/env bash
# mcp-config.sh — Shared library for MCP server configuration
# Usage: source cli/lib/mcp-config.sh
#
# Provides functions for IDE MCP config management:
#   resolve_ide_config_path  — Returns config file path for a given IDE + OS
#   detect_installed_ides    — Lists IDEs with existing config directories
#   generate_mcp_snippet     — Generates JSON config snippet for an MCP server
#   merge_mcp_config         — Merges snippet into IDE config (jq primary, print fallback)
#   backup_config            — Creates timestamped backup before modifying

# Inherit logger if not loaded
if ! command -v log_info &> /dev/null; then
  if [[ -f "$(dirname "${BASH_SOURCE[0]}")/logger.sh" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"
  else
    # Fallback stubs if logger not available
    log_info()  { echo "  ℹ️  $*"; }
    log_warn()  { echo "  ⚠️  $*"; }
    log_error() { echo "  ❌ $*"; }
    log_debug() { :; }
  fi
fi

# === Supported IDEs ===
MCP_SUPPORTED_IDES="antigravity antigravity-ide antigravity-v1 claude cursor"

# resolve_ide_config_path — Returns the config file path for a given IDE.
# Usage: resolve_ide_config_path "antigravity"
# Returns: absolute path to config file (may not exist yet). For "antigravity", returns space-separated paths.
resolve_ide_config_path() {
  local ide="$1"

  case "$ide" in
    antigravity)
      echo "$HOME/.gemini/config/mcp_config.json $HOME/.gemini/antigravity/mcp_config.json"
      ;;
    antigravity-ide)
      echo "$HOME/.gemini/config/mcp_config.json"
      ;;
    antigravity-v1)
      echo "$HOME/.gemini/antigravity/mcp_config.json"
      ;;
    claude)
      if [ "$(uname)" = "Darwin" ]; then
        echo "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
      else
        echo "$HOME/.config/claude/claude_desktop_config.json"
      fi
      ;;
    cursor)
      echo "$HOME/.cursor/mcp.json"
      ;;
    *)
      log_error "Unknown IDE: $ide"
      return 1
      ;;
  esac
}

# detect_installed_ides — Lists IDEs that have config directories present.
# Usage: detect_installed_ides
# Output: space-separated list of IDE names (e.g., "antigravity cursor")
detect_installed_ides() {
  local found_ides=""

  for ide in $MCP_SUPPORTED_IDES; do
    case "$ide" in
      antigravity-ide)
        if [ -d "$HOME/.gemini/antigravity-ide" ]; then
          found_ides="$found_ides $ide"
        fi
        ;;
      antigravity-v1)
        if [ -d "$HOME/.gemini/antigravity" ]; then
          found_ides="$found_ides $ide"
        fi
        ;;
      antigravity)
        if [ -d "$HOME/.gemini/antigravity-ide" ] || [ -d "$HOME/.gemini/antigravity" ]; then
          found_ides="$found_ides $ide"
        fi
        ;;
      *)
        local config_path
        config_path=$(resolve_ide_config_path "$ide" 2>/dev/null) || continue
        local config_dir
        config_dir=$(dirname "$config_path")
        if [ -d "$config_dir" ]; then
          found_ides="$found_ides $ide"
        fi
        ;;
    esac
  done

  echo "$found_ides" | sed 's/^ //'
}

# generate_mcp_snippet — Generates JSON snippet for an MCP server entry.
# Usage: generate_mcp_snippet "para-graph" "node" "/path/to/dist/cli.js" "serve" "/workspace"
# Args:
#   $1 — server_name (key in mcpServers)
#   $2 — command (runtime binary: node, python, etc.)
#   $3 — entry_path (absolute path to tool entry point)
#   $4+ — serve_args (remaining args appended after entry_path)
# Output: JSON string for the server entry
generate_mcp_snippet() {
  local server_name="$1"
  local command="$2"
  local entry_path="$3"
  shift 3
  local serve_args=("$@")

  if [ -z "$server_name" ] || [ -z "$command" ] || [ -z "$entry_path" ]; then
    log_error "generate_mcp_snippet: missing required arguments"
    return 1
  fi

  # Build args array: entry_path + serve_args
  local args_json
  args_json=$(printf '"%s"' "$entry_path")
  for arg in "${serve_args[@]}"; do
    args_json="$args_json, $(printf '"%s"' "$arg")"
  done

  cat <<EOF
{
  "$server_name": {
    "command": "$command",
    "args": [$args_json]
  }
}
EOF
}

# merge_mcp_config — Merges an MCP server entry into an IDE config file.
# Usage: merge_mcp_config "config_path" "server_name" "snippet_json"
# Uses Node.js for merge (cross-platform, fallback to print if missing).
# Returns: 0 on success, 1 on error
merge_mcp_config() {
  local config_path="$1"
  local server_name="$2"
  local snippet_json="$3"

  if [ -z "$config_path" ] || [ -z "$server_name" ] || [ -z "$snippet_json" ]; then
    log_error "merge_mcp_config: missing required arguments"
    return 1
  fi

  # Check if Node is available
  if ! command -v node &> /dev/null; then
    log_warn "Node.js is not installed — cannot auto-merge config."
    echo ""
    echo "  📋 Please add the following to your config file manually:"
    echo "     File: $config_path"
    echo ""
    echo "     Add this entry inside \"mcpServers\": {"
    echo "$snippet_json" | sed 's/^/     /'
    echo "     }"
    echo ""
    return 1
  fi

  # Create config file with base structure if it doesn't exist or is empty (0 bytes)
  if [ ! -f "$config_path" ] || [ ! -s "$config_path" ]; then
    local config_dir
    config_dir=$(dirname "$config_path")
    mkdir -p "$config_dir"
    echo '{ "mcpServers": {} }' > "$config_path"
    log_info "Created new/reset empty config file: $config_path"
  fi

  local merge_script
  merge_script=$(cat << 'EOF'
const fs = require('fs');
const configPath = process.argv[1];
const serverName = process.argv[2];
const snippetStr = process.argv[3];

try {
  let config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  if (!config.mcpServers) config.mcpServers = {};
  
  const snippet = JSON.parse(snippetStr);
  const serverConfig = snippet[serverName];
  
  if (config.mcpServers[serverName]) {
    console.log("EXISTS");
    process.exit(0);
  }
  
  config.mcpServers[serverName] = serverConfig;
  
  const tmpPath = configPath + '.tmp';
  const stat = fs.statSync(configPath);
  fs.writeFileSync(tmpPath, JSON.stringify(config, null, 2), 'utf8');
  fs.chmodSync(tmpPath, stat.mode);
  fs.renameSync(tmpPath, configPath);
  
  console.log("MERGED");
} catch (e) {
  console.log("ERROR");
}
EOF
)

  local result
  result=$(node -e "$merge_script" "$config_path" "$server_name" "$snippet_json")

  if [ "$result" = "ERROR" ]; then
    log_error "Config file is not valid JSON or merge failed: $config_path"
    return 1
  elif [ "$result" = "EXISTS" ]; then
    log_warn "Server '$server_name' already exists in config."
    printf "     Overwrite? (y/n): "
    read -r overwrite_answer
    if [ "$overwrite_answer" != "y" ] && [ "$overwrite_answer" != "Y" ]; then
      log_info "Skipped — existing config preserved."
      return 0
    fi
    
    local overwrite_result
    overwrite_result=$(node -e "
const fs = require('fs');
const configPath = process.argv[1];
const serverName = process.argv[2];
const snippetStr = process.argv[3];
try {
  let c = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  c.mcpServers[serverName] = JSON.parse(snippetStr)[serverName];
  const tmpPath = configPath + '.tmp';
  const stat = fs.statSync(configPath);
  fs.writeFileSync(tmpPath, JSON.stringify(c, null, 2), 'utf8');
  fs.chmodSync(tmpPath, stat.mode);
  fs.renameSync(tmpPath, configPath);
  console.log('SUCCESS');
} catch(e) {
  console.log('ERROR');
}
" "$config_path" "$server_name" "$snippet_json")

    if [ "$overwrite_result" = "ERROR" ]; then
      log_error "Failed to overwrite config file: $config_path"
      return 1
    fi
    log_info "MCP server '$server_name' configured in: $config_path"
    return 0
  elif [ "$result" = "MERGED" ]; then
    log_info "MCP server '$server_name' configured in: $config_path"
    return 0
  else
    log_error "Unknown error during Node.js merge."
    return 1
  fi
}

# backup_config — Creates a timestamped backup of a config file.
# Usage: backup_config "/path/to/config.json"
# Returns: 0 on success, 1 if file doesn't exist
backup_config() {
  local config_path="$1"

  if [ ! -f "$config_path" ]; then
    log_debug "backup_config: file does not exist, skipping: $config_path"
    return 0
  fi

  local backup_path="${config_path}.bak.$(date +%Y%m%d_%H%M%S)"
  if cp "$config_path" "$backup_path"; then
    log_info "Backup created: $backup_path"
    return 0
  else
    log_error "Failed to create backup: $backup_path"
    return 1
  fi
}

# resolve_tool_entry_path — Resolves absolute path to tool entry point.
# Implements 2-Tier resolution: Dev path preferred, Prod path fallback.
# Usage: resolve_tool_entry_path "graph" "dist/cli.js"
# Args:
#   $1 — tool short name (e.g., "graph")
#   $2 — entry point relative path (e.g., "dist/cli.js")
# Returns: absolute path to the entry point
resolve_tool_entry_path() {
  local tool_name="$1"
  local entry="$2"
  local para_name="para-$tool_name"

  if [ -z "$WORKSPACE_ROOT" ]; then
    log_error "resolve_tool_entry_path: WORKSPACE_ROOT not set"
    return 1
  fi

  # Tier 1: Dev path — Projects/<para-name>/repo/<entry>
  local dev_path="$WORKSPACE_ROOT/Projects/$para_name/repo/$entry"
  if [ -f "$dev_path" ]; then
    echo "$dev_path"
    return 0
  fi

  # Tier 2: Prod path — .para/tools/<name>/<entry>
  local prod_path="$WORKSPACE_ROOT/.para/tools/$tool_name/$entry"
  if [ -f "$prod_path" ]; then
    echo "$prod_path"
    return 0
  fi

  log_error "Entry point not found: $entry (checked Dev: $dev_path, Prod: $prod_path)"
  return 1
}
