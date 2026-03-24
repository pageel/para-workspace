# Project Schema Reference

> Reference documentation for `project.md` — the project manifest file.

## Overview

Every project in `Projects/` has a `project.md` file containing YAML frontmatter
that defines project metadata, status, and ecosystem relationships.

Schema: `kernel/schema/project.schema.json`

## Required Fields

| Field            | Type   | Description                         | Example              |
|:-----------------|:-------|:------------------------------------|:---------------------|
| `name`           | string | Kebab-case project name             | `my-cms`             |
| `status`         | enum   | active, inactive, archived          | `active`             |
| `kernel_version` | string | Kernel version at creation (semver) | `1.6.0`              |
| `created_at`     | date   | ISO 8601 creation date              | `2026-03-20`         |

## Optional Fields

| Field          | Type           | Description                                | Default     |
|:---------------|:---------------|:-------------------------------------------|:------------|
| `owner`        | string         | GitHub handle or name                      | —           |
| `profile`      | enum           | dev, general, marketer, ceo                | —           |
| `deadline`     | date \| null   | Project deadline                           | `null`      |
| `description`  | string         | Project description                        | `""`        |
| `tags`         | array          | Tag list                                   | `[]`        |
| `active_plan`  | string \| null | Path to active plan (see below)            | `""`        |
| `agent`        | object|null   | Agent config map: `rules`, `skills` booleans (v1.6.2+) | `null`      |
| `has_rules`    | boolean        | **DEPRECATED** — use `agent.rules` instead | `false`     |

## Ecosystem Fields (v1.6.0+)

| Field        | Type           | Description                            | Default     |
|:-------------|:---------------|:---------------------------------------|:------------|
| `type`       | enum           | standard, ecosystem                    | `standard`  |
| `ecosystem`  | string \| null | Parent ecosystem name (satellites)     | `null`      |
| `satellites` | array \| null  | Satellite project slugs (ecosystem)    | `null`      |

### Project Types

- **standard** — Regular project with source code in `repo/`. Default type.
- **ecosystem** — Meta-project coordinating satellites. No `repo/` directory.

### Ecosystem Relationships

```text
Projects/my-ecosystem/ (type: ecosystem)
├── satellites: [my-cms, my-tool]
│
├── Projects/my-cms/ (ecosystem: my-ecosystem)
└── Projects/my-tool/ (ecosystem: my-ecosystem)
```

- Ecosystem projects list satellites in `satellites` array
- Satellite projects reference their parent in `ecosystem` field
- `/para-audit` validates consistency between these fields

## Cross-Project Plans (`@` prefix)

The `active_plan` field supports cross-project plan references:

| Pattern                      | Resolves to                                      |
|:-----------------------------|:-------------------------------------------------|
| `plans/xxx.md`               | `Projects/{project}/artifacts/plans/xxx.md`      |
| `@{ecosystem}/plans/xxx.md`  | `Projects/{ecosystem}/artifacts/plans/xxx.md`    |

Example:

```yaml
# In my-cms/project.md:
ecosystem: my-ecosystem
active_plan: "@my-ecosystem/plans/shared-plan.md"
# → resolves to: Projects/my-ecosystem/artifacts/plans/shared-plan.md
```

Workflows that resolve `active_plan`: `/open`, `/end`, `/plan`, `/para-audit`.

## See Also

- [Project Schema](../../kernel/schema/project.schema.json)
- [Heuristics H7: Cross-Project References](../../kernel/heuristics.md)
- [Workflow: /new-project](../../../templates/common/agent/workflows/new-project.md)
