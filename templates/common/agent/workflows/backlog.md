---
description: Manage project features and bugs
source: catalog
---

# /backlog [project-name] [action]

> **Workspace Version:** 1.5.3 (Hot Lane)
> **Constraint:** Read `.para-workspace.yml` at the workspace root to get the user's preferred language from `preferences.language` (e.g., `vi` for Vietnamese). **All output and reports MUST be translated to this language.**

Manage the product backlog stored at `Projects/[project-name]/artifacts/tasks/backlog.md`.

## Actions

| Action     | Description                                        |
| :--------- | :------------------------------------------------- |
| `review`   | Show overview with summary stats and phase context |
| `add`      | Add new feature, epic, or bug                      |
| `evaluate` | ICE scoring for priorities                         |
| `update`   | Update status of existing items                    |
| `sync`     | Sync backlog with plan (map items to phases)       |
| `clean`    | Compress ✅ Done items into Completed section      |

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

> 💡 **Note:** Task sync to `done.md` happens at `/end` (Hot Lane Sync). The `update` action focuses on status changes only.

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

Compress `✅ Done` items from backlog active tables into the `✅ Completed (Archived)` section.

> **Important:** `clean` does NOT delete items from backlog. It **compresses** them into 1 line per plan in the Completed section. This preserves backlog as the single source of truth.

**Lookup chain:** `backlog.md` (plan + IDs) → `done.md` (per-task detail) → `plans/done/` (full plan)

1. Scan user story and bug tables for items with status `✅ Done` or `✅ Fixed`.
2. Group Done items by their associated plan (check `plans/done/` for matching plan files).
3. For each group:
   a. Append task details to `done.md` under the plan heading (create heading if new).
   b. Add or update a compressed row in the `✅ Completed (Archived)` section of `backlog.md`:
   - Plan name (as done.md link) + list of IDs.
     c. Remove the individual rows from the active user story / bug tables.
4. Items with no associated plan go under "Standalone Tasks" in both `done.md` and backlog.
5. Update Summary counts (Active Items, Archived).
6. Report:

```
🧹 BACKLOG CLEAN: [project-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 Compressed: [N] items → Completed section
📝 Details: done.md updated
📋 Active: [M] items remaining
```

> 💡 **Note:** `sprint-current.md` is NOT touched here. It is the Hot Lane for quick tasks, managed by `/end`.

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

| ID    | Story                    | Priority  | Status     | Phase |
| :---- | :----------------------- | :-------- | :--------- | :---- |
| XX-01 | [User story description] | 🔴 High   | ⏳ Pending | 0     |
| XX-02 | [User story description] | 🟡 Medium | 🚀 ToDo    | 1     |

---

## 🐛 Known Issues & Bugs

| ID     | Issue               | Priority  | Status     |
| :----- | :------------------ | :-------- | :--------- |
| BUG-01 | [Issue description] | 🟡 Medium | ⏳ Pending |

---

## ✅ Completed (Archived)

> Compressed by plan. Details → [done.md](./done.md) → `plans/done/`

| Plan         | IDs |
| :----------- | :-- |
| _(none yet)_ |     |

---

## 📊 Evaluation Scores (ICE)

| ID        | Impact | Confidence | Ease | ICE Score | Priority Hint    |
| :-------- | :----: | :--------: | :--: | :-------: | :--------------- |
| **XX-01** |   8    |     9      |  6   |  **432**  | 🚀 High Priority |

---

## 📊 Summary

| Category     | Count |
| :----------- | :---- |
| Active Items | N     |
| ✅ Done      | N     |
| 🔴 High      | N     |
| 🟡 Medium    | N     |
| 🟢 Low       | N     |
| ✅ Archived  | N     |

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
