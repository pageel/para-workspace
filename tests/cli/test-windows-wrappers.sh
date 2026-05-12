#!/usr/bin/env bash
# test-windows-wrappers.sh — Unit tests for Windows native wrappers (cmd and ps1)
# Usage: bash tests/cli/test-windows-wrappers.sh

set -euo pipefail

echo "=== Windows Native Wrappers Tests ==="
echo ""

PASS=0
FAIL=0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

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

assert_contains() {
  local label="$1"
  local needle="$2"
  local haystack_file="$3"
  echo -n "  $label... "
  if [ -f "$haystack_file" ] && grep -q "$needle" "$haystack_file"; then
    echo "PASS"
    PASS=$((PASS+1))
  else
    echo "FAIL — '$needle' not found in $haystack_file"
    FAIL=$((FAIL+1))
  fi
}

# --- Test para.cmd ---
echo "--- para.cmd ---"
CMD_FILE="$REPO_ROOT/para.cmd"
assert_file_exists "para.cmd exists" "$CMD_FILE"
assert_contains "Calls bash with para script" 'bash "%~dp0para"' "$CMD_FILE"

# --- Test para.ps1 ---
echo "--- para.ps1 ---"
PS1_FILE="$REPO_ROOT/para.ps1"
assert_file_exists "para.ps1 exists" "$PS1_FILE"
assert_contains "Calls bash with para script" 'bash "$PSScriptRoot/para"' "$PS1_FILE"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
