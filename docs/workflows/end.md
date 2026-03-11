# /end Workflow

> **Version**: 1.5.0

The `/end` workflow closes a working session by summarizing accomplishments and logging them to the correct PARA location. It ensures context is preserved for the next session.

> **Important:** `/end` does **NOT** perform any Git operations (commit, push, tag). Use `/push` for that.

## Commands

```
/end [project-name]          # Close session for a specific project
/end all                     # Close session for all modified projects
/end workspace               # Close session for workspace-level work
/end [project-name] done     # Close + clean up completed plan
```

| Option         | Description                                                           |
| :------------- | :-------------------------------------------------------------------- |
| `project-name` | Target project to close                                               |
| `all`          | Close all projects with changes in the current session                |
| `workspace`    | Log to `Areas/Workspace/sessions/` instead of a project               |
| `done`         | If `active_plan` is 100% complete, remove the field from `project.md` |

## Session Close Flow

```
Classify changes → Write session log → Sync queue → Plan progress → Master index
```

### 1. Classify & Identify Changes

Determines whether work belongs to a specific **Project** or to **Workspace/Learning**:

| Type                 | Criteria                                   | Log Destination                          |
| :------------------- | :----------------------------------------- | :--------------------------------------- |
| Project Work         | Development, bug fixes, project docs       | `Projects/[name]/sessions/YYYY-MM-DD.md` |
| Workspace & Learning | Structure refactoring, learning, standards | `Areas/Workspace/sessions/YYYY-MM-DD.md` |

### 2. Log Session

Creates or appends to the session log file. Uses "Session N" headers when multiple topics are covered in one day.

**Required sections:**

- **What was done** — completed items (bullet list)
- **Pending TODOs** — carry-forward items for next session
- **Downstream Impact** — if changes affect other projects

### 3. Cross-Project Sync Queue

If `project.md` declares `downstream` dependencies, appends a row to `Areas/Workspace/SYNC.md`:

```markdown
| YYYY-MM-DD | [source] | [version] | [downstream] | [action needed] | 🔴 Pending |
```

Skipped if no downstream dependencies exist.

### 4. Check Plan Phase Progress

> Only runs if `project.md` has a non-empty `active_plan` field.

1. Extracts the current phase from the plan file
2. Counts ✅ Done items for that phase against the backlog
3. Logs phase status in the session file

**When using the `done` keyword:**

- Plan 100% complete → removes `active_plan` from `project.md`
- Phase complete → announces next phase is ready

### 5. Update Master Index

Appends a one-line summary to `Areas/Workspace/SESSION_LOG.md`:

```markdown
| YYYY-MM-DD | [project-name] | [brief summary] |
```

## What `/end` Does NOT Do

| Does not        | Use instead    |
| :-------------- | :------------- |
| Commit code     | `/push`        |
| Push to remote  | `/push`        |
| Run build/test  | `/push --test` |
| Create releases | `/release`     |
| Review code     | `/verify`      |

## Recommended Flow

```
Work → /push (commit & push) → /end (log session) → /open (next day)
```

## Related

- [/open Workflow](./open.md) — Start session with context loading
- [Workflow Documentation](../workflows.md) — Workflow catalog and philosophy

---

_Added in v1.5.0_
