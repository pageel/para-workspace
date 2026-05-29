#!/bin/bash
# vibecode session manager helper script

KI_DIR="${HOME}/.gemini/antigravity-ide/knowledge/vibecode_session"
SESSION_FILE="${KI_DIR}/artifacts/session.md"

# Ensure directory exists
mkdir -p "${KI_DIR}/artifacts"

start_session() {
    local project="$1"
    local plan="$2"
    local phase="$3"
    
    cat << EOF > "$SESSION_FILE"
# Vibecode Session Memory

> **Status:** Active ⚡
> **Active Plan:** ${plan}
> **Current Phase:** ${phase}
> **Project:** ${project}

## Instruction
- You are currently running in **VIBECODE EXECUTION MODE** for the plan listed above.
- Your primary task is to implement code changes to complete the current phase.
- **DO NOT** edit, sync, or clean backlog.md, done.md, project.md, or system rules files under \`.agents/\`.
- All project management and metadata updates must be deferred to the \`/end\` workflow.
EOF
    echo "✅ Vibecode session memory updated to ACTIVE for plan: ${plan}"
}

stop_session() {
    cat << EOF > "$SESSION_FILE"
# Vibecode Session Memory

> **Status:** Inactive
> **Active Plan:** None

## Vibecode Rules
- Agent MUST only focus on code implementation tasks defined in the active plan.
- Do NOT modify project management artifacts (e.g., backlog.md, done.md) during vibecode.
- Defer all synchronization tasks to \`/end\`.
EOF
    echo "✅ Vibecode session memory reset to INACTIVE"
}

case "$1" in
    start)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Usage: $0 start [project-name] [plan-path] [phase-info]"
            exit 1
        fi
        start_session "$2" "$3" "$4"
        ;;
    stop)
        stop_session
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
