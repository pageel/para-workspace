#!/usr/bin/env bash
# rollback.sh — Atomic rollback for install/migrate operations
# Usage: source cli/lib/rollback.sh
#        rollback_init
#        rollback_register "/path/to/file"
#        rollback_execute   # ← rolls back all registered files
#        rollback_commit    # ← clears the register (operation succeeded)

# Rollback state
ROLLBACK_DIR=""
ROLLBACK_FILES=()

# Initialize rollback session — creates temp backup directory
rollback_init() {
  ROLLBACK_DIR="${WORKSPACE_ROOT:-.}/.para/backups/rollback-$(date +%s)"
  mkdir -p "$ROLLBACK_DIR"
  ROLLBACK_FILES=()
  log_debug "Rollback session initialized: $ROLLBACK_DIR"
}

# Register a file for rollback (backup before modification)
# Usage: rollback_register "/path/to/file"
rollback_register() {
  local file="$1"

  if [[ -f "$file" ]]; then
    local backup_name
    backup_name=$(echo "$file" | tr '/' '_')
    cp "$file" "$ROLLBACK_DIR/$backup_name"
    ROLLBACK_FILES+=("$file:$ROLLBACK_DIR/$backup_name")
    log_debug "Registered for rollback: $file"
  fi
}

# Execute rollback — restore all registered files
rollback_execute() {
  if [[ ${#ROLLBACK_FILES[@]} -eq 0 ]]; then
    log_warn "No files to rollback."
    return 0
  fi

  log_warn "Rolling back ${#ROLLBACK_FILES[@]} files..."

  for entry in "${ROLLBACK_FILES[@]}"; do
    local original="${entry%%:*}"
    local backup="${entry##*:}"

    if [[ -f "$backup" ]]; then
      cp "$backup" "$original"
      log_info "  Restored: $original"
    fi
  done

  log_success "Rollback complete."
  log_audit "CLI" "rollback" "files=${#ROLLBACK_FILES[@]}" "OK"
}

# Commit — operation succeeded, clean up backups
rollback_commit() {
  if [[ -n "$ROLLBACK_DIR" && -d "$ROLLBACK_DIR" ]]; then
    # Keep the backup for safety, but clear the register
    ROLLBACK_FILES=()
    log_debug "Rollback session committed (backup kept at $ROLLBACK_DIR)"
  fi
}
