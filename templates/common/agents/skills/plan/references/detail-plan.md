# Detail Plan Template

> **Naming:** Descriptive names (e.g., `implementation-plan.md`, `migration-plan.md`, `v2-redesign-plan.md`).
> **Lifecycle:** Active → archived to `plans/done/` when completed.
> **Role:** IS `active_plan` in `project.md`.

```markdown
# [Plan Title]: [project-name]

> **Version:** 1.0 | **Created:** YYYY-MM-DD
> **Baseline:** [Reference project or context, if any]

---

## 1. References

> Brainstorm, research, predecessor plans.

| # | File | Vai trò |
| :-- | :-- | :-- |
| B1 | [brainstorm-file](path) | [Mô tả] |
| R1 | [research-file](path) | [Mô tả] |

## 2. Architecture Overview

[Component diagram + Tech stack table]

## 3. Implementation Phases

### Phase 0: Setup & Infrastructure

[Tasks, timeline, output]

### Phase 1: [Core Feature]

[Tasks, timeline, output]

## 4. Backlog → Phase Mapping

[Cross-reference table]

## 5. Risks & Mitigations

[Risk table with mitigations]

## 6. Checklist

### Pre-push

- [ ] [Core implementation done]
- [ ] [Tests/dry-run pass]
- [ ] [Docs updated if needed]

### Post-push

- [ ] `git commit` + `git push` thành công
- [ ] `./para update` sync workspace
- [ ] Verify workspace files
- [ ] Clear `active_plan` trong `project.md`
```
