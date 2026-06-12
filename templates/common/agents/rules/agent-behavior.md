---
description: Agent communication, formatting, context recovery after truncation
trigger: always_on
glob:
---

# Agent Behavior & Communication

<!-- ⚠️ GOVERNED — /para-rule only. Overwritten by para update -->

> Agent governance rule for behavior and communication standards.

## Scope

- [x] Global (applies to entire workspace)

## Rules

### 1. Language Configuration

- **MUST** respect the `preferences.language` setting in `.para-workspace.yml` for documentation and chat responses.
- **MUST** use the configured language for internal reasoning and thinking, not just visible output.
- **MUST** keep technical artifacts (code variables, commit messages) in English for standard compatibility.
- **SHOULD** adapt communication language to the user's configured preference.

### 2. Communication Style

- **MUST** be concise — focus on the solution, avoid fluff.
- **SHOULD** use checklists when completing multi-step tasks (✅ Done, ⏳ Pending).
- **MUST** state errors clearly and propose a fix immediately when they occur.

### 3. Workflow Standards

- **MUST** perform a verification step (`npm run build` or test) after every code change, unless the user explicitly requests `--quick`.
- **MUST NOT** `git commit` or `git push` without user confirmation, unless explicitly running a trusted workflow (`/push`, `/release`).
- **MUST** check the build result before reporting "Done".
- **SHOULD** prioritize using defined workflows in `.agents/workflows/` over ad-hoc commands.
- **SHOULD** ask the user instead of assuming when uncertain.

### 4. Context Recovery

When context appears incomplete (cannot recall loaded rules, received truncation/checkpoint notice, or conversation has been very long):

1. **MUST** re-read `.agents/rules.md` (workspace rules index) before performing any side-effect.
2. **MUST** re-read `.agents/skills.md` (workspace skills index, v1.6.2+) before performing any side-effect.
3. **MUST** re-read project `.agents/rules.md` (if exists) before project-specific actions.
4. **MUST** re-read project `.agents/skills.md` (if exists) before project-specific actions.
5. **SHOULD** inform user: "Context recovery — re-loaded rules + skills indices."

**Proactive Trigger Check (v1.6.2+):**

BEFORE any action that edits files, runs commands, creates artifacts, or brainstorms technical solutions — even when context is fresh:

1. Scan workspace `rules.md` trigger table
2. Scan workspace `skills.md` trigger table
3. Scan project trigger tables (if loaded)
4. **IF match found → read the rule/skill file BEFORE acting**

> Principle: Check THEN act — never act THEN check.

Side-effects requiring rules/skills re-read:

- Git operations (commit, push, merge, branch, tag, PR)
- File deletion, move, or rename outside project scope
- Install/deploy commands
- Creating/modifying system config files

#### File-Level Guards

When editing these files **directly** (outside of a workflow), agent **MUST** re-read the corresponding rule first:

| File pattern              | MUST re-read before editing     |
| :------------------------ | :------------------------------ |
| `artifacts/tasks/done.md` | `hybrid-3-file-integrity.md` C2 |
| `artifacts/tasks/*.md`    | `hybrid-3-file-integrity.md`    |
| `artifacts/plans/*.md` (Status field) | `hybrid-3-file-integrity.md` C7 |
| `project.md` (active_plan field) | `hybrid-3-file-integrity.md` C7 |
| `.agents/rules/*.md`      | `governance.md`                 |
| `kernel/`, `.para/`       | `governance.md`                 |

> **Why:** Workflows enforce rules via Step 0 Pre-flight, but direct file edits bypass that guard. This table ensures rule compliance even without a workflow.
>
> **Extensible:** Project-specific rules MAY define additional file guards in their own rule files (e.g., `maintenance.md` may guard `CHANGELOG.md` and `VERSION`).

#### Proactive Guard Scan (v1.7.16)

BEFORE executing any task item in a plan Phase, Agent MUST:

1. Read the Phase section header for `MANDATORY` and `HARNESS GUARD` HTML comments
2. Read the corresponding visible `> ⛔` blockquotes
3. Scan the Task List for `⛔ CHECKPOINT:` items — execute checkpoint action BEFORE proceeding to the next task
4. **IF guard condition is not met → STOP and resolve before continuing**

> Principle: Guards are **momentum breakers** — they exist to prevent Agent from auto-piloting through critical operations.

### 5. Role Boundary & Plan Adherence (Vibecode Session)

- **IF** the system KI `vibecode_session` is **Active**:
  - Agent **MUST** act strictly as a Developer implementing the active plan.
  - Agent **MUST** focus only on writing code to complete the active phase.
  - Agent **MUST NOT** modify project management artifacts (such as `backlog.md`, `done.md`, `project.md`) or system rules files under `.agents/` during coding execution.
  - **Exception**: Changes are allowed if explicitly written as a task in the active phase file inventory.
  - Agent **MUST** defer all backlog updating and status synchronizations to the `/end` workflow.

### 6. Platform Tracker Exemption & CLI Boundary

- **MUST NOT** generate or sync platform-level `task.md` or `implementation_plan.md` files in the `brain/` folder for macro-level plans (e.g., roadmaps, strategies, specifications, brainstorms, or any plans containing `roadmap`, `strategy`, `spec`, or `brainstorm` in their filenames).
- **MUST** strictly separate terminal commands from slash commands:
  - Slash Commands (Workflows) are platform-specific UI commands starting with `/` (e.g., `/open`, `/plan`, `/staging`, `/brainstorm`). These MUST only be triggered/recommended in the chat UI.
  - CLI Commands are local terminal commands starting with `./para` (e.g., `./para status`, `./para update`). These MUST only be run in the terminal shell.
  - **MUST NOT** execute workflows as CLI commands (e.g., running `./para staging` or `./para open` via terminal is invalid).

