#!/bin/bash

# PARA Workspace Status (v1.4)
# Usage: para status [--json]

set -e

# === Cross-platform path normalization ===
normalize_path() {
  local p="$1"
  p="${p//\\//}"
  p="${p%/}"
  echo "$p"
}

# === Resolve workspace root ===
if [ -n "$WORKSPACE_ROOT" ]; then
  WS_ROOT="$(normalize_path "$WORKSPACE_ROOT")"
elif [ -f ".para-workspace.yml" ]; then
  WS_ROOT="$(normalize_path "$(pwd)")"
else
  echo "❌ Error: Not in a PARA workspace (no .para-workspace.yml found)."
  echo "Run 'para init' to create a workspace, or set WORKSPACE_ROOT."
  exit 1
fi

# === Parse arguments ===
JSON_MODE=false
for arg in "$@"; do
  case "$arg" in
    --json) JSON_MODE=true ;;
  esac
done

# === Read workspace config ===
CONFIG_FILE="$WS_ROOT/.para-workspace.yml"
KERNEL_VERSION="unknown"
PROFILE="unknown"
LANG_PREF="unknown"

if [ -f "$CONFIG_FILE" ]; then
  KERNEL_VERSION=$(grep '^kernel_version:' "$CONFIG_FILE" | sed 's/kernel_version:[[:space:]]*//; s/"//g' || echo "unknown")
  PROFILE=$(grep '^profile:' "$CONFIG_FILE" | sed 's/profile:[[:space:]]*//; s/"//g' || echo "unknown")
  LANG_PREF=$(grep '^language:' "$CONFIG_FILE" | sed 's/language:[[:space:]]*//; s/"//g' || echo "unknown")
fi

# === Count workspace stats ===
count_projects() {
  local dir="$1"
  local count=0
  if [ -d "$dir" ]; then
    for p in "$dir"/*/; do
      [ -d "$p" ] && count=$((count + 1))
    done
  fi
  echo "$count"
}

PROJECTS_COUNT=$(count_projects "$WS_ROOT/Projects")
AREAS_COUNT=$(count_projects "$WS_ROOT/Areas")
RESOURCES_COUNT=$(count_projects "$WS_ROOT/Resources")
ARCHIVE_COUNT=$(count_projects "$WS_ROOT/Archive")

# === JSON output mode ===
if [ "$JSON_MODE" = true ]; then
  echo "{"
  echo "  \"workspace\": \"$WS_ROOT\","
  echo "  \"kernel_version\": \"$KERNEL_VERSION\","
  echo "  \"profile\": \"$PROFILE\","
  echo "  \"language\": \"$LANG_PREF\","
  echo "  \"counts\": {"
  echo "    \"projects\": $PROJECTS_COUNT,"
  echo "    \"areas\": $AREAS_COUNT,"
  echo "    \"resources\": $RESOURCES_COUNT,"
  echo "    \"archive\": $ARCHIVE_COUNT"
  echo "  },"
  echo "  \"projects\": ["

  first=true
  for project_dir in "$WS_ROOT"/Projects/*/; do
    if [ -d "$project_dir" ]; then
      project_name="$(basename "$project_dir")"
      project_md="$project_dir/project.md"

      status="unknown"
      if [ -f "$project_md" ]; then
        status=$(grep '^status:' "$project_md" | sed 's/status:[[:space:]]*//; s/"//g; s/'\''//g' || echo "unknown")
      fi

      # Count tasks
      backlog="$project_dir/artifacts/tasks/backlog.md"
      total=0; done_count=0
      if [ -f "$backlog" ]; then
        total=$(grep -c '^- \[' "$backlog" 2>/dev/null || echo 0)
        done_count=$(grep -c '^- \[x\]' "$backlog" 2>/dev/null || echo 0)
      fi

      [ "$first" = true ] && first=false || echo ","
      printf '    {"name": "%s", "status": "%s", "tasks_total": %s, "tasks_done": %s}' \
        "$project_name" "$status" "$total" "$done_count"
    fi
  done

  echo ""
  echo "  ]"
  echo "}"
  exit 0
fi

# === Human-readable output ===
echo "📊 PARA Workspace Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🧠 Kernel: v$KERNEL_VERSION"
echo "  🎭 Profile: $PROFILE"
echo "  🌐 Language: $LANG_PREF"
echo "  📂 Root: $WS_ROOT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# PARA Directory counts
echo ""
echo "📦 Workspace Structure:"
echo "  Projects:  $PROJECTS_COUNT"
echo "  Areas:     $AREAS_COUNT"
echo "  Resources: $RESOURCES_COUNT"
echo "  Archive:   $ARCHIVE_COUNT"

# List active projects
if [ "$PROJECTS_COUNT" -gt 0 ]; then
  echo ""
  echo "🚀 Active Projects:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  for project_dir in "$WS_ROOT"/Projects/*/; do
    if [ -d "$project_dir" ]; then
      project_name="$(basename "$project_dir")"
      project_md="$project_dir/project.md"

      status="[unknown]"
      deadline=""

      if [ -f "$project_md" ]; then
        status=$(grep '^status:' "$project_md" | sed 's/status:[[:space:]]*//; s/"//g; s/'\''//g' || echo "unknown")
        deadline=$(grep '^deadline:' "$project_md" | sed 's/deadline:[[:space:]]*//; s/"//g; s/'\''//g' || echo "")

        # Overdue check
        if [ -n "$deadline" ] && [ "$status" = "active" ] && command -v date &>/dev/null; then
          today="$(date +%Y-%m-%d)"
          if [[ "$deadline" < "$today" ]]; then
            status="🔥 OVERDUE"
          fi
        fi
      fi

      # Count tasks from backlog.md (v1.4 canonical)
      backlog="$project_dir/artifacts/tasks/backlog.md"
      task_info="N/A"
      if [ -f "$backlog" ]; then
        total=$(grep -c '^- \[' "$backlog" 2>/dev/null || echo 0)
        done_count=$(grep -c '^- \[x\]' "$backlog" 2>/dev/null || echo 0)
        task_info="$done_count/$total"
      fi

      printf "  %-25s | Status: %-12s | Tasks: %-7s" "$project_name" "$status" "$task_info"
      [ -n "$deadline" ] && printf " | Due: %s" "$deadline"
      echo ""
    fi
  done
fi

# Agent stats
echo ""
echo "🤖 Agent Runtime:"
wf_total=$(find "$WS_ROOT/.agent/workflows" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l || echo 0)
wf_catalog=$(grep -rl "^source: catalog" "$WS_ROOT/.agent/workflows/"*.md 2>/dev/null | wc -l || echo 0)
wf_user=$((wf_total - wf_catalog))
echo "  Workflows: $wf_total ($wf_catalog catalog, $wf_user user)"

rl_total=$(find "$WS_ROOT/.agent/rules" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l || echo 0)
echo "  Rules:     $rl_total"

sk_total=$(find "$WS_ROOT/.agent/skills" -maxdepth 1 -type d 2>/dev/null | tail -n +2 | wc -l || echo 0)
echo "  Skills:    $sk_total"

# Cleanup warning
bak_count=$(find "$WS_ROOT" -name "*.bak" -not -path "*/.git/*" -not -path "*/node_modules/*" -not -path "$WS_ROOT/.para/*" 2>/dev/null | wc -l || echo 0)
old_backup_count=0
if [ -d "$WS_ROOT/.para/backups" ]; then
  rollback_dirs=$(find "$WS_ROOT/.para/backups" -maxdepth 1 -type d -name "rollback-*" 2>/dev/null | wc -l || echo 0)
  old_backup_count=$((old_backup_count + rollback_dirs))
fi
cleanup_total=$((bak_count + old_backup_count))
if [ "$cleanup_total" -gt 0 ]; then
  echo ""
  echo "⚠️  $bak_count legacy .bak file(s) + $old_backup_count rollback session(s) found."
  echo "   Run './para cleanup' to remove."
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

