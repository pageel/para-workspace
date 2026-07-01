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
OLD_INSTALL_DIR_BACKUP=""

# === Parse arguments ===
TOOL_INPUT=""
TOOL_VERSION=""
UPDATE_MODE=false
SKIP_AGENTS=false
SKIP_MCP=false
AGENTS_ONLY=false
SYNC_MODE=false
LATEST_MODE=false

for arg in "$@"; do
  case "$arg" in
    --version=*)
      TOOL_VERSION="${arg#--version=}"
      ;;
    --local=*)
      LOCAL_TARBALL="${arg#--local=}"
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
    --latest)
      LATEST_MODE=true
      TOOL_VERSION=""
      ;;
    --help|-h)
      echo "Usage: para install-tool <name> [--version=X.Y.Z] [--local=PATH] [--latest] [--update] [--agents] [--sync] [--no-agents] [--no-mcp]"
      echo ""
      echo "  <name>           Tool name (e.g., 'para-graph' or 'graph')"
      echo ""
      echo "Options:"
      echo "  --version=X.Y.Z  Install specific version"
      echo "  --local=PATH     Install from a local tarball file"
      echo "  --latest         Force install latest version from GitHub (fails if API unreachable)"
      echo "  --update         Remove existing installation before installing"
      echo "  --agents         Install only AI intelligence (tool must be already installed)"
      echo "  --sync           Fetch latest intelligence from GitHub (no tarball download)"
      echo "  --no-agents      Skip AI intelligence prompt during install"
      echo "  --no-mcp         Skip MCP server configuration prompt"
      echo ""
      echo "Examples:"
      echo "  para install-tool para-graph"
      echo "  para install-tool graph --version=0.7.0"
      echo "  para install-tool para-graph --local=./test.tar.gz"
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
    echo "  🔍 Checking latest version from GitHub..."
    REMOTE_LATEST=""
    REMOTE_LATEST=$(curl -sf --max-time 5 \
      "https://api.github.com/repos/${TOOL_REPO}/releases/latest" 2>/dev/null \
      | grep '"tag_name"' \
      | head -1 \
      | sed 's/.*"tag_name": *"v\{0,1\}//; s/".*//' ) || true

    if [ -n "$REMOTE_LATEST" ]; then
      if [ "$REMOTE_LATEST" != "$TOOL_VERSION" ]; then
        echo "  ⚠  Registry says v${TOOL_VERSION}, but GitHub latest is v${REMOTE_LATEST}."
        echo "     Using remote version v${REMOTE_LATEST}."
        echo "     💡 Run './para update' to sync your local registry."
        echo ""
        TOOL_VERSION="$REMOTE_LATEST"
      else
        echo "  ✅ Registry is up to date (v${TOOL_VERSION})."
      fi
    else
      if [ "$LATEST_MODE" = true ]; then
        echo "  ❌ Error: --latest flag used, but could not verify latest version from GitHub (API timeout or rate-limited)."
        exit 1
      else
        echo "  ⚠️  Could not verify latest version from GitHub (API timeout or rate-limited)."
        echo "     Falling back to registry version v${TOOL_VERSION}. Use --version=X.Y.Z to override."
        echo ""
      fi
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
  AGENT_NAMES=()
  AGENT_TRIGGERS=()
  AGENT_PRIORITIES=()

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
  local item_source="" item_target="" item_version="" item_name="" item_trigger="" item_priority=""
  local tmp_file
  tmp_file=$(mktemp)

  write_item() {
    if [ -n "$item_source" ]; then
      item_name="${item_name:-}"
      item_trigger="${item_trigger:-}"
      item_priority="${item_priority:-}"
      echo "${current_type}|${item_source}|${item_target}|${item_version}|${item_name}|${item_trigger}|${item_priority}" >> "$tmp_file"
    fi
  }

  # Read from agents: line to end, stop at next top-level key
  # tr -d '\r' strips carriage returns for Windows compatibility
  tail -n +"$start_line" "$manifest" | tr -d '\r' | {
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
        "  workflows:"*) write_item; item_source=""; current_type="workflows"; continue ;;
        "  skills:"*)    write_item; item_source=""; current_type="skills"; continue ;;
        "  rules:"*)     write_item; item_source=""; current_type="rules"; continue ;;
      esac

      # Detect item start: "    - source:"
      if echo "$line" | grep -q "^    - source:"; then
        write_item
        item_source=$(echo "$line" | sed 's/.*source: *//; s/^ *"//; s/" *$//')
        item_target=""
        item_version=""
        item_name=""
        item_trigger=""
        item_priority=""
        continue
      fi

      # Read target within an item
      if echo "$line" | grep -q "^      target:"; then
        item_target=$(echo "$line" | sed 's/.*target: *//; s/^ *"//; s/" *$//')
        continue
      fi

      # Read version
      if echo "$line" | grep -q "^      version:"; then
        item_version=$(echo "$line" | sed 's/.*version: *//; s/^ *"//; s/" *$//')
        continue
      fi

      # Read name (index sync metadata)
      if echo "$line" | grep -q "^      name:"; then
        item_name=$(echo "$line" | sed 's/.*name: *//; s/^ *"//; s/" *$//')
        continue
      fi

      # Read trigger (index sync metadata)
      if echo "$line" | grep -q "^      trigger:"; then
        item_trigger=$(echo "$line" | sed 's/.*trigger: *//; s/^ *"//; s/" *$//')
        continue
      fi

      # Read priority (index sync metadata)
      if echo "$line" | grep -q "^      priority:"; then
        item_priority=$(echo "$line" | sed 's/.*priority: *//; s/^ *"//; s/" *$//')
        continue
      fi
    done
    write_item
  }

  # Read parsed items into arrays
  if [ -s "$tmp_file" ]; then
    while IFS='|' read -r atype asource atarget aversion aname atrigger apriority; do
      AGENT_TYPES+=("$atype")
      AGENT_SOURCES+=("$asource")
      AGENT_TARGETS+=("$atarget")
      AGENT_VERSIONS+=("$aversion")
      AGENT_NAMES+=("$aname")
      AGENT_TRIGGERS+=("$atrigger")
      AGENT_PRIORITIES+=("$apriority")
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

# Helper: safe copy a single agent file with dirty-check & prompt
copy_agent_file_safe() {
  local src="$1"
  local dst="$2"
  local atype="$3"
  local atarget="$4"
  local rel_src="$5"

  # If target doesn't exist, copy it directly
  if [ ! -e "$dst" ]; then
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    # Save a backup of the unmodified template for future conflict detection (dirty check)
    if [ -n "$TOOL_INSTALL_DIR" ]; then
      local backup_dst="$TOOL_INSTALL_DIR/.templates_backup/$rel_src"
      mkdir -p "$(dirname "$backup_dst")"
      cp "$src" "$backup_dst"
    fi
    echo "  ✅ $atype/$atarget installed."
    return 0
  fi

  # If target is directory, warn
  if [ -d "$dst" ]; then
    echo "  ⚠️  Warning: Target $dst is a directory, cannot overwrite with file $src"
    return 1
  fi

  # If identical, skip silently
  if cmp -s "$src" "$dst"; then
    return 0
  fi

  # If there is a backup of the old template, check if workspace matches it
  local old_src=""
  if [ -n "$OLD_INSTALL_DIR_BACKUP" ]; then
    if [ -f "$OLD_INSTALL_DIR_BACKUP/.templates_backup/$rel_src" ]; then
      old_src="$OLD_INSTALL_DIR_BACKUP/.templates_backup/$rel_src"
    elif [ -f "$OLD_INSTALL_DIR_BACKUP/$rel_src" ]; then
      old_src="$OLD_INSTALL_DIR_BACKUP/$rel_src"
    fi
  elif [ -n "$TOOL_INSTALL_DIR" ] && [ -f "$TOOL_INSTALL_DIR/.templates_backup/$rel_src" ]; then
    # Fallback for --sync mode: compare with the last installed templates backup
    old_src="$TOOL_INSTALL_DIR/.templates_backup/$rel_src"
  fi

  if [ -n "$old_src" ] && [ -f "$old_src" ] && cmp -s "$old_src" "$dst"; then
    # Unmodified by user -> auto-overwrite
    cp "$src" "$dst"
    # Save a backup of the unmodified template for future conflict detection (dirty check)
    if [ -n "$TOOL_INSTALL_DIR" ]; then
      local backup_dst="$TOOL_INSTALL_DIR/.templates_backup/$rel_src"
      mkdir -p "$(dirname "$backup_dst")"
      cp "$src" "$backup_dst"
    fi
    echo "  ✅ $atype/$atarget updated."
    return 0
  fi

  # Workspace file has been customized! Prompt user.
  echo ""
  echo "  ⚠️  Template conflict: $atype/$atarget has been modified locally."
  echo "     Local file:   $dst"
  echo "     New template: $src"
  
  if command -v diff &>/dev/null; then
    echo "  --- Preview of differences (Local vs New Template) ---"
    diff -u "$dst" "$src" | head -n 20 || true
    echo "  -------------------------------------------------------"
  fi

  local answer=""
  if [ -t 0 ]; then
    printf "     Overwrite with the new template? (y/N): "
    read -r answer || true
  else
    if read -t 0 2>/dev/null; then
      read -r answer || true
    else
      # Non-interactive default is "n" to preserve customizations (safe default)
      echo "     Non-interactive environment detected. Preserving local customizations."
      answer="n"
    fi
  fi

  if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
    cp "$src" "$dst"
    # Save a backup of the unmodified template for future conflict detection (dirty check)
    if [ -n "$TOOL_INSTALL_DIR" ]; then
      local backup_dst="$TOOL_INSTALL_DIR/.templates_backup/$rel_src"
      mkdir -p "$(dirname "$backup_dst")"
      cp "$src" "$backup_dst"
    fi
    echo "  ✅ $atype/$atarget overwritten."
  else
    echo "  ⏭️  $atype/$atarget skipped (local customizations preserved)."
  fi
}

# Helper: safe copy a directory of templates recursively
copy_agents_recursive() {
  local src_dir="$1"
  local dst_dir="$2"
  local atype="$3"
  local atarget="$4"
  local rel_src_dir="$5"
  local rel_file src_file dst_file rel_src_file

  mkdir -p "$dst_dir"

  # Find command resolution to avoid Windows System32 find.exe conflict
  local find_cmd="find"
  if [ -x "/usr/bin/find" ]; then
    find_cmd="/usr/bin/find"
  elif [ -x "/bin/find" ]; then
    find_cmd="/bin/find"
  fi

  # Find all files in src_dir relative to src_dir
  (
    cd "$src_dir" && "$find_cmd" . -type f
  ) | while read -r rel_file; do
    rel_file="${rel_file#./}"
    src_file="$src_dir/$rel_file"
    dst_file="$dst_dir/$rel_file"
    rel_src_file="$rel_src_dir/$rel_file"
    copy_agent_file_safe "$src_file" "$dst_file" "$atype" "$atarget/$rel_file" "$rel_src_file"
  done
}

# Update rules/skills catalog index file (.agents/rules.md or .agents/skills.md)
update_workspace_index() {
  local atype="$1"
  local atarget="$2"
  local aname="$3"
  local atrigger="$4"
  local apriority="$5"

  # We only register rules and skills
  if [ "$atype" != "rules" ] && [ "$atype" != "skills" ]; then
    return 0
  fi

  # Skip if name or trigger is empty (no index sync metadata declared)
  if [ -z "$aname" ] || [ -z "$atrigger" ]; then
    return 0
  fi

  local index_file=""
  local relative_path=""
  if [ "$atype" = "rules" ]; then
    index_file="$AGENTS_DIR/rules.md"
    relative_path="rules/$atarget"
  else
    index_file="$AGENTS_DIR/skills.md"
    # Target can be a directory (skills/csa/) or a file
    if echo "$atarget" | grep -q "/$"; then
      relative_path="skills/${atarget}SKILL.md"
    else
      relative_path="skills/$atarget"
    fi
  fi

  if [ ! -f "$index_file" ]; then
    echo "  ⚠️  Index file not found: $index_file"
    return 0
  fi

  # Escape variables for safe sed/regex usage (security mitigation against command injection)
  local escaped_path
  escaped_path=$(echo "$relative_path" | sed 's/\//\\\//g')
  
  # Escape / and & in replacement to avoid breaking sed syntax
  local new_row
  if [ "$atype" = "rules" ]; then
    new_row="| $aname | $atrigger | rules/$atarget | $apriority |"
  else
    new_row="| $aname | $atrigger | $relative_path |"
  fi
  
  local escaped_row
  escaped_row=$(echo "$new_row" | sed 's/\//\\\//g; s/\&/\\\&/g')

  # Check if this file/path already exists in the index table
  if grep -q "|.*$relative_path" "$index_file"; then
    echo "  🔄 Updating index for $relative_path in $index_file..."
    local temp_index
    temp_index=$(mktemp)
    sed "s/.*$escaped_path.*/$escaped_row/" "$index_file" > "$temp_index"
    
    if [ -s "$temp_index" ]; then
      mv "$temp_index" "$index_file"
    else
      rm -f "$temp_index"
    fi
  else
    echo "  📝 Appending new index for $relative_path to $index_file..."
    # Ensure there is a trailing newline in the file before appending (POSIX)
    if [ -n "$(tail -c 1 "$index_file" 2>/dev/null)" ]; then
      echo "" >> "$index_file"
    fi
    echo "$new_row" >> "$index_file"
  fi
}

# Copy agent files from tool install dir to .agents/
install_agents() {
  local src_base="${1:-$TOOL_INSTALL_DIR}"
  local i=0
  while [ $i -lt ${#AGENT_SOURCES[@]} ]; do
    local atype="${AGENT_TYPES[$i]}"
    local asource="${AGENT_SOURCES[$i]}"
    local atarget="${AGENT_TARGETS[$i]}"

    # Path traversal protection
    if echo "$asource" | grep -q '\.\./'; then
      echo "❌ Security Error: Path traversal attempt detected in source: $asource"
      exit 1
    fi
    if echo "$atarget" | grep -q '\.\./'; then
      echo "❌ Security Error: Path traversal attempt detected in target: $atarget"
      exit 1
    fi

    local src_path="$src_base/$asource"
    local dst_dir="$AGENTS_DIR/$atype"
    local dst_path="$dst_dir/$atarget"

    if [ -d "$src_path" ]; then
      # Directory copy (skills) — recursive safe copy
      copy_agents_recursive "$src_path" "$dst_path" "$atype" "$atarget" "$asource"
    elif [ -f "$src_path" ]; then
      # File copy (workflows, rules)
      copy_agent_file_safe "$src_path" "$dst_path" "$atype" "$atarget" "$asource"
    else
      # Suppress warning if tool uses decoupled distribution via hooks
      if [ ! -f "$TOOL_INSTALL_DIR/install-hooks.sh" ]; then
        echo "  ⚠️  Source not found: $src_path (skipping)"
      fi
    fi

    # Auto-sync index if name and trigger are provided in manifest
    update_workspace_index "$atype" "$atarget" "${AGENT_NAMES[$i]}" "${AGENT_TRIGGERS[$i]}" "${AGENT_PRIORITIES[$i]}"

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

# === Handle --sync (fetch intelligence from GitHub or Local Dev without tarball) ===
# @para-doc [csa-install-tool-sync-local]
# @para-doc [csa-install-tool-sync-remote-manifest]
# @para-doc [csa-install-tool-index-sync]
if [ "$SYNC_MODE" = true ]; then
  if [ ! -d "$TOOL_INSTALL_DIR" ]; then
    echo "❌ Error: Tool '$PARA_TOOL_NAME' is not installed. Install it first."
    exit 1
  fi

  # Check if there is a local project folder in WORKSPACE_ROOT/Projects/
  LOCAL_PROJECT_DIR=""
  if [ -d "$WORKSPACE_ROOT/Projects/$PARA_TOOL_NAME/repo" ]; then
    LOCAL_PROJECT_DIR="$WORKSPACE_ROOT/Projects/$PARA_TOOL_NAME/repo"
  elif [ -d "$WORKSPACE_ROOT/Projects/$TOOL_NAME/repo" ]; then
    LOCAL_PROJECT_DIR="$WORKSPACE_ROOT/Projects/$TOOL_NAME/repo"
  fi

  SYNC_TEMP="$(mktemp -d)"

  if [ -n "$LOCAL_PROJECT_DIR" ]; then
    echo "🔄 Syncing AI intelligence for $PARA_TOOL_NAME from local development project..."
    if [ -f "$LOCAL_PROJECT_DIR/tool.manifest.yml" ]; then
      # Overwrite manifest file with local manifest first (Source Manifest Overwrite)
      cp "$LOCAL_PROJECT_DIR/tool.manifest.yml" "$MANIFEST_FILE"
    fi
    if [ -f "$LOCAL_PROJECT_DIR/install-hooks.sh" ]; then
      cp "$LOCAL_PROJECT_DIR/install-hooks.sh" "$TOOL_INSTALL_DIR/install-hooks.sh"
      # Re-load HOOKS_FILE path to point to the newly copied hooks
      HOOKS_FILE="$TOOL_INSTALL_DIR/install-hooks.sh"
    fi
    if [ -d "$LOCAL_PROJECT_DIR/templates/agents" ]; then
      mkdir -p "$SYNC_TEMP/templates"
      cp -r "$LOCAL_PROJECT_DIR/templates/agents" "$SYNC_TEMP/templates/"
      echo "  ✅ Synced templates from local development project: $LOCAL_PROJECT_DIR"
    else
      echo "  ⚠️  Local project found but no templates/agents directory exists."
    fi
  else
    echo "🔄 Syncing AI intelligence for $PARA_TOOL_NAME from GitHub..."
    if [ ! -f "$MANIFEST_FILE" ]; then
      echo "❌ Error: tool.manifest.yml not found in $TOOL_INSTALL_DIR"
      rm -rf "$SYNC_TEMP"
      exit 1
    fi

    # Fetch latest manifest from GitHub repo raw URL to avoid stale local manifest
    if [ -n "$TOOL_REPO" ]; then
      raw_manifest_url="https://raw.githubusercontent.com/${TOOL_REPO}/main/tool.manifest.yml"
      echo "  🔍 Fetching latest manifest from GitHub..."
      curl -fsSL --max-time 15 "$raw_manifest_url" -o "$MANIFEST_FILE" 2>/dev/null || true
    fi

    # Fetch templates from GitHub
    if ! fetch_templates_from_git "$MANIFEST_FILE" "$SYNC_TEMP"; then
      echo "❌ Error: Failed to fetch templates from GitHub."
      rm -rf "$SYNC_TEMP"
      exit 1
    fi
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
  install_agents "$SYNC_TEMP"

  # Post-install hook
  if [ -f "$HOOKS_FILE" ] && type post_install >/dev/null 2>&1; then
    post_install
  fi

  rm -rf "$SYNC_TEMP"
  echo ""
  echo "✅ AI intelligence synced successfully."
  exit 0
fi

if [ -d "$TOOL_INSTALL_DIR" ] && [ "$UPDATE_MODE" = false ]; then
  echo "⚠️  Tool '$PARA_TOOL_NAME' is already installed at: $TOOL_INSTALL_DIR"
  echo "   Use --update to reinstall."
  exit 1
fi

if [ "$UPDATE_MODE" = true ] && [ -d "$TOOL_INSTALL_DIR" ]; then
  echo "🔄 Backing up existing installation for dirty check..."
  OLD_INSTALL_DIR_BACKUP="$(mktemp -d)"
  cp -r "$TOOL_INSTALL_DIR/"* "$OLD_INSTALL_DIR_BACKUP/" 2>/dev/null || true
  trap 'rm -rf "$OLD_INSTALL_DIR_BACKUP"' EXIT
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
TEMP_DIR="$(mktemp -d)"

if [ -n "$LOCAL_TARBALL" ]; then
  echo "📦 Installing $PARA_TOOL_NAME from local tarball: $LOCAL_TARBALL..."
  echo ""
  
  if [ ! -s "$LOCAL_TARBALL" ]; then
    echo "❌ Error: Local tarball not found or empty: $LOCAL_TARBALL"
    rm -rf "$TEMP_DIR"
    exit 1
  fi
  
  TARBALL_FILE="$LOCAL_TARBALL"
  
  # For local installs, we might not have a TOOL_VERSION if --version wasn't provided
  if [ -z "$TOOL_VERSION" ]; then
    # Default to 0.0.0-local to satisfy later version checks
    TOOL_VERSION="0.0.0-local"
  fi
else
  echo "📦 Installing $PARA_TOOL_NAME v$TOOL_VERSION..."
  echo ""

  # Interpolate version into tarball URL
  TARBALL_URL="$(echo "$TOOL_TARBALL_PATTERN" | sed "s/{{VERSION}}/$TOOL_VERSION/g")"

  echo "  → Downloading from: $TARBALL_URL"

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

# === Handle npm pack structure (package/ prefix) ===
if [ ! -f "$TOOL_INSTALL_DIR/tool.manifest.yml" ] && [ -f "$TOOL_INSTALL_DIR/package/tool.manifest.yml" ]; then
  # Move all files (including hidden) up one level
  mv "$TOOL_INSTALL_DIR/package/"* "$TOOL_INSTALL_DIR/"
  mv "$TOOL_INSTALL_DIR/package/".* "$TOOL_INSTALL_DIR/" 2>/dev/null || true
  rm -rf "$TOOL_INSTALL_DIR/package"
fi

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
      if [ ! -f "$HOOKS_FILE" ]; then
        echo ""
        echo "  ✅ AI intelligence installed locally."
      fi
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
