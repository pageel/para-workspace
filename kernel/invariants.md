# Kernel Invariants

<!-- ⚠️ READ-ONLY SNAPSHOT — Do NOT modify (I9) -->

> **Breaking any invariant = MAJOR version bump**
> These are the hard rules of PARA Workspace. They MUST NOT be violated by any agent, CLI tool, workflow, or user operation.

---

## I1. PARA Directory Structure

Every workspace MUST have exactly four top-level directories corresponding to
the four PARA pillars: **Projects**, **Areas**, **Resources**, and **Archive**.
Their resolved filesystem names are determined by the workspace `layout` setting
in `.para-workspace.yml` (default: `standard`).

### Layout modes

| `layout` value  | Projects dir   | Areas dir   | Resources dir   | Archive dir   |
|:----------------|:---------------|:------------|:----------------|:--------------|
| `standard`      | `Projects`     | `Areas`     | `Resources`     | `Archive`     |
| `numeric`       | `1_Projects`   | `2_Areas`   | `3_Resources`   | `4_Archive`   |
| `numeric-wide`  | `10_PROJECTS`  | `20_AREAS`  | `30_RESOURCES`  | `40_ARCHIVE`  |

`_inbox` is a fifth optional directory excluded from layout modes; its `_`
prefix already guarantees correct sort order in all three schemes.

**Constraints:**

- Exactly one of the three layout modes MUST be declared (or implied by absence,
  which defaults to `standard`)
- No other top-level content directories are allowed
- Sub-folders within the four PARA dirs use **kebab-case** regardless of layout
- The layout is set once at `para init` and is workspace-wide

## I2. Task Management — Hybrid 3-File Model

Each project manages tasks through three files in `artifacts/tasks/`:

| File                | Role                           | Agent Behavior                                  |
| ------------------- | ------------------------------ | ----------------------------------------------- |
| `backlog.md`        | **CANONICAL** task store       | Primary read/write via `/backlog`               |
| `sprint-current.md` | **Hot Lane** for session tasks | Agent writes quick tasks + ticks `[x]` directly |
| `done.md`           | **APPEND-ONLY** archive        | Completed tasks appended by `/end`              |

**Rules:**

- `backlog.md` is the **operational authority** for all task mutations
  (the only file where tasks are created, edited, re-prioritized, or deleted)
- `sprint-current.md` is for ad-hoc quick tasks during coding sessions
  — agent MAY write directly. NOT a mirror of backlog.
- `done.md` receives completed tasks (both strategic and quick).
  Origin tracked via `#backlog` or `#session` tags.
- `/end` is the **sole sync point** — reconciles hot lane + strategic tasks
- Complete project task history spans `backlog.md` (active) + `done.md` (archive)

## I3. Project Naming

- Project slugs MUST use **kebab-case**: `my-saas-app`, `campaign-q1-2026`
- No spaces or PascalCase in project directory names (note: underscores are used by layout modes for top-level PARA dirs, but NOT in project slugs)
- This ensures agent parsability and cross-platform path safety

## I4. Project Inactivity

- A project with **no active tasks** in `backlog.md` (no items in "In Progress" section) is considered **inactive**
- `para status` must reflect this
- Archiving is a manual decision via `para archive`, not automatic

## I5. Areas Contain No Runtime Tasks

- `Areas/` directories contain **stable knowledge**: SOPs, policies, checklists, documentation
- If an Area contains a checklist, it is a **guideline**, not a runtime task
- Active work belongs in `Projects/`, not `Areas/`

## I6. Archive Is Cold Storage

- `Archive/` is **immutable cold storage**
- Kernel and agent **do NOT read** Archive during normal operations
- Contents in Archive must not be mutated after archiving
- Only `para archive` can move items into Archive
- Archive structure mirrors PARA: `Archive/Projects/`, `Archive/Areas/`, `Archive/Resources/`

## I7. Seeds Are Raw Ideas

- `.beads/seeds.md` contains **ideas, hypotheses, context fragments, raw notes**
- Seeds are NOT tasks — they are inputs for generating tasks and plans
- Seeds are allowed to be messy, partial, and contradictory
- Before archiving a project, perform a "Graduation Review" to extract valuable knowledge from seeds

## I8. No Loose Files

- Every file must belong to a `Project`, `Area`, `Resource`, or `Archive`
- No content files at workspace root (except approved config: `.para-workspace.yml`, `README.md`)
- `.agents/` is the only exception — it contains runtime guardrails

## I9. Resource Immutability

- Files in `Resources/ai-agents/` (kernel snapshot, workflow catalog) are **read-only references**
- Local customizations in `.agents/workflows/` must **NEVER** be written back to `Resources/`
- Resources are for learning, scaffolding, or installation — not for modification during regular work

## I10. Repo ↔ Workspace Separation

- The repo MUST NOT contain `Projects/`, `Areas/`, `Resources/`, `Archive/` directories
- The repo MUST NOT contain user data or workspace state
- The workspace kernel copy (`Resources/ai-agents/kernel/`) is a **snapshot**, not canonical
- The canonical kernel lives only in the repo's `kernel/` directory

## I11. Workflow Language Compliance

- Every workflow execution MUST read `.para-workspace.yml` at the workspace root
- The agent MUST use the value of `preferences.language` (e.g., `vi`, `en`) to determine the user's preferred language
- **All output, reports, session logs, and final summaries** produced by any workflow MUST be translated to this language
- If `.para-workspace.yml` does not exist or `preferences.language` is not set, default to English (`en`)

---

## Compliance

Any tool, workflow, or agent operation that violates these invariants is considered **non-compliant**. Non-compliant behavior should be flagged and corrected.

Changes to invariants require:

1. An RFC in `docs/rfcs/`
2. Community review
3. MAJOR version bump
4. Update to all test vectors in `examples/`
