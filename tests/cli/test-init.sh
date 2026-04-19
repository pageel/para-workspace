#!/usr/bin/env bash
# test-init.sh — Verify para init creates all expected directories and files
# Usage: bash tests/cli/test-init.sh [workspace-path]
# Extended: includes layout mode tests (feat/layout-modes)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

TOTAL_PASS=0
TOTAL_FAIL=0

# ─── helpers ────────────────────────────────────────────────────────────────

run_suite() {
  local suite_name="$1"
  local workspace="$2"
  local layout="${3:-standard}"
  local PASS=0
  local FAIL=0

  echo ""
  echo "=== Suite: $suite_name (layout=$layout) ==="
  echo "    Workspace: $workspace"
  echo ""

  check_dir() {
    local dir="$1" label="$2"
    echo -n "  $label... "
    if [[ -d "$workspace/$dir" ]]; then
      echo "PASS"; ((PASS += 1))
    else
      echo "FAIL — missing $dir"; ((FAIL += 1))
    fi
  }

  check_file() {
    local file="$1" label="$2"
    echo -n "  $label... "
    if [[ -f "$workspace/$file" ]]; then
      echo "PASS"; ((PASS += 1))
    else
      echo "FAIL — missing $file"; ((FAIL += 1))
    fi
  }

  check_layout_field() {
    local expected="$1"
    echo -n "  .para-workspace.yml has layout: $expected... "
    if grep -q "layout:.*\"$expected\"" "$workspace/.para-workspace.yml" 2>/dev/null; then
      echo "PASS"; ((PASS += 1))
    else
      echo "FAIL — layout field missing or wrong value"; ((FAIL += 1))
    fi
  }

  # T1: PARA core directories (layout-aware)
  echo "T1: PARA core directories"
  case "$layout" in
    standard)
      check_dir "Projects"    "Projects/"
      check_dir "Areas"       "Areas/"
      check_dir "Resources"   "Resources/"
      check_dir "Archive"     "Archive/"
      check_dir "_inbox"      "_inbox/"
      ;;
    numeric)
      check_dir "1_Projects"  "1_Projects/"
      check_dir "2_Areas"     "2_Areas/"
      check_dir "3_Resources" "3_Resources/"
      check_dir "4_Archive"   "4_Archive/"
      check_dir "_inbox"      "_inbox/"
      ;;
    numeric-wide)
      check_dir "10_PROJECTS"  "10_PROJECTS/"
      check_dir "20_AREAS"     "20_AREAS/"
      check_dir "30_RESOURCES" "30_RESOURCES/"
      check_dir "40_ARCHIVE"   "40_ARCHIVE/"
      check_dir "_inbox"       "_inbox/"
      ;;
  esac

  # T2: Agent Runtime
  echo "T2: Agent runtime directories"
  check_dir ".agents/workflows" ".agents/workflows/"
  check_dir ".agents/rules"     ".agents/rules/"

  # T3: Governed library snapshots (always under Resources pillar name)
  local res_dir
  case "$layout" in
    standard)     res_dir="Resources" ;;
    numeric)      res_dir="3_Resources" ;;
    numeric-wide) res_dir="30_RESOURCES" ;;
  esac
  echo "T3: Governed library snapshots"
  check_dir  "$res_dir/ai-agents/kernel"             "ai-agents/kernel/"
  check_dir  "$res_dir/ai-agents/workflows"          "ai-agents/workflows/"
  check_file "$res_dir/ai-agents/workflows/catalog.yml" "workflows/catalog.yml"

  # T4: Workspace runtime safety
  echo "T4: Workspace runtime safety"
  check_dir  ".para"              ".para/"
  check_file ".para/audit.log"   ".para/audit.log"
  check_dir  ".para/migrations"  ".para/migrations/"
  check_dir  ".para/backups"     ".para/backups/"

  # T5: Workspace config + layout field
  echo "T5: Workspace config"
  check_file ".para-workspace.yml" ".para-workspace.yml"
  if [[ "$layout" != "standard" ]]; then
    check_layout_field "$layout"
  fi

  echo ""
  echo "--- Suite results: $PASS passed, $FAIL failed ---"
  TOTAL_PASS=$((TOTAL_PASS + PASS))
  TOTAL_FAIL=$((TOTAL_FAIL + FAIL))
}

# ─── test runner ────────────────────────────────────────────────────────────

run_init() {
  local workspace="$1"
  local layout="$2"
  rm -rf "$workspace"
  export WORKSPACE_ROOT="$workspace"
  if [[ "$layout" == "standard" ]]; then
    bash "$REPO_ROOT/cli/para" init --profile=general --lang=en --path="$workspace" \
      > /dev/null 2>&1
  else
    bash "$REPO_ROOT/cli/para" init --profile=general --lang=en \
      --layout="$layout" --path="$workspace" > /dev/null 2>&1
  fi
}

echo "=== PARA CLI Init Tests (feat/layout-modes) ==="

# Suite 1: standard layout (default, no flag)
WS_STANDARD="/tmp/para-test-standard"
run_init "$WS_STANDARD" "standard"
run_suite "Standard layout (default)" "$WS_STANDARD" "standard"

# Suite 2: numeric layout
WS_NUMERIC="/tmp/para-test-numeric"
run_init "$WS_NUMERIC" "numeric"
run_suite "Numeric layout" "$WS_NUMERIC" "numeric"

# Suite 3: numeric-wide layout
WS_WIDE="/tmp/para-test-numeric-wide"
run_init "$WS_WIDE" "numeric-wide"
run_suite "Numeric-wide layout" "$WS_WIDE" "numeric-wide"

# Suite 4: invalid layout — must fail with exit 1
echo ""
echo "=== Suite: Invalid layout (must fail) ==="
echo -n "  para init --layout=invalid exits non-zero... "
if ! bash "$REPO_ROOT/cli/para" init --layout=invalid \
     --path="/tmp/para-test-invalid" > /dev/null 2>&1; then
  echo "PASS"; ((TOTAL_PASS += 1))
else
  echo "FAIL — should have rejected invalid layout"; ((TOTAL_FAIL += 1))
fi

# ─── cleanup ────────────────────────────────────────────────────────────────
rm -rf /tmp/para-test-standard /tmp/para-test-numeric \
       /tmp/para-test-numeric-wide /tmp/para-test-invalid

# ─── final results ──────────────────────────────────────────────────────────
echo ""
echo "========================================="
echo "TOTAL: $TOTAL_PASS passed, $TOTAL_FAIL failed"
echo "========================================="
exit $TOTAL_FAIL
