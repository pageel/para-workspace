# Hybrid 3-File Integrity

> **Version**: 1.5.4

Governs the 3-file task management system: `backlog.md` (source of truth), `sprint-current.md` (Hot Lane), and `done.md` (append-only archive). Six constraints (C1–C6) ensure the agent cannot accidentally break task workflows.

## Scope

- **Type**: Global (all projects with Hybrid 3-File setup)
- **Priority**: 🟡 Important
- **Trigger**: Reading/writing `artifacts/tasks/`, running `/backlog`, `/end`, handling ad-hoc requests

## Constraints

### C1: sprint-current.md — Hot Lane

| Action | Permission |
|:-------|:-----------|
| Add quick task (`- [ ] description`) | ✅ Allowed |
| Add `- [ ]` BEFORE starting code | ✅ Required (log-first) |
| Mark `[x]` when done | ✅ Allowed |
| Add notes to `## Notes` | ✅ Allowed |
| Copy strategic tasks from backlog | ❌ Forbidden |
| Edit descriptions/priorities of existing items | ❌ Forbidden |

### C2: done.md — APPEND-ONLY

New entries added ONLY through `/end` (Hot Lane Sync) or `/backlog clean`. Entries grouped by plan with origin tags: `#backlog` (strategic) or `#session` (hot lane). Existing entries MUST NOT be modified or deleted.

### C3: backlog.md — OPERATIONAL AUTHORITY

The single source of truth for all tasks. All structural mutations (add, remove, re-prioritize) MUST go through `/backlog`. Lookup chain: `backlog.md` → `done.md` → `plans/done/`.

### C4: Plan-Backlog Sync

MANDATORY after `/plan create`. Agent MUST suggest `/backlog sync` to map plan phases to backlog items.

### C5: /end — SOLE Sync Point

All task reconciliation happens at `/end` — NOT during coding. Hot Lane Sync: `[x]` → append done.md, `[ ]` → ask user, smart suggest from session log, clean sprint-current.md.

### C6: File Guard Headers

Task files SHOULD include inline guard comments. Agent MUST read and obey these before editing:

```markdown
<!-- ⚠️ APPEND-ONLY: Write via /end or /backlog clean only (C2) -->
<!-- ⚠️ HOT LANE ONLY: No strategic tasks from backlog (C1) -->
```

Guards act as a last-resort defense when agent has lost rule context post-truncation.

## Related

- [Hybrid 3-File Architecture](../architecture/hybrid-3-file.md)
- [Context Recovery](../architecture/context-recovery.md) — File Guard Headers (Layer 4)
- [RFC-0002](../../rfcs/0002-hybrid-3-file-integrity.md)
- **Source**: `templates/common/agents/rules/hybrid-3-file-integrity.md`
