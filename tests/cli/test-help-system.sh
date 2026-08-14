#!/bin/bash
# Test Suite: PARA CLI Help Subsystem
# Verifies bidirectional help (para help <cmd>, para <cmd> --help, -h),
# JSON command catalog, and smart workflow banners.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLI="$REPO_ROOT/cli/para"

PASSED=0
FAILED=0

assert_contains() {
  local output="$1"
  local expected="$2"
  local msg="$3"
  if echo "$output" | grep -F -q -- "$expected"; then
    echo "  $msg... PASS"
    PASSED=$((PASSED + 1))
  else
    echo "  $msg... FAIL"
    echo "    Expected to find: '$expected'"
    echo "    Actual output: $(echo "$output" | head -n 3)..."
    FAILED=$((FAILED + 1))
  fi
}

assert_exit_code() {
  local code="$1"
  local expected="$2"
  local msg="$3"
  if [ "$code" -eq "$expected" ]; then
    echo "  $msg... PASS"
    PASSED=$((PASSED + 1))
  else
    echo "  $msg... FAIL (Expected exit code $expected, got $code)"
    FAILED=$((FAILED + 1))
  fi
}

echo "=== PARA CLI Help Subsystem Tests ==="
echo ""

# Test 1: Global Help
echo "--- Test 1: Global Help ---"
OUT="$("$CLI" --help 2>&1)" || true
assert_contains "$OUT" "Usage: para <command>" "para --help contains usage"
assert_contains "$OUT" "Core Commands" "para --help contains Core Commands section"

# Test 2: Subcommand Help via 'para help <cmd>'
echo "--- Test 2: 'para help <cmd>' Forwarding ---"
OUT="$("$CLI" help install 2>&1)" || true
assert_contains "$OUT" "para install" "'para help install' displays install help"
assert_contains "$OUT" "--force" "'para help install' shows --force option"

OUT="$("$CLI" help status 2>&1)" || true
assert_contains "$OUT" "para status" "'para help status' displays status help"
assert_contains "$OUT" "--json" "'para help status' shows --json option"

# Test 3: Subcommand Help via 'para <cmd> --help' and '-h'
echo "--- Test 3: Subcommand flags --help and -h ---"
OUT="$("$CLI" status --help 2>&1)" || true
assert_contains "$OUT" "Usage: para status" "'para status --help' displays usage without running status"

OUT="$("$CLI" status -h 2>&1)" || true
assert_contains "$OUT" "Usage: para status" "'para status -h' displays usage"

OUT="$("$CLI" scaffold --help 2>&1)" || true
assert_contains "$OUT" "Usage: para scaffold" "'para scaffold --help' displays usage"

# Test 4: JSON Help Catalog for AI Agents
echo "--- Test 4: Machine-Readable JSON Catalog ---"
OUT="$("$CLI" help --json 2>&1)" || true
assert_contains "$OUT" '"commands"' "para help --json outputs commands object"
assert_contains "$OUT" '"install"' "para help --json includes install command"
assert_contains "$OUT" '"status"' "para help --json includes status command"

# Test 5: Workflow Smart Banner
echo "--- Test 5: Smart Workflow Redirection ---"
OUT="$("$CLI" help open 2>&1)" || true
assert_contains "$OUT" "/open" "'para help open' guides user to slash workflow /open"

echo ""
echo "=== Results: $PASSED passed, $FAILED failed ==="

if [ "$FAILED" -gt 0 ]; then
  exit 1
fi
exit 0
