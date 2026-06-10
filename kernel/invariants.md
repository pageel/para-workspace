# Kernel Invariants

<!-- ⚠️ READ-ONLY SNAPSHOT — Do NOT modify (I9) -->

> **Breaking any invariant = MAJOR version bump**
> These are the hard rules of PARA Workspace. They MUST NOT be violated by any agent, CLI tool, workflow, or user operation.

---

## I1. PARA Directory Structure

Every workspace MUST have exactly four top-level directories:

```
Projects/    — Active work with deadlines or deliverables
Areas/       — Stable knowledge, SOPs, ongoing responsibilities
Resources/   — Reference materials, tools, templates
Archive/     — Cold storage for completed/cancelled items
```

**Constraints:**

- These directories use **PascalCase** (the only exception to kebab-case convention)
- No other top-level content directories are allowed
- Sub-folders within these use **kebab-case**

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
- No spaces, underscores, or PascalCase in project directory names
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

- Every workflow execution MUST read `.para-workspace.yml` at the workspace root to resolve the user's preferred language.
- The agent MUST parse the language configuration according to the Hierarchical Resolution Pipeline:
  1. **Modern Map:** Check the `language` key at the root. If it is a map, extract sub-keys: `chat` (for communication), `thinking` (for internal reasoning <thought>), `artifacts` (for task/plan generated files in `artifacts/`), falling back to `default` (or ultimate fallback "en").
  2. **Root String:** If `language` is a string, use it for chat, thinking, and artifacts.
  3. **Nested Preferences (Legacy):** If undefined, look for `preferences.language` (legacy).
  4. **Ultimate Fallback:** Default to English ("en") if no configuration is present (crucial for OSS projects).
- All outputs (chat responses, generated files, logs, and reports) MUST comply with these parsed language roles.

---

## Compliance

Any tool, workflow, or agent operation that violates these invariants is considered **non-compliant**. Non-compliant behavior should be flagged and corrected.

Changes to invariants require:

1. An RFC in `docs/rfcs/`
2. Community review
3. MAJOR version bump
4. Update to all test vectors in `examples/`
