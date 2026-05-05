#!/bin/bash
# PARA Workspace — Install Tool Plugin
# Usage: ./para install-tool <name> [--version=X.Y.Z] [--update] [--agents] [--sync] [--no-agents]
#
# Downloads and installs a tool plugin from the PARA Tool Registry.
# Generates a wrapper script for dynamic CLI routing.
# Detects and optionally installs bundled AI intelligence (workflows, skills, rules).
# Supports tool hooks (install-hooks.sh) for decoupled tool lifecycle management.

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
SYNC_MODE=false

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
    --sync)
      SYNC_MODE=true
      ;;
    --help|-h)
      echo "Usage: para install-tool <name> [--version=X.Y.Z] [--update] [--agents] [--sync] [--no-agents] [--no-mcp]"
      echo ""
      echo "  <name>           Tool name (e.g., 'para-graph' or 'graph')"
      echo "  --version=X.Y.Z  Install specific version (default: latest)"
      echo "  --update         Remove existing installation before installing"
      echo "  --agents         Install only AI intelligence (tool must be already installed)"
      echo "  --sync           Fetch latest intelligence from GitHub (no tarball download)"
      echo "  --no-agents      Skip AI intelligence prompt during install"
      echo "  --no-mcp         Skip MCP server configuration prompt"
      echo ""
      echo "Examples:"
      echo "  para install-tool para-graph"
      echo "  para install-tool graph --version=0.7.0"
      echo "  para install-tool para-graph --update"
      echo "  para install-tool para-graph --agents"
      echo "  para install-tool para-graph --sync"
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

  # === Remote version check (R9: stale registry mitigation) ===
  # When no explicit --version, check GitHub API for actual latest release.
  # This prevents stale local registry from installing outdated versions.
  if [ -n "$TOOL_REPO" ]; then
    REMOTE_LATEST=""
    REMOTE_LATEST=$(curl -sf --max-time 5 \
      "https://api.github.com/repos/${TOOL_REPO}/releases/latest" 2>/dev/null \
      | grep '"tag_name"' \
      | head -1 \
      | sed 's/.*"tag_name": *"v\{0,1\}//; s/".*//' ) || true

    if [ -n "$REMOTE_LATEST" ] && [ "$REMOTE_LATEST" != "$TOOL_VERSION" ]; then
      echo "⚠ Registry says v${TOOL_VERSION}, but GitHub latest is v${REMOTE_LATEST}."
      echo "  Using remote version v${REMOTE_LATEST}."
      echo "  💡 Run './para update' to sync your local registry."
      echo ""
      TOOL_VERSION="$REMOTE_LATEST"
    fi
  fi
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

# === SemVer comparison (POSIX-compatible) ===
# Returns 0 if version A >= version B, 1 otherwise
# Usage: semver_gte "1.2.3" "1.2.0" → returns 0 (true)
semver_gte() {
  local a="$1" b="$2"
  if [ "$a" = "$b" ]; then
    return 0
  fi

  local a_major a_minor a_patch b_major b_minor b_patch

  a_major=$(echo "$a" | cut -d. -f1)
  a_minor=$(echo "$a" | cut -d. -f2)
  a_patch=$(echo "$a" | cut -d. -f3)
  b_major=$(echo "$b" | cut -d. -f1)
  b_minor=$(echo "$b" | cut -d. -f2)
  b_patch=$(echo "$b" | cut -d. -f3)

  # Default missing components to 0
  a_major=${a_major:-0}; a_minor=${a_minor:-0}; a_patch=${a_patch:-0}
  b_major=${b_major:-0}; b_minor=${b_minor:-0}; b_patch=${b_patch:-0}

  if [ "$a_major" -gt "$b_major" ] 2>/dev/null; then return 0; fi
  if [ "$a_major" -lt "$b_major" ] 2>/dev/null; then return 1; fi
  if [ "$a_minor" -gt "$b_minor" ] 2>/dev/null; then return 0; fi
  if [ "$a_minor" -lt "$b_minor" ] 2>/dev/null; then return 1; fi
  if [ "$a_patch" -ge "$b_patch" ] 2>/dev/null; then return 0; fi
  return 1
}

# === Fetch templates from GitHub (for --sync mode) ===
# Downloads templates/agents/ directory from GitHub repo main branch
fetch_templates_from_git() {
  local manifest="$1"
  local tmp_dir="$2"

  # Extract repo URL from manifest
  local repo_url
  repo_url=$(grep '^repo:' "$manifest" | sed 's/repo: *//; s/^ *"//; s/" *$//')
  if [ -z "$repo_url" ]; then
    echo "❌ Error: 'repo' field not found in manifest."
    return 1
  fi

  # Parse owner/repo: "https://github.com/pageel/para-graph" → "pageel/para-graph"
  local repo_slug
  repo_slug=$(echo "$repo_url" | sed 's|.*github.com/||; s|\.git$||')

  echo "  → Fetching templates from: $repo_slug (main branch)"

  # Fetch templates/agents directory listing from GitHub Contents API
  local api_url="https://api.github.com/repos/${repo_slug}/contents/templates/agents"
  local listing_file="$tmp_dir/api_listing.json"

  if ! curl -fsSL --max-time 30 "$api_url" -o "$listing_file" 2>/dev/null; then
    echo "❌ Error: Failed to fetch template listing from GitHub API."
    echo "   URL: $api_url"
    return 1
  fi

  # Parse JSON listing and download each subdirectory (workflows, skills, rules)
  local subdir
  for subdir in workflows skills rules; do
    local subdir_url="${api_url}/${subdir}"
    local subdir_listing="$tmp_dir/listing_${subdir}.json"

    if ! curl -fsSL --max-time 30 "$subdir_url" -o "$subdir_listing" 2>/dev/null; then
      echo "  ⚠️  No templates/$subdir found on remote (skipping)"
      continue
    fi

    mkdir -p "$tmp_dir/templates/agents/$subdir"

    # Extract download_url entries and fetch each file
    # Using grep+sed for POSIX compat (no jq dependency)
    grep '"download_url"' "$subdir_listing" | sed 's/.*"download_url": *"//; s/".*//' | while IFS= read -r dl_url; do
      if [ -n "$dl_url" ] && [ "$dl_url" != "null" ]; then
        local fname
        fname=$(basename "$dl_url")
        curl -fsSL --max-time 15 "$dl_url" -o "$tmp_dir/templates/agents/$subdir/$fname" 2>/dev/null
      fi
    done

    # Handle nested directories (e.g., skills/para-graph/) — check for type: dir entries
    grep '"type": *"dir"' "$subdir_listing" >/dev/null 2>&1 && {
      # Extract dir names
      awk -F'"' '/"name":/ {name=$4} /"type": *"dir"/ {print name}' "$subdir_listing" | while IFS= read -r dirname; do
        local nested_url="${subdir_url}/${dirname}"
        local nested_listing="$tmp_dir/listing_${subdir}_${dirname}.json"

        if curl -fsSL --max-time 30 "$nested_url" -o "$nested_listing" 2>/dev/null; then
          mkdir -p "$tmp_dir/templates/agents/$subdir/$dirname"
          grep '"download_url"' "$nested_listing" | sed 's/.*"download_url": *"//; s/".*//' | while IFS= read -r nested_dl; do
            if [ -n "$nested_dl" ] && [ "$nested_dl" != "null" ]; then
              local nfname
              nfname=$(basename "$nested_dl")
              curl -fsSL --max-time 15 "$nested_dl" -o "$tmp_dir/templates/agents/$subdir/$dirname/$nfname" 2>/dev/null
            fi
          done
        fi
      done
    }
  done

  echo "  ✅ Templates fetched successfully."
  return 0
}

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

# === Handle --sync (fetch intelligence from GitHub without tarball) ===
if [ "$SYNC_MODE" = true ]; then
  if [ ! -d "$TOOL_INSTALL_DIR" ]; then
    echo "❌ Error: Tool '$PARA_TOOL_NAME' is not installed. Install it first."
    exit 1
  fi
  if [ ! -f "$MANIFEST_FILE" ]; then
    echo "❌ Error: tool.manifest.yml not found in $TOOL_INSTALL_DIR"
    exit 1
  fi

  echo "🔄 Syncing AI intelligence for $PARA_TOOL_NAME from GitHub..."

  # Create temp directory for downloads
  SYNC_TEMP="$(mktemp -d)"

  # Fetch templates from GitHub
  if ! fetch_templates_from_git "$MANIFEST_FILE" "$SYNC_TEMP"; then
    echo "❌ Error: Failed to fetch templates from GitHub."
    rm -rf "$SYNC_TEMP"
    exit 1
  fi

  # Source hooks if available (from installed tool, not remote)
  HOOKS_FILE="$TOOL_INSTALL_DIR/install-hooks.sh"
  if [ -f "$HOOKS_FILE" ]; then
    echo "  🔌 Loading tool hooks..."
    # shellcheck source=/dev/null
    . "$HOOKS_FILE"
    if type pre_install >/dev/null 2>&1; then
      if ! pre_install; then
        echo "❌ pre_install hook failed. Aborting sync."
        rm -rf "$SYNC_TEMP"
        exit 1
      fi
    fi
  fi

  # Parse manifest and install agents using fetched templates
  parse_manifest_agents
  if [ ${#AGENT_SOURCES[@]} -eq 0 ]; then
    echo "ℹ️  No AI intelligence bundled with this tool."
    rm -rf "$SYNC_TEMP"
    exit 0
  fi

  # Override source paths to use fetched templates
  i=0
  while [ $i -lt ${#AGENT_SOURCES[@]} ]; do
    atype="${AGENT_TYPES[$i]}"
    asource="${AGENT_SOURCES[$i]}"
    atarget="${AGENT_TARGETS[$i]}"
    src_path="$SYNC_TEMP/$asource"
    dst_dir="$AGENTS_DIR/$atype"
    dst_path="$dst_dir/$atarget"

    if [ -e "$src_path" ]; then
      mkdir -p "$dst_dir"
      if [ -d "$src_path" ]; then
        [ -d "$dst_path" ] && rm -rf "$dst_path"
        cp -r "$src_path" "$dst_path"
      elif [ -f "$src_path" ]; then
        cp "$src_path" "$dst_path"
      fi
      echo "  ✅ $atype/$atarget synced."
    else
      echo "  ⚠️  $asource not found in fetched templates (skipping)"
    fi
    i=$((i + 1))
  done

  # Post-install hook
  if [ -f "$HOOKS_FILE" ] && type post_install >/dev/null 2>&1; then
    post_install
  fi

  rm -rf "$SYNC_TEMP"
  echo ""
  echo "✅ AI intelligence synced from GitHub."
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

# === Hook Detection (v1.8.5) ===
# Tools may ship install-hooks.sh with pre_install/post_install functions.
# This enables tools to control their own lifecycle without para-workspace updates.
HOOKS_FILE="$TOOL_INSTALL_DIR/install-hooks.sh"
if [ -f "$HOOKS_FILE" ]; then
  echo "  🔌 Loading tool hooks..."
  # shellcheck source=/dev/null
  . "$HOOKS_FILE"
  if type pre_install >/dev/null 2>&1; then
    if ! pre_install; then
      echo "❌ pre_install hook failed. Aborting."
      rm -rf "$TOOL_INSTALL_DIR"
      exit 1
    fi
  fi
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

# === Post-install hook (v1.8.5) ===
if [ -f "$HOOKS_FILE" ] && type post_install >/dev/null 2>&1; then
  post_install
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
