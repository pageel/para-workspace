# /para-audit Workflow

> **Version**: 1.5.0

The `/para-audit` workflow is the workspace **Macro Assessor** — it full-scans the workspace for structural drift against Kernel Specs (I1-I11) and generates a compliance report. This is the **only** workflow allowed to read `invariants.md` in full.

## Commands

```
/para-audit
```

## Why a Separate Workflow?

Instead of reading hundreds of lines of Kernel Specs on every `/open` or `/plan` (wasting tokens and causing attention decay), PARA uses **Progressive Disclosure**:

- Daily workflows → read only the ultra-light `governance.md`
- When audit is needed → run `/para-audit` for comprehensive checks

## Audit Flow

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

## Related

- [/para-rule](./para-rule.md) — Rule management
- [/para-workflow](./para-workflow.md) — Workflow management
- [/para Workflow](./para.md) — Master workspace controller
- [Workflow Documentation](../workflows.md) — Workflow catalog

---

_Added in v1.5.0_
