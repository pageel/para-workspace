---
description: Maintenance, catalog synchronization, versioning, and release integrity rules for para-workspace
trigger: always_on
glob: templates/*, repo/*, catalog.yml, VERSION
---

# Rule: Project Maintenance & Release Integrity (para-workspace)

<!-- ⚠️ GOVERNED — /para-rule only. Overwritten by para update -->

> Operational rules for maintaining, staging, and releasing `para-workspace`.

## Scope

- [x] Workspace & Meta-Project Release Operations (`para-workspace`)

## Rules

### M1. Template & Catalog Double-Declaration (MANDATORY)
- Whenever a new Workflow (`.md`), Rule (`.md`), Skill (directory), or System KI is created, edited, or added:
  - Agent **MUST** stage the asset into `repo/templates/common/agents/<type>/` via `/staging`.
  - Agent **MUST** register the asset ID, entrypoint, and description in the corresponding `catalog.yml` (`workflows/catalog.yml`, `rules/catalog.yml`, `skills/catalog.yml`).
  - Agent **MUST** update `VERSIONS.yml` when workspace version is bumped.
  - Agent **MUST** update the Workflow, Rule, and Skill count & tables in `repo/README.md` and `repo/docs/locales/vi-VN.md`.

### M2. Multi-File Version Synchronization (MANDATORY)
- Version numbers **MUST** be 100% identical across all 6 release locations:
  1. `repo/VERSION`
  2. `repo/VERSIONS.yml` (`workspace:` key)
  3. `repo/cli/para` (`# Version:`)
  4. `project.md` and `.para-workspace.yml` (`version:` and `kernel_version:`)
  5. `repo/README.md` (version badge & footer version)
  6. `repo/docs/locales/vi-VN.md` (version badge & footer version)

### M3. Non-Destructive Plan Verification (MANDATORY)
- Plan verification **MUST** use dry-run linter (`node .agents/skills/plan/scripts/lint-plan.js`) and non-destructive path checks.
- Agent **MUST NOT** execute invasive `./para install` or system mutation commands inside plan execution tasks.

### M4. OSS English-First Governance & Path Neutrality (MANDATORY)
- All `.agents/` files (workflows, rules, skills), templates, and code comments **MUST** be written in English to support global open-source contributors.
- All configuration templates and examples **MUST** use neutral placeholder domains (e.g., `example.com`, `your-saas-app.com`) and strictly prohibit hardcoding proprietary SaaS domains, local absolute paths, or production secrets.

