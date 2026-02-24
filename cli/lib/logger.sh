#!/usr/bin/env bash
# logger.sh — Structured logging for PARA CLI
# Usage: source cli/lib/logger.sh
#        log_info "message"
#        log_audit "CLI" "para init" "profile=dev lang=en" "OK"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GRAY='\033[0;90m'
NC='\033[0m'

log_info() {
  echo -e "${BLUE}ℹ${NC} $*"
}

log_success() {
  echo -e "${GREEN}✓${NC} $*"
}

log_warn() {
  echo -e "${YELLOW}⚠${NC} $*"
}

log_error() {
  echo -e "${RED}✗${NC} $*" >&2
}

log_debug() {
  if [[ "${PARA_DEBUG:-0}" == "1" ]]; then
    echo -e "${GRAY}[DEBUG] $*${NC}" >&2
  fi
}

# Append a structured line to .para/audit.log
# Usage: log_audit "CLI" "para init" "profile=dev lang=en" "OK"
log_audit() {
  local source="$1"
  local command="$2"
  local params="${3:-}"
  local status="${4:-OK}"
  local audit_file="${PARA_WORKSPACE_ROOT:-.}/.para/audit.log"

  if [[ -d "$(dirname "$audit_file")" ]]; then
    local timestamp
    timestamp=$(date -Iseconds 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S%z")
    echo "$timestamp | $source | $command | $params | $status" >> "$audit_file"
  fi
}
