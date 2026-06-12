#!/bin/bash
# Open Diagnostics Tool
# Usage: run_open.sh [project-name]

# Auto-detect Workspace Root by looking up for .para-workspace.yml
CUR_DIR="$(pwd)"
WORKSPACE_DIR=""
while [ "$CUR_DIR" != "/" ]; do
    if [ -f "$CUR_DIR/.para-workspace.yml" ]; then
        WORKSPACE_DIR="$CUR_DIR"
        break
    fi
    CUR_DIR="$(dirname "$CUR_DIR")"
done

if [ -z "$WORKSPACE_DIR" ]; then
    echo "❌ Error: Could not detect PARA workspace root." >&2
    exit 1
fi

cd "$WORKSPACE_DIR" || exit 1

PROJECT_NAME="$1"

if [ -z "$PROJECT_NAME" ]; then
    echo "❌ Error: Project name is required."
    exit 1
fi

PROJECT_DIR="Projects/${PROJECT_NAME}"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ Error: Project directory '$PROJECT_DIR' does not exist."
    exit 1
fi

echo "=== DIAGNOSTICS FOR PROJECT: $PROJECT_NAME ==="

# 1. Check Vibecode Session Memory at startup
SESSION_FILE="${HOME}/.gemini/antigravity-ide/knowledge/vibecode_session/artifacts/session.md"
if [ -f "$SESSION_FILE" ]; then
    if grep -q "Status.*Active" "$SESSION_FILE" 2>/dev/null; then
        echo "⚠️ Active Session: DETECTED"
        grep -E "Active Plan:|Current Phase:|Project:" "$SESSION_FILE" 2>/dev/null
    else
        echo "Active Session: Inactive"
    fi
else
    echo "Active Session: No session.md file"
fi

# 2. Find latest sessions
echo "Latest sessions:"
ls -t "${PROJECT_DIR}/sessions"/*.md 2>/dev/null | head -3 || echo "  No sessions found"

# 3. Check Pending Brainstorms
echo "Pending brainstorms:"
grep -l "Decision.*Pending\|Decision: Pending" "${PROJECT_DIR}/artifacts/para-decisions"/brainstorm-*.md 2>/dev/null || echo "  None"

# 4. Check if Compact Memory exists
echo -n "Compact memory: "
if [ -f "${PROJECT_DIR}/.beads/graph/memory-slices.jsonl" ] || [ -f "${PROJECT_DIR}/repo/.beads/graph/memory-slices.jsonl" ]; then
    echo "Present"
else
    echo "Absent"
fi

# 5. Extract Hot Lane Tasks (sprint-current.md)
echo "Hot Lane Tasks:"
if [ -f "${PROJECT_DIR}/artifacts/tasks/sprint-current.md" ]; then
    grep -E '^- \[[ ]\]' "${PROJECT_DIR}/artifacts/tasks/sprint-current.md" 2>/dev/null || echo "  No pending quick tasks"
else
    echo "  Sprint-current file: Missing"
fi

# 6. Extract Backlog Summary & Top Active Tasks
echo "Backlog Summary:"
if [ -f "${PROJECT_DIR}/artifacts/tasks/backlog.md" ]; then
    grep -A 8 "## §5.*Summary" "${PROJECT_DIR}/artifacts/tasks/backlog.md" 2>/dev/null || echo "  Summary table not found"
    echo "Top Active Tasks:"
    grep -E "ToDo|In Progress" "${PROJECT_DIR}/artifacts/tasks/backlog.md" 2>/dev/null | head -3 || echo "  None"
else
    echo "  Backlog file: Missing"
fi

# 7. Extract Roadmap Phases
echo "Roadmap details:"
if [ -f "${PROJECT_DIR}/artifacts/plans/roadmap.md" ]; then
    grep -E "^\| [P0-9]" "${PROJECT_DIR}/artifacts/plans/roadmap.md" 2>/dev/null | head -10 || echo "  Roadmap empty or not matched"
else
    echo "  Roadmap file: Missing"
fi

# 8. Check Draft Plans
echo "Draft plans:"
grep -l -E "Status.*Draft" "${PROJECT_DIR}/artifacts/plans"/*.md 2>/dev/null || echo "  None"

# 9. Check Git status
echo "Git status:"
if [ -d "${PROJECT_DIR}/repo/.git" ]; then
    (cd "${PROJECT_DIR}/repo" && git status --short && git log -n 1 --oneline)
else
    echo "  Not a git repository"
fi

echo "==========================================="
