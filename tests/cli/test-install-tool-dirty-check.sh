#!/usr/bin/env bash
# test-install-tool-dirty-check.sh — TDD regression tests for dirty-check logic
# Usage: bash tests/cli/test-install-tool-dirty-check.sh

set -euo pipefail

echo "=== Install Tool Dirty Check (TDD) Tests ==="
echo ""

PASS=0
FAIL=0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_TMP=$(mktemp -d)

# Cleanup on exit
trap '[ -f "$TEST_TMP/tools.yml.bak" ] && mv "$TEST_TMP/tools.yml.bak" "$REPO_ROOT/registry/tools.yml"; rm -rf "$TEST_TMP"; rm -f "$REPO_ROOT/cli/commands/test-dirty-check.sh"' EXIT

# Create a fake workspace and registry
export WORKSPACE_ROOT="$TEST_TMP/workspace"
mkdir -p "$WORKSPACE_ROOT"

REGISTRY_DIR="$REPO_ROOT/registry"
mkdir -p "$REGISTRY_DIR"
[ -f "$REGISTRY_DIR/tools.yml" ] && cp "$REGISTRY_DIR/tools.yml" "$TEST_TMP/tools.yml.bak"

cat << 'EOF' > "$REGISTRY_DIR/tools.yml"
test-dirty-check:
  repo: "pageel/para-test-dirty-check"
  description: "Test plugin for dirty-check"
  latest: "1.0.0"
  runtime: "node"
  min_runtime_version: "18"
  entry: "dist/cli.js"
  tarball_pattern: "https://example.com/{{VERSION}}.tar.gz"
EOF

# Function to create a fake tarball with workflows/skills
create_fake_tarball() {
  local version="$1"
  local workflow_content="$2"
  local target_tarball="$3"
  
  local build_dir="$TEST_TMP/build_$version"
  mkdir -p "$build_dir/package/templates/workflows"
  
  cat << EOF > "$build_dir/package/tool.manifest.yml"
name: test-dirty-check
version: $version
agents:
  workflows:
    - source: templates/workflows/hello.md
      target: hello.md
      version: "$version"
EOF
  echo "$workflow_content" > "$build_dir/package/templates/workflows/hello.md"
  touch "$build_dir/package/cli.js"
  
  tar -czf "$target_tarball" -C "$build_dir/package" tool.manifest.yml templates cli.js
  rm -rf "$build_dir"
}

# Assert helper
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

assert_file_content() {
  local label="$1"
  local file="$2"
  local expected_content="$3"
  echo -n "  $label... "
  if [ -f "$file" ]; then
    local actual_content
    actual_content=$(cat "$file")
    if [ "$actual_content" = "$expected_content" ]; then
      echo "PASS"
      PASS=$((PASS+1))
    else
      echo "FAIL — expected '$expected_content', got '$actual_content'"
      FAIL=$((FAIL+1))
    fi
  else
    echo "FAIL — file not found: $file"
    FAIL=$((FAIL+1))
  fi
}

# Create tarball version 1.0.0
TARBALL_V1="$TEST_TMP/test-dirty-check-1.0.0.tar.gz"
create_fake_tarball "1.0.0" "Hello version 1" "$TARBALL_V1"

# Create tarball version 2.0.0
TARBALL_V2="$TEST_TMP/test-dirty-check-2.0.0.tar.gz"
create_fake_tarball "2.0.0" "Hello version 2" "$TARBALL_V2"


# Test Case 1: First install should copy template successfully without prompt
echo "--- 1. First install (v1.0.0) ---"
# We simulate auto-approving agents
OUTPUT_1=$(echo "y" | bash "$REPO_ROOT/cli/commands/install-tool.sh" test-dirty-check --local="$TARBALL_V1" 2>&1)
assert_file_content "Workspace has hello.md with v1 content" "$WORKSPACE_ROOT/.agents/workflows/hello.md" "Hello version 1"

# Test Case 2: Upgrade to v2.0.0 with NO user customization -> should auto-overwrite silently
echo "--- 2. Upgrade (v2.0.0) with NO customization ---"
OUTPUT_2=$(echo "y" | bash "$REPO_ROOT/cli/commands/install-tool.sh" test-dirty-check --local="$TARBALL_V2" --update 2>&1)
assert_file_content "Workspace has hello.md automatically updated to v2 content" "$WORKSPACE_ROOT/.agents/workflows/hello.md" "Hello version 2"
# Confirm that it did NOT prompt for hello.md
echo -n "  No prompt warning in stdout... "
if echo "$OUTPUT_2" | grep -q "Template conflict"; then
  echo "FAIL — prompted user despite no modifications"
  FAIL=$((FAIL+1))
else
  echo "PASS"
  PASS=$((PASS+1))
fi

# Test Case 3: Modify the local template file in the workspace
echo "--- 3. Local customization ---"
echo "Hello customized" > "$WORKSPACE_ROOT/.agents/workflows/hello.md"

# Upgrade to v2.0.0 again with --update, simulating user choosing NOT to overwrite (n)
echo "--- 4. Upgrade (v2.0.0) with customization and answer 'N' ---"
OUTPUT_3=$(printf "y\nn\n" | bash "$REPO_ROOT/cli/commands/install-tool.sh" test-dirty-check --local="$TARBALL_V2" --update 2>&1)
assert_contains "Detects warning prompt for conflict" "Template conflict" "$OUTPUT_3"
assert_file_content "Local customization is preserved" "$WORKSPACE_ROOT/.agents/workflows/hello.md" "Hello customized"

# Upgrade to v2.0.0 again with --update, simulating user choosing YES to overwrite (y)
echo "--- 5. Upgrade (v2.0.0) with customization and answer 'Y' ---"
OUTPUT_4=$(printf "y\ny\n" | bash "$REPO_ROOT/cli/commands/install-tool.sh" test-dirty-check --local="$TARBALL_V2" --update 2>&1)
assert_contains "Detects warning prompt for conflict" "Template conflict" "$OUTPUT_4"
assert_file_content "Template is overwritten with v2 content" "$WORKSPACE_ROOT/.agents/workflows/hello.md" "Hello version 2"


echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
