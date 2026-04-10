# Ecosystem Architecture

> **Version**: 1.7.11 | **Last reviewed**: 2026-04-10

## Overview

PARA Workspace v1.6.0 introduces **Ecosystem Projects** — meta-projects that coordinate multiple related satellite projects without owning source code. v1.7.6 adds the **meta-project** type: a hybrid that owns both a `repo/` AND satellite coordination.

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

### Project Types

New optional fields in `project.md` frontmatter (v1.6.0+):

| Field | Type | Default | Description |
| :-- | :-- | :-- | :-- |
| `type` | `"standard"` \| `"ecosystem"` \| `"meta-project"` | `"standard"` | Project type |
| `ecosystem` | `string` \| `null` | `null` | Parent ecosystem (for satellite) |
| `satellites` | `string[]` \| `null` | `null` | Child project IDs |
| `active_plan` | `string` | `""` | Supports `@{eco}/path` syntax |
| `strategy` | `string` \| `null` | `null` | Strategy docs path (v1.6.1) |
| `roadmap` | `string` \| `null` | `null` | Roadmap plan path (v1.6.1) |

**Type semantics (v1.7.6):**

| Type | Has `repo/` | Has satellites | Git operations |
| :-- | :-- | :-- | :-- |
| `standard` | ✅ | Optional | Normal |
| `ecosystem` | ❌ | ✅ Required | Skip |
| `meta-project` | ✅ | ✅ Required | Normal |

All fields are optional — existing projects remain valid without changes.

## @Prefix Resolution (v1.6.3 Central Gate)

Satellites reference shared plans stored in the ecosystem project:

```yaml
# my-app/project.md
active_plan: "@my-ecosystem/plans/shared-roadmap.md"
```

Resolution: `@{name}/path` → `Projects/{name}/artifacts/path`

**Rules:**

- `@{name}/` → `Projects/{name}/artifacts/` (for `roadmap`, `active_plan`)
- `@{name}/` → `Projects/{name}/` (for `strategy` — lives in `docs/`)
- Applies to 3 fields: `strategy`, `roadmap`, `active_plan`
- Read-only: satellites cannot modify ecosystem files
- Workflows validate that the referenced file exists
- If field is null/empty → skip entirely (zero I/O)

## Workflow Adaptation

### Decision Flow (v1.7.6 update)

```text
                   /open [project]
                        │
                  ┌─────┴──────┐
                  │   Read     │
                  │ project.md │
                  └─────┬──────┘
                        │
                   type = ?
         ┌──────────┼──────────┐
      ecosystem  meta-project  standard
         │          │              │
  ┌──────┴──────┐   │       ┌─────┴─────────┐
  │  Skip git   │   │       │ has ecosystem?│
  │  List sats  │   │       │  YES → eco ctx│
  │  No repo/   │   │       │  NO  → normal │
  └─────────────┘   │       └───────────────┘
              ┌─────┴──────┐
              │ Run git ✅  │
              │ List sats   │
              │ Has repo/ ✅│
              └─────────────┘
```

> **meta-project** (v1.7.6): Combines both — runs git (has `repo/`) AND lists satellites.

| Workflow | Version | Ecosystem Behavior |
| :-- | :-- | :-- |
| `/open` | 1.4.0 | Skip git (ecosystem only), list satellites, resolve @prefix |
| `/end` | 1.5.0 | Skip git suggestions for ecosystem, resolve @prefix |
| `/plan` | 1.4.0 | Cross-project plan activation via @prefix |
| `/new-project` | 1.1.0 | `--meta` flag for direct ecosystem creation |
| `/para-audit` | 1.2.0 | Bidirectional consistency + meta-project validation |

## Consistency Checks

`/para-audit` validates ecosystem health:

| Check | Description | Severity |
| :-- | :-- | :-- |
| Bidirectional references | Ecosystem ↔ satellite must reference each other | ⚠️ Warn |
| @prefix file exists | Referenced plan file must exist at resolved path | 🔴 Error |
| Ecosystem has no `repo/` | Pure ecosystem should not contain source code | ⚠️ Warn |
| Meta-project has `repo/` | meta-project MUST have `repo/` + satellites | ⚠️ Warn |

## Governance

Ecosystem conventions are managed by **Heuristic H7** (Cross-Project References) in the kernel. These are SHOULD-level guidelines.

### Dynamic KI Templates (v1.7.6)

System KI templates at `repo/templates/knowledge/para_*` use template variables (`{{KERNEL_VERSION}}`, `{{LANGUAGE}}`, `{{PROFILE}}`). CLI renders variables into actual values at `./para install` or `./para update` time, ensuring KIs always reflect the current workspace state.

---

_See also:_

- _[Sidecar Skill Pattern](./sidecar-skill.md)_
- _[Knowledge System](./knowledge-system.md)_
- _[RFC-0003](../../rfcs/0003-meta-project-governance.md)_
- _[Project Reference](../reference/project.md)_
- _[Glossary](../reference/glossary.md)_

---

_Last updated: 2026-04-10 (FEAT-70: v1.7.11.1 docs publish)_
