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
- Entries include origin tags: `#backlog` (strategic) or `#session` (hot lane)
- Entries are grouped by completion date, most recent first

### C3: backlog.md is the OPERATIONAL AUTHORITY

- All structural task mutations (add, remove, re-prioritize, re-phase) MUST go through `backlog.md` via `/backlog` commands
- `backlog.md` is the **single source of truth** for all tasks (strategic and promoted quick tasks)
- `backlog.md` + `done.md` together represent the complete project task history

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

## Examples

### Allowed

```markdown
# sprint-current.md — Hot Lane

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
