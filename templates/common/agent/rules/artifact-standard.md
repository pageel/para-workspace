# Artifact-Driven Development Standard

> Agent governance rule for managing technical artifacts.

## Scope

- [x] Global (applies to entire workspace)

## Rules

### 1. Implementation Plans

- **Location**: `Projects/[project-name]/artifacts/plans/plan-YYYY-MM-DD-description.md`
- **MUST** include:
  - **Objective**: Detailed goal of the implementation.
  - **Technical Plan**: Step-by-step breakdown of actions.
  - **Verification Checklist**: Specific tests to confirm success.
  - **Rollback Strategy**: Instructions to revert changes if needed.

### 2. Walkthroughs (Evidence)

- **Location**: `Projects/[project-name]/artifacts/walkthroughs/walkthrough-description.md`
- **MUST** include:
  - **Summary**: Overview of what was implemented.
  - **Verification Log**: Execution results for each checklist item.
  - **Evidence**: Clipped terminal output, logs, or screenshots.

### 3. Task Management

- **Canonical store**: `Projects/[project-name]/artifacts/tasks/backlog.md`
- **MUST** use checkboxes for tracking.
- **MUST** define a clear "Definition of Done" for each task.
- **SHOULD** use the `/backlog` workflow for task management.

### 4. Persistent Mirroring

- **MUST** mirror internal thought artifacts (plans, tasks, walkthroughs) to the project `artifacts/` directory.
- **Rationale**: Internal agent state is ephemeral. Mirroring ensures that the logic behind a change is persistent and human-auditable.
- **MUST** update the corresponding artifact before or after every major tool call involving creative or architectural work.
