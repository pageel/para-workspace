# /open Workflow

> **Version**: 1.5.3

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

Checks `project.md` for `has_rules: true` (or checks if `Projects/[project-name]/.agent/rules.md` exists):

- If `has_rules: true` (or file exists) → reads the lightweight index (~5–10 lines) and notes trigger conditions for the session.
- Otherwise → skips entirely. Zero I/O cost.

During the session, when an action matches a trigger from the index, the agent loads the corresponding rule file before acting. See [Project Rules](../reference/project-rules.md) for details.

### 3. Find Latest Session

Reads the most recent session log to understand what was done and what's pending.

### 4. Read Task Context (Token Optimized)

> **Token optimization:** Reads backlog _summary_ (~10 lines) + hot lane. Never reads full backlog.

**4a. Backlog Summary** — Always reads the `📊 Summary` table and top active items (grep).

**4b. Hot Lane** — Reads `sprint-current.md` if it exists (small file, ~50-100 tokens). If not exists, reports `🔥 Hot Lane: empty`. This file holds ad-hoc quick tasks from previous sessions.

### 5. Read Plan (if active)

If `project.md` has an `active_plan` field, reads phase headers and the backlog-to-phase mapping to identify the current phase. Skipped if no plan exists.

### 6. Check Sync Queue (Conditional)

> **Token optimization:** Only reads `SYNC.md` if `project.md` (loaded in Step 2) has `downstream` or `upstream` fields. Otherwise skips entirely.

When applicable, reads `Areas/Workspace/SYNC.md` for pending cross-project notifications targeting this project.

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
📝 BACKLOG SUMMARY: High: N | Medium: N | Low: N
🔥 HOT LANE: [pending quick tasks or "empty"]

💡 SUGGESTED ACTIONS: [priorities]
❓ What would you like to work on?
```

## Related

- [Workflow Documentation](../reference/workflows.md) — Workflow catalog and philosophy
- [Project Rules](../reference/project-rules.md) — Project-specific rules loading

---

_Updated in v1.5.3 (Token optimized: backlog summary + hot lane + SYNC conditional)_
