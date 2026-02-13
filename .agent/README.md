# PARA Workspace — Repo Agent Context

> This file provides context for AI agents working on this **repo** (not a workspace instance).

## Identity

- **Repo**: `para-workspace` — The governed standard for PARA Workspace.
- **Version**: See `VERSION` file at repo root.
- **Branch convention**: `main` (stable), `refactor/*` (breaking), `feat/*` (features), `fix/*` (patches).

## Repo Structure (v1.4)

```
kernel/       — Constitution: invariants, heuristics, schemas, examples
cli/          — CLI tools: para entrypoint + commands/
workflows/    — Reference workflows (stateless, installable)
templates/    — Scaffolding: common + profiles (dev, general, marketer, ceo)
docs/         — Documentation: architecture, kernel, cli, workflows, migration
```

## Key Rules for Agents

1. **This is a repo, not a workspace.** There are no `Projects/`, `Areas/`, `Resources/`, `Archive/` dirs here.
2. **Kernel invariant changes** require RFC + MAJOR version bump (see `kernel/invariants.md`).
3. **Heuristic changes** require PR + MINOR/PATCH bump (see `kernel/heuristics.md`).
4. **Naming**: kebab-case for all files and directories.
5. **CLI scripts** must include `normalize_path()` for cross-platform compatibility.

## Quick Reference

- Invariants: `kernel/invariants.md` (10 hard rules)
- Heuristics: `kernel/heuristics.md` (8 soft conventions)
- Versioning policy: `VERSIONING.md`
- Contributing: `CONTRIBUTING.md`
