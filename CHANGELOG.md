# Changelog

All notable changes to this project will be documented in this file.

## [1.3.2] - 2026-02-06

### Added

- **Rule Management System**: New `./para rule` CLI and `/rule` workflow to manage the `.agent/rules` library.
- **Intelligent Merging**: `install -m` flag for workflows to blend catalog updates with user customizations.
- **Versioning Protocol**: Global `versioning.md` rule enforcing "Propose & Approve" protocol and mandatory Plans for MAJOR upgrades.
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
