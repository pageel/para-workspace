# Detail Plan Template

> **Naming:** `v[ver/X.X.X]-[YYYY-MM-DD]-[topic].md` (e.g., `v1.7.0-2026-04-09-optimization.md`)
> `[ver]` = the version this plan **serves** (not necessarily a version that will be bumped).
> Plans that don't produce a version bump still use the current/target version for grouping.
> **Lifecycle:** Active → archived to `plans/done/` when completed.
> **Role:** IS `active_plan` in `project.md`.

```markdown
# [Plan Title]: [project-name]

> **Version:** 1.0 | **Created:** YYYY-MM-DD
> **Status:** 📝 Draft
> **Baseline:** [Reference project or context, if any]

<!-- ⚠️ STATUS GATE: Agent MUST NOT execute any Phase tasks while Status is "📝 Draft".
     Agent may only execute when Status is "🔨 Active".
     Status lifecycle: 📝 Draft → 🔨 Active → ✅ Done
     - 📝 Draft:   Plan is being written/reviewed. No file modifications allowed.
     - 🔨 Active:  User has approved the plan. Execution permitted.
     - ✅ Done:    All phases completed. Ready for archive to plans/done/.
     Transition from Draft → Active requires explicit user approval. -->

---

## References

> Brainstorm, research, predecessor plans.

| # | File | Role |
| :-- | :-- | :-- |
| B1 | [brainstorm-file](path) | [Description] |
| R1 | [research-file](path) | [Description] |

## Architecture Overview & Execution Logic

[Component diagram + Tech stack table]

**Execution Logic Map:**

> ASCII flowchart showing Phase sequence, Guards, and Dependencies.
> Helps verify logic, security, and context coverage before execution.

## Implementation Phases

### Phase 0. Setup & Infrastructure

<!-- ⚠️ MANDATORY: Agent MUST read project.md and reload .agents/rules.md + .agents/skills.md BEFORE executing any tasks here -->

#### Implementation Plan

[Technical blueprint — specific file paths, line numbers, commands.
User reviews this artifact before Agent takes action.
Number steps as `X.Y` (X = Phase, Y = step).
Each step should specify: target file, exact operation, source reference if applicable.]

0.1 **[Step 1 name]** — [Detail: file path, line number, operation]
0.2 **[Step 2 name]** — [Detail: ...]

> ⚠️ Phase 0 does not produce a Git commit. Setup only.

#### Task List

[Progress tracking checklist — Agent ticks items when completed.
1:N relationship with Implementation Plan — one plan step may spawn multiple tasks.
Example: step 1.1 in Plan produces task 1.1a (EN) and 1.1b (VI).]

[ ] 0.1 [Task description]
[ ] 0.2 [Task description]

---

### Phase 1. [Core Feature]

<!-- ⚠️ MANDATORY: Agent MUST reload .agents/rules.md + .agents/skills.md BEFORE modifying files or executing git commands -->
<!-- ⚠️ HARNESS GUARD (Phase 1 Risk): [Derived from Risks & Mitigations table. Leave empty if no risk mapped to this Phase.] -->

#### Implementation Plan

[Goal in 1-2 sentences.]

1.1 **[Step name]** — [Detail: file path, line number, operation, source reference if applicable.]
1.2 **[Step name]** — [...]

1.N **Git checkpoint Phase 1**
```bash
git add [scope]
git commit -m "[conventional commit message]"
git push
```

#### Task List

[ ] 1.1a [Specific task — e.g. EN file]
[ ] 1.1b [Specific task — e.g. VI file]
[ ] 1.2 [Task]
[ ] 1.N Git commit + push Phase 1 successful.

---

### Phase 2. [Next Feature]

[Repeat structure: MANDATORY + HARNESS GUARD + Implementation Plan + Task List + Git checkpoint]

---

## Backlog → Phase Mapping

| Backlog Item | Priority | Phase |
|:--|:--|:--|
| [Item ID] | 🔴 High | Phase 1 |

> 💡 **[Optional] Complex & Meta-Project Add-ons:**
> If this plan is for an **Architecture Refactor** or a **Meta-Project (like PARA Workspace)**, insert:
> - **Execution Order**: Explicit dependency chain of tasks.
> - **Impact Analysis**: Blast radius across systems/workflows.
> - **Version Decision**: Justification for version bump level.

## Walkthrough (Completion Gate)

> Final verification checklist — only tick when ALL Phase Task Lists are complete.
> Equivalent to the Walkthrough artifact in Antigravity Planning mode.

[ ] All Task List items from Phase 0 → Phase N are [x].
[ ] All Git commit + push commands executed.
[ ] [Project-specific checks: build pass, docs updated, governance rules...]
[ ] Clear `active_plan` in `project.md`.

> 🛑 **STOP HERE:** Agent MUST explicitly ask the User to verify BEFORE executing the final git push in the last Phase.

### Risks & Mitigations

> Risks serve as a source to reinforce guardrails at each Phase.
> When a new risk is discovered during execution → add it here → update the
> `<!-- ⚠️ MANDATORY -->` guard of the related Phase accordingly.

| Risk | Mitigation | Harness (related Phase) |
|:--|:--|:--|
| [Risk description] | [Mitigation strategy] | [Phase N guard] |

### Review & Audit Tracking

> Counter table to assess plan health. Update after each working session.

| Criteria | Count | Last reviewed |
|:--|:--|:--|
| Logic review (Phase sequence, Task coverage) | 0 | — |
| Security review (context guards, published-only) | 0 | — |
| Checklist review (completeness, no missing files) | 0 | — |
| Build/Test pass | 0 | — |

### Suggested Next Steps

1. **Activate Plan:** Set `active_plan` in `project.md`.
2. [Project-specific next step...]
```
