# Ecosystem Architecture

> **Version**: 1.7.4 | **Last reviewed**: 2026-04-03

## Overview

PARA Workspace v1.6.0 introduces **Ecosystem Projects** — meta-projects that coordinate multiple related satellite projects without owning source code. This enables multi-project management within the standard PARA structure.

## Model

```text
                      Projects/

  ┌────────────────────────────┐
  │     my-ecosystem/          │  ECOSYSTEM
  │  ├─ project.md             │  type: ecosystem
  │  ├─ artifacts/plans/  ─────┼── Shared plans
  │  └─ docs/strategy.md       │  No repo/
  └─────────────┬──────────────┘
                │
                │  @my-ecosystem/ prefix
                │  (cross-project plan resolution)
                │
      ┌─────────┼─────────┬──────────┐
      ▼         ▼         ▼          ▼
  ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐
  │ app-a │ │ app-b │ │ lib-c │ │ lib-d │  SATELLITES
  │ repo/ │ │ repo/ │ │ repo/ │ │ repo/ │
  └───────┘ └───────┘ └───────┘ └───────┘

  ┌────────────────────────────┐
  │     standalone-project/    │  STANDARD
  │  └─ repo/                  │  type: standard
  └────────────────────────────┘
```

## Schema

New optional fields in `project.md` frontmatter (v1.6.0+):

| Field | Type | Default | Description |
| :-- | :-- | :-- | :-- |
| `type` | `"standard"` \ | `"ecosystem"` | `"standard"` | Project type |
| `ecosystem` | `string` \ | `null` | `null` | Parent ecosystem (for satellite) |
| `satellites` | `string[]` \ | `null` | `null` | Child project IDs |
| `active_plan` | `string` | `""` | Supports `@{eco}/path` syntax |

All fields are optional — existing projects remain valid without changes.

## @Prefix Resolution

Satellites reference shared plans stored in the ecosystem project:

```yaml
# my-app/project.md
active_plan: "@my-ecosystem/plans/shared-roadmap.md"
```

Resolution: `@{name}/path` → `Projects/{name}/artifacts/path`

- Read-only: satellites cannot modify ecosystem files
- Workflows validate that the referenced file exists

## Workflow Adaptation

```text
                   /open [project]
                        │
                  ┌─────┴──────┐
                  │   Read     │
                  │ project.md │
                  └─────┬──────┘
                        │
                 type = ecosystem?
                 ┌──────┴──────┐
                YES            NO
                 │              │
          ┌──────┴──────┐  ┌───┴──────────┐
          │  Skip git   │  │ Normal git   │
          │  List sats  │  │ flow         │
          └─────────────┘  └───┬──────────┘
                               │
                        has ecosystem?
                        ┌──────┴──────┐
                       YES            NO
                        │             │
                 ┌──────┴──────┐  ┌───┴───────┐
                 │ Show eco    │  │  Normal   │
                 │ Resolve @   │  │  flow     │
                 └─────────────┘  └───────────┘
```

| Workflow | Version | Ecosystem Behavior |
| :-- | :-- | :-- |
| `/open` | 1.3.0 | Skip git, list satellites, resolve @prefix |
| `/end` | 1.4.0 | Skip git suggestions, resolve @prefix |
| `/plan` | 1.3.0 | Cross-project plan activation via @prefix |
| `/new-project` | 1.1.0 | `--meta` flag for direct ecosystem creation |
| `/para-audit` | 1.2.0 | Bidirectional consistency validation |

## Consistency Checks

`/para-audit` validates ecosystem health:

| Check | Description | Severity |
| :-- | :-- | :-- |
| Bidirectional references | Ecosystem ↔ satellite must reference each other | ⚠️ Warn |
| @prefix file exists | Referenced plan file must exist at resolved path | 🔴 Error |
| Ecosystem has no `repo/` | Meta-projects should not contain source code | ⚠️ Warn |

## Governance

Ecosystem conventions are managed by **Heuristic H7** (Cross-Project References) in the kernel. These are SHOULD-level guidelines.

Governance roadmap:

```text
v1.6.0  Heuristic H7 (SHOULD)
   │
v1.7.0  Knowledge System + H10 (KI)  ← Shipped
   │
v1.8.0  Department System
   │
v2.0.0  Invariant I12 (MUST)   ← Promote when stable
```

---

_See also: [Knowledge System](./knowledge-system.md) · [RFC-0003](../../rfcs/0003-meta-project-governance.md) · [Project Reference](../reference/project.md) · [Glossary](../reference/glossary.md)_

---

_Last updated: 2026-04-03 (FEAT-61: v1.7.4)_
