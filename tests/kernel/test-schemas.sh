#!/usr/bin/env bash
# test-schemas.sh — Validate kernel schemas against examples
# Usage: bash tests/kernel/test-schemas.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCHEMA_DIR="$REPO_ROOT/kernel/schema"

PASS=0
FAIL=0

echo "=== PARA Kernel Schema Tests ==="
echo ""

# Test 1: All required schema files exist
echo -n "T1: Required schema files exist... "
REQUIRED_SCHEMAS=("catalog.schema.json" "workspace.schema.json" "project.schema.json" "backlog.schema.json")
ALL_EXIST=true
for schema in "${REQUIRED_SCHEMAS[@]}"; do
  if [[ ! -f "$SCHEMA_DIR/$schema" ]]; then
    echo "FAIL — missing $schema"
    ALL_EXIST=false
    FAIL=$((FAIL+1))
    break
  fi
done
if $ALL_EXIST; then
  echo "PASS"
  PASS=$((PASS+1))
fi

# Test 2: All schemas are valid JSON
echo -n "T2: All schemas are valid JSON... "
ALL_VALID=true
for schema in "$SCHEMA_DIR"/*.json; do
  if ! jq empty "$schema" 2>/dev/null; then
    echo "FAIL — invalid JSON: $(basename "$schema")"
    ALL_VALID=false
    FAIL=$((FAIL+1))
    break
  fi
done
if $ALL_VALID; then
  echo "PASS"
  PASS=$((PASS+1))
fi

# Test 3: catalog.schema.json has required fields
echo -n "T3: catalog.schema has required fields... "
REQUIRED=$(jq -r '.required | join(",")' "$SCHEMA_DIR/catalog.schema.json" 2>/dev/null)
if [[ "$REQUIRED" == *"version"* && "$REQUIRED" == *"library"* && "$REQUIRED" == *"items"* ]]; then
  echo "PASS"
  PASS=$((PASS+1))
else
  echo "FAIL — missing required fields: $REQUIRED"
  FAIL=$((FAIL+1))
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit $FAIL
