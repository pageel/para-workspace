#!/usr/bin/env bash
# test-task-2-1-core.sh — Verify core workflow modifications for Phase 2
# Usage: bash tests/workflows/test-task-2-1-core.sh

set -euo pipefail

echo "=== Core Workflow Template Checks ==="
echo ""

PASS=0
FAIL=0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

assert_contains() {
  local label="$1"
  local needle="$2"
  local haystack_file="$3"
  echo -n "  $label... "
  if [ -f "$haystack_file" ] && grep -qF "$needle" "$haystack_file"; then
    echo "PASS"
    PASS=$((PASS+1))
  else
    echo "FAIL — '$needle' not found in $(basename "$haystack_file")"
    FAIL=$((FAIL+1))
  fi
}

# 1. logs.md
LOGS_MD="$REPO_ROOT/templates/common/agents/workflows/logs.md"
assert_contains "[logs.md] view_file requirement" "MUST use the \`view_file\` tool to read" "$LOGS_MD"

# 2. plan.md
PLAN_MD="$REPO_ROOT/templates/common/agents/workflows/plan.md"
assert_contains "[plan.md] Graph Preparation" "Graph Preparation" "$PLAN_MD"

# 3. guard-catalog.md
GUARD_CATALOG="$REPO_ROOT/templates/common/agents/skills/harness/references/guard-catalog.md"
assert_contains "[guard-catalog.md] Graph Knowledge" "Graph Knowledge Preparation" "$GUARD_CATALOG"
assert_contains "[guard-catalog.md] TDD Strict" "TDD Strict Cycle" "$GUARD_CATALOG"

# 4. detail-plan templates
for t in detail-plan.md detail-plan-tdd.md detail-plan-docs.md; do
  f="$REPO_ROOT/templates/common/agents/skills/plan/references/$t"
  assert_contains "[$t] Graph Preparation in Phase 0" "Graph Knowledge Preparation" "$f"
done

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
