# /open Workflow

> **Version**: 1.5.1

The `/open` workflow starts a new working session with full context from previous work. It loads the project contract, latest session log, backlog, and sync queue — then presents a concise report so the user knows exactly where they left off.

## Commands

```
/open [project-name]
```

## Session Open Flow

```
Project paths → Contract → Project rules → Session log → Backlog → Plan → Sync queue → Git → Report
```

### 1. Identify Project Paths

Resolves the standard PARA project structure:

```
Projects/[project-name]/
├── repo/         # Source code (git root)
├── sessions/     # Session logs
├── artifacts/    # Tasks, backlog, plans
├── docs/         # Project documentation
└── project.md    # Project contract (YAML)
```

### 2. Read Project Contract

Reads `project.md` to extract goal, deadline, status, DoD, and downstream projects.

### 2.5. Load Project Rules Index (v1.5.0)

> Added in v1.5.0

Checks for `Projects/[project-name]/.agent/rules.md`:

- If exists → reads the lightweight index (~5–10 lines) and notes trigger conditions for the session.
- If not exists → skips entirely.

During the session, when an action matches a trigger from the index, the agent loads the corresponding rule file before acting. See [Project Rules](../project-rules.md) for details.

### 3. Find Latest Session

Reads the most recent session log to understand what was done and what's pending.

### 4. Read Task Context (Fast Mode)

> **Hybrid 3-File Model**: Instead of reading the full backlog, the agent reads `artifacts/tasks/sprint-current.md` first. This file contains only active tasks (ToDo/In Progress) and uses < 100 tokens.
> If the sprint file is empty, it falls back to reading the `backlog.md` summary table.

### 5. Read Plan (if active)

If `project.md` has an `active_plan` field, reads phase headers and the backlog-to-phase mapping to identify the current phase. Skipped if no plan exists.

### 6. Check Sync Queue

Reads `Areas/Workspace/SYNC.md` for pending cross-project notifications targeting this project. Displays upstream changes and asks the user to process or dismiss them.

### 7. Check Git Status

Quick `git status --short` and latest commit to show working tree state.

### 8. Display Report

Presents a structured summary:

```
🚀 Starting: [Project Name] | 📅 [Date]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 LAST SESSION: [Date] - [Focus]
✅ Completed: [items]
⏳ Pending TODO: [items]

📐 CURRENT PHASE: [Phase N: Name]
🔔 SYNC QUEUE: [N pending]
📥 BACKLOG SUMMARY: High: N | Medium: N | Low: N

💡 SUGGESTED ACTIONS: [priorities]
❓ What would you like to work on?
```

## Related

- [Workflow Documentation](../workflows.md) — Workflow catalog and philosophy
- [Project Rules](../project-rules.md) — Project-specific rules loading

---

_Updated in v1.5.1 (Added Fast Mode task context logic)_
