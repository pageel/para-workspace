#!/usr/bin/env bash
# fs.sh — File system utilities for PARA CLI
# Usage: source cli/lib/fs.sh
#        archive_file "path/to/file" "v1.4.6"
#        get_para_dir projects   # returns e.g. "10_PROJECTS" based on layout (numeric-wide)

# Inherit logger if not loaded
if ! command -v log_debug &> /dev/null; then
  # Try to load logger.sh from the same directory
  if [[ -f "$(dirname "${BASH_SOURCE[0]}")/logger.sh" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"
  fi
fi

# get_para_dir — resolve a canonical PARA pillar key to its filesystem directory name.
# Reads `layout:` from .para-workspace.yml in WORKSPACE_ROOT (defaults to "standard").
#
# Usage: get_para_dir <key>
#   key: projects | areas | resources | archive
#
# Examples:
#   get_para_dir projects      → "Projects"    (standard)
#   get_para_dir projects      → "1_Projects"  (numeric)
#   get_para_dir projects      → "10_PROJECTS" (numeric-wide)
get_para_dir() {
  local key="${1:-}"
  local ws_root="${WORKSPACE_ROOT:-.}"
  local config="$ws_root/.para-workspace.yml"
  local layout="standard"

  if [[ -f "$config" ]]; then
    local raw
    raw=$(grep '^layout:' "$config" 2>/dev/null | sed 's/layout:[[:space:]]*//' | tr -d '"' | tr -d "'" | tr -d '[:space:]')
    [[ -n "$raw" ]] && layout="$raw"
  fi

  case "${layout}:${key}" in
    standard:projects)       echo "Projects" ;;
    standard:areas)          echo "Areas" ;;
    standard:resources)      echo "Resources" ;;
    standard:archive)        echo "Archive" ;;
    numeric:projects)        echo "1_Projects" ;;
    numeric:areas)           echo "2_Areas" ;;
    numeric:resources)       echo "3_Resources" ;;
    numeric:archive)         echo "4_Archive" ;;
    numeric-wide:projects)   echo "10_PROJECTS" ;;
    numeric-wide:areas)      echo "20_AREAS" ;;
    numeric-wide:resources)  echo "30_RESOURCES" ;;
    numeric-wide:archive)    echo "40_ARCHIVE" ;;
    *)
      # Unknown layout or key — safe fallback to standard
      case "$key" in
        projects)  echo "Projects" ;;
        areas)     echo "Areas" ;;
        resources) echo "Resources" ;;
        archive)   echo "Archive" ;;
        *)         echo "$key" ;;
      esac
      ;;
  esac
}

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
