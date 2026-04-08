# Changelog

All notable changes to this project will be documented in this file.
Detailed version changelogs are maintained internally in project docs.

## [1.7.8] - 2026-04-08

Sidecar Skill & Template Optimization.

- **Added**: Sidecar Skill architecture pattern — decouples embedded data templates from workflow logic into just-in-time loaded `skills/{name}/references/` directories.
- **Added**: `plan` Sidecar Skill — Detail Plan & Roadmap templates (plan.md 714→594 lines, -17%).
- **Added**: `docs` Sidecar Skill — Architecture, CLI, Deployment, Changelog, Strategy templates (docs.md 577→416 lines, -28%).
- **Changed**: Zero-padding applied to all markdown tables in `plan.md` (-15%) and `docs.md` (-7%).
- **Changed**: `catalog.yml` — registered `plan` and `docs` Sidecar Skills.

## [1.7.7] - 2026-04-08

Brainstorm Consolidation & Naming Convention.

- **Changed**: `/brainstorm` v1.7.7 — Consolidated `brainstorms/` into `para-decisions/`. Dual Output (small/large). Naming convention `{type}-{YYYY-MM-DD}-{topic}.md`. Option G: `docs/researches/` extraction. 7 exit paths.
- **Changed**: `docs/workflows/brainstorm.md` — updated with v1.7.7 features.
- **Changed**: System KI `para_workspace_architecture_standards` — added brainstorm consolidation concepts, bumped `para_version`.

## [1.7.6] - 2026-04-07

Skill Catalog Architecture & Meta-Project Type.

- **Added**: `meta-project` type in H7 heuristics and `project.schema.json` — projects that produce code AND coordinate satellites.
- **Added**: `/para-skill` workflow promoted to Core — Co-Author engine for creating, validating, and testing AI Agent skills.
- **Added**: `page-map` skill registered in Core skills `catalog.yml`.
- **Changed**: `/open` v1.7.2 — explicit `meta-project` detection (Step 2), git skip condition excludes meta-projects (Step 7).
- **Changed**: `/para-audit` v1.7.1 — satellite validation extended to `meta-project` type, `repo/` existence check.
- **Changed**: OSS `para-skills/skills/catalog.yml` migrated to `items[]` array schema (unified with Core).
- **Changed**: `para-workspace` project type updated to `meta-project` with `satellites: [website-paraworkspace, para-skills]`.
- **Fixed**: `/update` BUG-29 — Agent pre-pull version gate caused false "no update needed". Decision gates now MUST always proceed to dry-run.
- **Changed**: README modernized — 6 ASCII diagrams replaced with Mermaid (flowchart, sequence, block-beta). GitHub-native rendering.
- **Added**: `docs/locales/` i18n structure — vi-VN (full), zh-CN, es-ES, fr-FR (placeholders). OSS-style language selector in all READMEs.
- **Added**: KI template variable substitution — `install.sh` and `update.sh` render `{{KERNEL_VERSION}}`, `{{LANGUAGE}}`, `{{PROFILE}}`, etc. from `.para-workspace.yml` into System KI artifacts. Hash comparison uses rendered output for idempotency.

## [1.7.5] - 2026-04-06

KR7 Ephemeral Ban & `/knowledge` → `/para-knowledge` Rename.

## [1.7.4] - 2026-04-03

Repo Path Standardization, Pending TODO Fix & Project Profile Skill.

## [1.7.3] - 2026-04-02

Agent Path Convention Fix (BUG-28) & Rule Frontmatter.

- **Fixed:** Renamed `.agent/` → `.agents/` across 90+ files to match Antigravity platform convention.
- **Added:** Antigravity-compatible frontmatter to all 12 governed rules (trigger, glob, description).
- **Added:** Auto-migration in `para update` — renames `.agent/` → `.agents/` for workspace + all projects.

## [1.7.2] - 2026-04-02

KI Index Schema Upgrade, Workflow Simplification & Knowledge Graph Seed.

- **Changed**: KI index schema `7` → `12` columns (added Owner, Scope, Domain, Purpose, PARA Ver).
- **Changed**: `/open` Step 2.7 — platform-injected KI context (removed `index.md` read).
- **Changed**: `/end` Step 4.7 — platform-injected KI cross-reference (removed file gate).
- **Changed**: `/plan` Phase E — platform-injected KI matching (removed file gate).
- **Changed**: `/learn` Step 4.5, `/brainstorm` Option F, `/retro` Step 4.5 — removed `index.md` gates.
- **Changed**: Knowledge workflow `1.1.0` → `1.2.0`, 6 workflows → `1.7.1`.
- **Changed**: Available Profiles — removed `marketer` and `ceo` (README, CLI, docs).
- **Changed**: System KI template `code_refs` — 4 → 16 file-level entries (Knowledge Graph seed).
- **Changed**: System KI template `concepts` — 6 → 10 entries (enriched).
- **Changed**: System KI template `para_version` — `1.6.5` → `1.7.2`.

## [1.7.1] - 2026-04-01

System KI Governed Lifecycle — namespace guard, template sync, governed defaults.

- **Added**: `/knowledge system [topic]` — create/update system KIs with version alignment.
- **Added**: `/knowledge system update` — sync system KIs from repo templates (merge-safe).
- **Added**: `/knowledge system defaults` — init all default system KIs from templates.
- **Added**: Namespace guard — reject `para_*` prefix for user KIs (KR3).
- **Added**: KR6 — System KI Governed Lifecycle rule (template source, update sync, merge strategy).
- **Added**: Dashboard split — System KIs vs User KIs sections.
- **Changed**: `/brainstorm` Option F — system KI hint for PARA patterns.
- **Changed**: `/retro` Step 4.5 — system KI hint for cross-project governance.
- **Changed**: `/end` hook — system KI suggestion for para-workspace sessions.
- **Changed**: Knowledge workflow `1.0.0` → `1.1.0`, rule `1.0.0` → `1.1.0`.
- **Added**: `repo/templates/common/docs/README.md` — modular docs scaffold (FEAT-58).
- **Changed**: `scaffold.sh` — auto-creates `docs/` with template on project creation.
- **Fixed**: Antigravity badge link 404 (`blog.google` → `antigravity.google`).

## [1.7.0] - 2026-04-01

Knowledge System — KI schema, `/knowledge` workflow, graph-ready taxonomy.

## [1.6.5] - 2026-03-30

Update Flow Fix — Version Direction Detection & Migration History.

- **Fixed**: `update.sh` version direction detection — shows ⏬ for downgrade, skips migration (BUG-22).
- **Fixed**: `migrate.sh` conditional history logging — only writes when migration steps actually ran (BUG-23).
- **Fixed**: `/update` workflow decision gates — added "Kernel > Repo VERSION" pre-pull warning (BUG-24).
- **Changed**: `update.sh` loads `validator.sh` at startup for `semver_gte` access.

## [1.6.4] - 2026-03-30

Para-Kit Skill v1.1.0, Recursive Sync & Git Hash Detection.

- **Changed**: `para-kit` SKILL.md rewritten as lean structure reference with Quick Reference Card (I1-I11 + H1-H9).
- **Added**: `templates/` and `examples/` colocated inside skill folder for automatic sync.
- **Added**: `sync_directory_recursive()` in `install.sh` — handles arbitrarily nested subdirectories.
- **Fixed**: `update.sh` version comparison — reads from `.para-workspace.yml` only (not `repo/VERSION`).
- **Added**: Git commit hash detection in `update.sh` — accurate for hotfixes without version bumps.
- **Added**: `formatting-tables-diagrams.md` promoted to governed rule with `rules.md` index entry.
- **Changed**: `/backup` workflow — added `skills` backup target.
- **Changed**: `upstream` field added to project.md schema (inverse of `downstream`).

## [1.6.3] - 2026-03-27

Central Gate — project.md as single source of truth for context loading.

- **Added**: `strategy` field in `project.schema.json` — path to strategy doc (supports `@` cross-project prefix).
- **Added**: `roadmap` field in `project.schema.json` — path to roadmap file (supports `@` cross-project prefix).
- **Added**: Path Resolution Convention — shared `@{ecosystem}/` resolution for strategy, roadmap, active_plan.
- **Added**: Completion Gate checklist in `/open` Step 2.6 — prevents skipping project agent indices.
- **Changed**: `/open` Step 2.5 split into 2.5 (workspace) + 2.6 (project) — fixes recurring agent skip bug.
- **Changed**: `/open` Step 2 strategy loading — filesystem probe → field-gated.
- **Changed**: `/open` Step 5.5 roadmap loading — filesystem glob → field-gated.
- **Changed**: `/plan` — sets `roadmap` field in project.md on roadmap creation.
- **Changed**: `/docs` — sets `strategy` field in project.md on strategy creation.
- **Changed**: `/end` Steps 3.2, 4.5 — field-gated change detection.

## [1.6.2] - 2026-03-24

Unified Agent Index — Skills Loading & Proactive Trigger Check (FEAT-53).

- **Added**: `.agents/skills.md` — Workspace Skills Trigger Index template (parallel to `rules.md`).
- **Added**: `agent` map in `project.schema.json` — replaces `has_rules` (deprecated, backward compat kept).
- **Added**: Proactive Trigger Check — agent scans trigger tables before ANY side-effect action.
- **Added**: Agent Indices Pre-flight (Step 0) to 7 workflows: `/plan`, `/docs`, `/backlog`, `/push`, `/release`, `/retro`, `/end`.
- **Changed**: `/open` v1.5.0 — Step 2.5 split into 2.5a (rules), 2.5b (skills), 2.5c (project agent config with backward compat).
- **Changed**: `/plan` v1.5.0 — D3 skills check, agent map compat in D2.
- **Changed**: `/para-audit` v1.3.0 — Agent Index Consistency check (rules + skills), legacy migration detection.
- **Changed**: `context-rules.md` v1.1.0 — §1 skills in priority, §4 Agent Index Loading with proactive check.
- **Changed**: `agent-behavior.md` v1.1.0 — §4 Context Recovery with skills, Proactive Trigger Check clause.
- **Changed**: `install.sh` — syncs `skills.md` alongside `rules.md`.
- **Changed**: README redesigned — logo, TOC, updated Two-Tier diagram with skills, new slogan.

## [1.6.1] - 2026-03-23

Unified Strategy → Plan Flow (FEAT-52).

- **Changed**: `/docs` v1.1.0 — Strategy docs discovery (Step 3.5), Ecosystem project type, Strategy Document template, Doc Index strategy/ support, smart routing from /brainstorm.
- **Changed**: `/plan` v1.4.0 — Plan Type Selection (Roadmap vs Detail Plan, Step 2.8), Strategy/Roadmap context loading (Step 2.9), Brainstorm/Strategy priority (D7, Step 2.5), Roadmap Plan template, Roadmap auto-update (Step 10), Roadmap lifecycle in review (Step 6.5).
- **Changed**: `/end` v1.5.0 — Strategy/Roadmap change detection (Step 3.2), Brainstorm follow-up with next-step suggestions (Step 3.3), Roadmap status sync (Step 4.5).
- **Changed**: `/open` v1.4.0 — Strategy summary loading (Step 2 ext), Pending brainstorms check (Step 3.5), Roadmap context loading (Step 5.5), Strategy cascade detection (D10), expanded report with Strategy/Roadmap/Brainstorm sections, priority-based Suggested Actions.

## [1.6.0] - 2026-03-20

Meta-Project & Ecosystem Support (RFC-0003).

- **Added**: `type` field in `project.schema.json` — `standard` (default) or `ecosystem` (meta-project).
- **Added**: `ecosystem` field — links satellite projects to their parent ecosystem.
- **Added**: `satellites` field — lists satellite project slugs for ecosystem projects.
- **Added**: `@` prefix convention for `active_plan` — cross-project plan references (e.g., `@my-ecosystem/plans/xxx.md`).
- **Added**: Heuristics H7 subsection — Ecosystem Projects conventions (v1.6.0+).
- **Changed**: `/open` v1.3.0 — ecosystem detection (Step 2), @prefix resolution (Step 5), skip git for ecosystem (Step 7).
- **Changed**: `/end` v1.4.0 — @prefix resolution (Step 4), skip git suggestions for ecosystem.
- **Changed**: `/plan` v1.3.0 — cross-project plan activation prompt (Step 10), @prefix in review action.
- **Changed**: `/new-project` v1.1.0 — ecosystem/satellite type option (Step 2), `--meta` flag for direct ecosystem creation.
- **Changed**: `/para-audit` v1.2.0 — ecosystem consistency validation (Step 3).
- **Added**: Project template `.project.yml` — ecosystem fields (commented, opt-in).
- **Added**: RFC-0003 — Meta-Project & Cross-Project Governance (Progressive, v1.6.0 → v2.0.0).
- **Added**: Glossary & Impact Map (`docs/reference/glossary.md`) — graph-ready 5-field structure.
- **Added**: Reference docs `docs/reference/project.md` (EN) — full project schema reference.
- **Added**: Architecture doc `docs/architecture/ecosystem.md` (EN) — ecosystem model, schema, workflows.
- **Added**: Guide `docs/guides/meta-project.md` (EN) — step-by-step ecosystem usage.
- **Added**: Test vectors `examples/projects/project-schema-vectors.md`.

## [1.5.4] - 2026-03-17

Context Recovery & Workflow Pre-flight (FEAT-47: Defense-in-Depth).

- **Added**: `agent-behavior.md` Section 4 — Context Recovery protocol. Agent re-reads `rules.md` when context appears incomplete (truncation, checkpoint, long conversation).
- **Added**: `/open` Safety Block in Step 8 report — compact rules reminder (~40 tokens) that persists across checkpoint summaries.
- **Added**: Rules Pre-flight (Step 0) to 7 workflows: `/push`, `/release`, `/retro`, `/end`, `/plan`, `/docs`, `/backlog`. Re-reads `rules.md` from disk before executing side-effects.
- **Changed**: `rules.md` index — added Priority column (🔴 Critical, 🟡 Important, 🟢 Standard). Reordered rules by priority. Enhanced VCS and Governance trigger descriptions.
- **Changed**: `context-rules.md` — updated Rules Index format example to include Priority column.
- **Added**: `agent-behavior.md` Section 4 File-Level Guards — maps specific file patterns to rules that MUST be re-read before direct edits (bypass protection).
- **Added**: `hybrid-3-file-integrity.md` C6: File Guard Headers — inline `<!-- ⚠️ -->` comments in `done.md` and `sprint-current.md` as last-resort defense against post-truncation violations.
- **Added**: `/new-project` Companion File Templates — `done.md` and `sprint-current.md` templates with guard headers for new projects.
- **Updated**: `docs/reference/project-rules.md`, `docs/architecture/rule-layers.md` — reflect Priority classification, Context Recovery, and Workflow Pre-flight coverage.
- **Expanded**: C6 Guard Headers taxonomy — 4 types: `TASK` (C1-C3), `KERNEL` (I9), `GOVERNED` (rules catalog), `WORKSPACE` (session/sync). Position convention defined.
- **Added**: `READ-ONLY SNAPSHOT` guard headers to 8 kernel files (`repo/kernel/`). Prevents agent modification of canonical kernel.
- **Added**: `GOVERNED` guard headers to 10 rules template files (`repo/templates/.../rules/`). Warns agent that direct edits are overwritten by `para update`.
- **Added**: `OPERATIONAL AUTHORITY` guard to `/new-project` backlog template. New projects auto-get all 3 task file guards.

## [1.5.3] - 2026-03-13

Hot Lane Refactor, `/end` Sync Point & Token Optimization.

- **Changed**: `sprint-current.md` role: "Derived Focus View" → "Agent-writable Hot Lane" for quick tasks.
- **Changed**: `/open` token optimization — reads backlog summary (~10 lines) + hot lane; SYNC gate skips if no dependencies.
- **Changed**: `/end` Step 3.5 — "Working Checkmarks reconcile" → "Hot Lane Sync" with Smart Suggest from session logs.
- **Changed**: `/backlog update` simplified — removed Auto-Sync Engine (77 lines), sync handled by `/end`.
- **Changed**: `/backlog clean` redesigned — compress-not-delete: Done items compressed into `✅ Completed` section (1 line/plan + IDs). Lookup chain: `backlog → done.md → plans/done/`.
- **Changed**: `done.md` template restructured — grouped by plan with links to `plans/done/`, origin tags `#backlog` / `#session`.
- **Changed**: Rule `hybrid-3-file-integrity.md` v2.0.0 — 5 constraints (C1-C5), backlog = compress-not-delete source of truth.
- **Fixed**: `/inbox` BUG-16 — added Project Context Check to prevent duplicate directory creation.

## [1.5.2] - 2026-03-12

Hybrid 3-File Integrity, Working Checkmarks & Docs Overhaul.

- **Added**: Rule `hybrid-3-file-integrity.md` — Working Checkmarks constraints (C1-C4) and reconciliation process.
- **Added**: Reconcile step in `/backlog update` (Step 0) and `/end` (Step 3.5) for Working Checkmarks.
- **Added**: Plan archiving — completed plans auto-move to `artifacts/plans/done/`.
- **Added**: Ask-to-activate flow in `/plan create` (Step 10) with `/backlog sync` suggestion.
- **Changed**: `tasks.schema.md` — Phase grouping for `sprint-current.md`, Working Checkmarks documented.
- **Changed**: Kernel audit — KERNEL.md v1.5.2, +4 schemas, README +I11/+H9.
- **Changed**: Docs restructured into 6 categories (architecture, reference, guides, rfcs, rules, workflows).
- **Changed**: RFC-0001 updated with implementation status, RFC-0002 created (Proposed).
- **Changed**: RFCs flattened — removed `rfcs/accepted/`, status defined in file header.

## [1.5.1] - 2026-03-11

Hybrid 3-File Synchronization & Fast Mode.

- **Added**: Hybrid 3-File Auto-Sync logic to `/backlog update` and new action `/backlog clean`.
- **Changed**: `/open` now prioritizes fast-mode reading from `sprint-current.md` to save tokens.
- **Changed**: `/retro` and `/plan review` refactored to use `done.md` as primary completion data source.
- **Fixed**: Template synchronizations for Profile General (FEAT-25, 34).

## [1.5.0] - 2026-03-05

Safe Workspace Update, Brainstorming & Progressive Rule Disclosure.

- **Added**: `/update` and `/brainstorm` workflows. Progressive Rule disclosure (`.agents/rules.md`).
- **Fixed**: `update.sh` version state read error skipping migrations.
- **Changed**: Workspace version `1.5.0`, updated workflow cross-links (`/open`, `/plan`, `/para-rule`).

## [1.4.10] - 2026-03-04

Documentation Manager (`/docs`) & Workflow Catalog Update.

- **Added**: Official `/docs` workflow (internal-first, Doc Index token optimization, auto repo adaptation).
- **Changed**: Workspace version `1.4.10`, `/docs` added to `catalog.yml`.

## [1.4.9] - 2026-03-04

Centralized Backup & Workspace Cleanup.

- **Added**: `para cleanup` command (FEAT-32) — removes old backups, rollback sessions, legacy `.bak` files. Status cleanup warning.
- **Changed**: `backup_file()` now stores in `.para/backups/<date>/` instead of scattered `.bak` files.

## [1.4.8] - 2026-03-04

Atomic Rollback, Dry-run Pipeline & README Installation Rewrite.

- **Added**: Atomic rollback for `install.sh` (FEAT-30), `--dry-run` for `install` and `update` (FEAT-31), Windows lock guard.
- **Changed**: README Installation rewrite with Platform Compatibility table (FEAT-33), CLI help text, audit logging.

## [1.4.7] - 2026-03-03

macOS Compatibility & Safe Migration Pipeline.

- **Added**: `/backup` project targets, `backup_and_copy()`, version gating in `migrate.sh`.
- **Fixed**: 3 macOS/Bash 3.2 incompatibilities (`sed -i`, `;;&`, `head -n -1`), env var consistency, rule protection.

## [1.4.6] - 2026-03-02

Smart Archive & Version Migration.

- **Added**: `cli/lib/fs.sh` with `archive_file`, Smart Archive rule.
- **Changed**: Integrated Smart Archive into `update.sh` and `migrate.sh`, overhauled migration docs.

## [1.4.5] - 2026-03-02

Safety Guardrails & Progressive Disclosure.

- **Added**: `/para-audit` workflow, Progressive Disclosure model.
- **Changed**: `governance.md` rewritten (ultra-lightweight), `/open` and `/plan` scoping.

## [1.4.4] - 2026-02-27

Token Optimization & PARA Kit Standardization.

- **Changed**: `/open` uses native `view_file`, PARA Kit v1.0.0 updated to v1.4.1+ standards.

## [1.4.3] - 2026-02-26

CLI Fixes & Plan-Aware Workflows.

- **Fixed**: `install.sh` kernel version propagation, nested library copying, workspace config update.
- **Changed**: `/end` v1.2.0 with `[done]` parameter, plan cleanup automation.

## [1.4.2] - 2026-02-26

Plan-Driven Development.

- **Added**: `/plan` workflow, `active_plan` field, `/backlog sync` action.
- **Changed**: `/backlog` v1.1.0, `/open` v1.1.0, `/end` v1.1.0 with plan phase tracking.

## [1.4.1] - 2026-02-24

Governed Libraries & Runtime Safety.

- **Added**: RFC process, governed library catalogs, kernel schemas, CLI libraries (`validator.sh`, `logger.sh`, `rollback.sh`), test suite, GitHub governance, H9.
- **Changed**: All 17 workflows standardized to v1.4.1.

## [1.4.0] - 2026-02-13

⚠️ **Breaking**: Repo ↔ Workspace Separation & Kernel System.

- **Breaking**: Repo purged of user data, `metadata.json` → `.para-workspace.yml`, new CLI paths, task model changed.
- **Added**: Kernel system (10 invariants, 8 heuristics), profile system, CLI rewrite, documentation suite.

## [1.3.6] - 2026-02-11

Cross-Project Sync Queue.

## [1.3.5] - 2026-02-11

Backup & Backlog Workflows.

## [1.3.4] - 2026-02-09

Full Catalog Install & Safety.

## [1.3.3] - 2026-02-06

Smart Installer & Rule Management.

## [1.3.1] - 2026-02-05

Artifact Mirroring & Workflow Prefix.

## [1.3.0] - 2026-02-05

Project Contracts & Smart Governance.

## [1.2.0] - 2026-02-05

Artifact-Driven Workflow.

## [1.1.0] - 2026-02-04

CLI Foundation.

