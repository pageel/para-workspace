---
description: Log session and close working day with PARA classification
source: catalog
---

# /end [project-name | all | workspace]

> **Workspace Version:** 1.4.1 (Governed Libraries)

Summarize accomplishments and log them to the correct context (Project vs. Workspace).

## Classification Rules

1. **Project Work**: Active development, bug fixes, or documentation for a specific project.
   - **Log Destination**: `Projects/[project-name]/sessions/YYYY-MM-DD.md`
2. **Workspace & Learning**: Refactoring workspace structure, creating learning artifacts, global standards, or infrastructure updates.
   - **Log Destination**: `Areas/Workspace/sessions/YYYY-MM-DD.md`

## Steps

### 1. Classify & Identify Changes

// turbo

Review your task and determine if it belongs to a specific Project or a Global Area. List modified files.

### 2. Log Session

Create or append to the correct destination based on the rules above. Use "Session X" headers if multiple topics were covered.

Include:

- **What was done** (completed items, bullet list)
- **Pending TODOs** (carry-forward items for next session)
- **Downstream Impact** (if changes affect other projects)

### 3. Cross-Project Sync Queue

Check if the project has `downstream` dependencies in `project.md` (or metadata).
If yes, **append one row** to `Areas/Workspace/SYNC.md` under the `## Pending` table:

```markdown
| YYYY-MM-DD | [project-name] | [new-version] | [downstream-project] | [brief action needed] | 🔴 Pending |
```

### 4. Update Master Index

// turbo

Append a summary line to the global index at `Areas/Workspace/SESSION_LOG.md`:

```markdown
| YYYY-MM-DD | [project-name] | [brief summary of session] |
```

## Related

- `/open` — Start session with context loading
- `/backlog` — View and manage project tasks
- `/push` — Quick commit and push
- `/retro` — Project retrospective before archiving
