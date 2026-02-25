---
description: Start a working session with context from previous logs and sync queue
---

# /open [project-name]

> **Workspace Version:** 1.4.1 (Governed Libraries)

Start a new working session with full context from previous sessions.

## Steps

> **Constraint:** Read `.para-workspace.yml` at the workspace root to get the user's preferred language from `preferences.language` (e.g., `vi` for Vietnamese). **All output and the final report MUST be translated to this language.**

### 1. Identify project paths

```
Base: Projects/[project-name]/
├── repo/         # Source code (git root)
├── sessions/     # Session logs
├── artifacts/    # Tasks, backlog, and other generated files
├── docs/         # Project documentation
└── project.md      # Project contract (YAML)
```

### 2. Read project contract

//turbo

Read `Projects/[project-name]/project.md` to understand goal, deadline, status, and DoD.

### 3. Find and read latest session

//turbo

```bash
ls -t Projects/[project-name]/sessions/*.md | head -3
```

Read the latest session log for context on previous work.

### 4. Read backlog (if exists)

//turbo

```bash
head -30 Projects/[project-name]/artifacts/tasks/backlog.md
```

### 5. 🔔 Check Sync Queue (Cross-Project Notifications)

//turbo

Read `Areas/Workspace/SYNC.md` and **filter rows** where the `Downstream` column matches `[project-name]` and Status is `🔴 Pending`.

If there are pending sync items, display them prominently:

```
⚠️ UPSTREAM CHANGES DETECTED:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
| Source: [upstream-project] v[version]
| Action: [what needs to be done]
| Date:   [when it was logged]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After presenting the sync items, ask the user whether they want to **process** the changes (update code/content) or simply **dismiss** them (mark as read).

Once the user decides, automatically update `SYNC.md`:

- Move the row from `## Pending` to `## Completed` (remove the Status column).
- **IMPORTANT:** Auto-trim the `## Completed` table, keeping only the **5 most recent** entries. Delete older rows to prevent file bloat and save system tokens.

### 6. Check Git status

//turbo

```bash
cd Projects/[project-name]/repo && git status --short && git log -n 1 --oneline
```

### 7. Display report

```
🚀 Starting: [Project Name] | 📅 [YYYY-MM-DD]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 LAST SESSION: [Date] - [Focus]

✅ Completed:
- [Items from session log]

⏳ Pending TODO:
- [ ] [Pending items]

🔔 SYNC QUEUE: [N pending] /[0 if none]

📥 backlog SUMMARY:
- High: [N] | Medium: [N] | Low: [N]
- Top items: [list 2-3 items]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 SUGGESTED ACTIONS:
1. [Priority 1 - include sync items if pending]
2. [Priority 2]

❓ What would you like to work on?
```

## Related

- `/end` - End session and log progress
- `/backlog` - View detailed backlog
- `/push` - Quick commit and push
