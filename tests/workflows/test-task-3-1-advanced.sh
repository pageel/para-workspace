#!/usr/bin/env bash
# test-task-3-1-advanced.sh — Verify advanced workflow modifications for Phase 3
# Usage: bash tests/workflows/test-task-3-1-advanced.sh

set -euo pipefail

echo "=== Advanced Workflow Template Checks ==="
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
  if [ -f "$haystack_file" ] && grep -qF -e "$needle" "$haystack_file"; then
    echo "PASS"
    PASS=$((PASS+1))
  else
    echo "FAIL — '$needle' not found in $(basename "$haystack_file")"
    FAIL=$((FAIL+1))
  fi
}

# 1. learn.md
LEARN_MD="$REPO_ROOT/templates/common/agents/workflows/learn.md"
assert_contains "[learn.md] Lessons architecture" "Lessons/" "$LEARN_MD"

# 2. brainstorm.md
BRAINSTORM_MD="$REPO_ROOT/templates/common/agents/workflows/brainstorm.md"
assert_contains "[brainstorm.md] UI Open/Decided" "Path A — Open Brainstorm" "$BRAINSTORM_MD"
assert_contains "[brainstorm.md] Graph flag" "--graph" "$BRAINSTORM_MD"
assert_contains "[brainstorm.md] Memory MCP push" "memory_push" "$BRAINSTORM_MD"

# 3. end.md
END_MD="$REPO_ROOT/templates/common/agents/workflows/end.md"
assert_contains "[end.md] Memory MCP push" "memory_push" "$END_MD"

# 4. Kebab-case skill folders
echo -n "  [skills/] Kebab-case folders only... "
SKILLS_DIR="$REPO_ROOT/templates/common/agents/skills"
NON_KEBAB_FOLDERS=$(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | sed 's/.*\///' | grep -v '^[a-z0-9-]*$' || true)

if [ -z "$NON_KEBAB_FOLDERS" ]; then
  echo "PASS"
  PASS=$((PASS+1))
else
  echo "FAIL — Found non-kebab-case folders: $NON_KEBAB_FOLDERS"
  FAIL=$((FAIL+1))
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
