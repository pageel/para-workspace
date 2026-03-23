# Glossary & Impact Map

> **Version:** 1.6.1 | **Last updated:** 2026-03-23
> **Purpose:** Glossary of terms, variables, and fields used in PARA Workspace.
> Each entry = 5 uniform fields (graph-ready design).

---

## active_plan

- **Definition:** Path to the currently active implementation plan. Supports local paths and `@{ecosystem}/` cross-project prefix.
- **Where defined:** `kernel/schema/project.schema.json` (type: string|null)
- **Where used:**
  - `/open` (Step 5) — read plan summary
  - `/open` (Step 5.5) — roadmap context (v1.6.1)
  - `/end` (Step 4) — check plan progress
  - `/end` (Step 4.5) — roadmap status sync (v1.6.1)
  - `/plan` (create Step 2.8, Step 10, review Step 1, Step 6.5) — activate/read/lifecycle plan
  - `/para-audit` (update Step 3) — validate field exists
- **Impact if changed:** 4 workflows. If `@` prefix syntax changes → update resolution logic in 4 places.
- **Note:** Only points to detail plans, never roadmap. Roadmap is reference context (v1.6.1).
- **Related:** `ecosystem`, `type`, `satellites`, `roadmap`, `detail_plan`

## type

- **Definition:** Project type. `standard` = regular project, `ecosystem` = meta-project that coordinates satellites.
- **Where defined:** `kernel/schema/project.schema.json` (enum: standard|ecosystem, default: standard)
- **Where used:**
  - `/open` (Step 2) — ecosystem detection
  - `/open` (Step 7) — skip git for ecosystem
  - `/end` (Step 3.5) — skip git suggestions
  - `/new-project` (Step 2) — prompt project type
  - `/para-audit` (update Step 3) — validate consistency
- **Impact if changed:** 5 workflows. If new enum value added → update 5 places.
- **Related:** `ecosystem`, `satellites`

## ecosystem

- **Definition:** Parent ecosystem name (meta-project slug). Set on satellite projects.
- **Where defined:** `kernel/schema/project.schema.json` (type: string|null, pattern: kebab-case)
- **Where used:**
  - `/open` (Step 2) — note parent ecosystem
  - `/open` (Step 5) — resolve `@` prefix
  - `/para-audit` (update Step 3) — cross-reference with satellites list
  - `/new-project` (Step 2) — prompt ecosystem name
- **Impact if changed:** 4 workflows. If naming convention changes → rename all satellite project.md.
- **Related:** `type`, `satellites`, `active_plan`

## satellites

- **Definition:** List of satellite project slugs. Only valid when `type: ecosystem`.
- **Where defined:** `kernel/schema/project.schema.json` (type: array|null, items: kebab-case)
- **Where used:**
  - `/open` (Step 2, Step 8) — display satellite list in report
  - `/para-audit` (update Step 3) — cross-reference with satellite ecosystem fields
- **Impact if changed:** 2 workflows. Low impact — display + validation only.
- **Related:** `type`, `ecosystem`

## profile

- **Definition:** Profile preset used during workspace init. Determines departments/capabilities.
- **Where defined:** `kernel/schema/workspace.schema.json` + `project.schema.json` (enum: dev|general|marketer|ceo)
- **Where used:**
  - `para init` CLI — select profile
  - `para scaffold` CLI — set in .project.yml
  - Profile presets (`templates/profiles/*/preset.yaml`) — directory structure
  - `/new-project` (Step 2) — inherit from workspace
- **Impact if changed:** Schema (2 files), CLI (2 commands), templates (4 presets), workflows (1). Very high.
- **Related:** `kernel_version`

## kernel_version

- **Definition:** Kernel version at time of init/update. SemVer format.
- **Where defined:** `kernel/schema/workspace.schema.json` + `project.schema.json` (type: string, pattern: semver)
- **Where used:**
  - `.para-workspace.yml` — workspace level
  - `project.md` — project level
  - `para update` CLI — compat check
  - `para migrate` CLI — version diff
  - Catalog `catalog.yml` — kernel_min/kernel_max constraints
  - `/para-audit` (update Step 1) — detect version change
- **Impact if changed:** Schema (2), CLI (2), catalog (all workflow entries), audit (1). Very high.
- **Related:** `profile`

## has_rules

- **Definition:** Boolean indicating project has custom rules in `.agent/rules.md`.
- **Where defined:** `kernel/schema/project.schema.json` (type: boolean, default: false)
- **Where used:**
  - `/open` (Step 2.5b) — gate rules loading (skip if false)
  - `/plan` (Step 2.7 D2) — load project rules constraints
  - `/para-audit` (update Step 5) — verify consistency with disk
- **Impact if changed:** 3 workflows. Low impact.
- **Note:** Planned deprecation in v1.6.2 → `agent` map. See FEAT-53.
- **Related:** —

## strategy

- **Definition:** `docs/strategy/` folder containing strategic documents (vision, decisions, product streams). Filesystem-detected, no schema field required.
- **Where defined:** Convention — no schema (v1.6.1). Detected by `docs/strategy/` directory existence.
- **Where used:**
  - `/docs` (Step 3.5) — strategy docs discovery + suggest creation
  - `/plan` (Step 2.5) — brainstorm/strategy priority (D7, skip brainstorm if strategy newer)
  - `/plan` (Step 2.9) — strategy context loading for detail plans
  - `/open` (Step 2 ext) — strategy summary loading (~30 tokens)
  - `/open` (Step 5.5) — strategy cascade detection (D10)
  - `/end` (Step 3.2) — strategy change detection → SYNC entries
- **Impact if changed:** 4 workflows. If folder path changes → update all glob patterns.
- **Related:** `roadmap`, `detail_plan`, `active_plan`

## roadmap

- **Definition:** `plans/*-roadmap.md` — living index of detail plans organized by phases. Never archived, never set as `active_plan`. Naming convention detected via glob.
- **Where defined:** Convention — `[scope]-roadmap.md` naming pattern (v1.6.1). No schema field.
- **Where used:**
  - `/plan` (Step 2.8) — plan type selection (detect existing roadmap)
  - `/plan` (Step 2.9) — extract target phase for detail plan scope
  - `/plan` (Step 10) — auto-update roadmap when detail plan activated
  - `/plan` (review Step 6.5) — roadmap lifecycle (mark done, suggest next phase)
  - `/open` (Step 5.5) — roadmap context loading (phase overview)
  - `/end` (Step 3.2) — roadmap change detection
  - `/end` (Step 4.5) — roadmap status sync
- **Impact if changed:** 3 workflows. If naming convention changes → update all glob patterns.
- **Related:** `strategy`, `detail_plan`, `active_plan`

## detail_plan

- **Definition:** `plans/*.md` (non-roadmap) — task-level implementation plan for a single version or feature. IS `active_plan`. Archived to `plans/done/` when complete.
- **Where defined:** Convention — any `plans/*.md` excluding `*-roadmap.md` (v1.6.1).
- **Where used:**
  - `/plan` (Step 2.8) — plan type selection (count active detail plans)
  - `/plan` (Step 9-10) — save + activate as `active_plan`
  - `/plan` (review Step 6) — archive to `plans/done/`
  - All workflows via `active_plan` field
- **Impact if changed:** Indirectly via `active_plan`. Low standalone impact.
- **Related:** `roadmap`, `strategy`, `active_plan`

---

## Impact Summary

| Term             | Workflows | Files        | Impact      |
|:-----------------|:----------|:-------------|:------------|
| `active_plan`    | 4         | 1 schema     | 🔴 High     |
| `type`           | 5         | 1 schema     | 🟡 Medium   |
| `ecosystem`      | 4         | 1 schema     | 🟡 Medium   |
| `satellites`     | 2         | 1 schema     | 🟢 Low      |
| `profile`        | 1+CLI     | 2 schemas    | 🔴 High     |
| `kernel_version` | 1+CLI     | 2 schemas    | 🔴 High     |
| `has_rules`      | 3         | 1 schema     | 🟢 Low      |
| `strategy`       | 4         | convention   | 🟡 Medium   |
| `roadmap`        | 3         | convention   | 🟡 Medium   |
| `detail_plan`    | 4 (via AP)| convention   | 🟢 Low      |

> Glossary will grow with v1.6.2 (agent map), v1.7.0 (department, tier), and v1.8.0 (provenance, trust).
