# Changelog

All notable changes to this project will be documented in this file.
For detailed release notes, see [docs/changelog/](docs/changelog/).

## [1.4.8] - 2026-03-04

Atomic Rollback, Dry-run Pipeline & README Installation Rewrite.
→ [Detailed release notes](docs/changelog/v1.4.8.md)

- **Added**: Atomic rollback for `install.sh` (FEAT-30), `--dry-run` for `install` and `update` (FEAT-31), Windows lock guard.
- **Changed**: README Installation rewrite with Platform Compatibility table (FEAT-33), CLI help text, audit logging.

## [1.4.7] - 2026-03-03

macOS Compatibility & Safe Migration Pipeline.
→ [Detailed release notes](docs/changelog/v1.4.7.md)

- **Added**: `/backup` project targets, `backup_and_copy()`, version gating in `migrate.sh`.
- **Fixed**: 3 macOS/Bash 3.2 incompatibilities (`sed -i`, `;;&`, `head -n -1`), env var consistency, rule protection.

## [1.4.6] - 2026-03-02

Smart Archive & Version Migration.
→ [Detailed release notes](docs/changelog/v1.4.6.md)

- **Added**: `cli/lib/fs.sh` with `archive_file`, Smart Archive rule.
- **Changed**: Integrated Smart Archive into `update.sh` and `migrate.sh`, overhauled migration docs.

## [1.4.5] - 2026-03-02

Safety Guardrails & Progressive Disclosure.
→ [Detailed release notes](docs/changelog/v1.4.5.md)

- **Added**: `/para-audit` workflow, Progressive Disclosure model.
- **Changed**: `governance.md` rewritten (ultra-lightweight), `/open` and `/plan` scoping.

## [1.4.4] - 2026-02-27

Token Optimization & PARA Kit Standardization.
→ [Detailed release notes](docs/changelog/v1.4.4.md)

- **Changed**: `/open` uses native `view_file`, PARA Kit v1.0.0 updated to v1.4.1+ standards.

## [1.4.3] - 2026-02-26

CLI Fixes & Plan-Aware Workflows.
→ [Detailed release notes](docs/changelog/v1.4.3.md)

- **Fixed**: `install.sh` kernel version propagation, nested library copying, workspace config update.
- **Changed**: `/end` v1.2.0 with `[done]` parameter, plan cleanup automation.

## [1.4.2] - 2026-02-26

Plan-Driven Development.
→ [Detailed release notes](docs/changelog/v1.4.2.md)

- **Added**: `/plan` workflow, `active_plan` field, `/backlog sync` action.
- **Changed**: `/backlog` v1.1.0, `/open` v1.1.0, `/end` v1.1.0 with plan phase tracking.

## [1.4.1] - 2026-02-24

Governed Libraries & Runtime Safety.
→ [Detailed release notes](docs/changelog/v1.4.1.md)

- **Added**: RFC process, governed library catalogs, kernel schemas, CLI libraries (`validator.sh`, `logger.sh`, `rollback.sh`), test suite, GitHub governance, H9.
- **Changed**: All 17 workflows standardized to v1.4.1.

## [1.4.0] - 2026-02-13

⚠️ **Breaking**: Repo ↔ Workspace Separation & Kernel System.
→ [Detailed release notes](docs/changelog/v1.4.0.md)

- **Breaking**: Repo purged of user data, `metadata.json` → `.para-workspace.yml`, new CLI paths, task model changed.
- **Added**: Kernel system (10 invariants, 8 heuristics), profile system, CLI rewrite, documentation suite.

## [1.3.6] - 2026-02-11

Cross-Project Sync Queue. → [Details](docs/changelog/v1.3.6.md)

## [1.3.5] - 2026-02-11

Backup & Backlog Workflows. → [Details](docs/changelog/v1.3.5.md)

## [1.3.4] - 2026-02-09

Full Catalog Install & Safety. → [Details](docs/changelog/v1.3.4.md)

## [1.3.3] - 2026-02-06

Smart Installer & Rule Management. → [Details](docs/changelog/v1.3.3.md)

## [1.3.1] - 2026-02-05

Artifact Mirroring & Workflow Prefix. → [Details](docs/changelog/v1.3.1.md)

## [1.3.0] - 2026-02-05

Project Contracts & Smart Governance. → [Details](docs/changelog/v1.3.0.md)

## [1.2.0] - 2026-02-05

Artifact-Driven Workflow. → [Details](docs/changelog/v1.2.0.md)

## [1.1.0] - 2026-02-04

CLI Foundation. → [Details](docs/changelog/v1.1.0.md)
