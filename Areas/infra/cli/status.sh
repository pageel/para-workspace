#!/bin/bash

# PARA Workspace Status
# Usage: ./cli/status.sh

set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
# Use environment variable if provided by 'para' wrapper, otherwise calculate
if [ -z "$WORKSPACE_ROOT" ]; then
  WORKSPACE_ROOT="$(dirname "$(dirname "$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")")")"
fi

# Get Version
VERSION_FILE="$WORKSPACE_ROOT/Projects/para-workspace/repo/VERSION"
VERSION=$(cat "$VERSION_FILE" 2>/dev/null || echo "Unknown")

echo "📊 PARA Workspace Status Report (v$VERSION)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for project_dir in "$WORKSPACE_ROOT"/Projects/*; do
  if [ -d "$project_dir" ]; then
    project_name=$(basename "$project_dir")
    project_md="$project_dir/project.md"
    
    status="[Unknown]"
    deadline="no-date"
    if [ -f "$project_md" ]; then
        # Detect if it's YAML frontmatter (v1.3)
        if grep -q -e "---" "$project_md"; then
            status=$(grep "^status:" "$project_md" | sed 's/status:[[:space:]]*//; s/["'\'']//g')
            deadline=$(grep "^deadline:" "$project_md" | sed 's/deadline:[[:space:]]*//; s/["'\'']//g')
            
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

    # Count project-specific rules and workflows
    p_rules=$(find "$project_dir/.agent/rules" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l || echo 0)
    p_wfs=$(find "$project_dir/.agent/workflows" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l || echo 0)

    printf "  %-25s | Status: %-12s | Tasks: %-7s | Rules/WFs: %s/%s\n" "$project_name" "$status" "$task_count" "$p_rules" "$p_wfs"
  fi
done
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Global Stats
g_rules=$(find "$WORKSPACE_ROOT/.agent/rules" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l || echo 0)
g_wfs=$(find "$WORKSPACE_ROOT/.agent/workflows" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l || echo 0)
c_rules=$(find "$WORKSPACE_ROOT/Resources/ai-agents/rules" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l || echo 0)
c_wfs=$(find "$WORKSPACE_ROOT/Resources/ai-agents/workflows" -maxdepth 1 -name "*.md" 2>/dev/null | wc -l || echo 0)

echo "🌍 Global Stats:"
echo "  Core Rules: $g_rules (Library: $c_rules)"
echo "  Core Workflows: $g_wfs (Library: $c_wfs)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
