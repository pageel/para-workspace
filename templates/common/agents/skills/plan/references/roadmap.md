# Roadmap Plan Template

> **Naming:** `roadmap-[scope].md` (e.g., `roadmap-cms.md`, `roadmap-ecosystem.md`)
> **Lifecycle:** Never archived — living document, updated when phases complete.
> **Role:** Index of detail plans — NOT `active_plan`.

```markdown
# [Project Name] — Project Roadmap

> **Version**: 1.0 | **Created**: YYYY-MM-DD | **Updated**: YYYY-MM-DD
> **Template:** roadmap.md
> **Type:** Meta-plan — each phase has its own detail plan.

---

## Overview

### Project Goals

[1-3 sentences describing the project and what this roadmap covers]

- **P1. [Goal name]** — [description]
- **P2. [Goal name]** — [description]
- **P3. [Goal name]** — [description]

### Implementation Phases

| Phase | Version | Duration | Depends on | Status |
|:------|:--------|:---------|:-----------|:-------|
| P1 | vX.Y.Z → vX.Y.Z | ✅ Done (YYYY-MM-DD) | — | ✅ Done |
| P2 | vX.Y | ✅ Done (YYYY-MM-DD) | P1 stable | ✅ Done |
| P3 | vX.Y | ~X weeks | P2 stable | 📋 Planned |

> **Total estimate:** ~X weeks active work.

### Dependency Flow

```
P1: [Name] (vX.Y)  ← No dependencies
  ↓
P2: [Name] (vX.Y)  ← P1 ([reason])
  ↓
PN: [Name] (vX.Y)  ← PN-1 ([reason])
```

---

## Horizon (Unscheduled Ideas)

> Ideas, specs, and features that have been proposed but are **not yet assigned
> to any Phase**. Serves as a parking lot for potential work items.
>
> **Review cadence:** Re-evaluate when starting a new Phase or running `/plan`.
> Items may be promoted to a Phase, merged with existing work, or archived.

- **H1. [Feature name]** — [Brief description, 1-2 sentences]
  _Source:_ [link to brainstorm/issue] | _Potential: vX.Y+_
- **H2. [Feature name]** — [Brief description]
  _Source:_ [link] | _Potential: TBD_

> **Graduation criteria** (promote to Phase):
> - Has a clear dependency chain
> - Has been brainstormed or has an RFC draft
> - Has a rough estimate (≥1 week of work)
> - Has user demand or architectural necessity
>
> **Archive criteria** (move to collapsed section):
> - Superseded by another approach
> - No longer aligns with project direction
> - Stale for >6 months with no interest

---

## Phase Details

### P1: [Name] ✅

> vX.Y.Z → vX.Y.Z | YYYY-MM-DD → YYYY-MM-DD

- **vX.Y.0** — [Key deliverables for this version, one line summary]
- **vX.Y.1** — [Key deliverables]
- **vX.Y.2 → vX.Y.N** — [Key deliverables]

**Sources:** [plan-name.md](./plan-name.md) | [plan-name-2.md](./plan-name-2.md)

---

### P2: [Name] 🔨

> **Goal:** [one sentence]
> **Detail plan:** [link to active detail plan]
> **Baseline:** [link to brainstorm if applicable]
> **Estimated:** ~X weeks

- ✅ [Completed deliverable]
- 📋 [Pending deliverable]

---

### PN: [Name] 📋

> **Goal:** [one sentence]
> **Detail plan:** — (not yet created)
> **Baseline:** [link to brainstorm if applicable]
> **Estimated:** ~X weeks

- 📋 [Key deliverable 1]
- 📋 [Key deliverable 2]

> When a Phase has no Detail Plan yet, extended content (detailed deliverables,
> decisions, open questions) can be included in a collapsible block.
> When the Detail Plan is created → move extended content there and remove from roadmap.

<details>
<summary>📋 Extended details (will move to Detail Plan when created)</summary>

#### Detailed Deliverables

- **N.1** [Task 1] — _Source: [brainstorm reference]_
- **N.2** [Task 2] — _Source: [brainstorm reference]_

#### Decisions Made

- ✅ [Decision 1 from brainstorm]
- ✅ [Decision 2]

#### Open Questions

1. **[Topic]:** [Question requiring brainstorm before execution]

</details>

---

## Backlog → Phase Mapping

| Backlog Item | Priority | Phase |
|:--|:--|:--|
| FEAT-XX: [Story] | 🔴 High | P1 ✅ |
| BUG-YY: [Bug] | 🟡 Medium | P2 ✅ |
| FEAT-ZZ: [Story] | 🟡 Medium | P3 |

---

## Scope Boundary

**In scope:**
- [Item 1]
- [Item 2]

**Out of scope:**
- [Item 1] (→ belongs to [other project])

---

## References

- [brainstorm-name.md](link) — Baseline for entire roadmap.
- [brainstorm-name-2.md](link) — Baseline for PN ([topic]).
```
