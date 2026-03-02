# Changelog

All notable changes to this project will be documented in this file.

## [1.4.6] - 2026-03-02

### Added

- **CLI Utilities**: Added `cli/lib/fs.sh` with `archive_file` helper for safely archiving structural files during version migrations instead of deleting them.
- **Smart Archive Rule**: Added strict code standard prohibiting `rm` on structural files during migrations to `CONTRIBUTING.md`.

### Changed

- **Kernel Version**: Bumped to `v1.4.6`.
- **Smart Archive Migration (FEAT-29)**: Integrated `archive_file` into `update.sh` and `migrate.sh` (`--from=1.4.5 --to=1.4.6`) to automatically move obsolete files (e.g. `docs/migration.md`) to `.para/archive/[version]-orphans/`.
- **Documentation**: Overhauled migration guides in `README.md` and `docs/README.vi.md`. Removed obsolete guides and introduced two official path: Auto Update (`para update`) and Manual Clean Slate (via `_inbox/` landing zone).

### Fixed

- **CLI Robustness**: Fixed recursive `.bak` file generation when updating the `para` wrapper in Repo mode.
- **Windows Compatibility**: Improved `install.sh` and `update.sh` to handle NTFS file locking issues. Added self-restart logic to the update process to ensure script integrity during upgrades.
- **Bug Fix**: Addressed BUG-09.

## [1.4.5] - 2026-03-02

### Added

- **Workflow: `/para-audit`** — New governed workflow functioning as a Macro Assessor to check structural drift against Kernel Specs. It's the only daily workflow allowed to full-scan the Kernel Specs.
- **Progressive Disclosure** — Implemented a token-saving model where agents only read the lightweight `governance.md` during regular tasks and only access the comprehensive Kernel Spec during `/plan`, `/para-audit` or when creating a new project.

### Changed

- **Kernel Version**: Bumped to `v1.4.5`.
- **Rule: `governance.md`** — Rewritten to be ultra-lightweight (saving thousands of tokens). Integrated **Invariant IDs** (e.g., `[I1 & I8]`) directly into safety rules so the agent can cross-reference invariants without loading the full `invariants.md` spec. Added **Safety Guardrails** (Terminal Allowlist) to protect workspaces.
- **Workflow: `/open`**: Modified to explicitly forbid scanning the Kernel Spec to prevent attention decay and context bloat.
- **Workflow: `/plan`**: Updated to allow selective, on-demand reading of Kernel components (like `invariants.md` or `heuristics.md`) rather than unrestricted scanning.

## [1.4.4] - 2026-02-27

- **Workflow: `/open`**: Optimized token usage by replacing bash commands (`head`, `grep`) with a directive to use native `view_file` capacity for reading the backlog summary, improving stability and performance.

### Changed

- **Skill: PARA Kit (v1.0.0, min_kernel: 1.4.1)**: Updated YAML frontmatter, file paths, terminology, and core strategies to conform with the v1.4.1+ standards. Replaced CLI commands with Workflows (`/para-workflow`, `/config`), added Artifacts-Driven standard, and Sync Queue awareness.

## [1.4.3] - 2026-02-26

### Fixed

- **CLI Updater**: Fixed `install.sh` failing to propagate `$KERNEL_VERSION` and crashing script execution due to unhandled `set -e` in `sync_file()`.
- **CLI Workspace**: Fixed `.para-workspace.yml` kernel version not automatically updating during `./para install` or `./para update`.
- **Governed Libraries (Skills)**: Fixed `install.sh` failing to copy nested subdirectories within libraries, effectively allowing complex items like `skills` (e.g., `para-kit`) to correctly sync to `.agent/skills/`.

### Changed

- **Profile Templates**: Added `/plan` workflow and `plans/` directory to the `dev` profile structure.

- **Workflow: `/end` v1.1.0 → v1.2.0**:
  - Added `[done]` optional parameter to the command syntax.
  - New logic: When the `done` keyword is used, the workflow detects if the project's `active_plan` is 100% complete.
  - Automated Action: If 100% complete (or requested via `done`), the agent automatically removes the `active_plan` field from `project.md` to optimize token usage for future sessions.
  - Updated all internal logic to be bilingual-ready.
- **Workflow Version Labels**: Bumped all governed library version references to `1.4.3`.

## [1.4.2] - 2026-02-26

### Added

- **Workflow: `/plan`** — New governed workflow for creating, reviewing, and updating phased implementation plans. Supports `create`, `review`, and `update` actions. Integrates with `/backlog` for phase tracking and cross-referencing.
- **`active_plan` Field** — New optional field in `project.md` frontmatter to register the active implementation plan. Enables token-optimized plan context loading in `/open` and `/end` (grep-only, no full plan reads).
- **Backlog Action: `sync`** — New action in `/backlog` to synchronize backlog items with plan phases, detecting unmapped tasks and auto-creating entries.
- **Catalog Entry**: Added `plan` to `workflows/catalog.yml` (now 18 total entries).

### Changed

- **Workflow: `/backlog` v1.0.0 → v1.1.0**:
  - `review` shows current Phase context from implementation plan.
  - `update` announces Phase completion when all phase items are done.
  - `add` asks which Phase new items belong to.
  - Template adds optional `Phase` column for plan integration.
  - Added language constraint from `.para-workspace.yml`.
  - Added Plan Integration reference section.
- **Workflow: `/open` v1.0.0 → v1.1.0**:
  - New Step 5: Read plan summary via `active_plan` field (grep-only, token-optimized).
  - Report template adds `📐 CURRENT PHASE` section with progress tracking.
  - Suggested Actions prioritize tasks from the current phase.
- **Workflow: `/end` v1.0.0 → v1.1.0**:
  - New Step 4: Check Plan Phase Progress via `active_plan` field (grep-only).
  - Adds `Plan Progress` block to session log template.
  - Suggests `/plan update` if scope changed during session.
- **Workflow: `/new-project`**: Added `active_plan` field to project.md template, added `/plan` to Related section.
- **Schema: `project.schema.json`**: Added `active_plan` property (string or null, backward-compatible).
- **Template: `project.md`**: Added `active_plan` field to frontmatter.

## [1.4.1] - 2026-02-25

### Added

- **Workflow: `/para-workflow`** — New governed workflow for managing, installing, standardizing, and validating agent workflows against `catalog.yml`.
- **Workflow: `/para-rule`** — New governed workflow for managing, installing, standardizing, and validating agent rules. Replaces legacy `rule.md`.
- **Catalog Entries**: Added `para-workflow` and `para-rule` to `workflows/catalog.yml` (now 17 total entries).

### Changed

- **All 17 Governed Workflows Standardized to v1.4.1**:
  - Unified version label to `1.4.1 (Governed Libraries)`.
  - Translated remaining Vietnamese instructions to English.
  - Replaced legacy `Resources/ai-agents/` paths with governed catalog paths.
  - Added `// turbo` annotations on all safe-to-autorun steps.
  - Added `## Related` section to all workflows.
  - Fixed `metadata.json` references → `.para-workspace.yml`.
  - Fixed `Resources/Remotes/` → `Resources/references/` (lowercase).
  - Removed legacy `/p-` prefixes (`/p-backup`, `/p-release`, `/p-retro`, `/p-verify`).
  - Expanded stub workflows (`config`, `release`, `retro`, `verify`, `new-project`) with full step-by-step instructions.
- **README (EN/VI)**: Updated workspace structure tree, install.sh description, workflow catalog (17 entries), and roadmap.

### Removed

- **`rule.md`** — Replaced by `para-rule.md` with richer functionality and catalog awareness.

## [1.4.1] - 2026-02-24

### Added

- **RFC Process** (`rfcs/`):
  - `TEMPLATE.md` — Standard template for proposing kernel changes.
  - `accepted/0001-governed-agent-libraries.md` — First accepted RFC documenting the governed library system.

- **Governed Library Catalogs** (`templates/common/agent/`):
  - `workflows/catalog.yml` — 16 workflow entries with kernel_min/max compatibility metadata.
  - `rules/catalog.yml` — 8 rule entries with kernel_min/max compatibility metadata.
  - `skills/catalog.yml` — 1 skill entry (para-kit) with kernel_min/max compatibility metadata.

- **Kernel Schemas** (`kernel/schema/`):
  - `catalog.schema.json` — JSON Schema for validating catalog.yml files.
  - `workspace.schema.json` — JSON Schema for .para-workspace.yml root config.
  - `project.schema.json` — JSON Schema for per-project .project.yml manifest.
  - `backlog.schema.json` — JSON Schema for backlog structure.

- **CLI Internal Library** (`cli/lib/`):
  - `validator.sh` — Parse catalog.yml and validate kernel compatibility with semver comparison.
  - `logger.sh` — Structured logging with colored output and audit.log appending.
  - `rollback.sh` — Atomic rollback mechanism for install/migrate operations.

- **GitHub Governance** (`.github/`):
  - `workflows/validate-pr.yml` — CI that enforces RFC requirement for invariant changes.
  - `CODEOWNERS` — Review ownership for kernel, CLI, and governed libraries.
  - `PULL_REQUEST_TEMPLATE.md` — PR template with PARA-specific checklist.

- **Test Suite** (`tests/`):
  - `kernel/test-schemas.sh` — Validates schema file existence, JSON validity, and required fields.
  - `kernel/test-invariants.sh` — Validates kernel document integrity.
  - `cli/test-init.sh` — Verifies para init creates all expected directories.
  - `cli/test-migrate.sh` — Migration test skeleton.

- **Project Template** (`templates/common/projects/.project.yml`):
  - Machine-readable project manifest template for `para scaffold`.

- **Kernel Heuristic H9**: Governed libraries require `catalog.yml` with `kernel_min` field.

### Changed

- **README**: Expanded repo and workspace architecture blocks with full sub-structure details, added Kernel ↔ Workspace Contracts table, updated Roadmap, linked RFC template in Contributing.
- **Heuristics**: Added H9 (now 9 total heuristics, was 8).

## [1.4.0] - 2026-02-13

### ⚠️ Breaking Changes

- **Repo ↔ Workspace Separation**: The repo no longer contains `Projects/`, `Areas/`, `Resources/`, `Archive/`. It is now purely governance (kernel, CLI, templates, workflows, docs).
- **`metadata.json` → `.para-workspace.yml`**: Replaced JSON metadata with YAML config.
- **`workspace.md` → merged into `README.md`**: Reduced file count.
- **CLI path changed**: `Areas/infra/cli/` → `cli/commands/`. Entry point: `cli/para`.
- **Workflow path changed**: `Resources/ai-agents/workflows/` → `workflows/` (top-level).
- **Rules extracted into Kernel**: `Resources/ai-agents/rules/` → `kernel/invariants.md` + `kernel/heuristics.md`.
- **Task model changed**: Single `tasks.md` → Hybrid 3-file (`backlog.md` canonical, `sprint-current.md` + `done.md` derived).

### Fixed (build.6) - 2026-02-24

- **Profile Architecture Simplification**: Eliminated redundant `.agent` folders from all profile templates, centralizing workflows in `templates/common/agent/workflows/`.
- **Workflow Enhanced**: Standardized and translated the `/learn` workflow to English, deploying it to the common catalog.
- **Documentation**: Updated `dev` Profile `README.md` to include `/learn` in its activities.
- **Backlog**: Marked Item 5 (Website) as Done.

### Fixed (build.5) - 2026-02-23

- **Workflow Enhancements**: Updated `/open` workflow to respect `preferences.language` in `metadata.json` (root), ensuring all agent output and final reports are translated to the user's preferred language (e.g., `vi` for Vietnamese).

### Fixed (build.4) - 2026-02-19

- **Centralized Workflows**: Merged `repo/workflows` (legacy) into `repo/templates/common/agent/workflows`.
- **Profile Standardization**: All 4 profiles (dev, general, marketer, ceo) now include `para-kit` skill and standard workflows.
- **CLI Refactor**: Updated `install.sh`, `migrate.sh` to reference the new centralized library.
- **Dedup**: Removed duplicate `repo/workflows` directory.

### Fixed (build.3) - 2026-02-19

- **BUG-05: Clone path mismatch**: Installation docs and `install.sh` wrapper used `Resources/Reference/` (PascalCase) but `para init` creates `Resources/references/` (lowercase). Standardized all paths to `Resources/references/` across README (EN/VI), `install.sh`, and `retro.md`.
- **BUG-08: Missing `_inbox` directory**: `para init` now automatically creates `_inbox/` as a landing zone for uncategorized items.
- **Docs: Clarify `chmod`**: Updated README (EN/VI) to specify that the `chmod +x` step is only for Linux and macOS.
- **Docs: Profile links**: Added direct link to each profile README guide in the README profiles table.
- **Docs: Profile READMEs**: Created `README.md` for all 4 profiles (`dev`, `general`, `marketer`, `ceo`), each documenting workspace structure, recommended workflows, active rules, and a standard daily workflow (open → backlog → develop → verify → end).
- **Docs: Default language**: Changed the example installation command to use `--lang=en` by default.
- **Cleanup: `migrate.sh` legacy fallbacks**: Removed unnecessary `$REPO_ROOT/../*` fallback paths left from old repo structure. `REPO_ROOT` already resolves correctly.

### Fixed

- **BUG-01: Permission denied on CLI scripts**: `init.sh` now explicitly sets executable permissions (`chmod +x`) right after workspace creation.
- **BUG-02: Missing install step in onboarding**: `init.sh` now calls `install.sh` automatically, ensuring the `./para` wrapper and all artifacts are correctly installed.
- **BUG-03: `install.sh` crash on duplicate files**: Added `.bak` backup mechanism to `sync_file()` when overwriting existing files with different content.
- **BUG-04: `para update` path error**: Fixed `REPO_ROOT` resolution in `update.sh` to correctly identify the git repository in personalized workspace structures.

- **Repo ↔ Workspace Separation**: The repo no longer contains `Projects/`, `Areas/`, `Resources/`, `Archive/`. It is now purely governance (kernel, CLI, templates, workflows, docs).
- **`metadata.json` → `.para-workspace.yml`**: Replaced JSON metadata with YAML config.
- **`workspace.md` → merged into `README.md`**: Reduced file count.
- **CLI path changed**: `Areas/infra/cli/` → `cli/commands/`. Entry point: `cli/para`.
- **Workflow path changed**: `Resources/ai-agents/workflows/` → `workflows/` (top-level).
- **Rules extracted into Kernel**: `Resources/ai-agents/rules/` → `kernel/invariants.md` + `kernel/heuristics.md`.
- **Task model changed**: Single `tasks.md` → Hybrid 3-file (`backlog.md` canonical, `sprint-current.md` + `done.md` derived).

### Added

- **Kernel System** (`kernel/`):
  - `KERNEL.md` — Constitution / supreme law.
  - `invariants.md` — 10 hard rules (I1–I10) that must not be violated.
  - `heuristics.md` — 8 soft conventions (H1–H8) for recommended practices.
  - `schema/tasks.schema.md` — Hybrid 3-file task model specification.
  - `schema/decision-plan.schema.json` — JSON Schema for decision records.
  - `examples/` — Compliance test vectors (decisions + tasks).
  - `README.md` — Quick reference for all invariants and heuristics.

- **Profile System** (`templates/profiles/`):
  - `general/preset.yaml` — Standard PARA workspace.
  - `dev/preset.yaml` — Developer-focused (AI tooling, infra Areas).
  - `marketer/preset.yaml` — Marketing-focused (campaign Areas).
  - `ceo/preset.yaml` — Strategic leadership workspace.

- **New CLI Commands**:
  - `para init [--profile=X] [--lang=X] [--path=X]` — Create workspace from repo + profile.
  - `para archive <type>/<name>` — Move items to Archive with graduation review.

- **Cross-platform Fix**: All CLI scripts include `normalize_path()` to fix Windows/PowerShell backslash path issues.

- **New Documentation** (`docs/`):
  - `architecture.md` — Repo ↔ Workspace ↔ Agent relationship.
  - `kernel.md` — Kernel concepts and change process.
  - `workflows.md` — Workflow philosophy and catalog.
  - `cli.md` — CLI command reference.
  - `migration.md` — v1.3.x → v1.4.0 migration guide.

- **Governance Files**:
  - `CONTRIBUTING.md` — Contributor guidelines with RFC process.
  - `VERSIONING.md` — Semantic versioning policy (kernel vs workspace tracks).

### Changed

- **CLI Rewrite**: All core scripts rewritten for v1.4 architecture:
  - `init.sh` — Full workspace generation from repo + profile.
  - `status.sh` — Reads `.para-workspace.yml`, supports `--json`, uses `backlog.md`.
  - `migrate.sh` — Handles v1.3→v1.4 migration with `--dry-run` mode.
  - `install.sh` — Syncs kernel + workflows from repo to workspace.
  - `scaffold.sh` — Supports `project/area/resource` types, kebab-case enforcement.
- **Templates** (`templates/common/`): Project, task, and agent governance templates.

## [1.3.6] - 2026-02-11

### Added

- **Cross-Project Sync Queue**: Centralized notification system in `Areas/Workspace/SYNC.md`. `/end` logs pending syncs, and `/open` alerts the user.
- **Sync Logic in Workflows**: Updated `/end` and `/open` to support metadata-driven downstream notifications.

### Changed

- **Version Bump**: Finalized sync queue architecture and bumped all core labels to 1.3.6.

## [1.3.5] - 2026-02-11

### Added

- **Backup Workflow (`/backup`)**: New workflow to create date-stamped snapshots of workflows, rules, and metadata.json with auto-cleanup (keeps 5 most recent).
- **Enhanced Backlog Workflow (`/backlog`)**: Expanded from minimal stub to comprehensive template with Epic/Story structure, Bug tracking, ICE scoring, Summary stats, and standardized status/priority conventions.

### Changed

- **README (EN/VI)**: Updated Workflow Catalog to include `/backup`. Bumped version to 1.3.5.
- **Scaffold Update**: `scaffold.sh` now generates `project.md` with standard Technical Context (WorkDir, TechStack, Commands, Links).

## [1.3.4+safety] - 2026-02-09

### Added

- **Safety (PARA Discipline)**: Added `Resource Immutability` and `Project Protection` rules to prevent agents from accidentally modifying core templates or the `para-workspace` repo itself.

## [1.3.4] - 2026-02-09

### Added

- **Full Catalog Install**: `./para install` now syncs **ALL** rules and workflows from `Resources/ai-agents/` to `.agent/` by default.
- **Workflow & Rule Catalog**: New section in README listing all available capabilities.
- **New Project Logic**: Standardized `/new-project` workflow (merged from `/kickoff`).

### Changed

- **Self-Hosting**: The `para-workspace` repo now correctly installs its own rules and workflows into `.agent/` from `Resources/`.
- **Versioning**: Updated core rule versioning to `1.3.4 (Full Sync)`.

## [1.3.3] - 2026-02-06

### Added

- **Start Installer (`/install`)**: New agentic workflow for smart installation, updates, and conflict resolution (Overwrite/Merge/Rename).
- **Intelligent Merge (`/merge`)**: Semantic merge workflow replacing dumb CLI append logic.
- **Rule Management System**: New `./para rule` CLI and `/rule` workflow to manage the `.agent/rules` library.
- **Config CLI**: New `./para config` command to manage workspace settings.

### Changed

- **Workflow Naming**: Removed mandatory `p-` prefix from standard workflows (e.g., `/kickoff`, `/retro`). Prefix is now optional and only suggested on conflict.
- **Path Resolution**: Improved `workspace_root` detection in CLI scripts to support execution via wrappers.
- **Documentation**: Updated READMEs (EN/VI) to reflect the new Rule Management and Versioning strategies.

## [1.3.1] - 2026-02-05

### Added

- **Artifact Mirroring Rule**: New standard in `artifact-standard.md` forcing agents to mirror brain artifacts to the project's `artifacts/` folder for persistence.
- **Unified Workflow Prefix**: All workflows now use the `p-` prefix for complete consistency, with `/para` remaining as the master entry command.

### Fixed

- **Workflow Library Cleanup**: `install.sh` now automatically removes legacy workflow files (without the `p-` prefix) from the root Resources directory.

### Documentation

- **README Overhaul**: Added detailed directory structure (Projects, Areas, Resources, Archive) and explicit installation guide for Antigravity agents.

## [1.3.0] - 2026-02-05

### Added

- **Project Contracts (v1.3)**: Mandatory YAML Frontmatter for `project.md` enabling machine-readable goals and deadlines.
- **Smart Governance**: Integrated `PARA Kit` skill for strategic agent decision-making.
- **Master Workflow**: The heart of the workspace is the `/para` slash command. Ask your agent:

> "Review my workspace health" or "@[/para] standardize all projects"ion and migration.

- **Project Migrator**: New `./para migrate` command to upgrade legacy folders to v1.3 standard.
- **Refined Status**: Overdue detection (🔥) and unquoted YAML parsing support.

### Changed

- **Migration Policy**: `install.sh` now automatically installs root wrappers and core workflows.
- **RFC Acceptance**: RFC-0001 to RFC-0004 moved from Draft to Accepted status.

## [1.2.0] - 2026-02-05

### Added

- **Artifact Layer**: Standardized `artifacts/` structure (plans, walkthroughs, tasks.md) for agentic projects.
- **Enhanced CLI**: Added `./para plan`, `./para verify`, and `./para status` for better workflow management.
- **Project Rules**: Added strict `para-discipline.md` and `artifact-standard.md` rules.
- **Workflow Catalog**: New workflows for `kickoff`, `verify`, `release-check`, and `retro`.
- **Internationalization**: Full README update (EN/VI) for Artifact-Driven Workflow.

### Changed

- **Scaffold System**: `scaffold.sh` now creates the full Artifact Layer.
- **CLI Wrapper**: `./para` improved with auto-root detection and new commands.

## [1.1.0] - 2026-02-04

### Added

- **CLI Tools**: Added `cli/` scripts (`install.sh`, `scaffold.sh`, `update.sh`) for project automation.
- **Workflow Catalog**: Initial workflow catalog system.
