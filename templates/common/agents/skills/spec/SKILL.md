---
name: spec-driven-development
description: >
  Governance skill for /spec workflow — provides spec templates, assumption
  surfacing rules, boundary definitions, and quality checklists. Load when
  creating specifications, defining feature scope, surfacing assumptions,
  writing acceptance criteria, or reviewing specs. Even if the user doesn't
  mention "spec", load this skill when requirements are ambiguous and need
  to be formalized before coding.
license: Apache-2.0
metadata:
  author: para-workspace
  version: "1.0.0"
  inspired-by: addyosmani/agent-skills (spec-driven-development)
compatibility: Any PARA Workspace project with artifacts/ directory
---

# Spec-Driven Development — Governance & Templates

> **Version:** 1.0.0 | **Kernel min:** 1.7.15 | **Type:** Sidecar Skill
> **Companion workflow:** `/spec` (`workflows/spec.md`)

This skill governs the quality standards, assumption surfacing rules, and
document templates for the `/spec` workflow. The workflow handles step-by-step
logic; this skill provides the governance rules and data resources.

---

## 1. Core Principles

### 1.1 Assumptions Are Dangerous

The spec's entire purpose is to surface misunderstandings *before* code gets
written. Assumptions are the most dangerous form of misunderstanding.

**Agent MUST:**
- List ALL assumptions before writing spec content (Step 2 of workflow)
- Pull assumptions from `project.md` (tech stack, dependencies, deployment)
- Identify implicit requirements the user hasn't stated
- Flag ambiguous requirements with a concrete default
- WAIT for user confirmation before proceeding

**Agent MUST NOT:**
- Silently fill in ambiguous requirements
- Proceed with "I think" or "I believe" — surface it as an explicit assumption
- Skip assumption listing because "it's obvious"

### 1.2 Gated Workflow — No Shortcuts

Each phase produces a concrete output. Skipping gates leads to:
- Misaligned expectations (Agent builds wrong thing)
- Scope creep (no written boundaries)
- Rework (assumptions discovered during implementation)

```
SPECIFY ──→ PLAN ──→ TASKS ──→ IMPLEMENT
   │          │        │          │
   ▼          ▼        ▼          ▼
 Human      Human    Human      Human
 reviews    reviews  reviews    reviews
```

### 1.3 Reframe Vague Requirements

When requirements are vague, Agent MUST translate them into testable conditions:

```
REQUIREMENT: "Make the search fast"

REFRAMED SUCCESS CRITERIA:
- Search returns results in < 200ms for 10k records
- UI shows loading indicator during search
- Results are paginated (max 50 per page)
→ Are these the right targets?
```

This lets the team verify completion objectively, not subjectively.

### 1.4 Boundaries System

Every spec MUST define three tiers of boundaries:

| Tier | Meaning | Example |
|:--|:--|:--|
| **Always do** | Non-negotiable rules | Run tests before commits, validate inputs |
| **Ask first** | Requires human approval | DB schema changes, adding dependencies |
| **Never do** | Absolute prohibitions | Commit secrets, edit vendor dirs, remove failing tests |

### 1.5 Spec Re-read Checkpoint (Implementation Guard)

Before starting ANY implementation task derived from an approved spec, Agent MUST:

1. **Locate the spec:** Find the relevant `artifacts/specs/spec-*.md` file
2. **Re-read Success Criteria:** Use `view_file` to read the spec's success criteria section
3. **Re-read Boundaries:** Confirm the Always/Ask First/Never rules are still in working memory
4. **Cross-reference task:** Verify the current task maps to a specific spec requirement

**Why this matters:** During long coding sessions, Agent context decays. A task that
started aligned with the spec can drift into hallucinated requirements if the spec
is not refreshed. This checkpoint costs ~200 tokens but prevents ~2000 tokens of
rework from spec violations.

```
BEFORE each implementation task:
  ┌─────────────────────────────┐
  │ 1. view_file(spec)          │  ← Re-read success criteria
  │ 2. Confirm task↔spec match  │  ← Verify alignment
  │ 3. Check boundaries         │  ← Always/Ask/Never still loaded?
  │ 4. BEGIN coding              │  ← Only after checkpoint passes
  └─────────────────────────────┘
```

**Anti-pattern:** "I already read the spec earlier" — earlier context may be
truncated or decayed. Re-read is cheap insurance.

## 2. Resource Router

> Agent reads this table to locate data files needed by the `/spec` workflow.

| Resource | Relative Path | When to Load |
|:--|:--|:--|
| Feature Spec Template | `references/templates/feature-spec.md` | Step 3: Writing spec document |
| Spec Quality Checklist | `references/spec-quality-checklist.md` | Before presenting spec for review (Gate 1) |

**Path resolution:** All paths are relative to this skill's directory
(`.agents/skills/spec/`).

## 3. Spec Document Lifecycle

### States

| Status | Meaning |
|:--|:--|
| `📝 Draft` | Being written, not yet reviewed |
| `✅ Approved` | All 3 gates passed, ready for implementation |
| `🔄 Updated` | Modified after initial approval (scope change) |
| `📦 Archived` | Implementation complete, moved to `specs/done/` |

### Storage Convention

```
Projects/[project-name]/artifacts/specs/
├── spec-2026-04-22-feature-name.md     ← Active specs
└── done/
    └── spec-2026-04-01-old-feature.md  ← Completed specs
```

### Integration with Other Workflows

| Workflow | Relationship |
|:--|:--|
| `/brainstorm` | Upstream — explore before specifying |
| `/plan` | Downstream — create formal plan from spec |
| `/backlog` | Downstream — add spec tasks to backlog |
| `/verify` | Downstream — verify implementation against spec criteria |
| `/docs` | Parallel — architecture docs feed spec context |

### Graph-Awareness

> 🔍 If project has `.beads/graph/`, read `para-graph §3.3.4` before writing specs.
> Graph provides prior-art discovery (existing implementations, patterns, boundaries).
> If no graph → proceed with source-only spec writing.

## 4. Quality Gate — Self-Check

Before presenting a spec for user review (Gate 1), Agent MUST self-check:

- [ ] All 6 core areas are covered (Objective, Commands, Structure, Style, Testing, Boundaries)
- [ ] Assumptions are explicitly listed (not silently embedded)
- [ ] Success criteria are specific and testable (not vague)
- [ ] Boundaries (Always/Ask First/Never) are defined
- [ ] Open questions are listed (not hidden)
- [ ] Vague requirements have been reframed into concrete conditions

> Load `references/spec-quality-checklist.md` for the full validation checklist.

## 5. Anti-Patterns

| Anti-Pattern | Why It's Harmful |
|:--|:--|
| Skipping to implementation | Agent builds the wrong thing, user discovers too late |
| Generic success criteria | "It should work well" → can never be verified as done |
| Missing boundaries | Agent makes decisions it shouldn't (DB changes, dep additions) |
| No assumption surfacing | Misunderstandings found during implementation cause 3x rework |
| Spec-as-documentation | Writing the spec *after* code defeats the purpose. Spec = before. |

## 6. Architecture Note — Sidecar Pattern

```
workflows/spec.md          ← LOGIC ONLY (step-by-step gated flow)
skills/spec/
├── SKILL.md               ← GOVERNANCE (this file: rules + router)
└── references/
    ├── templates/
    │   └── feature-spec.md    ← Spec document template
    └── spec-quality-checklist.md  ← Quality validation checklist
```

**Why Sidecar?** The workflow file contains only sequential logic. All supporting
data (templates, checklists) belongs in the companion skill directory. This
separation reduces token waste and keeps the `workflows/` namespace clean.

## 🧪 Test Mode (Sandbox Override)

> **Trigger:** User includes "Test Mode" or explicitly asks to test this skill.

When in Test Mode:

1. **No Live Edits:** Do NOT modify files outside the sandbox directory.
2. **Containment:** Route ALL outputs into `[PROJECT_ROOT]/sandbox/evals/spec-[YYYY-MM-DD]/`.
3. **Execute Task:** Run the full gated workflow as if in production.
4. **Generate Report:** Create `test-report.md` in the sandbox folder:

   ```markdown
   # Test Report: spec-driven-development
   > Date: YYYY-MM-DD | Prompt: "[user's prompt]"

   ## Actions Taken
   - [List each action performed]

   ## Gates Passed
   - [Which gates were passed, which required iteration]

   ## Files Created
   - [List files in sandbox/]

   ## Self-Assessment
   - [Did the skill surface assumptions effectively?]
   - [Were success criteria specific enough?]
   ```
