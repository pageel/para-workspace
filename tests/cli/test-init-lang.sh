#!/usr/bin/env bash
# test-init-lang.sh — Verify para init creates map-structured language configuration
# Usage: bash tests/cli/test-init-lang.sh [workspace-path]

set -euo pipefail

WORKSPACE="${1:-/tmp/para-test-workspace-lang}"

echo "=== PARA CLI Init Language Map Tests ==="
echo "Workspace: $WORKSPACE"
echo ""

# Clean up existing test workspace
rm -rf "$WORKSPACE"
mkdir -p "$WORKSPACE"

# Run init command with target language vi
# SCRIPT_DIR is Projects/para-workspace/repo/tests/cli
# We execute repo/cli/commands/init.sh
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

echo "Running init.sh..."
# We run the command with TARGET_PATH to avoid modifying current workspace
bash "$REPO_ROOT/cli/commands/init.sh" --lang=vi --path="$WORKSPACE"

PASS=0
FAIL=0

check_config_line() {
  local pattern="$1"
  local label="$2"
  echo -n "  $label... "
  if grep -q "$pattern" "$WORKSPACE/.para-workspace.yml"; then
    echo "PASS"
    PASS=$((PASS + 1))
  else
    echo "FAIL — pattern not found: $pattern"
    FAIL=$((FAIL + 1))
  fi
}

echo "T1: Verifying language map structure in .para-workspace.yml"
# We expect language: as a parent key
check_config_line "^language:" "language root key"
check_config_line "  default: \"vi\"" "language.default"
check_config_line "  repo: \"en\"" "language.repo"
check_config_line "  docs: \"en, vi\"" "language.docs"
check_config_line "  artifacts: \"vi\"" "language.artifacts"
check_config_line "  thinking: \"vi\"" "language.thinking"
check_config_line "  chat: \"vi\"" "language.chat"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="

# Clean up
rm -rf "$WORKSPACE"

exit $FAIL
