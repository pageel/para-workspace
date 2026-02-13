# Kernel Documentation

> For the canonical kernel files, see `../kernel/`

## What is the Kernel?

The Kernel is the rule system that governs all PARA Workspace instances. It defines:

- **Invariants**: Hard rules that must not be violated (change = MAJOR bump)
- **Heuristics**: Soft conventions that are recommended (change = MINOR/PATCH)
- **Schemas**: File format contracts for tasks, decisions, etc.

## Invariants Summary

See `../kernel/invariants.md` for full details.

| #   | Rule                                           |
| --- | ---------------------------------------------- |
| I1  | PARA directory structure is mandatory          |
| I2  | Hybrid 3-file task model (backlog = canonical) |
| I3  | kebab-case project naming                      |
| I4  | No active tasks = inactive project             |
| I5  | Areas contain no runtime tasks                 |
| I6  | Archive is immutable cold storage              |
| I7  | Seeds are raw ideas, not tasks                 |
| I8  | No loose files at workspace root               |
| I9  | Resources are read-only references             |
| I10 | Repo ↔ Workspace separation                    |

## Kernel Change Process

1. **Invariant changes**: RFC required → review → MAJOR bump
2. **Heuristic changes**: PR → review → MINOR/PATCH bump
3. **Schema changes**: Must update templates + examples

All changes must pass test vectors in `kernel/examples/`.

## Kernel in Workspaces

When installed in a workspace, the kernel exists as a **read-only snapshot** at `Resources/ai-agents/kernel/`. The version is tracked in `Resources/ai-agents/VERSION`.
