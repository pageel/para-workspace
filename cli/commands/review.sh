#!/bin/bash

# PARA Workspace Audit & Review Tool
# Audit project health, deadlines, and standard compliance.

set -e

# === Load Libraries ===
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIB_DIR="$SCRIPT_DIR/../lib"

if [ -f "$LIB_DIR/fs.sh" ]; then
  source "$LIB_DIR/fs.sh"
fi

WS_ROOT="${WORKSPACE_ROOT:-$(realpath "../../..")}"
export WORKSPACE_ROOT="$WS_ROOT"

echo "🔍 Starting Workspace Review (PARA v1.4.0)..."
echo "------------------------------------------"

# 1. Projects Audit
P_PROJECTS=$(get_para_dir projects)
echo "📁 Checking $P_PROJECTS..."
PROJECTS_DIR="$WS_ROOT/$P_PROJECTS"

if [ ! -d "$PROJECTS_DIR" ]; then
    echo "⚠️  $P_PROJECTS directory not found at $PROJECTS_DIR"
else
    for proj in "$PROJECTS_DIR"/*; do
        if [ -d "$proj" ]; then
            name=$(basename "$proj")
            echo "  - Project: $name"
            
            # Check for project.md
            if [ ! -f "$proj/project.md" ]; then
                echo "    ❌ ERROR: Missing project.md (Contract failure)"
            else
                # Extract status if yq exists, otherwise grep
                status=$(grep "status:" "$proj/project.md" | awk '{print $2}' | tr -d '"' | tr -d "'")
                echo "    ✅ Contract found (Status: $status)"
            fi
            
            # Check for standard artifacts
            if [ ! -d "$proj/artifacts" ]; then
                echo "    ⚠️  WARNING: Missing artifacts/ directory"
            fi
            
            # Check for recent activity (sessions)
            if [ -d "$proj/sessions" ]; then
                last_session=$(ls -t "$proj/sessions" | head -n 1)
                if [ -n "$last_session" ]; then
                    echo "    🕒 Last activity: $last_session"
                else
                    echo "    💤 No sessions recorded"
                fi
            fi
            echo ""
        fi
    done
fi

# 2. Agent Intelligence Audit
echo "🤖 Checking Agent Configuration..."
AGENT_DIR="$WS_ROOT/.agent"
if [ -d "$AGENT_DIR" ]; then
    rule_count=$(ls -1 "$AGENT_DIR/rules"/*.md 2>/dev/null | wc -l)
    work_count=$(ls -1 "$AGENT_DIR/workflows"/*.md 2>/dev/null | wc -l)
    echo "  ✅ Runtime Rules: $rule_count installed"
    echo "  ✅ Runtime Workflows: $work_count installed"
else
    echo "  ❌ ERROR: .agents/ directory missing at root"
fi

echo "------------------------------------------"
echo "✅ Review complete."
