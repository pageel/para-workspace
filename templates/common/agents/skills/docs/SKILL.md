---
name: docs
description: "Sidecar data for /docs workflow — loads document templates (architecture, CLI, deployment, changelog, strategy) just-in-time when generating documentation. Use when running /docs new to select and apply the correct reference template."
metadata:
  source: catalog
---

# Skill: Docs Templates

> Provides pre-built document templates for architecture docs, CLI references,
> deployment guides, changelogs, and strategy documents. Loaded by the `/docs`
> workflow **only during `/docs new`** (Step 6 — Generate Documentation).

## When to Load

- `/docs new` → Step 6 (Generate Documentation): load relevant template from `references/`
- `/docs review` → NOT needed
- `/docs update` → NOT needed
- `/docs publish` → NOT needed

## How to Apply

1. Read the template file from `references/` that matches the document type
2. Use the template as the structural skeleton for the generated document
3. Fill all placeholder sections with project-specific content
4. Verify no template markers (e.g. `[placeholder]`, `TODO`) remain in the output

## References

| File | When | Purpose |
|:--|:--|:--|
| `references/architecture.md` | Project type = any | System overview & component diagram |
| `references/cli.md` | Project type = CLI Tool | Command reference and usage |
| `references/deployment.md` | Project type = Web App, Website | Prerequisites, build, deploy, env vars |
| `references/changelog.md` | No existing changelog | Version history template |
| `references/strategy.md` | Strategy creation (Step 3.5) | Vision, decisions, roadmap alignment |

> **Convention:** Data files live in `references/` (not `templates/`).
