# PARA Workspace Kernel

> **Version**: 1.4.0
> **Status**: Canonical — this is the single source of truth for all PARA Workspace rules.

---

## What is the Kernel?

The Kernel is the **"constitution"** of the PARA Workspace system. It defines the invariant rules, soft heuristics, and schemas that every workspace instance, CLI tool, workflow, and AI agent must follow.

Think of it as:

- **Invariants** = laws (breaking them = unconstitutional = MAJOR version bump)
- **Heuristics** = guidelines (changing them = policy update = MINOR/PATCH)
- **Schemas** = contracts (file formats that tools and agents agree on)

## Core Philosophy

### Three Foundational Principles

1. **Repo is NOT a workspace**: The repo contains only governance (kernel, CLI, templates, workflows, docs). It never contains user data or runtime state.

2. **Workspace is a generated instance**: Each workspace is a standalone runtime, created by CLI from repo + profile + language preference. Multiple workspaces can coexist from one repo.

3. **Kernel is immutable at runtime**: The kernel defines the rules of the game. Agent and CLI always work with `Projects/`, `Areas/`, `Resources/`, `Archive/` — never with "roles" or "personas". Profiles are purely a UX layer for initial configuration.

### The Metaphor

```
Repo    = Constitution + Compiler
Workspace = Operating System Runtime (for Agent + User)
Agent   = Execution Environment
```

## Kernel Components

| File                               | Role                                               | Change Impact |
| ---------------------------------- | -------------------------------------------------- | ------------- |
| `KERNEL.md` (this file)            | Constitution — supreme law                         | MAJOR bump    |
| `invariants.md`                    | Hard rules — MUST NOT be violated                  | MAJOR bump    |
| `heuristics.md`                    | Soft rules — recommended but flexible              | MINOR/PATCH   |
| `schema/tasks.schema.md`           | Defines format for task management files           | Depends       |
| `schema/decision-plan.schema.json` | JSON Schema for `para-decisions/*.json`            | Depends       |
| `examples/`                        | Compliance test vectors — must pass before release | N/A           |

## How the Kernel is Used

### In the Repo (Canonical)

The `kernel/` directory in the repo is the **canonical** version. All changes go through the RFC process defined in `CONTRIBUTING.md`.

### In the Workspace (Snapshot)

When a workspace is created (`para init`) or updated (`para install`), the kernel is copied as a **read-only snapshot** to `Resources/ai-agents/kernel/`. The snapshot version is tracked in `Resources/ai-agents/VERSION`.

### By the Agent

The AI agent reads the kernel snapshot to understand:

- What file structures are valid
- What naming conventions to follow
- How to manage tasks, projects, and archives
- What contracts to enforce

## Governance

- **Invariant changes** require an RFC (`docs/rfcs/`) + MAJOR version bump
- **Heuristic changes** require a PR + MINOR/PATCH version bump
- **Schema changes** require updating all related templates and examples
- All changes must pass the test vectors in `examples/` before release

## Related Documents

- `invariants.md` — Hard rules (read this first)
- `heuristics.md` — Soft rules and conventions
- `schema/` — File format contracts
- `examples/` — Compliance test vectors
- `../docs/kernel.md` — Extended kernel documentation
- `../VERSIONING.md` — Version policy
- `../CONTRIBUTING.md` — Change process
