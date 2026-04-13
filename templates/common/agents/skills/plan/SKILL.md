---
name: plan
description: "Sidecar data for /plan workflow — loads Detail Plan and Roadmap document templates just-in-time at Step 9. Use when running /plan create to select and apply the correct plan structure from references/."
metadata:
  source: catalog
---

# Skill: Plan Templates

> Provides Detail Plan and Roadmap document templates for structuring project plans.
> Loaded by the `/plan` workflow **only during `/plan create`** (Step 9 — Write Plan File).

## When to Load

- `/plan create` → Step 9 (Write Plan File): load `references/detail-plan.md` or `references/roadmap.md`
- `/plan review` → NOT needed (no templates)
- `/plan update` → NOT needed (no templates)

## How to Apply

1. Determine plan type: **Detail Plan** (single implementation) or **Roadmap** (multi-phase)
2. Read the matching template from `references/`
3. Fill all sections with project-specific content from analyzed context
4. Save completed plan to `artifacts/plans/<plan-name>.md`
5. If checklist items below are not satisfied, revisit the relevant workflow step before proceeding

## References

| File | When | Purpose |
|:--|:--|:--|
| `references/detail-plan.md` | Step 9 — Plan Type = Detail Plan | Document structure for implementation plans |
| `references/roadmap.md` | Step 9 — Plan Type = Roadmap | Document structure for multi-phase roadmaps |

> **Convention:** Data files live in `references/` (not `templates/`).

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
