# RFC-0002: Hybrid 3-File Integrity (Hot Lane & /end Sync)

- Feature Name: hybrid-3-file-integrity
- Start Date: 2026-03-12
- Status: Accepted
- Revision: v2 (2026-03-13)
- Owners: @pageel (maintainer)
- Affected:
  - kernel/ (invariants.md I2)
  - templates/common/agent/rules/ (hybrid-3-file-integrity.md)
  - templates/common/agent/workflows/ (open, end, backlog, plan)
  - docs/
- Related:
  - Kernel Invariants: I2 (Task Management — Hybrid 3-File Model)
  - RFC-0001 (Governed Agent Libraries)

## Summary

Codify the interaction rules for the Hybrid 3-File task management system.
Define `sprint-current.md` as an agent-writable **Hot Lane** for ad-hoc quick
tasks, consolidate all synchronization to `/end` as the sole sync point,
and maintain `backlog.md` as the **Operational Authority** for all tasks.

## Motivation

The Hybrid 3-File architecture requires explicit governance rules to:

1. **Prevent unauthorized mutations** — Without a rule, agents may arbitrarily
   modify file structure or mix concerns between files.
2. **Enable natural agent workflow** — Agents need a low-friction way to track
   ad-hoc tasks during coding without interrupting flow.
3. **Give quick tasks a structured home** — User requests that arise during
   coding sessions ("fix this CSS", "change that color") need structured
   tracking beyond session logs.
4. **Minimize ceremony** — Synchronization should happen at natural boundaries
   (session end), not require manual commands during coding.

Goals:

- Give quick tasks a structured file (`sprint-current.md` as Hot Lane)
- Enable agents to write directly during coding (natural behavior)
- Consolidate sync to `/end` only (zero ceremony during coding)
- Maintain `backlog.md` as Operational Authority for all tasks
- Track task origin in `done.md` for analytics

Non-goals:

- Two-way sync between sprint-current.md and backlog.md
- Making sprint-current.md a mirror/derived view of backlog.md
- Requiring sync commands during active coding sessions

## Guide-level explanation

The 3-file system separates concerns:

```
backlog.md ← Agent reads for strategic context (summary + top items)
sprint-current.md ← Agent writes quick tasks + ticks [x] directly
done.md ← /end appends completed work (both strategic and quick)
```

During a coding session, the agent writes ad-hoc tasks to `sprint-current.md`
and ticks them off as completed. Strategic tasks from `backlog.md` are read
directly for context but not copied. At session end (`/end`), all completed
work is reconciled to `done.md` with origin tracking.

## Reference-level specification

### Definitions

- **Hot Lane**: `sprint-current.md` as an agent-writable buffer for quick,
  ad-hoc tasks not in `backlog.md`.
- **Operational Authority**: The file where all structural task mutations
  (add, delete, re-prioritize, phase change) MUST occur. This is `backlog.md`.
- **Origin Tag**: `#backlog` or `#session` appended to `done.md` entries
  to distinguish strategic tasks from quick tasks.
- **Smart Suggest**: At `/end`, the agent reads the session log, extracts
  task IDs mentioned, cross-checks backlog active items, and suggests
  which strategic tasks may be Done.

### Constraints (Rule)

| ID  | Constraint                         | Description                                                          |
| --- | ---------------------------------- | -------------------------------------------------------------------- |
| C1  | sprint-current.md = Hot Lane       | Agent writes quick tasks + ticks [x]. MUST NOT copy strategic tasks. |
| C2  | done.md = Append-only              | No edits to existing entries. Origin tags required.                  |
| C3  | backlog.md = Operational Authority | Single source of truth for ALL tasks. Mutations via `/backlog` only. |
| C4  | Plan-Backlog sync mandatory        | After `/plan create`, Agent MUST suggest `/backlog sync`.            |
| C5  | /end = Sole sync point             | All reconciliation at `/end`. No sync during coding sessions.        |

### Workflow integration

| Workflow          | Reads                                | Writes                              |
| ----------------- | ------------------------------------ | ----------------------------------- |
| `/open`           | backlog summary, hot lane, plan      | —                                   |
| coding session    | backlog (strategic context)          | sprint-current.md (quick tasks)     |
| `/end`            | sprint-current, session log, backlog | done.md, backlog.md, sprint-current |
| `/backlog update` | backlog.md                           | backlog.md                          |
| `/backlog clean`  | backlog.md                           | backlog.md, done.md                 |

### `/end` Hot Lane Sync process

1. Read `sprint-current.md`
2. Quick tasks marked `[x]` → append to `done.md` with `#session` tag
3. Quick tasks still `[ ]` → ask user: keep for next session? promote to backlog?
4. **Smart Suggest**: read session log → extract mentioned task IDs → cross-check
   backlog active items → suggest: "Mark these as Done?"
5. User-confirmed strategic tasks → update `backlog.md` → append `done.md`
   with `#backlog` tag
6. Clean `sprint-current.md` (remove `[x]` items, keep `[ ]` items)

### Token optimization for `/open`

- Read `backlog.md` Summary section only (~10 lines via grep)
- Read `sprint-current.md` (small file, graceful skip if not exists)
- Read plan headers only if `active_plan` exists in `project.md`
- Read `SYNC.md` only if `project.md` has `downstream` or `upstream` fields

### Schema changes

- `sprint-current.md`: Structure is `## Quick Tasks` (checklist) + `## Notes` (freeform)
- `done.md`: Entries include origin tag `#backlog` or `#session` at end of line
- Legacy entries (no tag) remain valid

### Compatibility & versioning

- **Kernel**: MINOR bump (I2 behavior refined, not broken)
- **Rule**: Major rewrite (v2.0.0), backward compatible replacement
- **Workflows**: Simplification, backward compatible

### Security / safety

- Hot Lane is agent-writable but scoped to quick tasks only
- Strategic tasks remain protected behind `/backlog` commands
- `/end` sync is deterministic and user-confirmed for strategic changes
- Origin tags provide audit trail for all completions

## Rationale

The Hot Lane approach balances agent autonomy with data integrity:

1. Agents naturally write quick notes and checklists — the Hot Lane leverages
   this behavior instead of fighting it.
2. Consolidating sync to `/end` removes friction that causes users and agents
   to skip synchronization steps.
3. Origin tags enable future analytics (strategic vs ad-hoc work ratio).
4. Keeping `backlog.md` as Operational Authority preserves the single source
   of truth principle while allowing lightweight parallel tracking.

## Alternatives considered

1. **Strict read-only sprint-current.md** — Creates unbearable friction
2. **Eliminate sprint-current.md** — Wastes a useful file
3. **Full two-way sync** — Destroys canonical authority concept
4. **Separate hot-lane file** — Redundant when sprint-current.md already exists

## Drawbacks

- Quick tasks may overlap with strategic tasks (mitigated by Smart Suggest)
- Agent may forget to log (mitigated by Rule C1: MUST log before coding)
- Origin tags add minor complexity (grep-friendly, backward compatible)

## Unresolved questions

- Should promoted quick tasks retain original description or be rewritten?
- Should Hot Lane have a size limit (e.g., max 20 quick tasks)?
