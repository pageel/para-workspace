# Task Management Schema

> **Defines**: The format and structure for task files in `artifacts/tasks/`
> **Kernel Version**: 1.5.3

---

## Overview

PARA Workspace uses a **Hybrid 3-File Model** for task management:

| File                | Role                           | Format        |
| ------------------- | ------------------------------ | ------------- |
| `backlog.md`        | Canonical task store           | Structured MD |
| `sprint-current.md` | Hot Lane (session quick tasks) | Structured MD |
| `done.md`           | Append-only archive            | Structured MD |

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

## sprint-current.md (Hot Lane)

An agent-writable buffer for **ad-hoc quick tasks** during coding sessions. This is NOT a mirror of backlog.md — it contains ONLY quick tasks created by the agent and session notes.

### Required Structure

```markdown
# Sprint Current — <Project Name>

> **Updated**: YYYY-MM-DD

## Quick Tasks

- [ ] <task-description>
- [x] <completed-task>

## Notes

<optional: discoveries, observations during coding session>
```

### Rules

- Agent MAY **add** new quick tasks (`- [ ]`) — MUST add before starting ad-hoc work
- Agent MAY **tick** tasks done (`[x]`) when completed
- Agent MAY write freeform notes in `## Notes`
- Agent MUST NOT copy strategic tasks from `backlog.md` into this file
- `/end` processes this file: `[x]` → done.md, `[ ]` → ask user

### What goes here vs backlog

| Type              | Example                      | Goes in                   |
| ----------------- | ---------------------------- | ------------------------- |
| Strategic feature | FEAT-13: Safety Guardrails   | `backlog.md`              |
| Quick fix         | Fix CSS alignment            | `sprint-current.md`       |
| Bug from backlog  | BUG-16: Inbox categorization | `backlog.md`              |
| Ad-hoc discovery  | "Responsive issue on mobile" | `sprint-current.md` Notes |

## done.md (Append-only Archive)

Archive of completed tasks, keeping `backlog.md` clean over time.

### Required Structure

```markdown
# Done — <Project Name>

> **Project**: <project-slug>

## YYYY-MM-DD

- [x] FEAT-XX: <task-description> #backlog
- [x] <quick-task-description> #session

## YYYY-MM-DD

- [x] <task-description> #backlog
```

### Rules

- Tasks are grouped by completion date
- Most recent dates at the top
- This file is append-only (no editing past entries)
- Entries include origin tag:
  - `#backlog` — task originated from backlog.md (strategic)
  - `#session` — task originated from sprint-current.md (quick/ad-hoc)
  - No tag — legacy entry (pre-v1.5.3)
- Agent adds entries here ONLY through `/end` (Hot Lane Sync) or `/backlog clean`

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
| Origin tag  | No       | `#backlog` or `#session`      | `#session`                |

## Compliance

A valid task management setup requires:

1. `backlog.md` exists and has the required sections
2. `sprint-current.md` exists OR is created on first ad-hoc task (graceful handling)
3. `done.md` exists (may be empty if no completed tasks)
4. All three files are in `artifacts/tasks/` within the project directory
