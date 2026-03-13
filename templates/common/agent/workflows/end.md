---
description: Log session and close working day with PARA classification
source: catalog
---

# /end [project-name | all | workspace] [done]

> **Workspace Version:** 1.5.3 (Hot Lane)
> **Constraint:** Read `.para-workspace.yml` at the workspace root to get the user's preferred language from `preferences.language` (e.g., `vi` for Vietnamese). **All output and the final report MUST be translated to this language.**

Summarize accomplishments and log them to the correct context (Project vs. Workspace).

| Option | Description                                                                                                      |
| :----- | :--------------------------------------------------------------------------------------------------------------- |
| `all`  | Close the working session for all modified projects in git status.                                               |
| `done` | (Optional) If the active plan (`active_plan`) is 100% complete, automatically remove this field in `project.md`. |

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

### 3.5. Hot Lane Sync (sprint-current.md)

// turbo

> **Rule:** `hybrid-3-file-integrity.md` C5 — `/end` is the sole sync point for all task reconciliation.

**Step A: Process Quick Tasks** (from sprint-current.md)

1. Read `artifacts/tasks/sprint-current.md`. If file not exists → skip to Step B.
2. For each item marked `[x]` in `## Quick Tasks`:
   - Append to `artifacts/tasks/done.md` under today’s date header, with `#session` tag:
     ```markdown
     - [x] <task-description> #session
     ```
3. For each item still `[ ]` in `## Quick Tasks`:
   - Ask user: **“Giữ cho phiên sau?”** or **“Promote vào backlog?”**
   - If promote → add to `backlog.md` via normal format, remove from sprint-current
   - If keep → leave in sprint-current for next session
4. Clean sprint-current.md: remove all `[x]` items, keep `[ ]` items and `## Notes`.
5. Report: `🔥 Hot Lane: [N] quick tasks → done.md, [M] pending`

**Step B: Smart Suggest Strategic Tasks** (from session log)

1. Read session log written in Step 2 (current session’s work summary).
2. Extract any task IDs mentioned (FEAT-XX, BUG-XX patterns).
3. Cross-reference with `backlog.md` active items (grep for matching IDs).
4. For each match, suggest to user:
   ```
   💡 Phiên này bạn đã làm việc với:
   - FEAT-13: Safety Guardrails — Đánh dấu Done?
   - BUG-16: Inbox categorization — Đánh dấu Done?
   ```
5. For user-confirmed items:
   - Update status in `backlog.md` to `✅ Done (YYYY-MM-DD)`
   - Append to `done.md` with `#backlog` tag:
     ```markdown
     - [x] FEAT-13: Safety Guardrails #backlog
     ```
6. Report: `📝 Strategic: [N] tasks → done.md`

### 4. Check Plan Phase Progress (if active)

// turbo

> ⚠️ **Token optimization:** Only check if `project.md` has `active_plan` field (already read in Step 1). Skip entirely if missing.

If `active_plan` exists in `project.md`:

1. Extract current phase:
   ```bash
   grep -n "^### Phase" Projects/[project-name]/artifacts/[active_plan]
   ```
2. Cross-reference with backlog — count ✅ Done items for the current phase.
3. Report phase status in the session log:

```markdown
### Plan Progress

- **Current Phase**: [Phase N: Name]
- **Progress**: [N/M] tasks done
- **Status**: [🔨 In Progress | 🎉 Phase Complete!]
```

4. If all items in the current phase are complete OR the user issues the command with the `done` keyword:
   - If the scenario is 100% complete:
     - Output: `🎉 Project Plan Complete! Cleaning up active_plan reference.`
     - **Action**: Remove the `active_plan` field from `project.md` to optimize context for future sessions.
   - If a midway phase is complete:
     - Output: `🎉 Phase [N] Complete! Phase [N+1] ready to start.`
5. If the scope or architecture changes during this session, suggest running `/plan update`.

### 5. Update Master Index

// turbo

Append a summary line to the global index at `Areas/Workspace/SESSION_LOG.md`:

```markdown
| YYYY-MM-DD | [project-name] | [brief summary of session] |
```

## Related

- `/open` — Start session with context loading
- `/plan` — View or update implementation plan
- `/backlog` — View and manage project tasks
- `/push` — Quick commit and push
- `/retro` — Project retrospective before archiving
