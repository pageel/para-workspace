# Detail Plan Template

> **Naming:** Descriptive names (e.g., `implementation-plan.md`, `migration-plan.md`, `v2-redesign-plan.md`).
> **Lifecycle:** Active → archived to `plans/done/` when completed.
> **Role:** IS `active_plan` in `project.md`.

```markdown
# [Plan Title]: [project-name]

> **Version:** 1.0 | **Created:** YYYY-MM-DD
> **Baseline:** [Reference project or context, if any]

---

## 📐 Architecture Overview

[Component diagram + Tech stack table]

## 📊 Data Schema

[Schema definition with examples]

## 🗓 Implementation Phases

### Phase 0: Setup & Infrastructure

[Tasks, timeline, output]

### Phase 1: [Core Feature]

[Tasks, timeline, output]

...

### Phase N: Polish & Extras

[Tasks, timeline, output]

## 📦 Code Reuse (if applicable)

[Reuse table from reference projects]

## 🔗 Backlog → Phase Mapping

[Cross-reference table]

## ⚠️ Risks & Lessons Applied

[Risk table with mitigations]

> If Step 2.6 found relevant lessons, list them here:
>
> - **Source:** `Areas/Learning/[lesson-name].md`
> - **Constraint applied:** [What checklist or pattern was incorporated into this plan]

> If Step 2.7 found active RFCs, list constraints here:
>
> - **RFC:** `docs/rfcs/[rfc-name].md` (Status: Implemented/Planned)
> - **Constraint applied:** [What decision or rule was incorporated into this plan]

## ✅ Definition of Done

[Copied from project.md for quick reference]
```
