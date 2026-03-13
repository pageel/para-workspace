# /para-audit Workflow

> **Version**: 1.5.3

The `/para-audit` workflow is the workspace **Macro Assessor** — it has two modes:

1. **Full-scan** (default) — Structural drift audit against Kernel Specs (I1-I11). The **only** workflow allowed to read `invariants.md` in full.
2. **Update** — Post-update compliance check: reads changelog, checks schemas, templates, and rules index for each project.

## Commands

```
/para-audit                # Full structural audit
/para-audit update         # Post-update compliance check
```

## Why a Separate Workflow?

Instead of reading hundreds of lines of Kernel Specs on every `/open` or `/plan` (wasting tokens and causing attention decay), PARA uses **Progressive Disclosure**:

- Daily workflows → read only the ultra-light `governance.md`
- When audit is needed → run `/para-audit` for comprehensive checks
- After `./para update` → run `/para-audit update` for version-specific checks

## Full-scan Flow

```
Full-scan Kernel → Check filesystem → Check projects → Check libraries → Generate report
```

### 1. Full-scan Kernel Specs

Reads all 11 invariants (I1-I11) from `invariants.md` to understand strict structural rules.

### 2. Check Filesystem Structure (I1, I8)

Verifies no loose files at workspace root (except `.para-workspace.yml`, `README.md`, `para`). Confirms top-level directories match `Projects/`, `Areas/`, `Resources/`, `Archive/`.

### 3. Check Active Projects (I4, I2)

For each project in `Projects/`: checks `project.md` exists and `backlog.md` has active items. Flags potentially inactive projects.

### 4. Check Libraries

Runs `/para-rule list` and `/para-workflow list` to identify untracked or misaligned components.

### 5. Generate Audit Report

Creates `Areas/Workspace/audits/audit-report-YYYY-MM-DD.md` with:

- **Structural Integrity**: Which invariants passed/failed
- **Drift Detected**: Loose files, missing structures, inactive projects
- **Library Status**: Outdated or untracked rules/workflows
- **Remediation Plan**: Next steps to fix issues

## Update Flow

```
Detect version change → Read changelog → Check schemas → Check templates → Check rules → Report
```

### 1. Detect Version Change

Reads `kernel_version` from `.para-workspace.yml` and compares with `.para/audit.log` to find the previous version. Stops early if no change detected.

### 2. Read Changelog (Token-Optimized)

Reads only the changelog for the new version (`docs/changelog/vX.Y.Z.md`). Extracts breaking changes, template changes, and rule changes to build a targeted check list.

### 3. Check Project Schema Compliance

For each project: reads `project.md` YAML frontmatter and flags missing fields (`has_rules`, `downstream`, `active_plan`) with suggested defaults.

### 4. Check Backlog Template Compliance

For each project with `backlog.md`: checks for `✅ Completed (Archived)` section, Summary categories, and Done items still in active tables. Suggests `/backlog clean` if needed.

### 5. Check Rules Index Consistency

For projects with `has_rules: true`: compares `.agent/rules.md` index with actual `.agent/rules/` files on disk. Flags mismatches.

### 6. Generate Post-Update Report

Displays an inline report with findings and suggested actions. Auto-fixable items can be applied with user confirmation.

## Related

- [/para-rule](./para-rule.md) — Rule management
- [/para-workflow](./para-workflow.md) — Workflow management
- [/para Workflow](./para.md) — Master workspace controller
- [/update Workflow](./update.md) — Safe workspace update
- [Workflow Documentation](../reference/workflows.md) — Workflow catalog

---

_Updated in v1.5.3 (Added `update` action — FEAT-45)_
