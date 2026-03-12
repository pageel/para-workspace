# Task Management Schema

> **Defines**: The format and structure for task files in `artifacts/tasks/`
> **Kernel Version**: 1.5.2

---

## Overview

PARA Workspace uses a **Hybrid 3-File Model** for task management:

| File                | Role                 | Format        |
| ------------------- | -------------------- | ------------- |
| `backlog.md`        | Canonical task store | Structured MD |
| `sprint-current.md` | Derived focus view   | Structured MD |
| `done.md`           | Derived archive      | Structured MD |

## backlog.md (Canonical)

The primary file for all task management. Agent reads/writes this file via the `/backlog` workflow.

### Required Structure

```markdown
# <Project Name> — Backlog

> **Project**: <project-slug>
> **Last Updated**: YYYY-MM-DD

## 🔨 In Progress

- [ ] <task-description> [#<id>] [priority: high|medium|low]
- [ ] <task-description>

## 📋 Backlog

### <category/epic>

- [ ] <task-description>
- [ ] <task-description>

## ✅ Recently Done

- [x] <task-description> (YYYY-MM-DD)
```

### Rules

- The `🔨 In Progress` section contains tasks **actively being worked on**
- The `📋 Backlog` section contains all planned tasks, optionally grouped by category
- The `✅ Recently Done` section temporarily holds completed tasks before moving to `done.md`
- Tasks use Markdown checkboxes: `- [ ]` (open) or `- [x]` (done)

## sprint-current.md (Derived Focus View)

A focused view showing ONLY the tasks currently in progress. This is a **derived file** — its content reflects the "In Progress" section of `backlog.md`.

### Required Structure

```markdown
# Sprint Current — <Project Name>

> **Source**: backlog.md
> **Updated**: YYYY-MM-DD

## <Phase Name> (when plan exists)

- [ ] <task-description> #<id> priority: <level>
- [x] <completed-task> #<id> priority: <level>

## Active Tasks (when no plan)

- [ ] <task-description>

## Context

<optional: brief context about current sprint focus>
```

### Rendering Rules

- If project has an `active_plan` in `project.md`: group tasks by **Phase**
- If no plan: use single `## Active Tasks` section
- Content mirrors `backlog.md` → "In Progress" + planned items for current phase
- Should be small and focused (ideally 3-7 active tasks per phase)

### Working Checkmarks (RFC-0002)

- Agent MAY mark tasks `[x]` in this file while coding (same UX as Planning Mode)
- Agent MUST NOT add, remove, or edit task descriptions
- On `/backlog update` or `/end`, checkmarks are reconciled back to `backlog.md`

## done.md (Derived Archive)

Archive of completed tasks, keeping `backlog.md` clean over time.

### Required Structure

```markdown
# Done — <Project Name>

> **Project**: <project-slug>

## YYYY-MM-DD

- [x] <task-description>
- [x] <task-description>

## YYYY-MM-DD

- [x] <task-description>
```

### Rules

- Tasks are grouped by completion date
- Most recent dates at the top
- This file is append-only (no editing past entries)
- Agent moves tasks here when they are marked complete in `backlog.md`

---

## Task Format

Individual tasks follow this format:

```
- [ ] <description> [#<id>] [priority: <level>]
```

| Field       | Required | Format                        | Example                   |
| ----------- | -------- | ----------------------------- | ------------------------- |
| Checkbox    | Yes      | `- [ ]` or `- [x]`            | `- [ ]`                   |
| Description | Yes      | Free text                     | `Add user authentication` |
| ID          | No       | `#<number>` or `#<tag>`       | `#42`, `#auth-flow`       |
| Priority    | No       | `priority: high\|medium\|low` | `priority: high`          |

## Compliance

A valid task management setup requires:

1. `backlog.md` exists and has the required sections
2. `sprint-current.md` exists (may be empty if no active tasks)
3. `done.md` exists (may be empty if no completed tasks)
4. All three files are in `artifacts/tasks/` within the project directory
