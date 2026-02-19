---
description: Start a working session with full context.
---

# /open [project-name]

Start a new working session with full context from previous sessions.

## Steps

### 1. Identify project paths

```
Base: Projects/[project-name]/
├── repo/         # Source code (git root)
├── sessions/     # Session logs & BACKLOG
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

### 4. Read BACKLOG (if exists)

//turbo

```bash
head -30 Projects/[project-name]/sessions/BACKLOG.md
```

### 5. 🔔 Check Sync Queue (Cross-Project Notifications)

//turbo

Read `Areas/Workspace/SYNC.md` and **filter rows** where the `Downstream` column matches `[project-name]` and Status is `🔴 Pending`.

If there are pending sync items, display them prominently.

### 6. Check Git status

//turbo

```bash
cd Projects/[project-name]/repo && git status --short && git log -n 1 --oneline
```

### 7. Display report

Generate a dashboard summarizing:

- Last session focus
- Pending TODOs
- Sync Queue alerts
- Backlog top items
- Suggested Actions

## Related

- `/end` - End session and log progress
- `/backlog` - View detailed backlog
