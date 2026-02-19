---
description: Master PARA Workspace management workflow. Standardize, configure, and maintain the workspace health.
---

# /para

> **Workspace Version:** 1.4.x (PARA Architecture)

The master controller workflow for the PARA Workspace. Use it to audit, configure, and maintain workspace health.

## 📋 Workspace Intelligence & Audit

- **Status Check**: Run `./para status` for a bird's-eye view of all projects.
- **Health Audit**: Use `./para review` for a deep analysis of structure, rules, and documentation.
- **Activity Monitor**: Identify stalled projects (no activity in 7 days) and propose updates or a `/retro`.

---

## 🛠 Catalog Management

Extend workspace capabilities by managing workflows and rules:

### 1. Workflows

Managed via **`/para-workflow`**:

- `list`: Show catalog vs. active workflows.
- `install`: Download from `Resources/ai-agents/workflows/`.
- `standardize`: Upgrade local workflows to the latest PARA standards.

### 2. Rules

Managed via **`/para-rule`**:

- `list`: Show catalog vs. active rules.
- `install`: Download from `Resources/ai-agents/rules/`.
- `standardize`: Ensure rules comply with `para-discipline.md`.

---

## 🏗 Operations & Lifecycle

//turbo

- **Scaffolding**: Create new PARA-compliant projects with `./para scaffold [name]`.
- **Migration**: Upgrade legacy projects using `./para migrate [project]`.
- **Archiving**: Graduate completed projects to `Archive/` after a `/retro`.
- **Configuration**: Managed via **`/config`** for `metadata.json` and workspace settings.

---

## 🛡 Rules & Governance

- **PARA Discipline**: STRICT adherence to `Projects/`, `Areas/`, `Resources/` structure.
- **Context Routing**: AI must stay within project boundaries (only load relevant files).
- **VCS Safety**: Only commit changes within `repo/` subdirectories. Metadata and session logs stay local.

---

## Related

- `/para-workflow` - Workflow automation
- `/para-rule` - AI safety and standards
- `/config` - Metadata management
- `/open` - Session entry point
