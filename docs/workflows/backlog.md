# /backlog Workflow

> **Version**: 1.5.3

The `/backlog` workflow manages the full lifecycle of a project's product backlog: review summaries, add features/bugs, evaluate priorities with ICE scoring, update statuses, and sync with implementation plans.

## Commands

```
/backlog [project-name] [action]
```

| Action     | Description                                        |
| :--------- | :------------------------------------------------- |
| `review`   | Show overview with summary stats and phase context |
| `add`      | Add new feature, epic, or bug                      |
| `evaluate` | ICE scoring for priorities                         |
| `update`   | Update status of existing items                    |
| `sync`     | Sync backlog with plan (map items to phases)       |
| `clean`    | Compress `✅ Done` items into Completed section    |

## Actions

### review

Reads `artifacts/tasks/backlog.md`, displays Summary table, Top 3 Actionable Items, and current phase context. Warns if working on future-phase items before completing the current phase.

### add

Asks: Epic or standalone? Feature or Bug? Generates next available ID, appends to correct section, and optionally maps to a plan phase.

### evaluate (ICE Scoring)

Scores pending items on Impact / Confidence / Ease (1-10). ICE = I × C × E. Priority hints: 500+ = 🚀 High, 200-499 = ✅ Quick Win, <200 = 📋 Backlog.

### update

Sets new status for a specified ID. Adds completion date for `✅ Done` items. Announces phase completion when all phase items are done.  
**Note:** Task sync to `done.md` happens at `/end` (Hot Lane Sync). The `update` action focuses on status changes only.

### clean

Compresses `✅ Done` items from active tables into the `✅ Completed (Archived)` section of `backlog.md` (1 line per plan + IDs). Details are preserved in `done.md` grouped by plan, linking to `plans/done/`. This keeps the canonical backlog readable while preserving it as the single source of truth.

### sync

Cross-references backlog with plan phases. Reports mapped vs. missing items per phase. Optionally auto-creates backlog items for unmapped plan tasks.

## ID Conventions

| Type       | Prefix            | Example          |
| :--------- | :---------------- | :--------------- |
| Epic-based | Epic abbreviation | `CI-01`, `AU-01` |
| Feature    | `FEAT-`           | `FEAT-01`        |
| Bug        | `BUG-`            | `BUG-01`         |

## Status Values

| Status               | Meaning                   |
| :------------------- | :------------------------ |
| ⏳ Pending           | Not started               |
| 🚀 ToDo              | Planned for current phase |
| 🔨 In Progress       | Currently being worked on |
| ✅ Done (YYYY-MM-DD) | Completed with date       |

## Related

- [/plan Workflow](./plan.md) — Create and manage implementation plans
- [Workflow Documentation](../reference/workflows.md) — Workflow catalog

---

_Updated in v1.5.3 (clean = compress-not-delete, plan-grouped done.md)_
