# Kernel Governance

> **Version**: 1.7.4 | **Last reviewed**: 2026-04-03

## Overview

The Kernel is the immutable core of PARA Workspace. It establishes strict rules, directory structure constraints, data format definitions, and contracts between the system and AI agents.

## Core Schemas

Kernel includes JSON schemas at `kernel/schema/` for automated validation:

### 1. `workspace.schema.json`

Defines `.para-workspace.yml` structure: `kernel_version`, `profile` (`dev`), `language`.

### 2. `backlog.schema.json`

Task list format: ID, title, priority, status, completion date.

### 3. `project.schema.json`

Project contract (`project.md`):
- Meta: `goal`, `dod` (Definition of Done).
- Lifecycle: `status`, `deadline`.
- Paths: `active_plan`, `roadmap`, `strategy` (supports `@` cross-project prefix).
- Agent config (v1.6.2+): `agent.rules: true`, `agent.skills: true` — replaces deprecated `has_rules`.
- Ecosystem (v1.6.0+): `type`, `ecosystem`, `satellites`, `downstream`.

### 4. `catalog.schema.json`

Validates `catalog.yml` for governed libraries (workflows, rules, skills).

### 5. `decision-plan.schema.json`

Decision Records format for `artifacts/para-decisions/`.

### 6. `tasks.schema.md`

Markdown spec for the Hybrid 3-File Model: `backlog.md` (Operational Authority), `sprint-current.md` (Hot Lane), `done.md` (Archive with origin tags). See [hybrid-3-file.md](hybrid-3-file.md).

### 7. `ki.schema.json` (v1.7.0+)

Knowledge Items metadata schema:
- 12-column index: name, slug, summary, owner, scope, domain, purpose, concepts, code_refs, related_to, para_version.
- `para_*` namespace guard (System KIs vs User KIs).
- See [knowledge-system.md](knowledge-system.md) and [ki-anatomy.md](ki-anatomy.md).

## Governance Principles

### 1. Invariants (Hard Rules — MUST)

11 rules that ensure workspace structural integrity. Any change requires RFC + MAJOR bump.

| # | Rule |
| :-- | :-- |
| I1 | PARA directory structure is mandatory |
| I2 | Hybrid 3-file task model (backlog = canonical) |
| I3 | kebab-case project naming |
| I6 | Archive is immutable cold storage |
| I8 | No loose files at workspace root |
| I9 | Resources are read-only references |
| I10 | Repo ↔ Workspace separation |

### 2. Heuristics (Soft Rules — SHOULD)

Recommended practices. Changes via MINOR/PATCH bump.

| ID | Rule | Added |
| :-- | :-- | :-- |
| H1 | Semantic file naming | v1.3 |
| H7 | Cross-project ecosystem references | v1.6.0 |
| H10 | Knowledge Items — 11 clauses for KI governance | v1.7.0 |

### 3. Consistency Constraints

1. **Immutable Invariants**: Kernel schemas are read-only for users. Changes go through `repo/`.
2. **Backward Compatibility**: Upgrades use Smart Archive (vault) instead of permanent deletion.
3. **Agent Constraint**: Agent must comply with Kernel structure. Invalid config triggers error.
4. **Proactive Trigger Check** (v1.6.2+): BEFORE any side-effect, agent scans trigger tables (workspace + project rules/skills) to load appropriate rule/skill.

### H10: Knowledge Items (v1.7.0+)

Heuristic enabling cross-session knowledge accumulation:

- KIs are starting points, not ground truth — always verify against active code.
- System KIs (`para_*`) governed by repo templates; User KIs freely created.
- Platform-injected summaries reduce token cost.

---

_Last updated: 2026-04-03 (FEAT-61: v1.7.4)_
