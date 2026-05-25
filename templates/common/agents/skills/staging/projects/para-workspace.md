# Staging Template: para-workspace

> **Type:** Project-specific template for `para-workspace`.
> **Usage:** Loaded by `/staging para-workspace` via Sidecar Skill router.

## Template Root

```
TEMPLATE_ROOT = repo/templates/common/agents
```

> `para-workspace` uses the `common/` layer to separate agent templates from profile and knowledge templates.

## Path Mappings

| Workspace Source | Template Destination (relative to TEMPLATE_ROOT) | Recursive |
|:--|:--|:--|
| `.agents/workflows/` | `workflows/` | No (flat copy) |
| `.agents/rules/` | `rules/` | No (flat copy) |
| `.agents/skills/[name]/` | `skills/[name]/` | Yes (full directory) |

## Exclusions

| Pattern | Reason |
|:--|:--|
| `catalog.yml` | Catalog is version-gated — update only during release plan |
| `*.bak` | Backup files are workspace-local |
| `.DS_Store` | OS artifacts |
| `pageel-*.md` | Pageel-specific workflows are not distributed via para-workspace |
| `playground.md` | Local-only experimental workflow |

## Post-Stage Notes

```
Needs: bump kernel_version in .para-workspace.yml template, update catalog.yml entries (id, version, description), update CHANGELOG.md, create release plan via /plan.
```
