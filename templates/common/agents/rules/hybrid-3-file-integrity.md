---
description: Hybrid 3-File task management integrity (backlog, sprint-current, done)
trigger: always_on
glob: artifacts/tasks/*
---

# Rule: Hybrid 3-File Integrity

> Agent MUST follow these constraints when working with task files
> in `artifacts/tasks/`.

## Scope

- [x] Global (applies to all projects with Hybrid 3-File setup)

## Triggers

- Reading or writing any file in `artifacts/tasks/`
- Running `/backlog update`, `/backlog clean`, `/end`
- Handling ad-hoc user requests not in backlog

## Constraints

### C1: sprint-current.md — Hot Lane

- Agent MAY **add** quick tasks (`- [ ] <description>`) to this file for ad-hoc work
- Agent MUST add `- [ ]` entry BEFORE starting ad-hoc code work (log-first principle)
- Agent MAY mark quick tasks `[x]` when completed
- Agent MAY add short notes in the `## Notes` section
- Agent MUST NOT copy strategic tasks from `backlog.md` into this file
- Agent MUST NOT edit task descriptions, priorities, or phase assignments of existing items

### C2: done.md is APPEND-ONLY

- Agent MUST NOT modify or delete existing entries in `done.md`
- New entries are added ONLY through `/end` (Hot Lane Sync) or `/backlog clean`
- Entries are grouped by **plan** (linking to `plans/done/`), with a standalone section for planless tasks
- Entries include origin tags: `#backlog` (strategic) or `#session` (hot lane)

### C3: backlog.md is the OPERATIONAL AUTHORITY

- All structural task mutations (add, remove, re-prioritize, re-phase) MUST go through `backlog.md` via `/backlog` commands
- `backlog.md` is the **single source of truth** for all tasks (active + archived)
- `/backlog clean` **compresses** Done items into the `✅ Completed (Archived)` section (1 line per plan + IDs) — it does NOT delete them
- Lookup chain: `backlog.md` (plan + IDs) → `done.md` (per-task detail) → `plans/done/` (full plan)
- **§4 Roadmap Sync** is VIEW-ONLY. Agent MUST NOT manually mutate it via `/backlog add`. It mirrors future scope from `plans/roadmap.md`.

### C4: Plan-Backlog Sync is MANDATORY after /plan create

- After creating and activating a plan, Agent MUST suggest `/backlog sync`
  to map plan phases to backlog items
- If `active_plan` exists in `project.md` but backlog items lack Phase assignments, Agent SHOULD warn

### C5: /end is the SOLE Sync Point

- All task reconciliation happens at `/end` — NOT during coding sessions
- `/end` Hot Lane Sync process:
  1. Quick tasks `[x]` → append `done.md` with `#session` tag
  2. Quick tasks `[ ]` → ask user: keep for next session? promote to backlog?
  3. Smart Suggest: read session log → extract mentioned task IDs → cross-check backlog active items → suggest: "Mark Done?"
  4. User-confirmed strategic tasks → update `backlog.md` status → append `done.md` with `#backlog` tag
  5. Clean `sprint-current.md` (remove `[x]` items, keep `[ ]` items)
- Agent MUST NOT run sync logic during coding sessions (zero ceremony)

### C6: File Guard Headers

Protected files SHOULD include an inline HTML guard comment. Agent MUST read and obey these guards before editing:

**Guard Types:**

| Type | Scope | Guard template |
|:--|:--|:--|
| **TASK** | `artifacts/tasks/` | `<!-- ⚠️ APPEND-ONLY — /end or /backlog clean only (C2) -->` |
| **TASK** | `artifacts/tasks/` | `<!-- ⚠️ HOT LANE ONLY — No backlog tasks here (C1) -->` |
| **TASK** | `artifacts/tasks/` | `<!-- ⚠️ OPERATIONAL AUTHORITY — Mutations via /backlog only (C3) -->` |
| **KERNEL** | `kernel/`, `Resources/ai-agents/kernel/` | `<!-- ⚠️ READ-ONLY SNAPSHOT — Do NOT modify (I9) -->` |
| **GOVERNED** | `.agents/rules/` | `<!-- ⚠️ GOVERNED — /para-rule only. Overwritten by para update -->` |
| **WORKSPACE** | `Areas/Workspace/` | `<!-- ⚠️ APPEND-ONLY — via /end only -->` |

**Position convention:**

- Files with YAML frontmatter: guard goes **after** closing `---`, **before** `# Title`
- Files without YAML: guard goes after `# Title` (line 3)

**Rules:**

- Guards act as a **last-resort defense** when agent has lost rule context (post-truncation)
- When creating task files, agent SHOULD include the appropriate guard header
- Agent MUST NOT remove or modify existing guard headers

### C7: Plan Status Transition is USER-ONLY

- Agent MUST NOT change the `Status` field in any plan file (`artifacts/plans/*.md`)
- Agent MUST NOT clear or modify `active_plan` in `project.md`
- Agent MAY **suggest** a status transition (e.g., "Phase 1-4 complete, shall I mark as Done?")
- Agent MUST **wait for explicit user confirmation** before making the change
- Violation of C7 is a **sovereignty violation** — the user owns plan lifecycle decisions

## Examples

### Allowed

```markdown
# sprint-current.md — Hot Lane

<!-- ⚠️ HOT LANE ONLY: No strategic tasks from backlog (C1) -->

> **Updated**: 2026-03-13

## Quick Tasks

- [x] Fix CSS alignment on homepage
- [ ] Update CTA button colors

## Notes

Found responsive issue on mobile — consider adding to backlog.
```

### NOT Allowed

```markdown
# sprint-current.md — INVALID: copying strategic tasks

## Quick Tasks

- [ ] Fix CSS alignment
- [ ] FEAT-13: Safety Guardrails ← VIOLATION of C1: copied from backlog
```

## Related

- **RFC-0002**: `rfcs/0002-hybrid-3-file-integrity.md`
- **Kernel Invariant I2**: Hybrid 3-File Task Model
- **Schema**: `kernel/schema/tasks.schema.md`
