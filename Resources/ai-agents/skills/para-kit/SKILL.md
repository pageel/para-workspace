# Skill: PARA Kit

Intelligence for managing an "Agent-Executable" PARA workspace. This skill helps the agent decide whether to use automated scripts (fast execution) or structured workflows (collaborative refinement).

## Core Capabilities

1. **Workspace Audit**: Uses `./para status` to identify non-compliant projects or overdue deadlines.
2. **Project Lifecycle**: Orchestrates `scaffold`, `migrate`, and `archive` operations.
3. **Strategy Selection**: Decides whether a task requires a full workflow (/p-retro, /p-kickoff) or just a direct CLI command.
4. **Catalog Management**: Uses `./para work` and `./para rule` to manage personal libraries.
5. **Configuration & Customization**: Uses `./para config` for workspace settings.
6. **Versioning Discipline**: Enforces the 1.3.x patch branch (user-approved minor jumps only).
7. **Safe Merging**: Recommends `install -m` to blend catalog updates with user-customized workflows.

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

## Intelligence Patterns (RFC-0002 & RFC-0003)

### 1. Context Routing (Smart Loading)

- **Priority Order**: `project.md` → Project Rules → Global Rules → Artifacts → Beads → Areas → Resources.
- **Isolation Enforcement**: Always scope research to the active project folder first. Only expand to `Areas/` or `Resources/` if the project context is insufficient.
- **Archive Policy**: Never read `Archive/` unless explicitly requested.

### 2. Beads Lifecycle Management

- **Bound to Projects**: Beads MUST live in `Projects/<project-name>/.beads/`.
- **Graduation Ritual**: During `/p-retro`, analyze Beads for potential graduation to `Areas/` (Standard Operating Procedures), `Resources/` (Reference), or `.agent/rules/` (Codified Guardrails).
- **Proactive Tagging**: Identify friction points (repeated failures, logic gaps) and suggest creating a Bead.

### 3. Advanced Auditing (Workspace Health)

- **Status Reporting**: Uses `./para status` to monitor task progress (Done/Total), rule density, and workflow adoption across projects.
- **Library Health**: Monitors the ratio of Core vs. Library components to ensure standardization.
- **Stalled Project Detection**: If a project has no tasks in `Current Sprint` and no log in `sessions/` for > 7 days, trigger a `./para status` review.

### 4. Versioning Strategy (Propose & Approve)

- **Universal Rule**: Applies to the workspace and ALL projects by default. Project-specific rules take precedence if they exist.
- **Protocol**: Always propose the **specific next version number** (e.g., `1.3.3`) and wait for user approval before modifying version files.
- **Elevation Control**: Strictly requests permission for MINOR or MAJOR jumps.
- **MAJOR Rules**: Jumps to a new MAJOR version (e.g., `1.x` -> `2.x`) MUST be backed by a formal **Implementation Plan** and align with the public **Roadmap**.
- **Traceability**: Link version increments to completed tasks in `BACKLOG.md` or `project.md`.

## Directory Structure

- `scripts/`: Internal helper scripts.
- `templates/`: Base templates for project metadata.
