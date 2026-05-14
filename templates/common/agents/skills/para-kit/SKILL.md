---
name: PARA Kit
description: PARA workspace structure reference — schema, layout, kernel governance, and intelligence routing.
source: catalog
---

# Skill: PARA Kit

> PARA structure reference for AI agents. Use this skill when you need to understand
> workspace layout, project.md schema, or kernel governance rules.

## 1. PARA Workspace Structure

### Four Pillars

```text
Projects/    — Active work with deadlines or deliverables
Areas/       — Stable knowledge, SOPs, ongoing responsibilities
Resources/   — Reference materials, tools, templates (READ-ONLY for ai-agents/)
Archive/     — Cold storage for completed/cancelled items (never read during normal ops)
```

### Standard Project Layout

```text
<project-slug>/           # kebab-case (I3)
├── project.md            # YAML frontmatter contract (see §2)
├── repo/                 # Source code (git-tracked)
├── sessions/             # Daily session logs (YYYY-MM-DD.md)
├── artifacts/
│   ├── tasks/
│   │   ├── backlog.md    # CANONICAL task store (I2)
│   │   ├── sprint-current.md  # Hot Lane (quick tasks)
│   │   └── done.md       # Completed tasks archive (append-only)
│   ├── plans/            # Implementation plans
│   └── para-decisions/   # Decision records
├── docs/                 # Internal documentation
├── .agents/               # Project-specific rules/skills
│   ├── rules.md          # Rules index (trigger table)
│   └── rules/            # Rule files (loaded on-demand)
└── .beads/
    └── seeds.md          # Ideas, hypotheses, raw notes (I7)
```

### Ecosystem Projects (v1.6.0+)

| Type | Purpose | Has repo/ | Has satellites |
| :-- | :-- | :-- | :-- |
| `standard` | Regular project (default) | Yes | No |
| `ecosystem` | Coordinates satellites | No | Yes |

Cross-project plan reference: `active_plan: "@ecosystem-slug/plans/shared-plan.md"`

## 2. project.md Schema (v1.6.3)

All fields in YAML frontmatter:

| Field | Type | Required | Default | Description |
| :-- | :-- | :-- | :-- | :-- |
| `goal` | string | ✅ | — | Project objective |
| `deadline` | date | ❌ | — | Target date (YYYY-MM-DD) |
| `status` | enum | ✅ | `active` | active / paused / done / archived |
| `version` | semver | ❌ | — | Current project version |
| `strategy` | string/~ | ✅ | `~` | Current strategic approach |
| `roadmap` | path | ✅ | — | Relative path to roadmap plan |
| `active_plan` | string | ❌ | `""` | Current implementation plan path |
| `agent.rules` | bool | ✅ | `false` | Has project-specific rules? |
| `agent.skills` | bool | ✅ | `false` | Has project-specific skills? |
| `type` | enum | ❌ | `standard` | standard / ecosystem |
| `ecosystem` | string | ❌ | — | Parent ecosystem slug (satellite) |
| `satellites` | list | ❌ | — | Child project slugs (ecosystem) |
| `upstream` | list | ❌ | — | Projects this project depends on |
| `downstream` | list | ❌ | — | Dependent project slugs |
| `dod` | list | ❌ | — | Definition of Done criteria |
| `milestones` | list | ❌ | — | Feature-first milestone tracking |
| `tags` | list | ❌ | — | Classification tags |
| `last_reviewed` | date | ❌ | — | Last project review date |

→ Full template: [templates/project-md.md](templates/project-md.md)
→ Test vectors: [examples/project-schema-vectors.md](examples/project-schema-vectors.md)

## 3. Quick Reference Card — Kernel Governance

> ⚠️ One-liner summary. Full detail → `Resources/ai-agents/kernel/invariants.md`, `heuristics.md`

### Invariants (MUST — vi phạm = MAJOR bump)

| ID | Name | Key Constraint |
| :-- | :-- | :-- |
| I1 | PARA Directory Structure | Only 4 top-level dirs (PascalCase) |
| I2 | Hybrid 3-File Model | backlog.md = authority, sprint = hot lane |
| I3 | Project Naming | kebab-case only |
| I4 | Project Inactivity | No active tasks = inactive, archive = manual |
| I5 | Areas No Runtime Tasks | Areas/ = stable knowledge, not active work |
| I6 | Archive Is Cold Storage | Immutable, never read during normal ops |
| I7 | Seeds Are Raw Ideas | .beads/ = ideas, NOT tasks |
| I8 | No Loose Files | Every file belongs to P/A/R/Archive |
| I9 | Resource Immutability | Resources/ai-agents/ = READ-ONLY |
| I10 | Repo-Workspace Separation | Repo has no user data, workspace has snapshot |
| I11 | Workflow Language Compliance | Output in preferences.language from .para-workspace.yml |

### Heuristics (SHOULD — vi phạm = MINOR/PATCH)

| ID | Name | Key Guidance |
| :-- | :-- | :-- |
| H1 | Naming Conventions | kebab-case files, PascalCase components |
| H2 | Context Loading Priority | project.md → rules → artifacts → areas |
| H3 | Versioning | PATCH auto, MINOR/MAJOR ask user |
| H4 | Project Structure | Standard layout: repo/, sessions/, artifacts/ |
| H5 | Beads Lifecycle | Create → messy → graduate at /retro |
| H6 | VCS & Git Boundaries | Git only in repo/, not workspace root |
| H7 | Cross-Project References | Full relative paths, prefer Resources/ |
| H8 | Workflow Compatibility | Declare kernel_compat in catalog.yml |
| H9 | Governed Library Catalogs | VERSIONS.yml is single source of truth for versions |

## 4. Selection Strategy

### Use CLI (`./para <cmd>`) when:
- Deterministic operations: `install`, `update`, `status`, `archive`
- System maintenance: `cleanup`, `migrate`
- Scripted automation or CI/CD pipelines

### Use Workflows (`/<cmd>`) when:
- Collaboration & analysis: `/brainstorm`, `/plan`, `/retro`
- Agent-driven: `/open`, `/end`, `/backlog`, `/push`
- Multi-step reasoning: `/para-audit`, `/verify`, `/release`

## 5. On-demand References

| File | Content |
| :-- | :-- |
| `templates/project-md.md` | Full project.md template with all v1.6.3 fields |
| `examples/project-schema-vectors.md` | Test vectors for schema validation |

> **Rules** (formatting, versioning, governance) → `.agents/rules/` (loaded via trigger from `.agents/rules.md`)
> **Full kernel** → `Resources/ai-agents/kernel/` (read only during `/para-audit`, `/plan`, or scaffolding)
