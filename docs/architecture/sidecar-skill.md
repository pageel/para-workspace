# Sidecar Skill Architecture (v1.7.8+)

> **Version**: 1.7.11 | **Last reviewed**: 2026-04-10

## Overview

Before v1.7.8, data templates (e.g., Detail Plan template, Roadmap template) were embedded directly inside workflow files. This caused:

- Workflow files **grew large** (700+ lines)
- Agent read the entire workflow = **loaded unneeded templates** = token waste
- Template changes → had to edit workflow → risk of breaking logic

**Sidecar Skill Pattern** solves this by separating template data from workflow logic:

```
Workflow = Logic only (steps, conditions, routing)
Sidecar Skill = Data router (templates, references, loaded on demand)
```

---

## Architecture

### Directory Structure

```text
.agents/skills/
├── plan/                    # Sidecar for /plan
│   ├── SKILL.md              # Entry point — JIT loader
│   └── references/           # Data templates
│       ├── detail-plan.md    # Detail Plan template
│       └── roadmap.md        # Roadmap template
├── docs/                    # Sidecar for /docs
│   ├── SKILL.md
│   └── references/
│       ├── architecture.md
│       ├── cli.md
│       ├── deployment.md
│       ├── changelog.md
│       └── strategy.md
├── formatting/              # Standalone skill
│   └── SKILL.md
├── para-kit/                # Standalone skill
│   └── SKILL.md
└── para-skill/              # Meta-skill: creates other skills
    └── SKILL.md
```

### Design Principles

1. **Just-In-Time (JIT):** SKILL.md is only read when the workflow needs a template. Example: `/plan create` Step 9 reads `skills/plan/SKILL.md` → SKILL.md routes to `references/detail-plan.md`.
2. **Convention `references/`:** Data files always live in `references/` (not `templates/`). Formalized in v1.7.6.3.
3. **Workflow keeps logic:** Workflow file contains only steps, conditions, routing. No template body.
4. **Agent Index gating:** Skills only load when trigger matches in `.agents/skills.md` (workspace index) or project `.agents/skills.md`.

---

## Current Sidecar Skills

### `/plan` Sidecar

| Before (v1.7.7) | After (v1.7.8) | Reduction |
|:--|:--|:--|
| 714 lines (workflow) | 594 lines (workflow) + ~120 lines (skill references) | -17% workflow size |

- **`references/detail-plan.md`**: Template for detail plans (phases, tasks, architecture, risks, checklist)
- **`references/roadmap.md`**: Template for roadmaps (phase overview, timeline, DoD)
- **Phase Pre-flight Traps (v1.7.11)**: Each Phase header in the template includes a context reload trap → agent must reload rules/skills before executing a new phase

### `/docs` Sidecar

| Before (v1.7.7) | After (v1.7.8) | Reduction |
|:--|:--|:--|
| 577 lines (workflow) | 416 lines (workflow) + ~160 lines (skill references) | -28% workflow size |

- 5 document templates: Architecture, CLI, Deployment, Changelog, Strategy
- Workflow Step 6 selects template by doc type → reads from `references/`

---

## Standalone Skills vs Sidecar Skills

| Criteria | Standalone | Sidecar |
|:--|:--|:--|
| **Purpose** | Provides independent expertise (formatting, schema reference) | Provides data templates for a specific workflow |
| **Trigger** | Agent needs knowledge (e.g. "draw a table") | Specific workflow step needs a template |
| **Examples** | `para-kit`, `formatting`, `para-skill` | `plan`, `docs` |
| **Has `references/`?** | Not required | Always |
| **Workflow relationship** | N/A — multiple workflows can use | 1:1 with parent workflow |

---

## Skill Registration

All skills (standalone + sidecar) must be registered in two places:

1. **`catalog.yml`** — Source of truth for `./para install` / `./para update` sync
2. **`.agents/skills.md`** — Trigger index so the agent knows when to load

---

## Token Budget Impact

| Metric | Value |
|:--|:--|
| Skill index load cost | ~100 tokens (workspace `skills.md`) |
| JIT template load | ~200-400 tokens (only when needed) |
| Compared to embedded | Saves ~300-500 tokens/session when templates are NOT needed |

---

## References

- [Architecture Overview](./overview.md) — Overall architecture
- [Rule Layers](./rule-layers.md) — Two-Tier loading + trigger index
- [Defense-in-Depth](./defense-in-depth.md) — Layered protection
- [Ecosystem](./ecosystem.md) — Cross-project coordination

---

_Last updated: 2026-04-10 (FEAT-70: v1.7.11.1 docs publish)_
