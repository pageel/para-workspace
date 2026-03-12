# RFC-0002: Hybrid 3-File Integrity (Working Checkmarks & Reconcile)

- Feature Name: hybrid-3-file-integrity
- Start Date: 2026-03-12
- Status: Proposed
- Target Release: v1.6.0
- Owners: @pageel (maintainer)
- Affected:
  - kernel/ (invariants.md — clarify I2 wording)
  - templates/common/agent/rules/ (new rule)
  - templates/common/agent/workflows/ (backlog.md, end.md refinements)
  - docs/
- Related:
  - Kernel Invariants: I2 (Task Management — Hybrid 3-File Model)
  - Prior RFCs: RFC-0001 (Governed Agent Libraries)
  - Brainstorm: `brainstorm-fast-mode-vs-planning-mode-2026-03-12.md`

## Summary

Codify the interaction rules for the Hybrid 3-File task management system.
Introduce "Working Checkmarks" — a low-friction mechanism where agents MAY
mark tasks as done `[x]` directly in `sprint-current.md` during coding sessions,
then reconcile these marks back to `backlog.md` on session end. Also clarifies
the "single source of truth" terminology in Invariant I2.

## Motivation

Two gaps discovered during docs review and brainstorming (2026-03-12):

1. **No enforcement mechanism** — The 3-file architecture relies on Agent
   discipline, but no rule exists to prevent agents from mutating
   `sprint-current.md` structure or `done.md` history.

2. **READ-ONLY vs Planning Mode friction** — AI agents in Planning Mode
   continuously tick `[x]` in their tasks file while coding. If
   `sprint-current.md` is strictly READ-ONLY, agents must interrupt their
   coding flow to call `/backlog update` for every completed task. This
   friction makes the 3-File system inferior to built-in Planning Mode.

Goals:

- Enable agents to track progress inline during coding (like Planning Mode)
- Maintain `backlog.md` as the Operational Authority for task structure
- Preserve the one-way architecture for structural data flow
- Add a governed rule to enforce correct behavior

Non-goals:

- Full two-way sync between sprint-current.md and backlog.md
- Changing the fundamental Hybrid 3-File architecture
- Modifying any existing workflow semantics

## Guide-level explanation

### Before this RFC

```
Agent codes Feature A → STOPS → calls /backlog update FEAT-01 → waits → resumes coding
Agent codes Feature B → STOPS → calls /backlog update FEAT-02 → waits → resumes coding
```

### After this RFC

```
Agent codes Feature A → marks [x] in sprint-current.md → codes Feature B → marks [x] → ...
                                                                                           │
At session end (/end or /backlog update):                                                   │
  Reconcile: read sprint-current.md checkmarks → update backlog.md → re-render + archive ◄──┘
```

### What agents see

During coding, the agent treats `sprint-current.md` like Planning Mode's
`tasks` file — checking off items as they're completed. At session boundaries,
the system reconciles these marks to the canonical `backlog.md` store.

## Reference-level specification

### Definitions

- **Working Checkmark**: A `[x]` mark applied by an agent to a task in
  `sprint-current.md` during a coding session, before reconciliation.
- **Reconcile**: The process of reading checkmarks from `sprint-current.md`
  and updating corresponding task statuses in `backlog.md`.
- **Operational Authority**: The file where all structural task mutations
  (add, delete, re-prioritize, phase change) MUST occur. This is `backlog.md`.

### Repo changes (normative)

#### 1. New Rule: `templates/common/agent/rules/hybrid-3-file-integrity.md`

```markdown
# Rule: Hybrid 3-File Integrity

> Agent MUST follow these constraints when working with task files
> in `artifacts/tasks/`.

## Triggers

- Writing to or reading from `artifacts/tasks/` directory
- Running `/backlog`, `/plan`, `/open`, `/end`

## Constraints

### C1: sprint-current.md — Working Checkmarks Only

- Agent MAY mark tasks as done `[x]` in sprint-current.md while coding.
  This mirrors Planning Mode behavior for low-friction progress tracking.
- Agent MUST NOT add, remove, or edit task descriptions in this file.
- Agent MUST NOT change priority or phase in this file.
- All structural changes go through `/backlog` commands on backlog.md.
- On `/backlog update` or `/end`, checkmarks are reconciled back to
  backlog.md before re-rendering.

### C2: done.md is APPEND-ONLY

- Agent MUST NOT edit or delete existing entries in `done.md`.
- New entries are added via `/backlog update` (Auto-Sync Step B)
  or `/backlog clean`.

### C3: backlog.md is the OPERATIONAL AUTHORITY

- All task mutations (add, evaluate, re-prioritize, delete, phase change)
  MUST go through `backlog.md` via `/backlog` commands.
- Status updates (→ Done) CAN originate from sprint-current.md checkmarks
  but MUST be reconciled to backlog.md before the session ends.

### C4: Plan-Backlog sync is MANDATORY after /plan create

- After creating a new plan, Agent MUST run `/backlog sync`
  to map plan phases to backlog items.
- If `active_plan` exists but backlog has no Phase column,
  Agent MUST warn and suggest `/backlog sync`.
```

#### 2. Update: `templates/common/agent/rules/catalog.yml`

Add entry for the new rule.

#### 3. Clarify: `kernel/invariants.md` I2 (non-breaking)

Current wording:

```
- `backlog.md` is the **single source of truth** for all tasks
```

Proposed wording (clarification, not behavioral change):

```
- `backlog.md` is the **operational authority** for all task mutations
  (the only file where tasks are created, edited, re-prioritized, or deleted)
- Complete project task history spans `backlog.md` (active) + `done.md` (archive)
```

> **Note**: This is a wording clarification, not a behavioral change.
> The existing rules already state that done.md "receives completed tasks."
> No MAJOR version bump required — the invariant behavior is unchanged.

#### 4. Update: `templates/common/agent/workflows/backlog.md`

Add "Reconcile Step" before Auto-Sync in the `update` action:

```
### 🔄 Reconcile Working Checkmarks (before Auto-Sync)

1. Read `artifacts/tasks/sprint-current.md`.
2. Find any tasks marked `[x]` that are NOT already Done in `backlog.md`.
3. For each found:
   a. Update status in `backlog.md` to `✅ Done (YYYY-MM-DD)`.
4. Proceed with existing Auto-Sync Steps A/B/C.
```

#### 5. Update: `templates/common/agent/workflows/end.md`

Add reconcile trigger in Plan Progress check (Step 4):

```
Before checking plan progress, if `sprint-current.md` contains
any `[x]` marks → auto-trigger reconcile (same logic as backlog
update reconcile step).
```

### Compatibility & versioning (normative)

- **Kernel wording change**: Clarification only — no behavioral change.
  Does NOT require MAJOR bump.
- **New rule**: PATCH bump (new governed rule, backward compatible).
- **Workflow refinement**: PATCH bump (additive reconcile step).
- **Combined release**: MINOR bump recommended (v1.6.0) since it
  introduces a new concept (Working Checkmarks).

### Security / safety (normative)

- Reconcile is idempotent — re-running it produces the same result.
- If `sprint-current.md` has no checkmarks, reconcile is a no-op.
- Reconcile only reads `[x]` status — it cannot introduce new tasks
  or modify task descriptions, preserving backlog.md authority.

## Rationale

"Working Checkmarks" is the minimum viable bridge between:

1. **Planning Mode UX** — agents mark progress inline while coding
2. **3-File architecture integrity** — one-way data flow for structure

Option A (strict READ-ONLY) was rejected because it creates unbearable
friction during coding. Option B (full two-way sync) was rejected because
it destroys the canonical authority concept.

## Alternatives

1. **Agent edits backlog.md directly during coding**
   → Rejected: forces agent to open/parse a potentially large file mid-coding.
   Sprint-current.md is the lightweight focus view specifically designed for this.

2. **Lightweight /backlog tick [ID] command**
   → Considered: A minimal command that just updates status without conversation.
   Could complement Working Checkmarks but adds workflow complexity.

3. **No change (keep READ-ONLY)**
   → Rejected: makes 3-File system objectively worse than Planning Mode for
   inline progress tracking, undermining its core value proposition.

## Drawbacks

- Reconcile adds a small amount of complexity to `/backlog update` and `/end`.
- Edge case: if an agent marks `[x]` but then backlog is also updated
  independently (e.g., by another agent or human), reconcile must handle
  conflicts. Current design: reconcile only adds Done status, never removes it.

## Implementation plan

1. Create `templates/common/agent/rules/hybrid-3-file-integrity.md`
2. Update `templates/common/agent/rules/catalog.yml`
3. Clarify `kernel/invariants.md` I2 wording
4. Add reconcile step to `templates/common/agent/workflows/backlog.md`
5. Add reconcile trigger to `templates/common/agent/workflows/end.md`
6. Update `kernel/schema/tasks.schema.md` to document Working Checkmarks
7. Update `docs/hybrid-3-file.md` with reconcile flow (✅ partially done)
8. Version bump to v1.6.0

## Migration plan

- `para update` / `para install` syncs new rule and updated workflows.
- No workspace structure changes required.
- Existing workspaces gain the rule and reconcile behavior automatically.
- No data migration needed.

## Testing plan

- Add `kernel/examples/valid/sprint-current-with-checkmarks.md`
  to show what a sprint-current.md with working checkmarks looks like.
- Verify reconcile logic manually in a real coding session.

## Unresolved questions

- Should reconcile run automatically at fixed intervals during long sessions,
  or only at explicit sync points (`/backlog update`, `/end`)?
- Should the rule be opt-in (project-level) or always-on (workspace-level)?
- Is a lightweight `/backlog tick [ID]` command worth adding as a complement
  to Working Checkmarks?
