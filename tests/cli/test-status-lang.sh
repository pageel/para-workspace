#!/usr/bin/env bash
# test-status-lang.sh — Verify hierarchical language resolution in status.sh
# Usage: bash tests/cli/test-status-lang.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TEST_DIR="$(mktemp -d)"

echo "=== PARA CLI Status Language Resolution Tests ==="
echo "Running in sandbox: $TEST_DIR"
echo ""

PASS=0
FAIL=0

verify_lang_output() {
  local label="$1"
  local expected="$2"
  
  # Run status.sh --json in the sandbox workspace context
  export WORKSPACE_ROOT="$TEST_DIR"
  local output
  output=$(bash "$REPO_ROOT/cli/commands/status.sh" --json)
  
  # Extract language field using simple grep and sed since we don't assume jq
  local resolved
  resolved=$(echo "$output" | grep '"language":' | sed 's/.*"language":[[:space:]]*"//; s/".*//' | tr -d '[:space:]')
  
  echo -n "  $label (Expected: '$expected', Got: '$resolved')... "
  if [ "$resolved" = "$expected" ]; then
    echo "PASS"
    PASS=$((PASS + 1))
  else
    echo "FAIL"
    FAIL=$((FAIL + 1))
  fi
}

# Ensure base directories exist to make status.sh run successfully
mkdir -p "$TEST_DIR/Projects"
mkdir -p "$TEST_DIR/Areas"
mkdir -p "$TEST_DIR/Resources"
mkdir -p "$TEST_DIR/Archive"

# Case 1: Modern Map with chat
cat << 'EOF' > "$TEST_DIR/.para-workspace.yml"
kernel_version: "1.8.16"
profile: "dev"
language:
  default: "vi"
  chat: "vi"
EOF
verify_lang_output "Case 1: Modern Map with chat" "vi"

# Case 2: Modern Map with only default
cat << 'EOF' > "$TEST_DIR/.para-workspace.yml"
kernel_version: "1.8.16"
profile: "dev"
language:
  default: "vi"
EOF
verify_lang_output "Case 2: Modern Map with only default" "vi"

# Case 3: Root String
cat << 'EOF' > "$TEST_DIR/.para-workspace.yml"
kernel_version: "1.8.16"
profile: "dev"
language: "fr"
EOF
verify_lang_output "Case 3: Root String" "fr"

# Case 4: Legacy Nested Preferences
cat << 'EOF' > "$TEST_DIR/.para-workspace.yml"
kernel_version: "1.8.16"
profile: "dev"
preferences:
  language: "jp"
EOF
verify_lang_output "Case 4: Legacy Nested Preferences" "jp"

# Case 5: Ultimate Fallback
cat << 'EOF' > "$TEST_DIR/.para-workspace.yml"
kernel_version: "1.8.16"
profile: "dev"
EOF
verify_lang_output "Case 5: Ultimate Fallback" "en"

# Clean up sandbox
rm -rf "$TEST_DIR"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
exit $FAIL
