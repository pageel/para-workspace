# /para-workflow Workflow

> **Version**: 1.5.0

The `/para-workflow` workflow manages, installs, and standardizes AI Agent workflows within a PARA Workspace. This manages the **workflow library itself** — not for day-to-day workflow usage.

## Commands

```
/para-workflow [action] [name]
```

| Action        | Description                                   |
| :------------ | :-------------------------------------------- |
| `list`        | Compare active workflows vs. governed catalog |
| `add`         | Create a new PARA-compliant workflow          |
| `standardize` | Upgrade workflow to v1.4.1 standards          |
| `install`     | Install workflow from governed catalog        |
| `validate`    | Check compliance without making changes       |

## Actions

### list

Lists active workflows in `.agent/workflows/`, reads `catalog.yml`, and displays comparison: ✅ Installed / ⚠️ Not installed / 🔶 Untracked.

### add

Creates `.agent/workflows/[name].md` with required YAML frontmatter (`description`), version label, `[project-name]` placeholders, `// turbo` annotations, and relative paths.

### standardize

8-point checklist: YAML frontmatter, version label, English language, relative paths, project placeholders, catalog paths, turbo annotations, no duplicate scope.

### install

Resolves source from catalog, checks for conflicts (delegates to `/install` if needed), and copies to `.agent/workflows/`.

### validate

Runs standardize checklist in read-only mode and outputs a compliance report with warnings and errors.

## Key Notes

- The governed catalog (`catalog.yml`) is the single source of truth for officially supported workflows
- User-created workflows not in catalog are valid but **untracked** — no automatic updates
- Always backup before running `standardize` on modified workflows

## Related

- [/para Workflow](./para.md) — Master workspace controller
- [/para-rule](./para-rule.md) — Rule management (sister workflow)
- [/install Workflow](./install.md) — Generic installer with conflict resolution
- [Workflow Documentation](../workflows.md) — Workflow catalog

---

_Added in v1.5.0_
