# Staging Template: para-graph

> **Type:** Project-specific template for `para-graph`.
> **Usage:** Loaded by `/staging para-graph` via Sidecar Skill router.

## Template Root

```
TEMPLATE_ROOT = repo/templates/agents
```

> `para-graph` uses a flat `templates/agents/` structure without the `common/` layer.

## Path Mappings

| Workspace Source | Template Destination (relative to TEMPLATE_ROOT) | Recursive |
|:--|:--|:--|
| `.agents/workflows/para-graph.md` | `workflows/para-graph.md` | No (single file) |
| `.agents/rules/graph-first-policy.md` | `rules/graph-first-policy.md` | No (single file) |
| `.agents/skills/para-graph/` | `skills/para-graph/` | Yes (full directory) |

> **Note:** para-graph only stages its OWN project-specific artifacts, not the full workspace library.

## Exclusions

| Pattern | Reason |
|:--|:--|
| `catalog.yml` | Not applicable — para-graph does not have a workflow catalog |
| `*.bak` | Backup files are workspace-local |
| All other workflows | Only `para-graph.md` is project-owned |
| All other rules | Only `graph-first-policy.md` is project-owned |

## Post-Stage Notes

```
Needs: version bump in package.json, update tool.manifest.yml shipped_in versions, rebuild tarball via npm run release:pack.
```
