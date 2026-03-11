# /para Workflow

> **Version**: 1.5.0

The `/para` workflow is the **master controller** for the PARA Workspace. It provides a central dashboard for auditing, configuring, and maintaining workspace health.

## Commands

```
/para
```

## Capabilities

### Workspace Intelligence & Audit

| Command          | Description                                         |
| :--------------- | :-------------------------------------------------- |
| `./para status`  | Bird's-eye view of all projects                     |
| `./para review`  | Deep analysis of structure, rules, docs             |
| Activity Monitor | Identifies stalled projects (no activity in 7 days) |

### Catalog Management

**Workflows** (via `/para-workflow`): `list`, `install`, `standardize`, `validate`

**Rules** (via `/para-rule`): `list`, `install`, `standardize`

### Operations & Lifecycle

| Operation                 | Command                    |
| :------------------------ | :------------------------- |
| Scaffold new project      | `./para scaffold [name]`   |
| Migrate legacy project    | `./para migrate [project]` |
| Archive completed project | `/retro` → `Archive/`      |
| Configure workspace       | `/config`                  |

### Rules & Governance

- **PARA Discipline**: Strict adherence to `Projects/`, `Areas/`, `Resources/` structure
- **Context Routing**: AI stays within project boundaries
- **VCS Safety**: Only commit within `repo/` subdirectories

## Related

- [/para-workflow](./para-workflow.md) — Workflow catalog management
- [/para-rule](./para-rule.md) — Rule catalog management
- [Workflow Documentation](../workflows.md) — Workflow catalog

---

_Added in v1.5.0_
