#!/usr/bin/env bash
# test-mcp-config.sh — Unit tests for cli/lib/mcp-config.sh
# Usage: bash tests/cli/test-mcp-config.sh

set -euo pipefail

echo "=== MCP Config Library Tests ==="
echo ""

PASS=0
FAIL=0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_TMP=$(mktemp -d)

# Cleanup on exit
trap 'rm -rf "$TEST_TMP"' EXIT

# Set WORKSPACE_ROOT for test context
export WORKSPACE_ROOT="$TEST_TMP/workspace"
mkdir -p "$WORKSPACE_ROOT/Projects/para-graph/repo/dist"
mkdir -p "$WORKSPACE_ROOT/.para/tools/graph/dist"

# Create fake entry points
echo "// fake" > "$WORKSPACE_ROOT/Projects/para-graph/repo/dist/cli.js"
echo "// fake" > "$WORKSPACE_ROOT/.para/tools/graph/dist/cli.js"

# Source the library
source "$REPO_ROOT/cli/lib/mcp-config.sh"

assert_eq() {
  local label="$1"
  local expected="$2"
  local actual="$3"
  echo -n "  $label... "
  if [ "$expected" = "$actual" ]; then
    echo "PASS"
    PASS=$((PASS+1))
  else
    echo "FAIL"
    echo "    Expected: $expected"
    echo "    Actual:   $actual"
    FAIL=$((FAIL+1))
  fi
}

assert_contains() {
  local label="$1"
  local needle="$2"
  local haystack="$3"
  echo -n "  $label... "
  if echo "$haystack" | grep -q "$needle"; then
    echo "PASS"
    PASS=$((PASS+1))
  else
    echo "FAIL — '$needle' not found in output"
    FAIL=$((FAIL+1))
  fi
}

assert_file_exists() {
  local label="$1"
  local path="$2"
  echo -n "  $label... "
  if [ -f "$path" ]; then
    echo "PASS"
    PASS=$((PASS+1))
  else
    echo "FAIL — file not found: $path"
    FAIL=$((FAIL+1))
  fi
}

assert_valid_json() {
  local label="$1"
  local path="$2"
  echo -n "  $label... "
  if jq empty "$path" 2>/dev/null; then
    echo "PASS"
    PASS=$((PASS+1))
  else
    echo "FAIL — invalid JSON: $path"
    FAIL=$((FAIL+1))
  fi
}

# ============================================================
echo "--- resolve_ide_config_path ---"

result=$(resolve_ide_config_path "antigravity")
assert_contains "Antigravity path (both) contains config/mcp_config.json" "config/mcp_config.json" "$result"
assert_contains "Antigravity path (both) contains antigravity/mcp_config.json" "antigravity/mcp_config.json" "$result"

result=$(resolve_ide_config_path "antigravity-ide")
assert_contains "Antigravity IDE 2.x path contains config/mcp_config.json" "config/mcp_config.json" "$result"

result=$(resolve_ide_config_path "antigravity-v1")
assert_contains "Antigravity v1.x path contains antigravity/mcp_config.json" "mcp_config.json" "$result"

result=$(resolve_ide_config_path "cursor")
assert_contains "Cursor path contains mcp.json" "mcp.json" "$result"

result=$(resolve_ide_config_path "claude")
assert_contains "Claude path contains claude_desktop_config.json" "claude_desktop_config.json" "$result"

# Test invalid IDE
echo -n "  Unknown IDE returns error... "
if resolve_ide_config_path "vscode" 2>/dev/null; then
  echo "FAIL — should have failed"
  FAIL=$((FAIL+1))
else
  echo "PASS"
  PASS=$((PASS+1))
fi

# ============================================================
echo ""
echo "--- detect_installed_ides ---"

TEST_HOME="$TEST_TMP/fake_home"
mkdir -p "$TEST_HOME"
ORIG_HOME="$HOME"
export HOME="$TEST_HOME"

# Test 1: No IDEs installed
result=$(detect_installed_ides)
assert_eq "No IDEs detected initially" "" "$result"

# Test 2: Only Antigravity IDE 2.x installed
mkdir -p "$HOME/.gemini/antigravity-ide"
result=$(detect_installed_ides)
assert_contains "Detects antigravity-ide when App Data 2.x exists" "antigravity-ide" "$result"
assert_contains "Detects antigravity (both) when App Data 2.x exists" "antigravity" "$result"

# Test 3: Only Antigravity v1.x installed
rm -rf "$HOME/.gemini/antigravity-ide"
mkdir -p "$HOME/.gemini/antigravity"
result=$(detect_installed_ides)
assert_contains "Detects antigravity-v1 when App Data 1.x exists" "antigravity-v1" "$result"
assert_contains "Detects antigravity (both) when App Data 1.x exists" "antigravity" "$result"

export HOME="$ORIG_HOME"

# ============================================================
echo ""
echo "--- generate_mcp_snippet ---"

snippet=$(generate_mcp_snippet "para-graph" "node" "/path/to/cli.js" "serve" "/workspace")
assert_contains "Snippet contains server name" "para-graph" "$snippet"
assert_contains "Snippet contains command node" '"command": "node"' "$snippet"
assert_contains "Snippet contains entry path" "/path/to/cli.js" "$snippet"
assert_contains "Snippet contains serve arg" '"serve"' "$snippet"

# Verify it's valid JSON
echo "$snippet" > "$TEST_TMP/snippet.json"
assert_valid_json "Snippet is valid JSON" "$TEST_TMP/snippet.json"

# Test missing arguments
echo -n "  Missing args returns error... "
if generate_mcp_snippet "" "" "" 2>/dev/null; then
  echo "FAIL — should have failed"
  FAIL=$((FAIL+1))
else
  echo "PASS"
  PASS=$((PASS+1))
fi

# ============================================================
echo ""
echo "--- merge_mcp_config (jq required) ---"

if command -v jq &> /dev/null; then
  # Test 1: New file creation
  CONFIG_PATH="$TEST_TMP/new_config.json"
  snippet=$(generate_mcp_snippet "test-server" "node" "/test/cli.js" "serve" "/ws")
  merge_mcp_config "$CONFIG_PATH" "test-server" "$snippet"
  assert_file_exists "Config file created" "$CONFIG_PATH"
  assert_valid_json "Config is valid JSON" "$CONFIG_PATH"

  # Verify content
  server_cmd=$(jq -r '.mcpServers."test-server".command' "$CONFIG_PATH")
  assert_eq "Server command is node" "node" "$server_cmd"

  # Test 2: Merge into existing config
  CONFIG_PATH_2="$TEST_TMP/existing_config.json"
  echo '{ "mcpServers": { "other-server": { "command": "python", "args": ["serve"] } } }' > "$CONFIG_PATH_2"
  snippet2=$(generate_mcp_snippet "new-server" "node" "/new/cli.js" "serve" "/ws")
  merge_mcp_config "$CONFIG_PATH_2" "new-server" "$snippet2"
  assert_valid_json "Merged config is valid JSON" "$CONFIG_PATH_2"

  # Verify both servers exist
  other_cmd=$(jq -r '.mcpServers."other-server".command' "$CONFIG_PATH_2")
  assert_eq "Existing server preserved" "python" "$other_cmd"
  new_cmd=$(jq -r '.mcpServers."new-server".command' "$CONFIG_PATH_2")
  assert_eq "New server added" "node" "$new_cmd"

  # Test 3: Invalid JSON file
  echo -n "  Invalid JSON file returns error... "
  echo "not json" > "$TEST_TMP/invalid.json"
  if merge_mcp_config "$TEST_TMP/invalid.json" "test" "$snippet" 2>/dev/null; then
    echo "FAIL — should have failed"
    FAIL=$((FAIL+1))
  else
    echo "PASS"
    PASS=$((PASS+1))
  fi
  # Test 4: Atomic Write & Permission Preservation
  echo ""
  echo "--- Atomic Write & Permissions ---"
  
  ATOMIC_CONFIG="$TEST_TMP/atomic_config.json"
  echo '{ "mcpServers": {} }' > "$ATOMIC_CONFIG"
  chmod 600 "$ATOMIC_CONFIG"
  
  # Inject a mock script to simulate write failure
  MOCK_FS="$TEST_TMP/mock_fs.js"
  cat << 'EOF' > "$MOCK_FS"
const fs = require('fs');
const originalWrite = fs.writeFileSync;
fs.writeFileSync = function(file, data, options) {
  if (file.includes('crash_test')) {
    // Truncate and write partial data to simulate crash during write
    originalWrite.call(fs, file, "{ corrupted }", options);
    throw new Error("Disk full simulation");
  }
  return originalWrite.call(fs, file, data, options);
}
EOF

  # Set NODE_OPTIONS to require the mock
  export NODE_OPTIONS="--require $MOCK_FS"
  
  # Run merge_mcp_config on normal file and check permissions
  merge_mcp_config "$ATOMIC_CONFIG" "test-perm" "$snippet"
  
  echo -n "  File permission is preserved (600)... "
  PERM=$(stat -c "%a" "$ATOMIC_CONFIG" 2>/dev/null || stat -f "%Lp" "$ATOMIC_CONFIG")
  if [ "$PERM" = "600" ]; then
    echo "PASS"
    PASS=$((PASS+1))
  else
    echo "FAIL — Expected 600, got $PERM"
    FAIL=$((FAIL+1))
  fi

  # Run on crash file and ensure original is NOT corrupted
  CRASH_CONFIG="$TEST_TMP/crash_test_config.json"
  echo '{ "mcpServers": { "original": { "command": "safe" } } }' > "$CRASH_CONFIG"
  
  echo -n "  Original file is NOT corrupted on write failure... "
  if merge_mcp_config "$CRASH_CONFIG" "test-crash" "$snippet" 2>/dev/null; then
    echo "FAIL — Should have returned error"
    FAIL=$((FAIL+1))
  else
    # Check if original content is still valid JSON and has original content
    if jq -e '.mcpServers.original.command == "safe"' "$CRASH_CONFIG" >/dev/null 2>&1; then
      echo "PASS"
      PASS=$((PASS+1))
    else
      echo "FAIL — File was corrupted/truncated!"
      FAIL=$((FAIL+1))
    fi
  fi
  
  unset NODE_OPTIONS

else
  echo "  ⏭️  Skipping merge tests — jq not installed"
fi

# ============================================================
echo ""
echo "--- backup_config ---"

BACKUP_TEST="$TEST_TMP/backup_test.json"
echo '{"test": true}' > "$BACKUP_TEST"
backup_config "$BACKUP_TEST"
BACKUP_COUNT=$(ls "$TEST_TMP"/backup_test.json.bak.* 2>/dev/null | wc -l)
echo -n "  Backup file created... "
if [ "$BACKUP_COUNT" -ge 1 ]; then
  echo "PASS"
  PASS=$((PASS+1))
else
  echo "FAIL — no backup found"
  FAIL=$((FAIL+1))
fi

# Test backup of non-existent file (should succeed silently)
echo -n "  Non-existent file backup succeeds... "
if backup_config "$TEST_TMP/nonexistent.json" 2>/dev/null; then
  echo "PASS"
  PASS=$((PASS+1))
else
  echo "FAIL — should succeed"
  FAIL=$((FAIL+1))
fi

# ============================================================
echo ""
echo "--- resolve_tool_entry_path (2-Tier) ---"

# Tier 1: Dev path preferred
result=$(resolve_tool_entry_path "graph" "dist/cli.js")
assert_contains "Tier 1 Dev path returned" "Projects/para-graph/repo/dist/cli.js" "$result"

# Remove Dev path, verify Tier 2 fallback
rm "$WORKSPACE_ROOT/Projects/para-graph/repo/dist/cli.js"
result=$(resolve_tool_entry_path "graph" "dist/cli.js")
assert_contains "Tier 2 Prod path fallback" ".para/tools/graph/dist/cli.js" "$result"

# Both missing
rm "$WORKSPACE_ROOT/.para/tools/graph/dist/cli.js"
echo -n "  Both paths missing returns error... "
if resolve_tool_entry_path "graph" "dist/cli.js" 2>/dev/null; then
  echo "FAIL — should have failed"
  FAIL=$((FAIL+1))
else
  echo "PASS"
  PASS=$((PASS+1))
fi

# ============================================================
echo ""
echo "--- mcp-setup.sh integration tests ---"

# Setup mock manifest
mkdir -p "$WORKSPACE_ROOT/Projects/para-graph/repo"
cat <<EOF > "$WORKSPACE_ROOT/Projects/para-graph/repo/tool.manifest.yml"
runtime: node
entry: dist/cli.js
mcp:
  server_name: "para-graph"
  transport: "stdio"
  serve_args: ["serve", "\${WORKSPACE_ROOT}"]
  description: "Test Server"
EOF

# Setup fake entry point
mkdir -p "$WORKSPACE_ROOT/Projects/para-graph/repo/dist"
echo "// fake" > "$WORKSPACE_ROOT/Projects/para-graph/repo/dist/cli.js"

TEST_HOME_SETUP="$TEST_TMP/fake_home_setup"
mkdir -p "$TEST_HOME_SETUP"
ORIG_HOME="$HOME"
export HOME="$TEST_HOME_SETUP"

# Test 1: Neither App Data folder exists -> Should fail because no IDE config is found/writable
echo -n "  No App Data folders exists returns error... "
if WORKSPACE_ROOT="$WORKSPACE_ROOT" bash "$REPO_ROOT/cli/commands/mcp-setup.sh" graph --ide=antigravity 2>/dev/null; then
  echo "FAIL — should have failed"
  FAIL=$((FAIL+1))
else
  echo "PASS"
  PASS=$((PASS+1))
fi

# Test 2: Only 2.x App Data folder exists -> Only writes to 2.x config
mkdir -p "$HOME/.gemini/antigravity-ide"
WORKSPACE_ROOT="$WORKSPACE_ROOT" bash "$REPO_ROOT/cli/commands/mcp-setup.sh" graph --ide=antigravity >/dev/null

assert_file_exists "Config file 2.x created" "$HOME/.gemini/config/mcp_config.json"
assert_valid_json "Config file 2.x is valid" "$HOME/.gemini/config/mcp_config.json"

echo -n "  Config file 1.x is NOT created... "
if [ ! -f "$HOME/.gemini/antigravity/mcp_config.json" ]; then
  echo "PASS"
  PASS=$((PASS+1))
else
  echo "FAIL — config file 1.x was created"
  FAIL=$((FAIL+1))
fi

# Test 3: Both App Data folders exist -> Writes to both
mkdir -p "$HOME/.gemini/antigravity"
rm -f "$HOME/.gemini/config/mcp_config.json"
WORKSPACE_ROOT="$WORKSPACE_ROOT" bash "$REPO_ROOT/cli/commands/mcp-setup.sh" graph --ide=antigravity >/dev/null

assert_file_exists "Config file 2.x recreated" "$HOME/.gemini/config/mcp_config.json"
assert_file_exists "Config file 1.x created" "$HOME/.gemini/antigravity/mcp_config.json"

export HOME="$ORIG_HOME"

# ============================================================
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
