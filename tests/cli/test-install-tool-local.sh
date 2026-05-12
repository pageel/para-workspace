#!/usr/bin/env bash
# test-install-tool-local.sh — Tests for --local flag
# Usage: bash tests/cli/test-install-tool-local.sh

set -euo pipefail

echo "=== Install Tool Local Flag Tests ==="
echo ""

PASS=0
FAIL=0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_TMP=$(mktemp -d)

# Cleanup on exit
trap 'rm -rf "$TEST_TMP"; [ -f "$TEST_TMP/tools.yml.bak" ] && mv "$TEST_TMP/tools.yml.bak" "$REPO_ROOT/registry/tools.yml"; rm -f "$REPO_ROOT/cli/commands/test-plugin.sh"' EXIT

# Create a fake workspace and registry
export WORKSPACE_ROOT="$TEST_TMP/workspace"
mkdir -p "$WORKSPACE_ROOT"

REGISTRY_DIR="$REPO_ROOT/registry"
mkdir -p "$REGISTRY_DIR"
[ -f "$REGISTRY_DIR/tools.yml" ] && cp "$REGISTRY_DIR/tools.yml" "$TEST_TMP/tools.yml.bak"
cat << 'EOF' > "$REGISTRY_DIR/tools.yml"
test-plugin:
  repo: "pageel/para-test-plugin"
  description: "Test plugin"
  latest: "1.0.0"
  runtime: "node"
  min_runtime_version: "18"
  entry: "dist/cli.js"
  tarball_pattern: "https://example.com/{{VERSION}}.tar.gz"
EOF

# Create a fake tarball
FAKE_TARBALL="$TEST_TMP/fake-plugin.tar.gz"
mkdir -p "$TEST_TMP/plugin/package"
cat << 'EOF' > "$TEST_TMP/plugin/package/tool.manifest.yml"
name: test-plugin
version: 1.0.0
EOF
touch "$TEST_TMP/plugin/package/cli.js"
tar -czf "$FAKE_TARBALL" -C "$TEST_TMP/plugin" package

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

echo "--- Run with --local ---"
# We expect this to succeed and install from the local tarball instead of downloading
# We pass --no-agents and --no-mcp to skip prompts
OUTPUT=$(bash "$REPO_ROOT/cli/commands/install-tool.sh" test-plugin --local="$FAKE_TARBALL" --no-agents --no-mcp 2>&1)

assert_contains "Detects local tarball install message" "Installing para-test-plugin from local tarball" "$OUTPUT"
assert_contains "Extracts properly" "Extracting to:" "$OUTPUT"
assert_contains "Generates wrapper" "Generating wrapper: cli/commands/test-plugin.sh" "$OUTPUT"
assert_contains "Reports success" "Successfully installed para-test-plugin" "$OUTPUT"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
