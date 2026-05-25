---
name: Staging Templates
description: >
  Sidecar data for /staging workflow — project-specific path mapping templates
  loaded just-in-time. Extensible by user.
source: user
---

# Skill: Staging Templates

> **Trigger:** `/staging` workflow requests path mapping for a target project.
> **Pattern:** Sidecar Skill — data resources only, no executable logic.

## Resource Router

| Resource | Relative Path | Loaded when |
|:--|:--|:--|
| Default Template | `projects/default.md` | `/staging [project]` when no project-specific template exists |
| Project Template | `projects/[project-name].md` | `/staging [project]` when project-specific template exists |

## How It Works

1. When `/staging [project]` runs, the workflow reads this Skill at Step 0 (Pre-flight).
2. Agent checks if `projects/[project-name].md` exists (e.g., `projects/para-workspace.md`).
3. **If found:** Load the project-specific template → use its `TEMPLATE_ROOT`, path mappings, and exclusion rules.
4. **If not found:** Load `projects/default.md` → use the generic convention-based mapping.
5. The loaded template defines:
   - **Template Root:** The base path inside `repo/` where agent artifacts are stored. This varies per project:
     - `para-workspace` → `repo/templates/common/agents` (has `common/` layer)
     - `para-graph` → `repo/templates/agents` (flat structure)
   - **Path Mappings:** Workspace directories → destinations relative to `TEMPLATE_ROOT`.
   - **Exclusions:** Files/patterns to never stage (e.g., `catalog.yml`, project-specific exclusions).
   - **Post-Stage Notes:** Project-specific reminders appended to the sprint task.

## Creating a Project Template

To create a custom staging template for a project:

```bash
# Copy the default template and rename
cp .agents/skills/staging/projects/default.md .agents/skills/staging/projects/[project-name].md
# Edit the path mappings and exclusions for your project
```

The user can customize path mappings, add extra exclusions, or define project-specific post-stage notes without modifying the workflow logic.

## Conventions

- Template filenames MUST match the project directory name exactly (case-sensitive).
- `default.md` is the fallback and MUST always exist.
- Templates define **data only** (path maps, exclusions) — no workflow logic.
- All paths in templates are relative to workspace root.
