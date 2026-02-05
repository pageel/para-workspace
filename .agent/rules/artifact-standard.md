# Artifact Standard

All complex tasks (lasting >1 session or involving significant architectural changes) must follow the Artifact-Driven Workflow.

## 1. Implementation Plans

- **Location**: `artifacts/plans/plan-YYYY-MM-DD-description.md`
- **Content**:
  - Objective
  - Step-by-step technical plan
  - Verification checklist
  - Rollback strategy

## 2. Walkthroughs

- **Location**: `artifacts/walkthroughs/walkthrough-description.md`
- **Content**:
  - Summary of changes
  - Execution of verification checklist
  - Evidence of success/failure

## 3. Tasks (DoD)

- **Location**: `artifacts/tasks.md`
- **Requirement**: Must have clear checkboxes for tracking progress and defining when a task is "Done".

## 4. Persistent Mirroring (AI Rule)

- **Principle**: AI agents must mirror their internal brain artifacts (plans, tasks, walkthroughs) to the project's `artifacts/` directory.
- **Why**: Internal brain artifacts are ephemeral. Mirroring ensures that project management data is persistent, version-controlled (locally), and visible to humans.
- **Action**: After creating/updating an internal artifact, the agent should immediately `write_to_file` the same content to the corresponding project artifact path.
