# test-migrate.sh — Verify para migrate works correctly
# Usage: bash tests/cli/test-migrate.sh

set -e

# Setup sandbox
TEST_DIR="$(mktemp -d)"
export PARA_WORKSPACE_ROOT="$TEST_DIR"
export WORKSPACE_ROOT="$TEST_DIR"
export PARA_DEBUG=1

echo "=== PARA CLI Migrate & FS Tests ==="
echo "Running in sandbox: $TEST_DIR"

# Test 1: fs.sh archive_file
echo ""
echo "[Test 1] archive_file functionality"

# Create mock command structure needed
mkdir -p "$TEST_DIR/cli/lib"
cat << 'LIB' > "$TEST_DIR/cli/lib/logger.sh"
log_info() { echo "INFO: $*"; }
log_warn() { echo "WARN: $*"; }
log_error() { echo "ERROR: $*"; }
log_debug() { echo "DEBUG: $*"; }
LIB

cp /media/tienle/DATA/WORKSPACE/para/Projects/para-workspace/repo/cli/lib/fs.sh "$TEST_DIR/cli/lib/fs.sh"

source "$TEST_DIR/cli/lib/fs.sh"

test_file="$TEST_DIR/some_obsolete_file.md"
echo "Mock content" > "$test_file"

archive_file "$test_file" "v1.4.6"

if [[ -f "$TEST_DIR/.para/archive/v1.4.6-orphans/some_obsolete_file.md" ]]; then
  echo "✓ archive_file successfully moved the file to the archive directory."
else
  echo "✗ archive_file failed to move the file."
  exit 1
fi

if [[ ! -f "$test_file" ]]; then
  echo "✓ archive_file successfully removed the original file."
else
  echo "✗ archive_file left the original file behind."
  exit 1
fi

# Cleanup sandbox
rm -rf "$TEST_DIR"
echo ""
echo "=== Results: All tests passed ==="
