# Changelog

All notable changes to this project will be documented in this file.
Detailed version changelogs are maintained internally in project docs.

## [1.8.14] - 2026-05-26

MCP Windows Path Conversion & Plan Auto-Activation.

- **Fixed**: Convert absolute POSIX path of `RUNTIME_CMD` (Node.exe) to Windows mixed path via `cygpath -m` on Windows in `cli/commands/mcp-setup.sh`, preventing path execution errors (BUG-37).
- **Fixed**: Integrated defensive check to append `.exe` to `RUNTIME_CMD` if the exact resolved path does not exist but the `.exe` file does.
- **Changed**: Updated `plan` workflow template (`templates/common/agents/workflows/plan.md`) to automatically activate the plan when executing `/plan dev`, removing the manual Y/N prompt, and improved plan templates `Suggested Next Steps`.
- **Changed**: Synced version to 1.8.14 in `cli/para`, `project.md`, `README.md`, and language locales (vi-VN, zh-CN, fr-FR, es-ES).
- **Changed**: Updated System KI template `para_workspace_architecture_standards` metadata and version history to version 1.8.14.

## [1.8.13] - 2026-05-26

Node Path Resolution for NVM/fnm/Volta & Plan Template Next Steps.

- **Added**: Node Path Resolution script (`cli/lib/node-resolver.sh`) to automatically resolve Node from NVM, fnm, Volta, or custom `preferences.node_path` (BUG-10).
- **Changed**: Updated `tool-wrapper.sh.tmpl` template to source the node resolver before runtime checks.
- **Changed**: Updated plan templates (`detail-plan*.md`) to direct agents to run `/plan dev` or `/vibecode loop` at the `Suggested Next Steps` section.
- **Changed**: Updated `workspace.schema.json`, `init.sh`, `migrate.sh` and `/update` workflow to support `preferences.node_path` configuration.
- **Changed**: Updated `install.sh` to automatically detect the active Node directory and populate `preferences.node_path` in `.para-workspace.yml` if it is currently empty.
- **Changed**: Bumped `registry/tools.yml` graph latest to `0.15.8`.
- **Changed**: Updated System KI template `para_workspace_architecture_standards` to define `implementation plan` and `tasks` authority, strictly directing agents to follow workspace plan/task definitions rather than ephemeral IDE brain files.
- **Changed**: Updated `artifact-standard` rule template with Artifact Authority & Platform Separation standards.


## [1.8.12] - 2026-05-26

MCP Config Migration for Antigravity IDE 2.x & TDD Hardening.

- **Added**: Resolve multiple config paths for `antigravity` (space-separated paths for both IDE 2.x and v1.x) in `cli/lib/mcp-config.sh`.
- **Added**: Smart detection of installed IDEs in `detect_installed_ides` by checking actual IDE App Data folder existence.
- **Added**: Multi-write support in `cli/commands/mcp-setup.sh` by iterating over `CONFIG_PATHS` to merge and backup configs independently.
- **Added**: Smart filtering in `mcp-setup.sh` to only write config files if their corresponding App Data folders exist, preventing dirty directory generation.
- **Added**: Strict TDD unit tests in `tests/cli/test-mcp-config.sh` verifying path resolution, detection, and smart filtering behaviors.
- **Changed**: Synced version to 1.8.12 in `cli/para`, `project.md`, `README.md`, and all 4 language locales (vi-VN, es-ES, fr-FR, zh-CN).
- **Changed**: Updated System KI templates (`para_workspace_architecture_standards`) metadata and history to version 1.8.12.

## [1.8.11] - 2026-05-25

Release Patch & Synchronization (Staging, Vibecode, Scan-Sec, Resource).

- **Added**: Taught `install-tool` dirty-check template logic to avoid bulk overwriting custom workflows/skills, prompting user for Overwrite/Keep/Dry-run/Abort.
- **Added**: Automated test suite `tests/cli/test-install-tool-dirty-check.sh` verifying overwrite logic.
- **Added**: Integrated 4 new workflows (`/staging`, `/vibecode`, `/scan-sec`, `/resource`) and corresponding skills into Core catalog.
- **Changed**: Synchronized all 4 locales (vi-VN, zh-CN, fr-FR, es-ES) to reflect the new counts of **32 workflows**, **14 rules**, and **21 skills**.
- **Changed**: Replaced external `vbsec` branding with OWASP Top 10 references in security scanner reports, templates, and locales.
- **Changed**: Documented all third-party dependencies (jq, Git, Node.js, marked, mermaid, force-graph, lucide, Google Fonts) in README.md and all locale docs.
- **Fixed**: Fixed title match query and quarantine output expectations in `tests/workflows/test-quarantine.sh` to align with the actual `plan.md` template logic.

## [1.8.10] - 2026-05-22

Release Hardening, HTML Renderer Integration & Governance Catalog updates.

- **Added**: `--render` flag to `/docs` workflow, supporting automatic HTML compilation and watch server startup. Outlined requirements to output absolute clickable `file://` link to README.html.
- **Added**: `html-renderer` skill v1.0.0 — Modular HTML rendering engine for compiling docs, supporting full-text search (Ctrl+K), deep linking, and interactive minimalist interface.
- **Added**: Support for default implicit output directory (`[source_folder]/.html`) in docs compiler script, simplifying command-line usage.
- **Added**: Registered new governance rules (`agent-persona`, `tool-routing`, `graph-first-policy`) and skill (`new-project`) in the governance catalog.
- **Added**: Custom Instructions Cascade to `agent-persona` rule, mandating agents check for and load project-specific `AGENTS.md` upon starting/resuming work.
- **Added**: Project-specific `AGENTS.md` loader within Step 1 (Context Gathering) of the `/brainstorm` workflow.
- **Changed**: Updated Architecture & Governance Standards KI (`para_workspace_architecture_standards`) to reflect 14 rules, 16 skills, and version history.
- **Changed**: Migrated `html-renderer` from FontAwesome to Lucide Icons under ISC license for OSS/MIT compliance.
- **Changed**: Renamed all Notion trademark references in HTML templates and CSS class names (`notion-callout` → `clean-callout`) to prevent license and trademark concerns.
- **Changed**: Integrated System KI upgrade sync logic directly into `install.sh` with recursive subdirectory support, and removed redundant code from `update.sh` to ensure automatic KI updates on version bump.
- **Changed**: Shortened separator lines across all workflow templates (28 characters) for cleaner reporting.


## [1.8.9] - 2026-05-18

Ecosystem-wide Para-Graph MCP Integration & Memory Operations.

- **Added**: Ecosystem-wide Para-Graph MCP Integration with Project Sidecar Skill loading.
- **Added**: Memory Operations lifecycle (search/push/curate) and consolidated context pre-flight across 11 catalog workflows (brainstorm, plan, spec, docs, end, open, qa, retro, verify, logs, learn).


## [1.8.8] - 2026-05-14

TDD Governance Hygiene, QA Red Team Upgrade & Technical Debt Purge.

- **Added**: `--gate` flag in `tdd-test.sh` for automated RED/GREEN cycle verification without manual log reading.
- **Added**: Automated Quarantine Hook in `/plan`, `/para-audit`, and `/end` workflows to move test artifacts to `artifacts/tests/tmp/*.bak`, preventing sandbox trash buildup.
- **Changed**: TDD Evidence Sandbox moved from `.beads/tdd-evidence.log` to `artifacts/tests/tdd-evidence.log`.
- **Changed**: QA Skill updated to force Red Team personas (Architect/Tech Lead) to suggest `@[/brainstorm]` for `🔴 Critical` bugs.
- **Changed**: `detail-plan.md` and `qa.md` templates upgraded with Graph Context (`Graph Impact`) for better Phase-Loop precision.
- **Fixed**: Technical Debt Purge — Removed legacy `catalog.yml` version references from `/para-workflow`, `/para-skill`, `/para-rule`, and `para-kit` in favor of `VERSIONS.yml` single source of truth.

## [1.8.7] - 2026-05-12

TDD Governance Workflow.

- **Added**: "Graph Knowledge Preparation" phase 0 to all detail-plan templates.
- **Changed**: Standardized all skill directory names to `kebab-case`.
- **Added**: TDD compliance telemetry logging in workspace release pipeline.
- **Changed**: Enforced mandatory `view_file` for log audits.
- **Added**: Section 17 "Temporary Test Scripts Policy" added to `maintenance.md`.

## [1.8.6] - 2026-05-08

QA Governance Workflow & Sidecar Skill Integration.

- **Added**: `/qa` workflow for Systematic Red Team Q&A loop.
- **Added**: `qa/SKILL.md` sidecar data with Red Team personas.
- **Added**: `--graph` flag for `/docs` workflow — Graph Intelligence pipeline before documentation generation.
- **Added**: `--project` flag for `/plan` workflow — default for `create`, loads project-level rules/skills context before planning.
- **Changed**: `/brainstorm` and `/plan` workflows updated with Graph Intelligence (`--graph`).
- **Changed**: `/plan` Step 1.5 — project rules/skills loading promoted from Step 2.7D to first-class concern.
- **Changed**: System KI Templates and documentation updated to reflect `/qa` workflow.

## [1.8.5] - 2026-05-05

Hybrid Hook Architecture — Decoupled Tool Lifecycle.

- **Added**: `--sync` flag for `install-tool` — fetch latest intelligence from GitHub without tarball download.
- **Added**: Hook detection (`install-hooks.sh`) — tools ship `pre_install()`/`post_install()` hooks for decoupled lifecycle management.
- **Added**: `semver_gte()` — POSIX-compatible semver comparison utility for version guards.
- **Changed**: `tool.schema.json` — additive fields `shipped_in` and `min_engine_version` for Engine-Aligned Versioning.
- **Fixed**: BUG-34 — `update.sh` consumer mode uses `git fetch + reset --hard` instead of `git pull` to avoid Windows NTFS file lock. Graceful fallback if reset fails.
- **Fixed**: `install-tool` JSON Parsing — Fixed a bug where `--sync` failed to detect nested tool template directories due to `grep` limitations. Replaced with robust `awk` parsing for GitHub API responses.
- **Changed**: `update.sh` Windows detection — POSIX `case` statement replaces `[[ ]]`.
- **Changed**: `registry/tools.yml` — `para-graph` latest bumped to `0.8.6`.

## [1.8.4] - 2026-05-04

Plan Template Governance Checklist + Para-Graph v0.8.5 Registry Sync.

- **Added**: `#### Project Governance Checklist` in plan templates — Agent auto-generates review items from project rules/skills indices at plan creation time.
- **Changed**: `/plan` workflow v1.7.11 — Tier-2 Proactive Trigger in Step 0 forces project-specific index loading.
- **Changed**: Plan templates — English-First fix for Commit Consolidation Policy and Suggested Next Steps.
- **Changed**: `registry/tools.yml` — `para-graph` latest bumped to `0.8.5` (Universal Para-Injector + `--version` flag).

## [1.8.3] - 2026-05-04

Graph Router Sync — Sidecar skills updated for para-graph v0.8.4 Centralized Router.

- **Changed**: `plan`, `docs`, `brainstorm`, `spec` sidecar skills now reference centralized `para-graph §3.3.x` instead of inline graph logic.
- **Added**: `plan/references/detail-plan-docs.md` template with `§3.3.2` pipeline for graph-enhanced doc generation.
- **Added**: `para-graph` trigger entry in `skills.md` index for on-demand loading.
- **Changed**: `registry/tools.yml` updated `para-graph` to v0.8.4.

## [1.8.2] - 2026-04-28

MCP Auto-Setup System (Option 5: Manifest-Declared MCP Config).

- **Added**: `mcp-setup` command — configures MCP server for IDE based on `mcp:` block in `tool.manifest.yml`. Supports Antigravity, Claude, Cursor.
- **Added**: `mcp-list` command — discovers tools with MCP capabilities across Dev and Prod paths.
- **Added**: `mcp-remove` command — cleanly removes an MCP server from IDE configuration.
- **Added**: `cli/lib/mcp-config.sh` — shared library for JSON atomic merging via `jq` with gracefull fallback to printed snippet.
- **Added**: `install-tool --no-mcp` flag to selectively bypass auto-setup.
- **Changed**: `install-tool` now automatically detects and invokes `mcp-setup` post-installation.
- **Changed**: System KI `para_workspace_architecture_standards` updated with `mcp auto-setup` concepts and references.
- **Changed**: `para-graph` tool plugin updated with `mcp:` block in its manifest for auto-discovery.

## [1.8.1] - 2026-04-28

Tool Intelligence Installer.

- **Added**: `install-tool` `--agents` and `--no-agents` flags for selective intelligence installation.
- **Added**: `remove-tool` agents cleanup, detecting and offering removal of bundled intelligence.
- **Added**: `tool.schema.json` extended with `agents` property for schema validation.
- **Added**: Tool Intelligence Installer parses `agents:` block via state-machine (bash-only, no `yq`).
- **Changed**: System KI template `para_workspace_architecture_standards` updated with `para_version` 1.8.1, Tool Intelligence Installer section, and metadata concepts.
- **Changed**: Detail Plan template updated with Execution Ownership icons and Graph-First conditional step.

## [1.8.0] - 2026-04-26

Dynamic Tool System & para-graph integration.

- **Added**: `install-tool`, `remove-tool`, and `list-tools` commands.
- **Added**: Plugin ecosystem support with language-agnostic wrappers.
- **Added**: Zero Global Dependencies architecture with `.para/tools/` isolation.

## [1.7.16] - 2026-04-24

Harness Guard Enforcement Overhaul — Dual-Format guards, Checkpoint items, Spec workflow.

- **Added**: C7 rule (`hybrid-3-file-integrity.md`) — Plan Status Transition is USER-ONLY. Prevents agent from changing plan Status or clearing `active_plan` without explicit user approval (BUG-33).
- **Added**: Proactive Guard Scan (`agent-behavior.md` §4) — Agent MUST scan Phase section for `MANDATORY`, `CHECKPOINT`, and `HARNESS GUARD` patterns before executing task items.
- **Added**: File Guards for `artifacts/plans/*.md` (Status field) and `project.md` (active_plan field) — linked to C7.
- **Added**: `CHECKPOINT` guard type (`guard-catalog.md`) — visible inline task items that break momentum bias before git/status operations.
- **Added**: Dual-Format Convention (`guard-catalog.md`) — every guard exists as both HTML comment and visible `> ⛔` blockquote.
- **Added**: Commit Consolidation Policy Convention — rules for when commit merging is allowed.
- **Added**: `/spec` workflow and `spec-driven-development` Sidecar Skill — write structured specifications before coding (FEAT-82).
- **Changed**: `detail-plan.md` template — Dual-Format visible blockquotes, CHECKPOINT task items, Commit Consolidation Policy section.
- **Changed**: `decision.md` template — upgraded from Summary-only to Linear Text format with per-option Concept/Pros/Cons/Deep Dive analysis (FEAT-83).
- **Fixed**: `/end` workflow §4.7 — removed auto-suggest "Create KI?" for new insights; retained update-existing-KI flow (FEAT-71).

## [1.7.15] - 2026-04-17

Harness Skill, Plan Status Gate & Roadmap Prefix Convention.

- **Added**: `harness` Sidecar Skill (`skills/harness/`) — centralized guard catalog (6 guard types) and auto-scan protocol for generating context-aware safety guards across plans, workflows, and artifacts.
- **Added**: Plan Status Gate (`📝 Draft` → `🔨 Active` lifecycle) — agent execution blocked until user explicitly activates a plan. Injected into `detail-plan.md` template and `/plan` workflow.
- **Added**: `email` content type template for `/write` workflow — professional communication template with 6 categories (outreach, proposal, follow-up, announcement, inquiry, thank-you).
- **Changed**: Roadmap naming convention — prefix-based `roadmap-[scope].md` replaces `[scope]-roadmap.md` for OSSS compliance (FEAT-76).
- **Changed**: `detail-plan.md` template — Status Gate header, Phase-specific push logic, and Harness Guard integration.
- **Changed**: Guard taxonomy expanded from 4 types to 6: `STATUS GATE`, `MANDATORY`, `HARNESS GUARD`, `FILE GUARD`, `WORKFLOW GATE`, `CONTEXT RECOVERY`.
- **Changed**: `skills.md` index — added Harness Guards trigger entry.
- **Changed**: `catalog.yml` — registered `harness` skill (kernel_min: 1.7.15), updated `write` description to include `email`.
- **Changed**: Strategy reference (`docs/references/strategy.md`) — roadmap link pattern updated to match new naming convention.
- **Changed**: README and all 4 locales (vi-VN, zh-CN, es-ES, fr-FR) updated — version badge, skill count (8→9), roadmap entry, guard type count.
- **Fixed**: FEAT-78 — `/logs deep` command granularity: `🛠️ Tools Invoked` now splits `run_command` into individual rows with exact `CommandLine`, preventing traceability loss from grouping.
- **Fixed**: FEAT-73 (partial) — `/logs` Token Budget Estimate: added `💰 Token Budget` section counting platform-injected KI tokens (~200-800/KI) that were previously invisible in estimates.

## [1.7.14] - 2026-04-13

Content Authoring Ecosystem & Session Telemetry.

- **Added**: `/write` workflow — structured content authoring (ebook, paper, tutorial, blog, social) with Sidecar Skill for just-in-time template loading.
- **Added**: `write` Sidecar Skill (`skills/write/`) — 5 content type templates, writing rules, and quality checklist loaded on-demand.
- **Added**: `/logs` workflow — session telemetry diagnostics with Fast Glance (memory-based) and Structured Audit (`--deep`) modes. Scope filtering: `--all`, `--last`, `--workflow`.
- **Fixed**: BUG-32 — `/para-workflow add` template defaulted `source: catalog` instead of `source: user`. User-created workflows now correctly tagged.
- **Fixed**: `/write` boundary violation — path references corrected from `docs/` to `writings/`.
- **Added**: `quality-checklist.md` — missing quality gate for `/write review` action.

## [1.7.13.2] - 2026-04-13

Anti-Token-Decay Guardrails & Git Consent Protection.

- **Added**: `SafeToAutoRun: false` requirement in `vcs.md` rule. All auto-generated Git commmit/push commands must explicitly trigger the IDE graphical consent loop. LLM auto-commit bypassing is now physically blocked.
- **Added**: "Staged Drill-down Gate" (`🛑 STOP HERE`) inside `detail-plan.md` Checklist. The Agent is forced to ask the User to verify all checklist items before advancing to the final Git stage.
- **Added**: "Phase Pre-flight HTML Locks" (`<!-- ⚠️ DO NOT MODIFY THIS BLOCK -->`) inside `detail-plan.md`. These un-editable tags force the Agent to deterministically reload Rule + Skill indices prior to every Phase execution.
- **Changed**: System KI Governance Metadata (`para_workspace_architecture_standards`) updated with `Anti-Token-Decay Guardrails` concepts. Workspace version bumped to `1.7.13.2`.

## [1.7.13] - 2026-04-13

VERSIONS.yml Migration & Anti-Bulk-Overwrite Convention.

- **Added**: `VERSIONS.yml` at repo root — centralized single source of truth for governed library item versions. Replaces per-item `version` field in catalogs.
- **Added**: `preferences.date_format` field in `.para-workspace.yml` — configurable content display date format (default: `YYYY-MM-DD`). Filenames always use ISO 8601.
- **Added**: Date format convention in `naming.md` §6 — filenames MUST use `YYYY-MM-DD`, content display SHOULD read `preferences.date_format`.
- **Added**: `/config` workflow — `show` displays `preferences.date_format`, `update` suggests common format options.
- **Changed**: `catalog.schema.json` — `version` field no longer required in items (deprecated, kept for backward compatibility).
- **Changed**: `heuristics.md` H9 — `version` field marked optional with `VERSIONS.yml` reference.
- **Changed**: `versioning.md` §5 — references `VERSIONS.yml` instead of `catalog.yml`; adds anti-bulk-update guard.
- **Removed**: `§9.5 Catalog Version Convention` from project maintenance rules — root cause of catalog version bulk-overwrite corruption.
- **Removed**: `version` field from all 42 catalog items (24 workflows, 11 rules, 7 skills).

## [1.7.12] - 2026-04-10

Extract Paradigm, Brainstorm Sidecar Skill & Catalog Version Convention.

- **Added**: Brainstorm Sidecar Skill (`skills/brainstorm/`) — Decision and Research document templates extracted from workflow into just-in-time loaded skill. Reduces `brainstorm.md` by ~70 lines.
- **Added**: Extract Paradigm for `/brainstorm` Step 4 — brainstorm file always kept intact, Research is a NEW file via COPY+TRANSFORM. User consent required. Threshold raised from 80 to 500 lines.
- **Added**: `§9.5 Catalog Version Convention` in maintenance rules — all catalog `version` fields MUST equal workspace VERSION at time of last modification.
- **Added**: `§6 Integration with /plan` in `para-skill/SKILL.md` — guidance for plans that design new Sidecar Skills.
- **Changed**: Step 3 (Refinement) now has mandatory `MUST NOT skip` guard preventing Agent from bypassing user evaluation.
- **Changed**: All 3 catalog.yml files (workflows, rules, skills) standardized to version `1.7.12`.

## [1.7.11] - 2026-04-09

Backlog Governance & Staged Reload (Cognitive Bypass Phase 2).

- **Added**: `Step 9.5 Pre-Checklist Context Reload` (Staged Reload) into `/plan` workflow to completely prevent Agent Token Decay when writing plan checklists (Cognitive Bypass).
- **Added**: `Phase Pre-flight Trap` inside the `detail-plan.md` Sidecar template. This forces the Agent to reload rules & skills prior to executing any planned phase.
- **Added**: Generic artifact naming rules (`naming.md`) covering Plans, Brainstorms, Backlog IDs, and VCS conventions.
- **Changed**: Replaced the outdated `Icebox` table with `§4 Roadmap Sync` (View-only mirror) within the backlog templates, preventing data duplication.
- **Changed**: Standardized `tasks/backlog.md` template with `§1-§5` headers, reflecting the updated `hybrid-3-file-integrity.md` (C3) schema.
- **Fixed**: Audited `repo/templates/` OSS templates to remove any localized language snippets and ensure strict **English-first** compliance with generic placeholders.

## [1.7.10] - 2026-04-09

Cognitive Bypass Fix & Workflow Padding Optimization (OPT-1).

- **Changed**: Zero-padding stripped from 76 templates (workflows, rules, skills, docs) saving ~8,100 tokens per workspace sync.
- **Changed**: `/plan` template (`detail-plan.md`) completely refactored with clean numbered structure, split Pre/Post-push checklists, and prominent References section.
- **Changed**: `/brainstorm` v1.7.10 — Injected Tier-1 Index Force Load (Soft Dump) bash script into Step 1 Context Gathering. Physical Force replaces passive text reminder.
- **Changed**: `/plan` v1.7.10 — Replaced Step 0 passive "Re-read" text with Soft Dump bash script.
- **Changed**: `/docs` v1.7.10 — Replaced Step 0 passive "Re-read" text with Soft Dump bash script.
- **Changed**: `catalog.yml` — bumped brainstorm, plan, docs to v1.7.10.
- **Fixed**: Version drift — `cli/para`, `project.md`, `vi-VN.md` synced to 1.7.10.

## [1.7.9] - 2026-04-08

Proactive Trigger Check for Brainstorming & Ideation (Hotfix).

- **Changed**: `agent-behavior.md` and `context-rules.md` — extended Proactive Trigger Check to include "brainstorms technical solutions" to prevent context gap during planning phase.
- **Changed**: `/open` and `/brainstorm` workflows — added explicit Proactive Trigger Check reminder before ideation operations.
- **Changed**: System KI `para_workspace_architecture_standards` — updated `governance.md` trigger check rule, bumped `para_version` to 1.7.9.

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

