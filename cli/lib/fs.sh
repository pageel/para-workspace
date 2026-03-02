#!/usr/bin/env bash
# fs.sh — File system utilities for PARA CLI
# Usage: source cli/lib/fs.sh
#        archive_file "path/to/file" "v1.4.6"

# Inherit logger if not loaded
if ! command -v log_debug &> /dev/null; then
  # Try to load logger.sh from the same directory
  if [[ -f "$(dirname "${BASH_SOURCE[0]}")/logger.sh" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"
  fi
fi

# archive_file moves obsolete structure files to .para/archive/ instead of deleting them.
# Usage: archive_file "path/to/obsolete_file.md" "v1.4.6"
archive_file() {
  local source_path="$1"
  local version_tag="${2:-unknown}"

  if [[ -z "$source_path" ]]; then
    log_warn "archive_file: missing source_path"
    return 1
  fi

  if [[ ! -e "$source_path" ]]; then
    log_debug "archive_file: file not found, skipping: $source_path"
    return 0
  fi

  # Determine archive directory
  local workspace_root="${WORKSPACE_ROOT:-.}"
  local archive_base="$workspace_root/.para/archive"
  local target_dir="$archive_base/${version_tag}-orphans"
  
  # Ensure target directory exists
  mkdir -p "$target_dir"

  # Base filename
  local basename=$(basename "$source_path")
  local target_path="$target_dir/$basename"

  # Prevent collision
  if [[ -e "$target_path" ]]; then
    target_path="${target_path}.$(date +%s)"
  fi

  # Perform move
  if mv "$source_path" "$target_path"; then
    log_info "Archived orphan file: $basename -> .para/archive/${version_tag}-orphans/"
    return 0
  else
    log_error "archive_file: failed to move $source_path"
    return 1
  fi
}
