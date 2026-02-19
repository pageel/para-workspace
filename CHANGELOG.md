# Changelog

All notable changes to this project will be documented in this file.

## [1.4.0] - 2026-02-13

### ⚠️ Breaking Changes

- **Repo ↔ Workspace Separation**: The repo no longer contains `Projects/`, `Areas/`, `Resources/`, `Archive/`. It is now purely governance (kernel, CLI, templates, workflows, docs).
- **`metadata.json` → `.para-workspace.yml`**: Replaced JSON metadata with YAML config.
- **`workspace.md` → merged into `README.md`**: Reduced file count.
- **CLI path changed**: `Areas/infra/cli/` → `cli/commands/`. Entry point: `cli/para`.
- **Workflow path changed**: `Resources/ai-agents/workflows/` → `workflows/` (top-level).
- **Rules extracted into Kernel**: `Resources/ai-agents/rules/` → `kernel/invariants.md` + `kernel/heuristics.md`.
- **Task model changed**: Single `tasks.md` → Hybrid 3-file (`backlog.md` canonical, `sprint-current.md` + `done.md` derived).

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
