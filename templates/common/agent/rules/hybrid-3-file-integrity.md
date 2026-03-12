# Rule: Hybrid 3-File Integrity

> Agent MUST follow these constraints when working with task files
> in `artifacts/tasks/`.

## Scope

- [x] Global (applies to all projects with Hybrid 3-File setup)

## Triggers

- Reading or writing any file in `artifacts/tasks/`
- Running `/backlog update`, `/backlog clean`, `/end`
- Marking tasks as completed during coding sessions

## Constraints

### C1: sprint-current.md — Working Checkmarks Only

- Agent MAY mark tasks `[x]` in this file while coding (same UX as Planning Mode)
- Agent MUST NOT add new tasks
- Agent MUST NOT remove or delete tasks
- Agent MUST NOT edit task descriptions, priorities, or phase assignments
- On session end (`/end`) or `/backlog update`, checkmarks MUST be reconciled back to `backlog.md`

### C2: done.md is APPEND-ONLY

- Agent MUST NOT modify or delete existing entries in `done.md`
- New entries are added ONLY through `/backlog update` or `/backlog clean`
- Entries are grouped by completion date, most recent first

### C3: backlog.md is the OPERATIONAL AUTHORITY

- All structural task mutations (add, remove, re-prioritize, re-phase) MUST go through `backlog.md`
- Status changes to Done MAY originate from `sprint-current.md` Working Checkmarks but MUST be reconciled to `backlog.md`
- `backlog.md` + `done.md` together represent the complete project task history

### C4: Plan-Backlog Sync is MANDATORY after /plan create

- After creating and activating a plan, Agent MUST suggest `/backlog sync`
- If `active_plan` exists in `project.md` but backlog items lack Phase assignments, Agent SHOULD warn

## Reconciliation Process

When `/end` or `/backlog update` detects Working Checkmarks in `sprint-current.md`:

1. Scan `sprint-current.md` for items marked `[x]`
2. For each `[x]` item, update corresponding entry in `backlog.md` to `✅ Done (YYYY-MM-DD)`
3. Append completed items to `done.md` under today's date header
4. Re-render `sprint-current.md` from `backlog.md` (removes completed items)
5. Run Plan Completion Check if `active_plan` exists

## Examples

### Allowed

```markdown
# sprint-current.md — BEFORE coding

- [ ] FEAT-36: Create hybrid-3-file-integrity rule priority: high

# sprint-current.md — AFTER coding (Working Checkmark)

- [x] FEAT-36: Create hybrid-3-file-integrity rule priority: high
```

### NOT Allowed

```markdown
# sprint-current.md — INVALID: adding new task

- [x] FEAT-36: Create hybrid-3-file-integrity rule priority: high
- [ ] FEAT-99: New task I just thought of ← VIOLATION of C1
```

## Related

- **RFC-0002**: `rfcs/0002-hybrid-3-file-integrity.md`
- **Kernel Invariant I2**: Hybrid 3-File Task Model
- **Schema**: `kernel/schema/tasks.schema.md`
