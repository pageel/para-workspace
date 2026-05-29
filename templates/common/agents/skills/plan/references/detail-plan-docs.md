# Detail Plan Template — Documentation

> **Naming:** `v[ver/X.X.X]-[YYYY-MM-DD]-docs-[topic].md` (e.g., `v2.1.x-2026-05-04-docs-internal.md`)
> **Lifecycle:** Active → archived to `plans/done/` when completed.
> **Role:** IS `active_plan` in `project.md`.
> **Scope:** Internal docs (`Projects/[name]/docs/`) — NOT `repo/docs/`.
> No git commit/push. Use `/docs publish` separately when ready to ship.

> **When to use this template instead of `detail-plan.md`:**
> - Plan scope is **documentation-only** (no code changes)
> - Target files are in `docs/` (PARA workspace internal), not `repo/`
> - Plan involves writing feature docs, architecture docs, or API references
>
> **When NOT to use:**
> - Plan includes code changes alongside docs → use `detail-plan.md`
> - Publishing docs to `repo/docs/` → that's a `/docs publish` action, not a plan

````markdown
# [Docs Plan Title]: [project-name]

> **Version:** 1.0 | **Created:** YYYY-MM-DD
> **Status:** 📝 Draft
> **Baseline:** [Current codebase version, e.g., "v2.1.0 stable"]

<!-- ⚠️ STATUS GATE: Agent MUST NOT execute any Phase tasks while Status is "📝 Draft".
     Agent may only execute when Status is "🔨 Active".
     Status lifecycle: 📝 Draft → 🔨 Active → ✅ Done
     Transition from Draft → Active requires explicit user approval.
     Transition from Active → Done requires Walkthrough completion + explicit user approval. -->

> ⛔ **STATUS GATE:** Agent MUST NOT execute Phase tasks while Status = "📝 Draft".
> Lifecycle: 📝 Draft → 🔨 Active → ✅ Done. Transition requires explicit user approval.

> ℹ️ **Scope:** Internal documentation in `Projects/[name]/docs/` (PARA workspace).
> This is NOT code in `repo/` — no git commit/push.
> When you need to ship docs to repo, use `/docs publish` separately.

---

## References

> Brainstorm, existing docs, predecessor plans.

| #   | File                    | Role          |
| :-- | :---------------------- | :------------ |
| R1  | [existing-doc](path)    | [Description] |

## Architecture Overview

```text
Projects/[project-name]/docs/
├── README.md (Index — updated in Phase 0)
│
├── [Existing docs]
│   ├── architecture.md
│   └── ...
│
└── [New docs — N files]
    ├── feature-xxx.md         ← Phase N
    └── ...
```

## Implementation Phases

### Phase 0. Setup & Context Gathering ⚙️ `Difficulty: 🟢 Low`

> ⛔ **MANDATORY:** Re-read `project.md`, `.agents/rules.md`, `.agents/skills.md` BEFORE executing.

> 💡 **Model Hint:** This phase is primarily setup — user can use a lighter model.

#### Implementation Plan

<!-- ═══════════════════════════════════════════════════════
     GRAPH INTELLIGENCE — Centralized in para-graph skill §3.3.2
     Agent MUST read `skills/para-graph/SKILL.md §3.3.2` for the full pipeline.
     IF `.beads/graph/` NOT exists → skip graph steps, execute Step D only.
     ═══════════════════════════════════════════════════════ -->

> 🔍 **Graph Pipeline:** Read `para-graph §3.3.2` for Steps A-C (build → identify → enrich).
> Skip Steps A-C if `.beads/graph/metadata.json` does not exist.

**Step D — Update docs index (ALWAYS):**

0.1 🤖 **Update docs/README.md** — Add a "Feature Docs" table listing all docs to be created.

#### Task List

- [ ] 0.0 🤖 Graph Knowledge Preparation (if para-graph enabled)
- [ ] 0.1 🤖 Graph pipeline per `para-graph §3.3.2` (**skip if no `.beads/graph/`**).
- [ ] 0.2 🤖 Update `docs/README.md` index.
- [ ] ⛔ CHECKPOINT: Agent MUST verify ALL tasks in Phase 0 are checked [x] AND get explicit User approval before proceeding to Phase 1.

---

### Phase N. [Doc Group Name] ⚙️ `Difficulty: 🟢 Low`

<!-- ⚠️ MANDATORY: Agent MUST reload .agents/rules.md + .agents/skills.md BEFORE writing docs -->

> ⛔ **MANDATORY:** Re-read `.agents/rules.md` + `.agents/skills.md` BEFORE writing docs.

> 💡 **Model Hint:** This phase is primarily documentation — consider switching to a lighter model to save costs.

<!-- ⚠️ HARNESS GUARD (Phase N Risk): [Derived from Risks & Mitigations table. Leave empty if no risk mapped to this Phase.] -->

#### Implementation Plan

[Goal in 1-2 sentences.]

**Context loading per doc:**

> **Per-doc context loading:** Follow `para-graph §3.3.2` context modes (graph-enhanced or source-only).

N.1 🤖 **[doc-filename].md** — Load context for `[Component.tsx]` → write doc:
  - [Section 1 description]
  - [Section 2 description]

N.2 🤖 **[doc-filename].md** — Load context for `[Component.tsx]` → write doc:
  - [Section 1 description]
  - [Section 2 description]

> **Execution Ownership Legend:**
> 🤖 = Agent auto-run — safe, read-only, or non-destructive operations
> 👤 = User approval required — destructive, external, or state-mutating operations
>
> **For docs plans:** All tasks are 🤖 (writing to `docs/` is non-destructive).
> Exception: `/docs publish` to `repo/docs/` requires 👤.

#### Task List

- [ ] N.1 🤖 Create `[doc-filename].md`.
- [ ] N.2 🤖 Create `[doc-filename].md`.
- [ ] ⛔ CHECKPOINT: Agent MUST verify ALL tasks in Phase N are checked [x] AND get explicit User approval before proceeding to the next Phase.

---

## Walkthrough (Completion Gate)

> Final verification checklist — only tick when ALL Phase Task Lists are complete.

- [ ] All Task List items from Phase 0 → Phase N are [x].
- [ ] All docs are linked in `docs/README.md` index.
- [ ] Content verified against source code (Zero-hallucination check).
- [ ] Graph enrichment data preserved — if graph was used (nodes have `semantic` field).
- [ ] ⛔ CHECKPOINT (Walkthrough Completion): Agent MUST verify all above Walkthrough items are ticked [x] BEFORE proposing Status transition.
- [ ] ⛔ CHECKPOINT (C7 Status Transition): Agent MUST NOT change Status to "✅ Done" without explicit user approval. Agent presents the completed Walkthrough checklist → User verifies → User approves transition. Only AFTER user confirms → Agent sets Status and clears `active_plan`.
- [ ] User approved Done transition.
- [ ] Clear `active_plan` in `project.md`.

### Risks & Mitigations

> Docs-specific risks. No git risks (no git operations in this plan).

| Risk | Mitigation | Phase |
| :--- | :--------- | :---- |
| Docs hallucinate non-existent features | Read source code (+ graph context if available) BEFORE writing | All |
| Existing docs conflict with new docs | Cross-check `architecture.md` and update if needed | Phase 1 |
| Graph data stale after recent code changes | Re-run `/para-graph build` in Phase 0 (if graph available) | Phase 0 |

### Review & Audit Tracking

> Counter table to assess plan health. Update after each working session.

| Criteria                                          | Count | Last reviewed |
| :------------------------------------------------ | :---- | :------------ |
| Content accuracy (docs match source code)         | 0     | —             |
| Completeness (all features documented)            | 0     | —             |
| Project governance compliance (see below)         | 0     | —             |

#### Project Governance Checklist

> ⛔ **MANDATORY — Auto-generated at plan creation time.**
> Agent MUST scan project `.agents/rules.md` and `.agents/skills.md` indices
> and generate checklist items for each triggered rule/skill.
> This section is EMPTY if the project has no `agent.rules` / `agent.skills`.
>
> **Template — replace with actual items from project indices:**

```markdown
IF project has agent.rules: true OR agent.skills: true:

  Scan project .agents/rules.md → for each rule with matching trigger:
    [ ] [rule-name]: [key requirement] (e.g., "docs-standard.md: all docs include graph_nodes frontmatter")

  Scan project .agents/skills.md → for each skill with matching trigger:
    [ ] [skill-name]: [key requirement] (e.g., "para-graph: run inject after docs generation")

ELSE:
  (No project-specific governance — standard checklist only)
```

### Suggested Next Steps

- **Option A (Activate & Execute):** Run `/plan [project-name] dev` (or `/plan dev`) to begin automatic execution of the phases.
- **Option B (Stress-test Plan):** Run `/qa [project-name] plan` (or `/qa plan`) to trigger a Red Team Q&A review before execution.
- **Option C (Post-Run Publish):** After execution, run `/docs publish` to sync public documents to `repo/docs/`.
- **Option D (Docs Quality Review):** Run `/docs review` for quality checks.
````
