#!/usr/bin/env bash
# test-mcp-setup.sh — Integration tests for mcp-setup, mcp-list, mcp-remove commands
# Usage: bash tests/cli/test-mcp-setup.sh

set -euo pipefail

echo "=== MCP Setup Integration Tests ==="
echo ""

PASS=0
FAIL=0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_TMP=$(mktemp -d)

# Cleanup on exit
trap 'rm -rf "$TEST_TMP"' EXIT

# Setup mock workspace
export WORKSPACE_ROOT="$TEST_TMP/workspace"
mkdir -p "$WORKSPACE_ROOT/.para/tools/mock-tool/dist"
mkdir -p "$WORKSPACE_ROOT/Projects/para-mock-tool/repo/dist"

# Create mock entry points
echo "// mock" > "$WORKSPACE_ROOT/.para/tools/mock-tool/dist/cli.js"
echo "// mock" > "$WORKSPACE_ROOT/Projects/para-mock-tool/repo/dist/cli.js"

# Create mock manifest WITH mcp: block
cat > "$WORKSPACE_ROOT/Projects/para-mock-tool/repo/tool.manifest.yml" << 'MANIFEST'
name: para-mock-tool
version: "1.0.0"
runtime: node
min_runtime_version: "18.0.0"
entry: dist/cli.js
description: "Mock tool for testing"
repo: "https://github.com/test/para-mock-tool"

mcp:
  server_name: "para-mock-tool"
  transport: stdio
  serve_args: ["serve", "${WORKSPACE_ROOT}"]
  description: "Mock MCP server for testing"
MANIFEST

# Create mock manifest WITHOUT mcp: block (for backward compat test)
mkdir -p "$WORKSPACE_ROOT/Projects/para-plain/repo/dist"
echo "// mock" > "$WORKSPACE_ROOT/Projects/para-plain/repo/dist/cli.js"
cat > "$WORKSPACE_ROOT/Projects/para-plain/repo/tool.manifest.yml" << 'MANIFEST'
name: para-plain
version: "1.0.0"
runtime: node
min_runtime_version: "18.0.0"
entry: dist/cli.js
description: "Plain tool without MCP"
repo: "https://github.com/test/para-plain"
MANIFEST

assert_contains() {
  local label="$1"
  local needle="$2"
  local haystack="$3"
  echo -n "  $label... "
  if echo "$haystack" | grep -qF -- "$needle"; then
    echo "PASS"
    PASS=$((PASS+1))
  else
    echo "FAIL — '$needle' not found in output"
    FAIL=$((FAIL+1))
  fi
}

assert_not_contains() {
  local label="$1"
  local needle="$2"
  local haystack="$3"
  echo -n "  $label... "
  if echo "$haystack" | grep -qF -- "$needle"; then
    echo "FAIL — '$needle' found but should not be"
    FAIL=$((FAIL+1))
  else
    echo "PASS"
    PASS=$((PASS+1))
  fi
}

assert_exit_code() {
  local label="$1"
  local expected="$2"
  local actual="$3"
  echo -n "  $label... "
  if [ "$expected" = "$actual" ]; then
    echo "PASS"
    PASS=$((PASS+1))
  else
    echo "FAIL — expected exit $expected, got $actual"
    FAIL=$((FAIL+1))
  fi
}

# ============================================================
echo "--- mcp-setup --print-only ---"

output=$("$REPO_ROOT/cli/commands/mcp-setup.sh" "mock-tool" --print-only 2>&1) || true
assert_contains "Shows server name" "para-mock-tool" "$output"
assert_contains "Shows transport" "stdio" "$output"
assert_contains "Shows JSON snippet" '"command": "node"' "$output"
assert_contains "Has entry path" "dist/cli.js" "$output"
assert_contains "Has serve arg" "serve" "$output"

# ============================================================
echo ""
echo "--- mcp-setup handles Windows cygpath ---"

# Temporarily mock cygpath for this test only
mkdir -p "$TEST_TMP/cygbin"
cat > "$TEST_TMP/cygbin/cygpath" << 'EOF'
#!/bin/sh
if [ "$1" = "-m" ]; then
  echo "$2" | sed 's|^/|C:/|'
else
  echo "$2"
fi
EOF
chmod +x "$TEST_TMP/cygbin/cygpath"

# Run with fake cygpath in PATH
output=$(PATH="$TEST_TMP/cygbin:$PATH" "$REPO_ROOT/cli/commands/mcp-setup.sh" "mock-tool" --print-only 2>&1) || true
assert_contains "Uses cygpath for entry_path" "C:/" "$output"
assert_contains "Uses cygpath for serve_args" "C:/" "$output"

# ============================================================
echo ""
echo "--- mcp-setup --print-only with para- prefix ---"

output=$("$REPO_ROOT/cli/commands/mcp-setup.sh" "para-mock-tool" --print-only 2>&1) || true
assert_contains "Works with para- prefix" "para-mock-tool" "$output"

# ============================================================
echo ""
echo "--- mcp-setup --help ---"

output=$("$REPO_ROOT/cli/commands/mcp-setup.sh" --help 2>&1) || true
assert_contains "Help shows usage" "Usage:" "$output"
assert_contains "Help shows --ide" "--ide" "$output"
assert_contains "Help shows --print-only" "--print-only" "$output"

# ============================================================
echo ""
echo "--- mcp-setup with missing tool ---"

exit_code=0
output=$("$REPO_ROOT/cli/commands/mcp-setup.sh" "nonexistent-tool" --print-only 2>&1) || exit_code=$?
assert_exit_code "Missing tool exits with error" "1" "$exit_code"
assert_contains "Missing tool shows error" "not found" "$output"

# ============================================================
echo ""
echo "--- mcp-list ---"

output=$("$REPO_ROOT/cli/commands/mcp-list.sh" 2>&1) || true
assert_contains "Lists mock-tool" "para-mock-tool" "$output"
assert_not_contains "Does not list plain tool" "para-plain" "$output"
assert_contains "Shows transport column" "stdio" "$output"

# ============================================================
echo ""
echo "--- mcp-list --json ---"

output=$("$REPO_ROOT/cli/commands/mcp-list.sh" --json 2>&1) || true
assert_contains "JSON has server_name" '"server_name"' "$output"
assert_contains "JSON has transport" '"transport"' "$output"

# Validate JSON
echo "$output" > "$TEST_TMP/mcp-list.json"
echo -n "  JSON output is valid... "
if jq empty "$TEST_TMP/mcp-list.json" 2>/dev/null; then
  echo "PASS"
  PASS=$((PASS+1))
else
  echo "FAIL — invalid JSON"
  FAIL=$((FAIL+1))
fi

# ============================================================
echo ""
echo "--- mcp-remove --help ---"

output=$("$REPO_ROOT/cli/commands/mcp-remove.sh" --help 2>&1) || true
assert_contains "Remove help shows usage" "Usage:" "$output"
assert_contains "Remove help shows --ide" "--ide" "$output"

# ============================================================
echo ""
echo "--- mcp-setup writes to IDE config ---"

if command -v jq &> /dev/null; then
  # Create fake IDE config dir
  FAKE_HOME="$TEST_TMP/fake_home"
  mkdir -p "$FAKE_HOME/.gemini/antigravity"
  
  # Override HOME temporarily for this test
  ORIG_HOME="$HOME"
  export HOME="$FAKE_HOME"
  
  # Run mcp-setup with --ide=antigravity
  "$REPO_ROOT/cli/commands/mcp-setup.sh" "mock-tool" --ide=antigravity 2>&1 || true
  
  CONFIG_FILE="$FAKE_HOME/.gemini/antigravity/mcp_config.json"
  echo -n "  Config file created... "
  if [ -f "$CONFIG_FILE" ]; then
    echo "PASS"
    PASS=$((PASS+1))
  else
    echo "FAIL — file not found"
    FAIL=$((FAIL+1))
  fi
  
  echo -n "  Config has correct server... "
  if [ -f "$CONFIG_FILE" ] && jq -e '.mcpServers."para-mock-tool"' "$CONFIG_FILE" &>/dev/null; then
    echo "PASS"
    PASS=$((PASS+1))
  else
    echo "FAIL"
    FAIL=$((FAIL+1))
  fi
  
  # Restore HOME
  export HOME="$ORIG_HOME"
else
  echo "  ⏭️  Skipping write test — jq not installed"
fi

# ============================================================
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
