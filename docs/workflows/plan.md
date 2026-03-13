# /plan Workflow

> **Version**: 1.5.3

The `/plan` workflow creates, reviews, and updates phased implementation plans for PARA projects. It integrates with brainstorm outputs, the project backlog, and the learning index to produce comprehensive, actionable plans.

## Commands

```
/plan [project-name] [action]
```

| Action   | Description                         |
| -------- | ----------------------------------- |
| `create` | Create a new implementation plan    |
| `review` | Summarize existing plan with status |
| `update` | Modify phases, status, or timeline  |

## Plan Creation Flow

```
Contract → Backlog → Brainstorm check → Learnings → Architecture → Phases → Save → Register
```

### Key Steps

1. **Read Project Contract** — Goal, deadline, DoD from `project.md`
2. **Read Backlog** — Feature scope, priorities, status distribution
3. **Check Brainstorm Context** (v1.5.0) — Auto-discovers recent brainstorm outputs in `artifacts/para-decisions/brainstorm-*.md`. If found, uses the Options and Decision sections as baseline context.
4. **Scan Learnings Index** — Cross-references `Areas/Learning/README.md` with project tech stack. Reads matched lessons (max 3) to prevent repeating past mistakes.
5. **Analyze Reference Projects** — If contract references another project, checks for reusable code.
6. **Design Architecture** — Component diagram (ASCII), tech stack table, data flow.
7. **Define Phases** — 4-7 sequential phases, each with tasks, timeline, and deliverables.
8. **Map Backlog → Phases** — Links High/Medium priority items to implementation phases.
9. **Rule Impact Check** (v1.5.3) — If plan tasks modify `rules/` or `kernel/`, auto-adds sync tasks to final phase.
10. **Write Plan File** — Saves to `artifacts/plans/[plan-name].md`
11. **Register in project.md** — Sets `active_plan` field for `/open` and `/end` discovery.

### Phase Structure

| Rule      | Description                             |
| --------- | --------------------------------------- |
| Phase 0   | Always "Setup & Infrastructure"         |
| Phase 1–N | Core feature phases in dependency order |
| Final     | Always "Polish & Extras"                |

## Plan Review

`/plan [project-name] review` displays a status table:

```
📋 PLAN REVIEW: [plan-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
| Phase   | Status         | Tasks  | Source    |
| ------- | -------------- | ------ | --------- |
| Phase 0 | ✅ Done        | 5/5    | done.md   |
| Phase 1 | 🔨 In Progress | 3/5    | backlog   |
| Phase 2 | ⏳ Pending     | 0/4    | —         |
Overall: 40% complete | Deadline: YYYY-MM-DD
```

> **Hybrid 3-File**: `/plan review` cross-references completed task IDs located in `done.md` instead of searching the backlog. This reliably detects when a phase reaches 100% completion in order to suggest a retrospective early.

### Plan Archiving

When all phases reach 100%, `/plan review` automatically:

1. Moves the plan to `artifacts/plans/done/[plan-name].md`
2. Creates a **completion review** at `artifacts/plans/done/[plan-name]-review.md` (task status, phase summary, deferred items)
3. Removes `active_plan` from `project.md`
4. Suggests running `/retro`

## Integration Points

| Workflow      | Relationship                                              |
| ------------- | --------------------------------------------------------- |
| `/brainstorm` | Plan auto-discovers brainstorm outputs (Step 2.5)         |
| `/learn`      | Plan scans learning index for relevant lessons (Step 2.6) |
| `/open`       | Open reads `active_plan` to show current phase            |
| `/end`        | End checks plan completion, cleans up `active_plan`       |
| `/verify`     | Verify checks task completion against plan                |

## Related

- [Brainstorm Guide](./brainstorm.md) — Ideation before planning
- [Workflow Documentation](../workflows.md) — Workflow catalog
- [Planning Guide](../planning.md) — Plan + Backlog combined guide

---

_Updated in v1.5.3 (Rule Impact Check, completion review in plans/done/, has_rules gate)_
