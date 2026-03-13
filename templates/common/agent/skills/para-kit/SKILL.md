---
name: PARA Kit
description: Intelligence for managing an Agent-Executable PARA workspace.
source: catalog
---

# Skill: PARA Kit

Intelligence for managing an "Agent-Executable" PARA workspace. This skill helps the agent decide whether to use automated scripts (fast execution) or structured workflows (collaborative refinement).

## Core Capabilities

1. **Workspace Audit**: Uses `./para status` to identify non-compliant projects or overdue deadlines.
2. **Project Lifecycle**: Orchestrates `scaffold`, `migrate`, and `archive` operations.
3. **Strategy Selection**: Decides whether a task requires a full workflow (/retro, /plan) or just a direct CLI command.
4. **Catalog Management**: Uses `/para-workflow` and `/para-rule` workflows to manage governed libraries.
5. **Configuration & Customization**: Uses the `/config` workflow for workspace metadata and settings.
6. **Versioning Discipline**: Enforces the patch branch (user-approved minor jumps only).

## Selection Strategy (Workflow vs. Script)

### Use CLI Scripts (`./para <cmd>`) when:

- Performing **maintenance** (status, install, update).
- **Low-level Scaffolding** (`./para scaffold`) as an automated step inside a larger wrapper.
- **Bulk Migration** (migrate).
- The task is deterministic and requires no human-in-the-loop decision or creative thinking.

### Use Workflows (`/[cmd]`) when:

- **Collaboration** with the user is needed to define scope or start a new project (e.g., **`/new-project`** instead of raw `./para scaffold`).
- Performing **analysis** that requires documentation (e.g., /retro, /plan).
- The task produces a **permanent artifact** (e.g., plan.md, walkthrough.md) following the Artifact-Driven Standard.
- **Complex validation** is required (/verify).

## Intelligence Patterns (RFC-0002 & RFC-0003)

### 1. Context Routing (Smart Loading)

- **Priority Order**: `project.md` → `active_plan` (if exists) → Project Rules → Global Rules → Artifacts → Beads → Areas → Resources.
- **Isolation Enforcement**: Always scope research to the active project folder first. Only expand to `Areas/` or `Resources/` if the project context is insufficient.
- **Archive Policy**: Never read `Archive/` unless explicitly requested.

### 2. Artifact-Driven Standard & Beads Lifecycle

- **Persistent Mirroring**: ALWAYS mirror creative logic, architectural plans, and verification evidence into `Projects/<project-name>/artifacts/`. Use `plans/` for design, `plans/done/` for archived plans + completion reviews, `walkthroughs/` for task verification.
- **Artifact Location Rule**: Plan completion reviews go in `artifacts/plans/done/` alongside the archived plan. Task verification checklists go in `artifacts/walkthroughs/`. NEVER save project evidence in the conversation brain — brain is for scratch notes only.
- **Beads Bound to Projects**: Temporary thinking lives in `Projects/<project-name>/.beads/`.
- **Graduation Ritual**: During `/retro`, analyze Beads for potential graduation to `Areas/` (Standard Operating Procedures), `Resources/` (Reference), or `.agent/rules/` (Codified Guardrails).
- **Proactive Tagging**: Identify friction points (repeated failures, logic gaps) and suggest creating a Bead.

### 3. Advanced Auditing (Workspace Health)

- **Status Reporting**: Uses `./para review` for deep governance analysis and `./para status` for a quick overview of task progress (Done/Total) and rule density.
- **Sync Queue Awareness**: Actively monitors `Areas/Workspace/SYNC.md` for pending downstream tasks. If a project is blocked by an upstream sync, propose running `/open [project-name]` to resolve it.
- **Library Health**: Monitors the ratio of Core vs. Library components to ensure standardization.
- **Stalled Project Detection**: If a project has no tasks in `Current Sprint` and no log in `sessions/` for > 7 days, trigger a `./para status` or `/retro` review.

### 4. Versioning Strategy (Propose & Approve)

- **Universal Rule**: Applies to the workspace and ALL projects by default. Project-specific rules take precedence if they exist.
- **Protocol**: Always propose the **specific next version number** (e.g., `1.3.3`) and wait for user approval before modifying version files.
- **Elevation Control**: Strictly requests permission for MINOR or MAJOR jumps.
- **Traceability**: Link version increments to completed tasks in `artifacts/tasks/backlog.md` or `project.md`.

## Directory Structure

- `scripts/`: Internal helper scripts.
- `templates/`: Base templates for project metadata.
