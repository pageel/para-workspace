# Detail Plan Template

> **Naming:** `v[ver/X.X.X]-[YYYY-MM-DD]-[topic].md` (e.g., `v1.7.0-2026-04-09-optimization.md`)
> `[ver]` = the version this plan **serves** (not necessarily a version that will be bumped).
> Plans that don't produce a version bump still use the current/target version for grouping.
> **Lifecycle:** Active → archived to `plans/done/` when completed.
> **Role:** IS `active_plan` in `project.md`.

```markdown
# [Plan Title]: [project-name]

> **Version:** 1.0 | **Created:** YYYY-MM-DD
> **Baseline:** [Reference project or context, if any]

---

## 1. References

> Brainstorm, research, predecessor plans.

| # | File | Role |
| :-- | :-- | :-- |
| B1 | [brainstorm-file](path) | [Description] |
| R1 | [research-file](path) | [Description] |

## 2. Architecture Overview

[Component diagram + Tech stack table]

## 3. Implementation Phases

### Phase 0: Setup & Infrastructure

> ⚠️ **PHASE PRE-FLIGHT (ANTI-BYPASS):** 
> Before executing any task in this Phase, Agent MUST read project.md and reload `.agents/rules.md` + `.agents/skills.md` based on Phase scope.

**Goal:** [One sentence]

| # | Task | Target | Description |
|:--|:--|:--|:--|
| 1 | [ID or name] | `[file/path]` | [What to do] |
| 2 | [ID or name] | `[file/path]` | [What to do] |

**Output:** [Deliverables]

### Phase 1: [Core Feature]

> ⚠️ **PHASE PRE-FLIGHT (ANTI-BYPASS):** 
> Before executing any task in this Phase, Agent MUST reload `.agents/rules.md` + `.agents/skills.md`.

**Goal:** [One sentence]

| # | Task | Target | Description |
|:--|:--|:--|:--|
| 1 | [ID or name] | `[file/path]` | [What to do] |

**Output:** [Deliverables]

## 4. Backlog → Phase Mapping

[Cross-reference table]

## 5. Risks & Mitigations

[Risk table with mitigations]

> 💡 **[Optional] Complex & Meta-Project Add-ons:**
> If this plan is for an **Architecture Refactor** or a **Meta-Project (like PARA Workspace)**, you MUST insert the following sections here to prevent cascading failures:
> - **Execution Order**: Explicit dependency chain of tasks.
> - **File Inventory**: Modified/Created tables.
> - **Impact Analysis**: Blast radius across systems/workflows.
> - **Version Decision**: Justification for version bump level.

## 6. Checklist

> ⚠️ **MANDATORY**: Agent MUST only generate this Checklist AFTER executing **Step 9.5 (Pre-Checklist Context Reload)** entirely, to prevent Token Decay from omitting critical rules (like Version Bump, Docs Impact, or KI Sync).

> ⚠️ **COMPLETION GATE**: Agent MUST explicitly verify EVERY pre-completion item is Done (with evidence) BEFORE proposing next step (push or close). Do NOT skip verification.

### Pre-completion

- [ ] [Core implementation done]
- [ ] [Tests/dry-run pass]
- [ ] [Docs updated if needed]
- [ ] [Project-specific Governance rules checked (e.g., OSS English-first, linting)]

### Post-completion

- [ ] Clear `active_plan` in `project.md`

#### If plan involves `repo/` changes:

- [ ] `git commit` + `git push` successful
- [ ] `./para update` sync workspace (if governed files changed)
- [ ] Verify workspace files
```
