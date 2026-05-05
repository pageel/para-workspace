#!/bin/bash
# Test: install-tool --sync + hook detection + semver_gte
# Run: bash tests/cli/test-install-tool-sync.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

PASS=0
FAIL=0

assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    echo "  ✅ $desc"
    PASS=$((PASS + 1))
  else
    echo "  ❌ $desc (expected: $expected, got: $actual)"
    FAIL=$((FAIL + 1))
  fi
}

# === Test semver_gte ===
echo "🧪 Testing semver_gte()..."

# Source the function (extract from install-tool.sh)
eval "$(sed -n '/^semver_gte()/,/^}/p' "$REPO_ROOT/cli/commands/install-tool.sh")"

# Equal versions
semver_gte "0.8.0" "0.8.0" && result=0 || result=1
assert_eq "0.8.0 >= 0.8.0" "0" "$result"

# Greater patch
semver_gte "0.8.1" "0.8.0" && result=0 || result=1
assert_eq "0.8.1 >= 0.8.0" "0" "$result"

# Greater minor
semver_gte "0.9.0" "0.8.0" && result=0 || result=1
assert_eq "0.9.0 >= 0.8.0" "0" "$result"

# Greater major
semver_gte "1.0.0" "0.8.5" && result=0 || result=1
assert_eq "1.0.0 >= 0.8.5" "0" "$result"

# Less than
semver_gte "0.7.0" "0.8.0" && result=0 || result=1
assert_eq "0.7.0 < 0.8.0 (should fail)" "1" "$result"

# Less patch
semver_gte "0.8.0" "0.8.1" && result=0 || result=1
assert_eq "0.8.0 < 0.8.1 (should fail)" "1" "$result"

# Major difference
semver_gte "0.9.9" "1.0.0" && result=0 || result=1
assert_eq "0.9.9 < 1.0.0 (should fail)" "1" "$result"

# === Test --sync flag parsing ===
echo ""
echo "🧪 Testing --sync flag in --help output..."

help_output=$(WORKSPACE_ROOT="$REPO_ROOT" "$REPO_ROOT/cli/commands/install-tool.sh" --help 2>&1 || true)
if echo "$help_output" | grep -q "\-\-sync"; then
  echo "  ✅ --sync appears in help text"
  PASS=$((PASS + 1))
else
  echo "  ❌ --sync NOT found in help text"
  FAIL=$((FAIL + 1))
fi

# === Test hook detection syntax ===
echo ""
echo "🧪 Testing hook detection in install-tool.sh..."

if grep -q "install-hooks.sh" "$REPO_ROOT/cli/commands/install-tool.sh"; then
  echo "  ✅ install-hooks.sh reference found"
  PASS=$((PASS + 1))
else
  echo "  ❌ install-hooks.sh reference NOT found"
  FAIL=$((FAIL + 1))
fi

if grep -q "pre_install" "$REPO_ROOT/cli/commands/install-tool.sh"; then
  echo "  ✅ pre_install hook reference found"
  PASS=$((PASS + 1))
else
  echo "  ❌ pre_install hook reference NOT found"
  FAIL=$((FAIL + 1))
fi

if grep -q "post_install" "$REPO_ROOT/cli/commands/install-tool.sh"; then
  echo "  ✅ post_install hook reference found"
  PASS=$((PASS + 1))
else
  echo "  ❌ post_install hook reference NOT found"
  FAIL=$((FAIL + 1))
fi

# === Summary ===
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Results: $PASS passed, $FAIL failed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
