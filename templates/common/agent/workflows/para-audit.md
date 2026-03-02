---
description: Macro Assessor to check structural drift against Kernel Specs
source: catalog
---

# /para-audit

> **Workspace Version:** 1.4.5 (Governed Libraries)

Strict workspace macro-assessor to scan for structural drift against Kernel Specs (I1-I11) and generate a compliance report. This is the **only** daily workflow allowed to full-scan the Kernel Specs.

## Steps

### 1. Full-scan Kernel Spec (Allowed Exception)

// turbo

```bash
cat Resources/ai-agents/kernel/invariants.md
```

Read the 11 invariants (I1-I11) to understand the strict structural rules of the workspace.

### 2. Check File System Structure (I1, I8)

// turbo

```bash
ls -la
```

Verify that there are no loose files at the workspace root (except `.para-workspace.yml`, `README.md`, `para`, etc.). Check that the top-level directories match `Projects/`, `Areas/`, `Resources/`, `Archive/`. Note any undocumented files or folders.

### 3. Check Active Projects (I4, I2)

For each active project inside `Projects/`:

1. Check if `project.md` exists.
2. Check if `backlog.md` exists and has items in "In Progress" or "ToDo". If empty or missing, flag the project as potentially inactive.

### 4. Delegate to Package Managers for Libraries

Use the built-in listing commands of the workflow and rule managers to check for inconsistencies.

// turbo

```bash
/para-rule list
/para-workflow list
```

Identify any untracked or misaligned rules and workflows.

### 5. Create Audit Report

Generate a detailed `audit-report-YYYY-MM-DD.md` in `Areas/Workspace/audits/` summarizing:

- **Structural Integrity:** Which Invariants passed/failed.
- **Drift Detected:** Loose files, missing structures, inactive projects.
- **Library Status:** Outdated or untracked rules/workflows.
- **Remediation Plan:** Next steps to fix the issues, potentially using `/para-rule standardize` or manual cleanup.

## Related

- `/para-rule` — Rule management (CRUD logic)
- `/para-workflow` — Workflow management (CRUD logic)
- `/para` — Master workspace controller
