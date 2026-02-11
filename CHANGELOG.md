# Changelog

All notable changes to this project will be documented in this file.

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
