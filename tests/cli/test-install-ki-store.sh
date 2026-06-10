#!/usr/bin/env bash
# test-install-ki-store.sh — Verify KI Store path resolution in install.sh
# Usage: bash tests/cli/test-install-ki-store.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FAKE_HOME="/tmp/fake_home_ki"
WORKSPACE="/tmp/fake_workspace_ki"

echo "=== PARA CLI KI Store Resolution Tests ==="
echo "Fake Home: $FAKE_HOME"
echo "Workspace: $WORKSPACE"
echo ""

PASS=0
FAIL=0

cleanup() {
  rm -rf "$FAKE_HOME"
  rm -rf "$WORKSPACE"
}

run_install_test() {
  local label="$1"
  local expected_store="$2"
  
  # Set target workspace root
  export WORKSPACE_ROOT="$WORKSPACE"
  export HOME="$FAKE_HOME"
  
  # Run installer
  echo "  Running install.sh for $label..."
  bash "$REPO_ROOT/cli/commands/install.sh" >/dev/null
  
  # Verify if KIs are created under the expected store directory
  # The installer creates para_ anti_truncation_guardrail or others.
  # Let's check if the directory exists.
  local found=false
  # System KI defaults has some templates like para_anti_truncation_guardrail
  # Let's check if there is a directory starting with 'para_' under expected_store
  if [ -d "$expected_store" ] && [ "$(find "$expected_store" -mindepth 1 -maxdepth 1 -type d -name "para_*" 2>/dev/null | wc -l)" -gt 0 ]; then
    found=true
  fi
  
  echo -n "  $label... "
  if [ "$found" = true ]; then
    echo "PASS"
    PASS=$((PASS + 1))
  else
    echo "FAIL — KIs not found in $expected_store"
    FAIL=$((FAIL + 1))
  fi
}

# Scenario 1: antigravity-ide exists
cleanup
mkdir -p "$FAKE_HOME/.gemini/antigravity-ide/knowledge"
mkdir -p "$WORKSPACE"
# Initialize workspace config
cat << 'EOF' > "$WORKSPACE/.para-workspace.yml"
kernel_version: "1.8.16"
profile: "dev"
language: "en"
EOF
# Run test
run_install_test "Scenario 1: antigravity-ide store exists" "$FAKE_HOME/.gemini/antigravity-ide/knowledge"

# Scenario 2: Only antigravity exists
cleanup
mkdir -p "$FAKE_HOME/.gemini/antigravity/knowledge"
mkdir -p "$WORKSPACE"
# Initialize workspace config
cat << 'EOF' > "$WORKSPACE/.para-workspace.yml"
kernel_version: "1.8.16"
profile: "dev"
language: "en"
EOF
# Run test
run_install_test "Scenario 2: Only antigravity store exists" "$FAKE_HOME/.gemini/antigravity/knowledge"

# Cleanup
cleanup
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit $FAIL
