---
name: Plan Templates
description: Sidecar data for /plan workflow — Detail Plan and Roadmap templates loaded just-in-time.
source: catalog
---

# Skill: Plan Templates

> Sidecar Skill for the `/plan` workflow. Contains plan document templates
> that the Agent loads **only when writing the plan file** (Step 9).
>
> **Pattern:** Workflow = Logic → Sidecar Skill = Data Router.
> The `/plan` workflow instructs the Agent to read this skill at template-write time.

## When to Load

- `/plan create` → Step 9 (Write Plan File): load `references/detail-plan.md` or `references/roadmap.md`
- `/plan review` → NOT needed (no templates)
- `/plan update` → NOT needed (no templates)

## References

| File | When | Purpose |
|:--|:--|:--|
| `references/detail-plan.md` | Step 9 — Plan Type = Detail Plan | Document structure for implementation plans |
| `references/roadmap.md` | Step 9 — Plan Type = Roadmap | Document structure for multi-phase roadmaps |

> **Convention:** Data files live in `references/` (not `templates/`).
> This follows the Sidecar Skill convention formalized in v1.7.6.3.

## Output Checklist

After writing the plan, verify:

- [ ] Project contract analyzed
- [ ] Backlog items mapped to phases
- [ ] Project knowledge scanned (docs index, RFCs, architecture baseline, project rules)
- [ ] Architecture designed with component diagram (extended if baseline exists)
- [ ] Data schema defined (if applicable)
- [ ] Plan type selected: Roadmap vs Detail Plan (Step 2.8)
- [ ] Strategy/roadmap context loaded if applicable (Step 2.9)
- [ ] Phases defined (4-7 phases recommended)
- [ ] Code reuse documented (if reference projects exist)
- [ ] Plan saved to `artifacts/plans/`
- [ ] `active_plan` field set in `project.md` (detail plans only)
- [ ] Roadmap auto-updated if exists (Step 10)
- [ ] `/backlog sync` suggested (or auto-triggered)
- [ ] Session log updated
