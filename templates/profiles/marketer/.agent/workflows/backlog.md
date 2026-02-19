---
description: Manage project features and bugs
---

# /p-backlog [project-name] [action]

> **Workspace Version:** 1.4.0

Manage the backlog in `Projects/[project]/sessions/BACKLOG.md`.

## Actions

- `review`: Show overview with summary stats.
- `add`: Add new feature, epic, or bug.
- `evaluate`: ICE scoring for priorities.
- `update`: Update status of existing items.

## Backlog Template

When creating a new BACKLOG.md, use this structure:

```markdown
# [Project Name] - Product Backlog

> 🎯 [One-line project goal or description]

---

## 🏗️ Epic: [Epic Name]

[Short description of the epic's purpose.]

### User Stories

| ID    | Story                    | Priority  | Status               |
| :---- | :----------------------- | :-------- | :------------------- |
| XX-01 | [User story description] | 🔴 High   | ⏳ Pending           |
| XX-02 | [User story description] | 🟡 Medium | 📊 Evaluated         |
| XX-03 | [User story description] | 🟢 Low    | ✅ Done (YYYY-MM-DD) |

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

## ID Prefix Convention

- **Epic-based**: Use epic abbreviation (e.g., `MC-01` for Multi-Collection, `WF-01` for Workflow).
- **Feature-based**: Use `FEAT-01`, `FEAT-02`, etc.
- **Bugs**: Always use `BUG-01`, `BUG-02`, etc.

## Status Values

| Status                | Meaning                    |
| :-------------------- | :------------------------- |
| ⏳ Pending            | Not started                |
| 🚀 ToDo               | Planned for next sprint    |
| 🔨 In Progress        | Currently being worked on  |
| 📊 Evaluated          | ICE scored, awaiting start |
| ✅ Done (YYYY-MM-DD)  | Completed with date        |
| ✅ Fixed (YYYY-MM-DD) | Bug fixed with date        |

## Priority Levels

| Level     | Meaning                    |
| :-------- | :------------------------- |
| 🔴 High   | Critical for next release  |
| 🟡 Medium | Important but not blocking |
| 🟢 Low    | Nice-to-have, can defer    |

## Steps

### review

1. Read `Projects/[project]/sessions/BACKLOG.md`.
2. Display summary table (Total / Done / High / Medium / Low).
3. Highlight top 3 actionable items (not Done, sorted by priority).

### add

1. Ask: Epic or standalone? Feature or Bug?
2. Generate next available ID with proper prefix.
3. Append to the correct section in BACKLOG.md.
4. Update Summary counts.
5. Update `_Last updated` date.

### evaluate

1. List all items with status ⏳ Pending or 🚀 ToDo.
2. For each, ask user to score Impact / Confidence / Ease (1-10).
3. Calculate ICE = Impact × Confidence × Ease.
4. Update the ICE Evaluation table.
5. Sort by ICE Score descending.
6. Suggest priority hints based on score ranges.
