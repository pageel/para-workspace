#!/usr/bin/env bash
# test-install-tool-local-sync.sh — Tests for local sync and index auto-sync
# Usage: bash repo/tests/cli/test-install-tool-local-sync.sh

set -euo pipefail

echo "=== Install Tool Local Sync & Index Auto-Sync Tests ==="
echo ""

PASS=0
FAIL=0
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEST_TMP=$(mktemp -d)

# Cleanup on exit
trap '[ -f "$TEST_TMP/tools.yml.bak" ] && mv "$TEST_TMP/tools.yml.bak" "$REPO_ROOT/registry/tools.yml"; rm -f "$REPO_ROOT/cli/commands/test-plugin.sh"; rm -rf "$TEST_TMP"' EXIT

# Create a fake workspace
export WORKSPACE_ROOT="$TEST_TMP/workspace"
mkdir -p "$WORKSPACE_ROOT/.para/tools/test-plugin"
mkdir -p "$WORKSPACE_ROOT/.agents/rules"
mkdir -p "$WORKSPACE_ROOT/.agents/skills"

# Temporary swap registry
REGISTRY_DIR="$REPO_ROOT/registry"
mkdir -p "$REGISTRY_DIR"
[ -f "$REGISTRY_DIR/tools.yml" ] && cp "$REGISTRY_DIR/tools.yml" "$TEST_TMP/tools.yml.bak"
cat << 'EOF' > "$REGISTRY_DIR/tools.yml"
test-plugin:
  repo: "https://github.com/pageel/para-test-plugin"
  description: "Test plugin"
  latest: "1.0.0"
  runtime: "node"
  min_runtime_version: "18"
  entry: "dist/cli.js"
  tarball_pattern: "https://example.com/{{VERSION}}.tar.gz"
EOF

# Initialize old manifest in installed tools
cat << 'EOF' > "$WORKSPACE_ROOT/.para/tools/test-plugin/tool.manifest.yml"
name: test-plugin
version: "1.0.0"
repo: "https://github.com/pageel/para-test-plugin"
agents:
  rules: []
  skills: []
EOF

# Create fake local project directory in Projects/para-test-plugin/repo/
LOCAL_PROJECT_DIR="$WORKSPACE_ROOT/Projects/para-test-plugin/repo"
mkdir -p "$LOCAL_PROJECT_DIR/templates/agents/rules"
mkdir -p "$LOCAL_PROJECT_DIR/templates/agents/skills/test-skill"

# Write fake local manifest with index metadata
cat << 'EOF' > "$LOCAL_PROJECT_DIR/tool.manifest.yml"
name: test-plugin
version: "1.1.0"
repo: "https://github.com/pageel/para-test-plugin"
agents:
  rules:
    - source: templates/agents/rules/test-rule.md
      target: test-rule.md
      version: "1.1.0"
      name: "Test Rule Title"
      trigger: "When running tests"
      priority: "🔴"
  skills:
    - source: templates/agents/skills/test-skill/
      target: test-skill/
      version: "1.2.0"
      name: "Test Skill Title"
      trigger: "When calling test-skill"
EOF

echo "Fake Rule Content" > "$LOCAL_PROJECT_DIR/templates/agents/rules/test-rule.md"
echo "Fake Skill Content" > "$LOCAL_PROJECT_DIR/templates/agents/skills/test-skill/SKILL.md"

# Initialize mock rules.md and skills.md indexes
cat << 'EOF' > "$WORKSPACE_ROOT/.agents/rules.md"
# Workspace Rules Index

| Rule | Trigger | File | Pri |
| :-- | :-- | :-- | :-- |
| Governance | Touching kernel/ | rules/governance.md | 🔴 |
EOF

cat << 'EOF' > "$WORKSPACE_ROOT/.agents/skills.md"
# Workspace Skills Index

| Skill | Trigger | Path |
| :-- | :-- | :-- |
| PARA Kit | PARA structure | skills/para-kit/SKILL.md |
EOF

assert_contains() {
  local label="$1"
  local needle="$2"
  local haystack="$3"
  echo -n "  $label... "
  if echo "$haystack" | grep -q "$needle"; then
    echo "PASS"
    PASS=$((PASS+1))
  else
    echo "FAIL — '$needle' not found"
    FAIL=$((FAIL+1))
  fi
}

assert_exists() {
  local label="$1"
  local file="$2"
  echo -n "  $label... "
  if [ -f "$file" ]; then
    echo "PASS"
    PASS=$((PASS+1))
  else
    echo "FAIL — File $file does not exist"
    FAIL=$((FAIL+1))
  fi
}

echo "--- Run Sync (Expect Local Fallback & Index Registration) ---"
# Run sync command
OUTPUT=$(bash "$REPO_ROOT/cli/commands/install-tool.sh" test-plugin --sync 2>&1 || echo "CRASHED")

echo "Output of sync:"
echo "$OUTPUT"
echo ""

# Assertions
assert_contains "Uses local project templates" "Synced templates from local" "$OUTPUT"
assert_exists "Copy rule file" "$WORKSPACE_ROOT/.agents/rules/test-rule.md"
assert_exists "Copy skill file" "$WORKSPACE_ROOT/.agents/skills/test-skill/SKILL.md"

# Check manifest overwritten
assert_contains "Manifest version bumped" "version: \"1.1.0\"" "$(cat "$WORKSPACE_ROOT/.para/tools/test-plugin/tool.manifest.yml")"

# Check index files
assert_contains "Register rule in index" "| Test Rule Title | When running tests | rules/test-rule.md | 🔴 |" "$(cat "$WORKSPACE_ROOT/.agents/rules.md")"
assert_contains "Register skill in index" "| Test Skill Title | When calling test-skill | skills/test-skill/SKILL.md |" "$(cat "$WORKSPACE_ROOT/.agents/skills.md")"

# Test Idempotency / Update
echo "--- Run Sync again with updated trigger (Expect Row Update) ---"
# Update trigger in local manifest
sed -i 's/When running tests/When running TDD tests/' "$LOCAL_PROJECT_DIR/tool.manifest.yml"

OUTPUT2=$(bash "$REPO_ROOT/cli/commands/install-tool.sh" test-plugin --sync 2>&1 || echo "CRASHED")

assert_contains "Register updated rule" "| Test Rule Title | When running TDD tests | rules/test-rule.md | 🔴 |" "$(cat "$WORKSPACE_ROOT/.agents/rules.md")"
# Verify no duplicate entries
DUPS=$(grep -c "rules/test-rule.md" "$WORKSPACE_ROOT/.agents/rules.md")
echo -n "  Verify no duplicate rows... "
if [ "$DUPS" -eq 1 ]; then
  echo "PASS"
  PASS=$((PASS+1))
else
  echo "FAIL — Found duplicate rule entries: $DUPS"
  FAIL=$((FAIL+1))
fi

# Test Path Traversal Protection
echo "--- Run Sync with path traversal in manifest (Expect Security Error) ---"
cat << 'EOF' > "$LOCAL_PROJECT_DIR/tool.manifest.yml"
name: test-plugin
version: "1.2.0"
repo: "https://github.com/pageel/para-test-plugin"
agents:
  rules:
    - source: ../../../etc/passwd
      target: passwd.md
      version: "1.2.0"
      name: "Traversal Rule"
      trigger: "Traversal"
EOF

OUTPUT3=$(bash "$REPO_ROOT/cli/commands/install-tool.sh" test-plugin --sync 2>&1 || echo "CRASHED")
assert_contains "Blocks path traversal in source" "Security Error" "$OUTPUT3"

cat << 'EOF' > "$LOCAL_PROJECT_DIR/tool.manifest.yml"
name: test-plugin
version: "1.2.0"
repo: "https://github.com/pageel/para-test-plugin"
agents:
  rules:
    - source: templates/agents/rules/test-rule.md
      target: ../../../passwd.md
      version: "1.2.0"
      name: "Traversal Rule"
      trigger: "Traversal"
EOF

OUTPUT4=$(bash "$REPO_ROOT/cli/commands/install-tool.sh" test-plugin --sync 2>&1 || echo "CRASHED")
assert_contains "Blocks path traversal in target" "Security Error" "$OUTPUT4"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
