#!/bin/bash

# PARA Workspace Cleanup
# Removes old backups, committed rollback sessions, and legacy .bak files
# Usage: para cleanup [--dry-run] [--force] [--keep=N]

set -e

# === Cross-platform path normalization ===
normalize_path() {
  local p="$1"
  p="${p//\\//}"
  p="${p%/}"
  echo "$p"
}

# === Resolve paths ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../lib"

if [ -f "$LIB_DIR/logger.sh" ]; then
  source "$LIB_DIR/logger.sh"
fi

if [ -n "$WORKSPACE_ROOT" ]; then
  WS_ROOT="$(normalize_path "$WORKSPACE_ROOT")"
elif [ -f ".para-workspace.yml" ]; then
  WS_ROOT="$(normalize_path "$(pwd)")"
else
  echo "❌ Error: WORKSPACE_ROOT not set."
  exit 1
fi

# === Parse arguments ===
DRY_RUN=false
FORCE=false
KEEP_DAYS=5

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --force) FORCE=true ;;
    --keep=*) KEEP_DAYS="${arg#--keep=}" ;;
    --help|-h)
      echo "Usage: para cleanup [--dry-run] [--force] [--keep=N]"
      echo ""
      echo "Removes old backups and legacy .bak files from the workspace."
      echo ""
      echo "Options:"
      echo "  --dry-run     Preview what would be removed (no changes)"
      echo "  --force       Remove without confirmation"
      echo "  --keep=N      Keep N most recent backup days (default: 5)"
      echo ""
      echo "What gets cleaned:"
      echo "  1. Old backup folders in .para/backups/<date>/ (older than --keep days)"
      echo "  2. Committed rollback sessions in .para/backups/rollback-*"
      echo "  3. Legacy .bak files scattered across the workspace (pre-v1.4.9)"
      exit 0
      ;;
  esac
done

PARA_STATE="$WS_ROOT/.para"
BACKUP_DIR="$PARA_STATE/backups"

echo "🧹 PARA Workspace Cleanup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Workspace: $WS_ROOT"
echo "  Keep:      $KEEP_DAYS most recent backup days"
if [ "$DRY_RUN" = true ]; then
  echo "  Mode:      DRY RUN (preview only)"
fi
echo ""

total_removed=0
total_bytes=0

# === 1. Old date-based backup folders ===
echo "📦 Scanning backup folders..."
old_dirs=0
if [ -d "$BACKUP_DIR" ]; then
  # List date-format dirs, sort, skip the most recent $KEEP_DAYS
  date_dirs=()
  while IFS= read -r d; do
    [ -d "$d" ] && date_dirs+=("$d")
  done < <(find "$BACKUP_DIR" -maxdepth 1 -type d -name "20[0-9][0-9]-[0-9][0-9]-[0-9][0-9]" | sort)

  total_date_dirs=${#date_dirs[@]}
  if [ "$total_date_dirs" -gt "$KEEP_DAYS" ]; then
    remove_count=$((total_date_dirs - KEEP_DAYS))
    for i in $(seq 0 $((remove_count - 1))); do
      dir="${date_dirs[$i]}"
      dir_size=$(du -sk "$dir" 2>/dev/null | cut -f1 || echo 0)
      total_bytes=$((total_bytes + dir_size))
      if [ "$DRY_RUN" = true ]; then
        echo "   → Would remove: $(basename "$dir")/ (${dir_size}K)"
      else
        rm -rf "$dir"
        echo "   ✓ Removed: $(basename "$dir")/"
      fi
      old_dirs=$((old_dirs + 1))
    done
  fi
fi

if [ "$old_dirs" -eq 0 ]; then
  echo "   ✓ No old backup folders to remove (keeping $KEEP_DAYS most recent)"
fi

# === 2. Committed rollback sessions ===
echo "🔄 Scanning rollback sessions..."
rollback_count=0
if [ -d "$BACKUP_DIR" ]; then
  for rdir in "$BACKUP_DIR"/rollback-*; do
    [ -d "$rdir" ] || continue
    dir_size=$(du -sk "$rdir" 2>/dev/null | cut -f1 || echo 0)
    total_bytes=$((total_bytes + dir_size))
    if [ "$DRY_RUN" = true ]; then
      echo "   → Would remove: $(basename "$rdir")/ (${dir_size}K)"
    else
      rm -rf "$rdir"
      echo "   ✓ Removed: $(basename "$rdir")/"
    fi
    rollback_count=$((rollback_count + 1))
  done
fi

if [ "$rollback_count" -eq 0 ]; then
  echo "   ✓ No rollback sessions to remove"
fi

# === 3. Legacy .bak files scattered in workspace ===
echo "📄 Scanning legacy .bak files..."
legacy_count=0
while IFS= read -r bakfile; do
  [ -z "$bakfile" ] && continue
  file_size=$(du -sk "$bakfile" 2>/dev/null | cut -f1 || echo 0)
  total_bytes=$((total_bytes + file_size))
  if [ "$DRY_RUN" = true ]; then
    rel_path="${bakfile#$WS_ROOT/}"
    echo "   → Would remove: $rel_path (${file_size}K)"
  else
    rm -f "$bakfile"
  fi
  legacy_count=$((legacy_count + 1))
done < <(find "$WS_ROOT" -name "*.bak" \
  -not -path "*/.git/*" \
  -not -path "*/node_modules/*" \
  -not -path "$PARA_STATE/*" \
  2>/dev/null)

if [ "$legacy_count" -eq 0 ]; then
  echo "   ✓ No legacy .bak files found"
elif [ "$DRY_RUN" = false ]; then
  echo "   ✓ Removed $legacy_count legacy .bak files"
fi

total_removed=$((old_dirs + rollback_count + legacy_count))

# === Summary ===
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$total_removed" -eq 0 ]; then
  echo "✨ Workspace is clean! Nothing to remove."
elif [ "$DRY_RUN" = true ]; then
  echo "🔍 Dry run complete. Would remove:"
  echo "   $old_dirs old backup folder(s)"
  echo "   $rollback_count rollback session(s)"
  echo "   $legacy_count legacy .bak file(s)"
  echo "   ~${total_bytes}K total"
  echo ""
  echo "   Remove --dry-run to apply cleanup."
else
  echo "✅ Cleanup complete!"
  echo "   Removed $old_dirs backup folder(s), $rollback_count rollback(s), $legacy_count legacy .bak(s)"
  echo "   ~${total_bytes}K freed"
  # Audit log
  if command -v log_audit &>/dev/null; then
    log_audit "CLI" "para cleanup" "removed=$total_removed,freed=${total_bytes}K" "OK"
  elif [ -d "$PARA_STATE" ]; then
    echo "$(date -Iseconds 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S%z") | SYSTEM | para cleanup | removed=$total_removed,freed=${total_bytes}K | OK" >> "$PARA_STATE/audit.log"
  fi
fi
