#!/usr/bin/env bash
# test-invariants.sh — Verify kernel invariant document integrity
# Usage: bash tests/kernel/test-invariants.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

PASS=0
FAIL=0

echo "=== PARA Kernel Invariant Tests ==="
echo ""

# Test 1: invariants.md exists
echo -n "T1: invariants.md exists... "
if [[ -f "$REPO_ROOT/kernel/invariants.md" ]]; then
  echo "PASS"
  PASS=$((PASS+1))
else
  echo "FAIL"
  FAIL=$((FAIL+1))
fi

# Test 2: Contains all 10 invariants (I1..I10)
echo -n "T2: All 10 invariants present... "
COUNT=$(grep -cE "^###?\s*(I[0-9]+|Invariant [0-9]+)" "$REPO_ROOT/kernel/invariants.md" 2>/dev/null || echo 0)
if [[ "$COUNT" -ge 10 ]]; then
  echo "PASS ($COUNT found)"
  PASS=$((PASS+1))
else
  echo "FAIL (only $COUNT found, expected ≥10)"
  FAIL=$((FAIL+1))
fi

# Test 3: heuristics.md exists
echo -n "T3: heuristics.md exists... "
if [[ -f "$REPO_ROOT/kernel/heuristics.md" ]]; then
  echo "PASS"
  PASS=$((PASS+1))
else
  echo "FAIL"
  FAIL=$((FAIL+1))
fi

# Test 4: KERNEL.md exists
echo -n "T4: KERNEL.md exists... "
if [[ -f "$REPO_ROOT/kernel/KERNEL.md" ]]; then
  echo "PASS"
  PASS=$((PASS+1))
else
  echo "FAIL"
  FAIL=$((FAIL+1))
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit $FAIL
