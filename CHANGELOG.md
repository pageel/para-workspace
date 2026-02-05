# Changelog

All notable changes to this project will be documented in this file.

## [1.3.0] - 2026-02-05

### Added

- **Project Contracts (v1.3)**: Mandatory YAML Frontmatter for `project.md` enabling machine-readable goals and deadlines.
- **Smart Governance**: Integrated `PARA Kit` skill for strategic agent decision-making.
- **Master Workflow**: Added `/para` slash command for automated workspace standardization and migration.
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
