#!/usr/bin/env bash
# test-init.sh — Verify para init creates all expected directories and files
# Usage: bash tests/cli/test-init.sh [workspace-path]

set -euo pipefail

WORKSPACE="${1:-/tmp/para-test-workspace}"

echo "=== PARA CLI Init Tests ==="
echo "Workspace: $WORKSPACE"
echo ""

PASS=0
FAIL=0

check_dir() {
  local dir="$1"
  local label="$2"
  echo -n "  $label... "
  if [[ -d "$WORKSPACE/$dir" ]]; then
    echo "PASS"
    ((PASS++))
  else
    echo "FAIL — missing $dir"
    ((FAIL++))
  fi
}

check_file() {
  local file="$1"
  local label="$2"
  echo -n "  $label... "
  if [[ -f "$WORKSPACE/$file" ]]; then
    echo "PASS"
    ((PASS++))
  else
    echo "FAIL — missing $file"
    ((FAIL++))
  fi
}

# PARA Core Directories
echo "T1: PARA core directories"
check_dir "Projects" "Projects/"
check_dir "Areas" "Areas/"
check_dir "Resources" "Resources/"
check_dir "Archive" "Archive/"
check_dir "_inbox" "_inbox/"

# Agent Runtime
echo "T2: Agent runtime directories"
check_dir ".agent/workflows" ".agent/workflows/"
check_dir ".agent/rules" ".agent/rules/"

# Governed Libraries (read-only snapshots)
echo "T3: Governed library snapshots"
check_dir "Resources/ai-agents/kernel" "Resources/ai-agents/kernel/"
check_dir "Resources/ai-agents/workflows" "Resources/ai-agents/workflows/"
check_file "Resources/ai-agents/workflows/catalog.yml" "workflows/catalog.yml"

# Workspace Runtime Safety (v1.4.1)
echo "T4: Workspace runtime safety"
check_dir ".para" ".para/"
check_file ".para/audit.log" ".para/audit.log"
check_dir ".para/migrations" ".para/migrations/"
check_dir ".para/backups" ".para/backups/"

# Workspace Config
echo "T5: Workspace config"
check_file ".para-workspace.yml" ".para-workspace.yml"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit $FAIL
