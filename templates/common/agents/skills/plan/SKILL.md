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

- `/plan create` → Step 9 (Write Plan File): load the appropriate template from `references/`
- `/plan review` → NOT needed (no templates)
- `/plan update` → NOT needed (no templates)

## References

| File | When | Purpose |
|:--|:--|:--|
| `references/detail-plan.md` | Step 9 — Plan Type = Detail Plan (code changes) | Document structure for implementation plans |
| `references/detail-plan-docs.md` | Step 9 — Plan Type = Detail Plan (docs-only) | Document structure for documentation plans (no git, graph-first) |
| `references/roadmap.md` | Step 9 — Plan Type = Roadmap | Document structure for multi-phase roadmaps |
| `references/session-plan.md` | Step 9 — Plan Type = Session Plan (DSP) | Document structure for dynamic lightweight session plans |

| `references/detail-plan-tdd.md` | Step 9 — Plan Type = Detail Plan (TDD mode) | Document structure for strict Test-Driven Development implementation |
| `references/detail-plan-hardened.md` | Step 9 — Plan Type = Hardened Plan | Detail Plan + Mandatory Audit Gate + Selective TDD injection |

> **Convention:** Data files live in `references/` (not `templates/`).
> This follows the Sidecar Skill convention formalized in v1.7.6.3.

### Template Selection Logic

> Agent MUST select the correct template based on plan scope:

```text
IF plan type = Roadmap
  → load references/roadmap.md
ELIF plan type = Session Plan (DSP)
  → load references/session-plan.md
ELIF plan scope is documentation-only
     (target files are in docs/, no code changes, no repo/ modifications)
  → load references/detail-plan-docs.md
ELIF user specifically requests strict TDD (Test-Driven Development)
  → load references/detail-plan-tdd.md
ELIF user requests --hardened OR plan involves mixed code+docs with audit needs
  → load references/detail-plan-hardened.md
ELSE
  → load references/detail-plan.md
```

## Template Adaptation Rules

When generating a plan, Agent MUST load context in this order:

### Pre-requisite: Project Governance & Roadmap Loading

> ⛔ **MANDATORY — Before writing ANY plan content:**
>
> 1. **Roadmap Sync:** Agent MUST check `project.md` for the `roadmap` field.
>    - IF `roadmap` exists → Agent MUST read the roadmap file BEFORE drafting the plan to determine the correct Phase name, target Version number, and Dependency flow. Failure to read the roadmap leads to hallucinated versions and incorrect phase tracking.
>
> 2. **Governance Sync:** Agent MUST check `project.md` for `agent.rules` and `agent.skills` fields.
> - IF `agent.rules: true` → read project `.agents/rules.md` index → load ALL triggered rules
> - IF `agent.skills: true` → read project `.agents/skills.md` index → load ALL triggered skills
>
> This step ensures the plan respects project-specific governance:
> - Maintenance rules (git scope, template-first flow, release process)
> - Review checklists (plan review §7, ecosystem integration)
> - Naming conventions, documentation flow, quality standards
>
> **Failure to load project rules/skills → plan WILL miss critical steps.**

### Adaptation Table

After loading project governance, read `project.md` and adapt the chosen template:

| Condition | Action |
|:--|:--|
| Plan Status is `📝 Draft` | Agent MUST NOT execute Phase tasks. Only review/edit the plan content. |
| Plan Status is `🔨 Active` | Agent MAY execute Phase tasks following the plan sequence. |
| Plan Type is Session Plan | Set status directly to `🔨 Active`, skip setup Phase 0, define milestones with activated options. |
| Project has no `repo/` | Omit Git checkpoint steps and Git items in Walkthrough |
| Project has no build tool | Omit `Build/Test pass` from Audit Tracking |
| Project is not bilingual | Omit 1:N EN/VI task expansion pattern |
| Project has `agent.rules: true` | Keep `<!-- ⚠️ MANDATORY -->` guards in every Phase |
| Plan scope is documentation-only | Use `detail-plan-docs.md` template (no git, graph-first enrichment pipeline) |
| Project has `.beads/graph/` | Read `para-graph §4.3.1` for Phase 0 context. Agent MUST also keep `**Graph Impact**` sections and add `Graph Update` steps in Phase N. |
| Project distributes templates (tool.manifest.yml) | Apply Template-First flow: edit `repo/templates/` BEFORE workspace copies |
| Project has release process | Include release Phase (build + tarball + gh release) per project rules |
| Risks & Mitigations table has entries | Add `<!-- ⚠️ HARNESS GUARD (Phase N Risk): ... -->` comment to each mapped Phase |

> **Principle:** Template = clean skeleton. Adaptation = Skill responsibility.
> **Status lifecycle:** 📝 Draft → 🔨 Active → ✅ Done. Transition from Draft → Active requires explicit user approval at `/plan create` Step 10 or `/plan update`.

### Difficulty Rating & Model Switching (v0.8.2+)

Each Phase header MUST include a difficulty tag to help users choose the appropriate AI model per phase:

**Format:** `### Phase N. [Name] ⚙️ \`Difficulty: [🟢 Low | 🟡 Medium | 🔴 High]\``

| Rating | Scope | Recommended Model |
|:--|:--|:--|
| 🟢 Low | Documentation, formatting, config, version bumps, changelog | Cheaper models (Gemini Flash, Claude Haiku) |
| 🟡 Medium | Code changes with clear patterns, refactoring, test writing | Standard models (Gemini Pro, Claude Sonnet) |
| 🔴 High | Architecture design, complex algorithms, security-critical code | Thinking models (Claude Opus, Gemini Pro Deep Think) |

**Convention rules:**

1. **Final phase after `git push`** SHOULD be `🟢 Low` — reserved for low-thinking tasks (docs, readme, changelog) so user can switch to a cheaper model.
2. Phase with `Difficulty: 🟢 Low` MUST include a Model Hint blockquote:
   ```
   > 💡 **Model Hint:** This phase is primarily documentation — consider switching to a lighter model to save costs.
   ```
3. Agent SHOULD assess difficulty based on the **most complex task** in the phase (not the average).

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
