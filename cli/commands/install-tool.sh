#!/bin/bash
# PARA Workspace — Install Tool Plugin
# Usage: ./para install-tool <name> [--version=X.Y.Z] [--update] [--agents] [--no-agents]
#
# Downloads and installs a tool plugin from the PARA Tool Registry.
# Generates a wrapper script for dynamic CLI routing.
# Detects and optionally installs bundled AI intelligence (workflows, skills, rules).

set -e

# === Resolve paths ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLI_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_ROOT="$(cd "$CLI_DIR/.." && pwd)"
COMMANDS_DIR="$SCRIPT_DIR"
TEMPLATES_DIR="$CLI_DIR/templates"
REGISTRY_FILE="$REPO_ROOT/registry/tools.yml"
TEMPLATE_FILE="$TEMPLATES_DIR/tool-wrapper.sh.tmpl"

# Workspace Root (inherited from parent CLI or detect)
if [ -z "$WORKSPACE_ROOT" ]; then
  echo "❌ Error: WORKSPACE_ROOT not set. Run this via './para install-tool'."
  exit 1
fi

TOOLS_DIR="$WORKSPACE_ROOT/.para/tools"
AGENTS_DIR="$WORKSPACE_ROOT/.agents"

# === Parse arguments ===
TOOL_INPUT=""
TOOL_VERSION=""
UPDATE_MODE=false
SKIP_AGENTS=false
SKIP_MCP=false
AGENTS_ONLY=false

for arg in "$@"; do
  case "$arg" in
    --version=*)
      TOOL_VERSION="${arg#--version=}"
      ;;
    --update)
      UPDATE_MODE=true
      ;;
    --no-agents)
      SKIP_AGENTS=true
      ;;
    --no-mcp)
      SKIP_MCP=true
      ;;
    --agents)
      AGENTS_ONLY=true
      ;;
    --help|-h)
      echo "Usage: para install-tool <name> [--version=X.Y.Z] [--update] [--agents] [--no-agents] [--no-mcp]"
      echo ""
      echo "  <name>           Tool name (e.g., 'para-graph' or 'graph')"
      echo "  --version=X.Y.Z  Install specific version (default: latest)"
      echo "  --update         Remove existing installation before installing"
      echo "  --agents         Install only AI intelligence (tool must be already installed)"
      echo "  --no-agents      Skip AI intelligence prompt during install"
      echo "  --no-mcp         Skip MCP server configuration prompt"
      echo ""
      echo "Examples:"
      echo "  para install-tool para-graph"
      echo "  para install-tool graph --version=0.7.0"
      echo "  para install-tool para-graph --update"
      echo "  para install-tool para-graph --agents"
      echo "  para install-tool para-graph --no-agents"
      exit 0
      ;;
    -*)
      echo "❌ Error: Unknown option '$arg'"
      echo "Run 'para install-tool --help' for usage."
      exit 1
      ;;
    *)
      if [ -z "$TOOL_INPUT" ]; then
        TOOL_INPUT="$arg"
      else
        echo "❌ Error: Too many arguments. Expected: para install-tool <name>"
        exit 1
      fi
      ;;
  esac
done

if [ -z "$TOOL_INPUT" ]; then
  echo "❌ Error: Missing tool name."
  echo "Usage: para install-tool <name> [--version=X.Y.Z]"
  echo ""
  echo "Available tools:"
  # Show registered tools
  if [ -f "$REGISTRY_FILE" ]; then
    grep -E "^[a-z]" "$REGISTRY_FILE" | sed 's/:$//' | while read -r name; do
      echo "  - $name"
    done
  else
    echo "  (no registry found)"
  fi
  exit 1
fi

# === Normalize tool name ===
# Accept both "para-graph" and "graph"
PARA_TOOL_NAME="$TOOL_INPUT"
if echo "$TOOL_INPUT" | grep -q "^para-"; then
  TOOL_NAME="${TOOL_INPUT#para-}"
else
  TOOL_NAME="$TOOL_INPUT"
  PARA_TOOL_NAME="para-$TOOL_INPUT"
fi

# === Validate registry ===
if [ ! -f "$REGISTRY_FILE" ]; then
  echo "❌ Error: Registry file not found: $REGISTRY_FILE"
  exit 1
fi

# Simple YAML parser — extract tool block using grep/sed (R3: no yq dependency)
# Look for the tool's short name as a top-level key
if ! grep -q "^${TOOL_NAME}:" "$REGISTRY_FILE" 2>/dev/null; then
  echo "❌ Error: Tool '$PARA_TOOL_NAME' not found in registry."
  echo ""
  echo "Available tools:"
  grep -E "^[a-z][a-z0-9_-]*:" "$REGISTRY_FILE" | sed 's/:$//' | while read -r name; do
    echo "  - para-$name"
  done
  exit 1
fi

# === Parse tool metadata from registry (grep/sed — R3 mitigation) ===
# Extract the block between this tool's key and the next top-level key
parse_registry_field() {
  local field="$1"
  # Get value of field within the tool block
  sed -n "/^${TOOL_NAME}:/,/^[a-z]/p" "$REGISTRY_FILE" \
    | grep "^  ${field}:" \
    | head -1 \
    | sed "s/^  ${field}: *//; s/^ *\"//; s/\" *$//; s/^ *'//; s/' *$//"
}

TOOL_REPO="$(parse_registry_field "repo")"
TOOL_RUNTIME="$(parse_registry_field "runtime")"
TOOL_MIN_VERSION="$(parse_registry_field "min_runtime_version")"
TOOL_ENTRY="$(parse_registry_field "entry")"
TOOL_LATEST="$(parse_registry_field "latest")"
TOOL_TARBALL_PATTERN="$(parse_registry_field "tarball_pattern")"
TOOL_DESCRIPTION="$(parse_registry_field "description")"

# Use latest if no version specified
if [ -z "$TOOL_VERSION" ]; then
  TOOL_VERSION="$TOOL_LATEST"
fi

if [ -z "$TOOL_VERSION" ]; then
  echo "❌ Error: No version specified and no 'latest' version in registry."
  exit 1
fi

# === AI Intelligence Functions ===
# Arrays to store parsed agent items
AGENT_SOURCES=()
AGENT_TARGETS=()
AGENT_VERSIONS=()
AGENT_TYPES=()

# State machine parser: reads agents: block from tool.manifest.yml line-by-line
parse_manifest_agents() {
  AGENT_SOURCES=()
  AGENT_TARGETS=()
  AGENT_VERSIONS=()
  AGENT_TYPES=()

  local manifest="$MANIFEST_FILE"
  if [ ! -f "$manifest" ]; then
    return
  fi

  # Find agents: block start line
  local start_line
  start_line=$(grep -n "^agents:" "$manifest" 2>/dev/null | head -1 | cut -d: -f1)
  if [ -z "$start_line" ]; then
    return
  fi

  local current_type=""
  local item_source="" item_target="" item_version=""
  local tmp_file
  tmp_file=$(mktemp)

  # Read from agents: line to end, stop at next top-level key
  tail -n +"$start_line" "$manifest" | {
    # Skip the "agents:" line itself
    read -r _header_line

    while IFS= read -r line; do
      # Stop at next top-level key (non-indented, non-empty)
      case "$line" in
        [a-z]*) break ;;
        "") continue ;;
      esac

      # Detect type section: "  workflows:", "  skills:", "  rules:"
      case "$line" in
        "  workflows:"*) current_type="workflows"; continue ;;
        "  skills:"*)    current_type="skills"; continue ;;
        "  rules:"*)     current_type="rules"; continue ;;
      esac

      # Detect item start: "    - source:"
      if echo "$line" | grep -q "^    - source:"; then
        item_source=$(echo "$line" | sed 's/.*source: *//; s/^ *"//; s/" *$//')
        continue
      fi

      # Read target within an item
      if echo "$line" | grep -q "^      target:"; then
        item_target=$(echo "$line" | sed 's/.*target: *//; s/^ *"//; s/" *$//')
        continue
      fi

      # Read version — completes the item
      if echo "$line" | grep -q "^      version:"; then
        item_version=$(echo "$line" | sed 's/.*version: *//; s/^ *"//; s/" *$//')
        echo "${current_type}|${item_source}|${item_target}|${item_version}" >> "$tmp_file"
        item_source="" item_target="" item_version=""
        continue
      fi
    done
  }

  # Read parsed items into arrays
  if [ -s "$tmp_file" ]; then
    while IFS='|' read -r atype asource atarget aversion; do
      AGENT_TYPES+=("$atype")
      AGENT_SOURCES+=("$asource")
      AGENT_TARGETS+=("$atarget")
      AGENT_VERSIONS+=("$aversion")
    done < "$tmp_file"
  fi
  rm -f "$tmp_file"
}

# Compare manifest version with installed version
compare_agent_version() {
  local agent_type="$1"
  local agent_target="$2"
  local manifest_version="$3"

  local existing_path=""
  case "$agent_type" in
    workflows) existing_path="$AGENTS_DIR/workflows/$agent_target" ;;
    skills)    existing_path="$AGENTS_DIR/skills/$agent_target" ;;
    rules)     existing_path="$AGENTS_DIR/rules/$agent_target" ;;
  esac

  if [ ! -e "$existing_path" ]; then
    echo "NEW"
    return
  fi

  echo "INSTALLED"
}

# Display summary of available AI intelligence
display_agents_summary() {
  echo ""
  echo "  🧠 AI Intelligence available:"
  local i=0
  while [ $i -lt ${#AGENT_SOURCES[@]} ]; do
    local atype="${AGENT_TYPES[$i]}"
    local atarget="${AGENT_TARGETS[$i]}"
    local aversion="${AGENT_VERSIONS[$i]}"
    local status
    status=$(compare_agent_version "$atype" "$atarget" "$aversion")

    local label=""
    case "$atype" in
      workflows) label="Workflow" ;;
      skills)    label="Skill   " ;;
      rules)     label="Rule    " ;;
    esac

    echo "    $label: $atarget (v$aversion) — $status"
    i=$((i + 1))
  done
  echo ""
}

# Copy agent files from tool install dir to .agents/
install_agents() {
  local i=0
  while [ $i -lt ${#AGENT_SOURCES[@]} ]; do
    local atype="${AGENT_TYPES[$i]}"
    local asource="${AGENT_SOURCES[$i]}"
    local atarget="${AGENT_TARGETS[$i]}"
    local src_path="$TOOL_INSTALL_DIR/$asource"
    local dst_dir="$AGENTS_DIR/$atype"
    local dst_path="$dst_dir/$atarget"

    mkdir -p "$dst_dir"

    if [ -d "$src_path" ]; then
      # Directory copy (skills) — remove existing first for clean update
      if [ -d "$dst_path" ]; then
        rm -rf "$dst_path"
      fi
      cp -r "$src_path" "$dst_path"
    elif [ -f "$src_path" ]; then
      # File copy (workflows, rules)
      cp "$src_path" "$dst_path"
    else
      echo "  ⚠️  Source not found: $src_path (skipping)"
    fi

    i=$((i + 1))
  done
}

# === Handle --update ===
TOOL_INSTALL_DIR="$TOOLS_DIR/$TOOL_NAME"
WRAPPER_SCRIPT="$COMMANDS_DIR/$TOOL_NAME.sh"
MANIFEST_FILE="$TOOL_INSTALL_DIR/tool.manifest.yml"

# === Handle --agents (standalone mode) ===
if [ "$AGENTS_ONLY" = true ]; then
  if [ ! -d "$TOOL_INSTALL_DIR" ]; then
    echo "❌ Error: Tool '$PARA_TOOL_NAME' is not installed. Install it first."
    exit 1
  fi
  if [ ! -f "$MANIFEST_FILE" ]; then
    echo "❌ Error: tool.manifest.yml not found in $TOOL_INSTALL_DIR"
    exit 1
  fi
  echo "🧠 Installing AI intelligence for $PARA_TOOL_NAME..."
  parse_manifest_agents
  if [ ${#AGENT_SOURCES[@]} -eq 0 ]; then
    echo "ℹ️  No AI intelligence bundled with this tool."
    exit 0
  fi
  display_agents_summary
  install_agents
  echo ""
  echo "✅ AI intelligence installed."
  exit 0
fi

if [ -d "$TOOL_INSTALL_DIR" ] && [ "$UPDATE_MODE" = false ]; then
  echo "⚠️  Tool '$PARA_TOOL_NAME' is already installed at: $TOOL_INSTALL_DIR"
  echo "   Use --update to reinstall."
  exit 1
fi

if [ "$UPDATE_MODE" = true ] && [ -d "$TOOL_INSTALL_DIR" ]; then
  echo "🔄 Removing existing installation..."
  rm -rf "$TOOL_INSTALL_DIR"
fi

# === Runtime check (R9: warn but don't block) ===
check_runtime_warning() {
  case "$TOOL_RUNTIME" in
    node)
      if ! command -v node &>/dev/null; then
        echo "⚠️  Warning: Node.js not found. Tool requires Node.js >= $TOOL_MIN_VERSION"
        echo "   Install: https://nodejs.org/"
      fi
      ;;
    python)
      if ! command -v python3 &>/dev/null; then
        echo "⚠️  Warning: Python 3 not found. Tool requires Python >= $TOOL_MIN_VERSION"
      fi
      ;;
  esac
}

# === Download tarball (R8: check exit code + file existence) ===
echo "📦 Installing $PARA_TOOL_NAME v$TOOL_VERSION..."
echo ""

# Interpolate version into tarball URL
TARBALL_URL="$(echo "$TOOL_TARBALL_PATTERN" | sed "s/{{VERSION}}/$TOOL_VERSION/g")"

echo "  → Downloading from: $TARBALL_URL"

# Create temp directory for download
TEMP_DIR="$(mktemp -d)"
TARBALL_FILE="$TEMP_DIR/${PARA_TOOL_NAME}-v${TOOL_VERSION}.tar.gz"

# Download (R8: explicit error check)
if ! curl -fSL "$TARBALL_URL" -o "$TARBALL_FILE" 2>/dev/null; then
  echo "❌ Error: Failed to download tarball."
  echo "   URL: $TARBALL_URL"
  echo "   Check that the release exists and you have network access."
  rm -rf "$TEMP_DIR"
  exit 1
fi

# Verify file exists and is not empty (R8)
if [ ! -s "$TARBALL_FILE" ]; then
  echo "❌ Error: Downloaded file is empty or missing."
  rm -rf "$TEMP_DIR"
  exit 1
fi

# === Extract ===
echo "  → Extracting to: $TOOL_INSTALL_DIR"
mkdir -p "$TOOL_INSTALL_DIR"

if ! tar -xzf "$TARBALL_FILE" -C "$TOOL_INSTALL_DIR" 2>/dev/null; then
  echo "❌ Error: Failed to extract tarball."
  rm -rf "$TEMP_DIR" "$TOOL_INSTALL_DIR"
  exit 1
fi

# Cleanup temp
rm -rf "$TEMP_DIR"

# === Validate manifest ===
MANIFEST_FILE="$TOOL_INSTALL_DIR/tool.manifest.yml"
if [ ! -f "$MANIFEST_FILE" ]; then
  echo "❌ Error: tool.manifest.yml not found in tarball."
  echo "   The tarball must include a tool.manifest.yml at its root."
  rm -rf "$TOOL_INSTALL_DIR"
  exit 1
fi

# === Generate wrapper script ===
echo "  → Generating wrapper: cli/commands/$TOOL_NAME.sh"

if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "❌ Error: Wrapper template not found: $TEMPLATE_FILE"
  rm -rf "$TOOL_INSTALL_DIR"
  exit 1
fi

# sed replace placeholders (R1: portable sed via temp file)
TEMP_WRAPPER="$(mktemp)"
sed \
  -e "s|{{TOOL_NAME}}|$TOOL_NAME|g" \
  -e "s|{{PARA_TOOL_NAME}}|$PARA_TOOL_NAME|g" \
  -e "s|{{RUNTIME}}|$TOOL_RUNTIME|g" \
  -e "s|{{MIN_RUNTIME_VERSION}}|$TOOL_MIN_VERSION|g" \
  -e "s|{{ENTRY}}|$TOOL_ENTRY|g" \
  "$TEMPLATE_FILE" > "$TEMP_WRAPPER"

mv "$TEMP_WRAPPER" "$WRAPPER_SCRIPT"
chmod +x "$WRAPPER_SCRIPT"  # R9: ensure executable

# === Runtime warning ===
check_runtime_warning

# === Success ===
echo ""
echo "✅ Successfully installed $PARA_TOOL_NAME v$TOOL_VERSION"
echo ""
echo "  Install path: $TOOL_INSTALL_DIR"
echo "  Wrapper:      $WRAPPER_SCRIPT"
echo "  Runtime:      $TOOL_RUNTIME (>= $TOOL_MIN_VERSION)"
echo ""
echo "Usage:"
echo "  ./para $TOOL_NAME <subcommand>"

# === AI Intelligence prompt (after successful install) ===
if [ "$SKIP_AGENTS" != true ]; then
  parse_manifest_agents
  if [ ${#AGENT_SOURCES[@]} -gt 0 ]; then
    display_agents_summary
    printf "  Install AI intelligence? (y/n): "
    read -r INSTALL_AGENTS_ANSWER
    if [ "$INSTALL_AGENTS_ANSWER" = "y" ] || [ "$INSTALL_AGENTS_ANSWER" = "Y" ]; then
      install_agents
      echo ""
      echo "  ✅ AI intelligence installed."
    else
      echo "  ⏭️  Skipped. Run './para install-tool $PARA_TOOL_NAME --agents' later."
    fi
  fi
fi

# === MCP Server prompt (after agents) ===
if [ "$SKIP_MCP" != true ]; then
  if grep -q "^mcp:" "$MANIFEST_FILE" 2>/dev/null; then
    MCP_SERVER_NAME=$(sed -n '/^mcp:/,/^[a-z]/p' "$MANIFEST_FILE" | grep '  server_name:' | head -1 | sed 's/.*server_name: *//; s/^ *"//; s/" *$//')
    if [ -n "$MCP_SERVER_NAME" ]; then
      echo ""
      printf "  \xF0\x9F\x94\x8C MCP Server available: %s\n" "$MCP_SERVER_NAME"
      printf "     Configure now? (y/n): "
      read -r MCP_ANSWER
      if [ "$MCP_ANSWER" = "y" ] || [ "$MCP_ANSWER" = "Y" ]; then
        "$COMMANDS_DIR/mcp-setup.sh" "$TOOL_NAME"
      else
        echo "  ⏭️  Skipped. Run './para mcp-setup $PARA_TOOL_NAME' later."
      fi
    fi
  fi
fi
