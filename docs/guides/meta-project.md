# Meta-Project & Ecosystem Guide

> **Version**: 1.6.0 | **Last reviewed**: 2026-03-20

## What is a Meta-Project?

A Meta-Project is a coordination project that manages strategy, roadmaps, and cross-project plans for a group of related projects (an ecosystem). It has **no source code** — only documentation and plans.

| Scenario                         | Solution                                  |
|:---------------------------------|:------------------------------------------|
| Single product, single repo      | Standard project (`type: standard`)       |
| Single product, multiple repos   | **Meta-Project** (`type: ecosystem`)      |
| Unrelated products               | No need — each project is independent     |

## Creating an Ecosystem

### Using `/new-project --meta`

```
/new-project my-ecosystem --meta
```

This scaffolds an ecosystem project (no `repo/` directory):

```
Projects/my-ecosystem/
├── project.md            ← type: ecosystem, satellites: []
├── artifacts/
│   ├── tasks/backlog.md  ← Ecosystem-level backlog
│   └── plans/            ← Cross-project plans
├── docs/                 ← Strategy, architecture docs
└── sessions/             ← Session logs
```

### Manual Setup

```yaml
# Projects/my-ecosystem/project.md
---
goal: "Coordinate the product ecosystem"
status: "active"
type: "ecosystem"
satellites:
  - my-app
  - my-lib
  - my-docs
---
```

## Linking Satellites

Each satellite project declares its parent ecosystem:

```yaml
# Projects/my-app/project.md
---
ecosystem: "my-ecosystem"
---
```

`/para-audit` validates bidirectional consistency — both sides must reference each other.

## Cross-Project Plans

### Create a shared plan

Place plans in the ecosystem's `artifacts/plans/` directory:

```
Projects/my-ecosystem/artifacts/plans/
└── feature-rollout.md
```

### Reference from a satellite

Use the `@{ecosystem}/` prefix in `active_plan`:

```yaml
# Projects/my-app/project.md
active_plan: "@my-ecosystem/plans/feature-rollout.md"
```

**Resolution:** `@my-ecosystem/plans/feature-rollout.md` → `Projects/my-ecosystem/artifacts/plans/feature-rollout.md`

Rules:
- `@{name}/` resolves to `Projects/{name}/artifacts/`
- Read-only — satellites cannot modify ecosystem files
- Workflows validate the referenced file exists

## Workflow Differences

| Step            | Standard Project | Ecosystem Project                |
|:----------------|:-----------------|:---------------------------------|
| Git status      | ✅ Runs           | ⏭️ Skipped (no repo/)            |
| Git log         | ✅ Runs           | ⏭️ Skipped                       |
| Satellites list | ❌ N/A            | ✅ Displayed                      |
| Backlog         | ✅ Read           | ✅ Read (ecosystem-level)         |
| Active plan     | ✅ Read           | ✅ Read                           |

## Schema Reference

| Field         | Type                          | Default      | Description                      |
|:--------------|:------------------------------|:-------------|:---------------------------------|
| `type`        | `"standard"` \| `"ecosystem"` | `"standard"` | Project type                     |
| `ecosystem`   | `string` \| `null`            | `null`       | Parent ecosystem (for satellite) |
| `satellites`  | `string[]` \| `null`          | `null`       | List of satellite project IDs    |
| `active_plan` | `string`                      | `""`         | Supports `@{ecosystem}/path`     |

All fields are optional — existing projects work without changes.

## FAQ

**Does an ecosystem project have a Git repo?**
No. Ecosystem projects have no `repo/` — they only contain strategy docs, plans, and backlogs. Source code lives in satellites.

**Can a satellite belong to multiple ecosystems?**
Currently no. The `ecosystem` field is single-valued.

**Do I need an ecosystem for a single project?**
No. Ecosystems are only useful when you have ≥2 related projects that need coordination.

---

_See also: [Ecosystem Architecture](../architecture/ecosystem.md) · [RFC-0003](../../rfcs/0003-meta-project-governance.md) · [Project Reference](../reference/project.md)_
