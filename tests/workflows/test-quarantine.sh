#!/bin/bash
set -e

echo "=== TDD Quarantine Test ==="

TEST_TMP="/tmp/para-quarantine-test-$$"
mkdir -p "$TEST_TMP/Projects/mock-project/artifacts/tests"
# Create mock evidence log
touch "$TEST_TMP/Projects/mock-project/artifacts/tests/tdd-evidence.log"
touch "$TEST_TMP/Projects/mock-project/project.md"

cd "$TEST_TMP/Projects/mock-project"

echo "--- Simulating Quarantine Hook ---"
# Extract the hook from plan.md
HOOK_CMD=$(grep -A 3 "Quarantine Test Evidence:" "$WORKSPACE_ROOT/Projects/para-workspace/repo/templates/common/agents/workflows/plan.md" | grep "if \[\[" | sed 's/^ *//')

if [ -z "$HOOK_CMD" ]; then
  echo "  Failed to extract hook from plan.md"
  exit 1
fi

eval "$HOOK_CMD"

echo "--- Verifying Quarantine ---"
if [ ! -f "artifacts/tests/tdd-evidence.log" ]; then
  echo "  Original file removed from artifacts/tests/... PASS"
else
  echo "  Original file removed from artifacts/tests/... FAIL"
  exit 1
fi

if [ -f "artifacts/tests/tmp/tdd-evidence.log.bak" ]; then
  echo "  File quarantined and renamed to .bak... PASS"
else
  echo "  File quarantined and renamed to .bak... FAIL"
  exit 1
fi

echo "=== Results: All passed ==="
exit 0
