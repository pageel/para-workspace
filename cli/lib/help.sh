#!/bin/bash
# PARA CLI Shared Help Formatting Library
# Standardizes help message rendering, formatting, options, and examples.

print_usage() {
  local cmd="$1"
  local syntax="$2"
  echo "Usage: para $cmd $syntax"
  echo ""
}

print_description() {
  local desc="$1"
  echo "$desc"
  echo ""
}

print_section() {
  local title="$1"
  echo "━━━ $title ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
}

print_options() {
  echo "Options:"
  while [ $# -gt 0 ]; do
    local flag="$1"
    local desc="$2"
    printf "  %-20s %s\n" "$flag" "$desc"
    shift 2
  done
  echo ""
}

print_examples() {
  echo "Examples:"
  while [ $# -gt 0 ]; do
    echo "  $1"
    shift
  done
  echo ""
}

print_workflow_redirect() {
  local wf_name="$1"
  echo "💡 '$wf_name' is a Platform Workflow (Slash Command), not a CLI command."
  echo ""
  echo "Usage in Chat UI:"
  echo "  /$wf_name"
  echo ""
  echo "Workflow documentation:"
  echo "  .agents/workflows/$wf_name.md"
  echo ""
}
