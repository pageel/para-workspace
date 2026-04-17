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

## Template Adaptation Rules

When generating a plan from `detail-plan.md`, Agent MUST read `project.md` first and adapt:

| Condition | Action |
|:--|:--|
| Plan Status is `📝 Draft` | Agent MUST NOT execute Phase tasks. Only review/edit the plan content. |
| Plan Status is `🔨 Active` | Agent MAY execute Phase tasks following the plan sequence. |
| Project has no `repo/` | Omit Git checkpoint steps and Git items in Walkthrough |
| Project has no build tool | Omit `Build/Test pass` from Audit Tracking |
| Project is not bilingual | Omit 1:N EN/VI task expansion pattern |
| Project has `agent.rules: true` | Keep `<!-- ⚠️ MANDATORY -->` guards in every Phase |
| Plan scope is documentation-only | Risks table may reference `docs-authoring` rules as harness |
| Risks & Mitigations table has entries | Add `<!-- ⚠️ HARNESS GUARD (Phase N Risk): ... -->` comment to each mapped Phase |

> **Principle:** Template = clean skeleton. Adaptation = Skill responsibility.
> **Status lifecycle:** 📝 Draft → 🔨 Active → ✅ Done. Transition from Draft → Active requires explicit user approval at `/plan create` Step 10 or `/plan update`.

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
