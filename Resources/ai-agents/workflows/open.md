---
description: Resume work with context from the last session
---

# /p-open [project-name]

> **Workspace Version:** 1.3.1 (PARA Architecture)

Initialize the environment for a project by reviewing recent context, backlog, and status.

## Steps

### 1. Read Global Index

// turbo

```bash
cat Areas/Development/SESSION_LOG.md
```

Check `SESSION_LOG.md` for the most recent activity in the workspace.

### 2. Review Recent Session

// turbo

```bash
ls -t Projects/[project-name]/sessions/*.md | head -1
```

Read the latest session log in `Projects/[project-name]/sessions/` to regain technical context.

### 3. Check Backlog

// turbo

```bash
cat Projects/[project-name]/sessions/BACKLOG.md 2>/dev/null | head -20
```

Review the internal backlog for any high-priority features or bugs.

### 4. Git Status & Directory Setup

// turbo

```bash
# Locate the source path from metadata.json
jq -r ".products[\"[project-name]\"].path" metadata.json
```

Navigate to the source directory and run `git status` to check for uncommitted work.

### 5. Deployment Status (Optional)

If the project is a web app, verify the current deployment URL.

### 6. Report Context

Display a summary for the user:

- **Last Session:** Summary of achievements.
- **Pending TODOs:** Items left from the last log.
- **Backlog Highlights:** Top 2-3 items from backlog.
- **Proposed Tasks:** 1-2 recommended next steps.

## Related

- `/p-end` - Save session progress
- `/p-backlog` - View detailed project tasks
- `/p-push` - Quick commit and push
