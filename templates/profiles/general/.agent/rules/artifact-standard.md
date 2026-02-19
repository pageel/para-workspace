# Artifact-Driven Development Standard

> **Workspace Version:** 1.4.x (PARA Architecture)

Policy for managing technical artifacts to ensure transparency, persistence, and provable verification in AI workflows.

## 1. Implementation Plans (Blueprints)

- **Location**: `artifacts/plans/plan-YYYY-MM-DD-description.md`
- **Mandatory Sections**:
  - **Objective**: Detailed goal of the implementation.
  - **Technical Plan**: Step-by-step breakdown of actions.
  - **Verification Checklist**: Specific tests to confirm success.
  - **Rollback Strategy**: Instructions to revert changes if needed.

## 2. Walkthroughs (Evidence)

- **Location**: `artifacts/walkthroughs/walkthrough-description.md`
- **Mandatory Sections**:
  - **Summary**: Overview of what was implemented.
  - **Verification Log**: Execution results for each checklist item.
  - **Evidence**: Clipped terminal output, logs, or screenshots.

## 3. Task Management (DoD)

- **Location**: `Projects/[project-name]/artifacts/tasks.md`
- **Requirement**: Use checkboxes for tracking. Each task must have a clear "Definition of Done".

## 4. Persistent Mirroring (AI Rule)

- **Mirroring Principle**: AI agents MUST mirror their internal thought artifacts (plans, tasks, walkthroughs) to the project `artifacts/` directory.
- **Goal**: Internal agent state is ephemeral. Mirroring ensures that the logic behind a change is persistent and human-auditable.
- **Action**: Every major tool call involving creative or architectural work should be preceded or followed by an update to the corresponding artifact in the file system.
