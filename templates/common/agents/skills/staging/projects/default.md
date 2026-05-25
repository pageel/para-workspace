# Staging Template: Default

> **Type:** Fallback template — used when no project-specific template exists.
> **Usage:** Loaded by `/staging` workflow via Sidecar Skill router.

## Template Root

The base directory inside `repo/` where agent artifacts are stored. This varies per project.

```
TEMPLATE_ROOT = repo/templates/agents
```

> Agent MUST prepend `Projects/[project]/` + `TEMPLATE_ROOT` to build the full path.

## Path Mappings

| Workspace Source | Template Destination (relative to TEMPLATE_ROOT) | Recursive |
|:--|:--|:--|
| `.agents/workflows/` | `workflows/` | No (flat copy) |
| `.agents/rules/` | `rules/` | No (flat copy) |
| `.agents/skills/[name]/` | `skills/[name]/` | Yes (full directory) |

## Exclusions

Files and patterns that MUST NOT be staged regardless of diff status:

| Pattern | Reason |
|:--|:--|
| `catalog.yml` | Catalog updates are versioned separately during release |
| `*.bak` | Backup files are workspace-local |
| `.DS_Store` | OS artifacts |

## Post-Stage Notes

Additional context appended to the sprint-current task entry:

```
Needs: version bump, catalog update, release plan.
```
