#!/bin/bash
set -e

echo "=== TDD Sandbox Test ==="

TEST_TMP="/tmp/para-tdd-test-$$"
mkdir -p "$TEST_TMP/Projects/mock-project/repo"
# Mock project boundary
touch "$TEST_TMP/Projects/mock-project/project.md"

ORIGINAL_WORKSPACE="/media/tienle/DATA/WORKSPACE/para"

# Copy the tdd-test.sh
mkdir -p "$TEST_TMP/Projects/mock-project/.agents/skills/tdd/scripts"
cp "$ORIGINAL_WORKSPACE/Projects/para-workspace/repo/templates/common/agents/skills/tdd/scripts/tdd-test.sh" "$TEST_TMP/Projects/mock-project/.agents/skills/tdd/scripts/"
chmod +x "$TEST_TMP/Projects/mock-project/.agents/skills/tdd/scripts/tdd-test.sh"

cd "$TEST_TMP/Projects/mock-project/repo"

echo "--- TDD Test Script resolves project root correctly ---"
# Run the script with a dummy test command
bash "../.agents/skills/tdd/scripts/tdd-test.sh" echo "hello tdd" >/dev/null

# The evidence log should be created at artifacts/tests/tdd-evidence.log in the project root
if [ -f "$TEST_TMP/Projects/mock-project/artifacts/tests/tdd-evidence.log" ]; then
  echo "  Project root traversal... PASS"
else
  echo "  Project root traversal... FAIL — file not found in artifacts/tests/tdd-evidence.log"
  exit 1
fi

echo "--- Scaffold creates sandbox gitignore ---"
# We will test scaffold.sh
cd "$TEST_TMP"
export WORKSPACE_ROOT="$TEST_TMP"
mkdir -p "$TEST_TMP/Projects/para-workspace/repo/cli/commands"
cp "$ORIGINAL_WORKSPACE/Projects/para-workspace/repo/cli/commands/scaffold.sh" "$TEST_TMP/Projects/para-workspace/repo/cli/commands/"
# Run scaffold
bash "$TEST_TMP/Projects/para-workspace/repo/cli/commands/scaffold.sh" project test-proj >/dev/null
if grep -q "artifacts/tests/" "$TEST_TMP/Projects/test-proj/repo/.gitignore"; then
  echo "  artifacts/tests in gitignore... PASS"
else
  echo "  artifacts/tests in gitignore... FAIL"
  exit 1
fi

if grep -q "\.test-output" "$TEST_TMP/Projects/test-proj/repo/.gitignore"; then
  echo "  .test-output in gitignore... PASS"
else
  echo "  .test-output in gitignore... FAIL"
  exit 1
fi

echo "=== Results: All passed ==="
exit 0
