---
name: Docs Templates
description: Sidecar data for /docs workflow — document templates loaded just-in-time when generating docs.
source: catalog
---

# Skill: Docs Templates

> Sidecar Skill for the `/docs` workflow. Contains document templates
> that the Agent loads **only when generating documentation** (Step 6).
>
> **Pattern:** Workflow = Logic → Sidecar Skill = Data Router.

## When to Load

- `/docs new` → Step 6 (Generate Documentation): load relevant template from `references/`
- `/docs review` → NOT needed
- `/docs update` → NOT needed
- `/docs publish` → NOT needed

## References

| File | When | Purpose |
|:--|:--|:--|
| `references/architecture.md` | Project type = any | System overview & component diagram |
| `references/cli.md` | Project type = CLI Tool | Command reference and usage |
| `references/deployment.md` | Project type = Web App, Website | Prerequisites, build, deploy, env vars |
| `references/changelog.md` | No existing changelog | Version history template |
| `references/strategy.md` | Strategy creation (Step 3.5) | Vision, decisions, roadmap alignment |

> **Convention:** Data files live in `references/` (not `templates/`).

## Graph-Awareness

When generating documentation that covers code architecture or features:

> 🔍 If project has `.beads/graph/`, read `para-graph §3.3.2` for the graph-enhanced
> documentation pipeline (build → enrich → context bundle per doc).
> If no graph → proceed with source-only doc writing.
