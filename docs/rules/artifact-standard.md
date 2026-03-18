# Artifact Standard — Artifact-Driven Development

> **Version**: 1.5.4

Standardizes how the agent creates and manages technical artifacts (plans, walkthroughs, tasks). Ensures every important decision is persisted to disk — not just kept in ephemeral conversation context.

## Scope

- **Type**: Global (all projects)
- **Priority**: 🟢 Standard
- **Trigger**: Creating/editing artifacts, plans, walkthroughs

## Rules

### 1. Implementation Plans

**Location**: `Projects/[project-name]/artifacts/plans/plan-YYYY-MM-DD-description.md`

Every plan MUST include: **Objective** (detailed goal), **Technical Plan** (step-by-step), **Verification Checklist** (tests), and **Rollback Strategy** (revert instructions).

### 2. Walkthroughs (Evidence)

**Location**: `Projects/[project-name]/artifacts/walkthroughs/walkthrough-description.md`

Every walkthrough MUST include: **Summary** (what was implemented), **Verification Log** (results per checklist item), and **Evidence** (terminal output, logs, screenshots).

### 3. Task Management

Canonical store: `Projects/[project-name]/artifacts/tasks/backlog.md`. MUST use checkboxes for tracking. MUST define clear "Definition of Done" per task. SHOULD use `/backlog` workflow.

### 4. Persistent Mirroring

MUST mirror internal thought artifacts (plans, tasks, walkthroughs) to the project `artifacts/` directory. Internal agent state is ephemeral — mirroring ensures logic is persistent and human-auditable. MUST update artifacts before or after major creative/architectural work.

## Workflow

```
1. /plan create → artifacts/plans/
2. Implement   → reference plan, update checklist
3. /verify     → artifacts/walkthroughs/
4. /end        → sync task status
```

## Related

- [Hybrid 3-File Integrity](./hybrid-3-file-integrity.md) — Task file management
- [Naming Conventions](./naming.md) — Artifact file naming
- **Source**: `templates/common/agent/rules/artifact-standard.md`
