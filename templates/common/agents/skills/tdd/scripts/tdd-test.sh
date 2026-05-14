#!/usr/bin/env bash
# TDD Evidence Logger — Wraps test commands to create audit trail
# Usage: bash .agents/skills/tdd/scripts/tdd-test.sh <test-command...>
# Evidence is appended to .beads/tdd-evidence.log (outside repo, no gitignore needed)
#
# Example:
#   bash .agents/skills/tdd/scripts/tdd-test.sh npm test --run test/foo.test.ts
#
# IMPORTANT: This script MUST be run from the repo root directory (Projects/<name>/repo/).
# The default log path (../.beads/) assumes this CWD.

set -o pipefail

# Find project root by looking for project.md
CURRENT_DIR="$(pwd)"
PROJECT_ROOT=""
while [ "$CURRENT_DIR" != "/" ]; do
  if [ -f "$CURRENT_DIR/project.md" ]; then
    PROJECT_ROOT="$CURRENT_DIR"
    break
  fi
  CURRENT_DIR="$(dirname "$CURRENT_DIR")"
done

# Fallback to pwd if not found
if [ -z "$PROJECT_ROOT" ]; then
  PROJECT_ROOT="$(pwd)"
fi

LOG_FILE="${TDD_LOG:-$PROJECT_ROOT/artifacts/tests/tdd-evidence.log}"

if [ $# -eq 0 ]; then
  echo "❌ Usage: tdd-test.sh <test-command...>"
  echo "   Example: tdd-test.sh npm test --run test/foo.test.ts"
  exit 1
fi

TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S)
mkdir -p "$(dirname "$LOG_FILE")"

# Run the test command and capture output + exit code
OUTPUT=$("$@" 2>&1)
EXIT_CODE=$?

STATUS=$( [ $EXIT_CODE -eq 0 ] && echo "PASS" || echo "FAIL" )

# Append evidence entry
cat >> "$LOG_FILE" <<EOF
---
timestamp: $TIMESTAMP
status: $STATUS
exit_code: $EXIT_CODE
command: $*
snippet: |
$(echo "$OUTPUT" | tail -5 | sed 's/^/  /')

EOF

# Show original output to caller (Agent)
echo "$OUTPUT"
exit $EXIT_CODE
