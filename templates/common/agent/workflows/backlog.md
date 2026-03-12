---
description: Manage project features and bugs
source: catalog
---

# /backlog [project-name] [action]

> **Workspace Version:** 1.5.0 (Governed Libraries)
> **Constraint:** Read `.para-workspace.yml` at the workspace root to get the user's preferred language from `preferences.language` (e.g., `vi` for Vietnamese). **All output and reports MUST be translated to this language.**

Manage the product backlog stored at `Projects/[project-name]/artifacts/tasks/backlog.md`.

## Actions

| Action     | Description                                        |
| :--------- | :------------------------------------------------- |
| `review`   | Show overview with summary stats and phase context |
| `add`      | Add new feature, epic, or bug                      |
| `evaluate` | ICE scoring for priorities                         |
| `update`   | Update status of existing items + auto-sync 3-file |
| `sync`     | Sync backlog with plan (map items to phases)       |
| `clean`    | Archive ✅ Done items from backlog to done.md      |

---

## 📋 Action: review

// turbo

1. Read `Projects/[project-name]/artifacts/tasks/backlog.md`.
2. Check if an implementation plan exists at `Projects/[project-name]/artifacts/plans/`.
3. Display summary:

```
📋 BACKLOG REVIEW: [project-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Summary:
| Category    | Count |
| ----------- | ----- |
| Total Items | N     |
| ✅ Done     | N     |
| 🔴 High     | N     |
| 🟡 Medium   | N     |
| 🟢 Low      | N     |

🎯 Top 3 Actionable Items:
1. [ID] [Story] — 🔴 High — ⏳ Pending
2. [ID] [Story] — 🔴 High — 🚀 ToDo
3. [ID] [Story] — 🟡 Medium — ⏳ Pending

📐 Current Phase: [Phase N: Name] (from plan)
   Phase items: N total, N done, N remaining
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

4. If a plan exists, cross-reference the "Backlog → Phase Mapping" table:
   - Show which Phase the top items belong to.
   - Highlight items from the **current phase** (first incomplete phase).
   - Warn if items from future phases are being worked on before the current phase is done.

---

## ➕ Action: add

1. Ask: Epic or standalone? Feature or Bug?
2. If Epic: Ask which existing Epic to join, or create a new one.
3. Generate next available ID with proper prefix.
4. Append to the correct section in backlog.md.
5. If a plan exists, ask which Phase this item belongs to.
   - If identified, suggest updating the plan's "Backlog → Phase Mapping" table.
6. Update Summary counts.
7. Update `_Last updated` date.

---

## 📊 Action: evaluate

1. List all items with status ⏳ Pending or 🚀 ToDo.
2. For each, ask user to score Impact / Confidence / Ease (1-10).
3. Calculate ICE = Impact × Confidence × Ease.
4. Update the ICE Evaluation table.
5. Sort by ICE Score descending.
6. Suggest priority hints based on score ranges:

| ICE Range | Hint             |
| :-------- | :--------------- |
| 500+      | 🚀 High Priority |
| 200-499   | ✅ Quick Win     |
| 100-199   | 📋 Backlog       |
| <100      | 🗃 Low Priority  |

---

## ✏️ Action: update

1. Ask: Which ID to update?
2. Set new status value.
3. If status is `✅ Done`, add completion date: `✅ Done (YYYY-MM-DD)`.
4. Update Summary counts.
5. Update `_Last updated` date.
6. If a plan exists, check if all items in the current Phase are now Done.
   - If yes, display: `🎉 Phase [N] Complete! Ready to start Phase [N+1].`

### 🔄 Hybrid 3-File Auto-Sync (after every update)

> **Triggered automatically** after steps 1-6 complete. See `docs/hybrid-3-file.md`.

**Step 0: Reconcile Working Checkmarks** (before re-render)

// turbo

1. Read `artifacts/tasks/sprint-current.md`.
2. Scan for items marked `[x]` that are NOT yet `✅ Done` in `backlog.md`.
3. For each unreconciled `[x]` item:
   a. Update corresponding entry in `backlog.md` to `✅ Done (YYYY-MM-DD)`.
   b. Append to `done.md` under today's date header.
4. If no unreconciled checkmarks found, skip silently.

> **Rule:** `hybrid-3-file-integrity.md` C1 — Working Checkmarks are reconciled here.

**Step A: Render `sprint-current.md`** (One-way Snapshot)

// turbo

1. Scan `backlog.md` for all items with status `🚀 ToDo` or `🔨 In Progress`.
2. **Overwrite** `artifacts/tasks/sprint-current.md` completely with:

```markdown
# Sprint Current — [Project Name]

> **Source**: backlog.md (Hybrid 3-File Model)
> **Updated**: YYYY-MM-DD

## Active Tasks

| ID                            | Story | Priority | Status | Phase |
| :---------------------------- | :---- | :------- | :----- | :---- |
| [rows extracted from backlog] |

## Context

_Auto-generated from backlog.md. Do NOT edit directly._
```

3. If no active tasks found, write: `_(no active tasks)_`.

**Step B: Archive to `done.md`** (Append-only, only when status → Done)

// turbo

If the updated item's new status is `✅ Done`:

1. Extract the full row from `backlog.md`.
2. Append to `artifacts/tasks/done.md` under a date header:

```markdown
## YYYY-MM-DD

| ID              | Story      | Priority | Completed |
| :-------------- | :--------- | :------- | :-------- |
| [extracted row] | YYYY-MM-DD |
```

3. If the date header already exists, append under it.

**Step C: Plan Completion Check**

If a plan exists (`active_plan` in `project.md`):

1. Count all Done items in `done.md` that match task IDs from the plan's phase mapping.
2. If 100% of ALL phases are complete:
   - Output: `🎉 Project Plan Complete!`
   - Remove `active_plan` from `project.md`.
   - Suggest running `/retro`.
3. If only the current phase is complete:
   - Output: `🎉 Phase [N] Complete! Phase [N+1] ready.`
   - Suggest running `/retro` for phase review.

---

## 🔄 Action: sync

Synchronize backlog with an existing implementation plan.

1. Read the plan from `Projects/[project-name]/artifacts/plans/`.
2. Read the backlog from `Projects/[project-name]/artifacts/tasks/backlog.md`.
3. For each plan Phase, check if corresponding backlog items exist.
4. Display mapping report:

```
🔄 BACKLOG ↔ PLAN SYNC: [project-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
| Phase   | Backlog Items | Mapped | Missing |
| ------- | ------------- | ------ | ------- |
| Phase 0 | 5             | 5      | 0       |
| Phase 1 | 6             | 4      | 2 ⚠️    |
| Phase 2 | 0             | 0      | 5 ⚠️    |
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️ Missing items (tasks in plan but not in backlog):
- Phase 1: "Image proxy endpoint", "SEO meta tags"
- Phase 2: All 5 tasks not yet in backlog

💡 Actions:
1. Add missing items to backlog? (auto-generate IDs)
2. Update plan mapping? (link new backlog IDs)
```

5. Optionally auto-create backlog items for unmapped plan tasks.
6. Update the plan's "Backlog → Phase Mapping" table with new IDs.

---

## 🧹 Action: clean

Archive all `✅ Done` items from backlog to `done.md` in bulk.

> Use this periodically to keep `backlog.md` lean. The `update` action does this per-item automatically, but `clean` processes ALL done items at once.

1. Scan `backlog.md` for all items with status `✅ Done` or `✅ Fixed`.
2. For each found item:
   a. Extract the full row (ID, Story, Priority, completion date).
   b. Append to `artifacts/tasks/done.md` under the completion date header.
3. Remove the archived rows from `backlog.md`.
4. Update Summary counts in `backlog.md`.
5. Re-render `sprint-current.md` (same logic as `update` Step A).
6. Report:

```
🧹 BACKLOG CLEAN: [project-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 Archived: [N] items → done.md
📋 Backlog: [M] items remaining
🔄 sprint-current.md: Re-rendered
```

---

## Backlog Template

When creating a new backlog.md (via `/new-project` or `/backlog add`), use this structure:

```markdown
# [Project Name] - Product Backlog

> 🎯 [One-line project goal or description]

---

## 🏗️ Epic: [Epic Name]

[Short description of the epic's purpose.]

### User Stories

| ID    | Story                    | Priority  | Status               | Phase |
| :---- | :----------------------- | :-------- | :------------------- | :---- |
| XX-01 | [User story description] | 🔴 High   | ⏳ Pending           | 0     |
| XX-02 | [User story description] | 🟡 Medium | 📊 Evaluated         | 1     |
| XX-03 | [User story description] | 🟢 Low    | ✅ Done (YYYY-MM-DD) | 2     |

---

## 🐛 Known Issues & Bugs

| ID     | Issue               | Status                |
| :----- | :------------------ | :-------------------- |
| BUG-01 | [Issue description] | ⏳ Pending            |
| BUG-02 | [Issue description] | ✅ Fixed (YYYY-MM-DD) |

---

## 📊 Evaluation Scores (ICE)

| ID        | Impact | Confidence | Ease | ICE Score | Priority Hint    |
| :-------- | :----: | :--------: | :--: | :-------: | :--------------- |
| **XX-01** |   8    |     9      |  6   |  **432**  | 🚀 High Priority |
| **XX-02** |   5    |     9      |  8   |  **360**  | ✅ Quick Win     |

---

## 📊 Summary

| Category    | Count |
| :---------- | :---- |
| Total Items | N     |
| ✅ Done     | N     |
| 🔴 High     | N     |
| 🟡 Medium   | N     |
| 🟢 Low      | N     |

---

_Last updated: YYYY-MM-DD_
```

> **Note:** The `Phase` column in User Stories is optional. It is used when an implementation plan exists to cross-reference which phase the task belongs to.

## ID Prefix Convention

- **Epic-based**: Use epic abbreviation (e.g., `CI-01` for Core Infrastructure, `AU-01` for Authentication).
- **Feature-based**: Use `FEAT-01`, `FEAT-02`, etc.
- **Bugs**: Always use `BUG-01`, `BUG-02`, etc.

## Status Values

| Status                | Meaning                    |
| :-------------------- | :------------------------- |
| ⏳ Pending            | Not started                |
| 🚀 ToDo               | Planned for current phase  |
| 🔨 In Progress        | Currently being worked on  |
| 📊 Evaluated          | ICE scored, awaiting start |
| ✅ Done (YYYY-MM-DD)  | Completed with date        |
| ✅ Fixed (YYYY-MM-DD) | Bug fixed with date        |

## Priority Levels

| Level     | Meaning                    |
| :-------- | :------------------------- |
| 🔴 High   | Critical for current phase |
| 🟡 Medium | Important but not blocking |
| 🟢 Low    | Nice-to-have, can defer    |

## Plan Integration

When both a plan and backlog exist, they should be kept in sync:

| Scenario                                 | Action                                                   |
| :--------------------------------------- | :------------------------------------------------------- |
| New plan created → backlog exists        | Run `/backlog sync` to map existing items to phases      |
| New backlog item added                   | Ask which Phase it belongs to, update plan mapping       |
| All items in a Phase are ✅ Done         | Announce Phase completion, suggest starting next Phase   |
| Plan scope changed                       | Run `/backlog sync` to find new unmapped items           |
| Backlog item moved to different priority | No plan update needed (plan tracks phases, not priority) |

> **Reference:** See `Areas/Learning/plan-backlog-workflow.md` for the complete best practices guide on combining Plan + Backlog.

## Related

- `/plan` — Create and manage implementation plans
- `/open` — Start session with context loading
- `/end` — End session and log progress
- `/verify` — Verify task completion
