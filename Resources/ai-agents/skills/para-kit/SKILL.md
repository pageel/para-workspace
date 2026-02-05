# Skill: PARA Kit

Intelligence for managing an "Agent-Executable" PARA workspace. This skill helps the agent decide whether to use automated scripts (fast execution) or structured workflows (collaborative refinement).

## Core Capabilities

1. **Workspace Audit**: Uses `./para status` to identify non-compliant projects or overdue deadlines.
2. **Project Lifecycle**: Orchestrates `scaffold`, `migrate`, and `archive` operations.
3. **Strategy Selection**: Decides whether a task requires a full workflow (/p-retro, /p-kickoff) or just a direct CLI command.

## Selection Strategy (Workflow vs. Script)

### Use CLI Scripts (`./para <cmd>`) when:

- Performing **maintenance** (status, install, update).
- **Initialization** (scaffold).
- **Bulk Migration** (migrate).
- The task is deterministic and requires no human-in-the-loop decision.

### Use Workflows (`/p-<cmd>`) when:

- Performing **analysis** that requires documentation (e.g., /p-retro, /p-plan).
- **Collaboration** with the user is needed to define scope (/p-kickoff).
- The task produces a **permanent artifact** (e.g., plan.md, walkthrough.md).
- **Complex validation** is required (/p-verify).

## Intelligence Patterns

- **Stalled Project Detection**: If a project has no tasks in `Current Sprint` and no log in `sessions/` for > 7 days, trigger a `/para` review.
- **Resource Extraction**: When a project is 100% complete, analyze `repo/` and `docs/` for patterns to move to `Resources/`.

## Directory Structure

- `scripts/`: Internal helper scripts.
- `templates/`: Base templates for project metadata.
