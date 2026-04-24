#!/bin/bash
# PARA Workspace — Install Tool Plugin
# Usage: ./para install-tool <name> [--version=X.Y.Z] [--update]
#
# Downloads and installs a tool plugin from the PARA Tool Registry.
# Generates a wrapper script for dynamic CLI routing.

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

# === Parse arguments ===
TOOL_INPUT=""
TOOL_VERSION=""
UPDATE_MODE=false

for arg in "$@"; do
  case "$arg" in
    --version=*)
      TOOL_VERSION="${arg#--version=}"
      ;;
    --update)
      UPDATE_MODE=true
      ;;
    --help|-h)
      echo "Usage: para install-tool <name> [--version=X.Y.Z] [--update]"
      echo ""
      echo "  <name>           Tool name (e.g., 'para-graph' or 'graph')"
      echo "  --version=X.Y.Z  Install specific version (default: latest)"
      echo "  --update         Remove existing installation before installing"
      echo ""
      echo "Examples:"
      echo "  para install-tool para-graph"
      echo "  para install-tool graph --version=0.7.0"
      echo "  para install-tool para-graph --update"
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

# === Handle --update ===
TOOL_INSTALL_DIR="$TOOLS_DIR/$TOOL_NAME"
WRAPPER_SCRIPT="$COMMANDS_DIR/$TOOL_NAME.sh"

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
