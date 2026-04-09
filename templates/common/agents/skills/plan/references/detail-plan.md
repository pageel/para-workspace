# Detail Plan Template

> **Naming:** `v[ver/X.X.X]-[YYYY-MM-DD]-[topic].md` (e.g., `v1.7.0-2026-04-09-optimization.md`)
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

[Tasks, timeline, output]

### Phase 1: [Core Feature]

> ⚠️ **PHASE PRE-FLIGHT (ANTI-BYPASS):** 
> Before executing any task in this Phase, Agent MUST reload `.agents/rules.md` + `.agents/skills.md`.

[Tasks, timeline, output]

## 4. Backlog → Phase Mapping

[Cross-reference table]

## 5. Risks & Mitigations

[Risk table with mitigations]

## 6. Checklist

> ⚠️ **MANDATORY**: Agent MUST only generate this Checklist AFTER executing **Step 9.5 (Pre-Checklist Context Reload)** entirely, to prevent Token Decay from omitting critical rules (like Version Bump, Docs Impact, or KI Sync).

### Pre-push

- [ ] [Core implementation done]
- [ ] [Tests/dry-run pass]
- [ ] [Docs updated if needed]
- [ ] [Project-specific Governance rules checked (e.g., OSS English-first, linting)]

### Post-push

- [ ] `git commit` + `git push` successful
- [ ] `./para update` sync workspace
- [ ] Verify workspace files
- [ ] Clear `active_plan` in `project.md`
```
