#!/bin/bash

# PARA Workspace Status
# Usage: ./cli/status.sh

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
# Use environment variable if provided by 'para' wrapper, otherwise calculate
if [ -z "$WORKSPACE_ROOT" ]; then
  WORKSPACE_ROOT="$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")")")"
fi

echo "📊 PARA Workspace Status Report"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for project_dir in "$WORKSPACE_ROOT"/Projects/*; do
  if [ -d "$project_dir" ]; then
    project_name=$(basename "$project_dir")
    project_md="$project_dir/project.md"
    
    status="[Unknown]"
    deadline="no-date"
    if [ -f "$project_md" ]; then
        # Detect if it's YAML frontmatter (v1.3)
        if grep -q "---" "$project_md"; then
            status=$(grep "^status:" "$project_md" | cut -d'"' -f2 | cut -d"'" -f2)
            deadline=$(grep "^deadline:" "$project_md" | cut -d'"' -f2 | cut -d"'" -f2)
            
            # Simple overdue check
            if [ "$deadline" != "no-date" ] && [ "$status" == "active" ]; then
                today=$(date +%Y-%m-%d)
                if [[ "$deadline" < "$today" ]]; then
                    status="🔥 OVERDUE"
                fi
            fi
        else
            # Fallback to old format (v1.2 and below)
            status=$(grep -E "^- \[x\] (Active|On Hold|Completed)" "$project_md" | sed 's/- \[x\] //')
            if [ -z "$status" ]; then
                status=$(grep -E "^- \[[xX]\]" "$project_md" | sed 's/- \[[xX]\] //' | head -1)
            fi
        fi
    fi
    
    [ -z "$status" ] && status="Active?"
    
    # Count tasks if tasks.md exists
    tasks_file="$project_dir/artifacts/tasks.md"
    task_count="N/A"
    if [ -f "$tasks_file" ]; then
        total=$(grep -c "^- \[" "$tasks_file" || true)
        done=$(grep -c "^- \[[xX]\]" "$tasks_file" || true)
        task_count="$done/$total"
    fi

    printf "  %-25s | Status: %-12s | Deadline: %-10s | Tasks: %s\n" "$project_name" "$status" "$deadline" "$task_count"
  fi
done
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
