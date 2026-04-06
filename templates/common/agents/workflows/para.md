---
description: Master PARA Workspace management workflow. Standardize, configure, and maintain the workspace health.
source: catalog
---

# /para

> **Workspace Version:** 1.5.0 (Governed Libraries)

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

- `list`: Compare active workflows vs. governed `catalog.yml`.
- `install`: Install from governed catalog into `.agents/workflows/`.
- `standardize`: Upgrade local workflows to v1.4.1 standards.
- `validate`: Check compliance without making changes.

### 2. Rules

Managed via **`/para-rule`**:

- `list`: Compare active rules vs. governed `catalog.yml`.
- `install`: Install from governed catalog into `.agents/rules/`.
- `standardize`: Ensure rules comply with `para-discipline.md`.

---

## 🏗 Operations & Lifecycle

//turbo

- **Scaffolding**: Create new PARA-compliant projects with `./para scaffold [name]`.
- **Migration**: Upgrade legacy projects using `./para migrate [project]`.
- **Archiving**: Graduate completed projects to `Archive/` after a `/retro`.
- **Configuration**: Managed via **`/config`** for `.para-workspace.yml` and workspace settings.

---

## 🛡 Rules & Governance

- **PARA Discipline**: STRICT adherence to `Projects/`, `Areas/`, `Resources/` structure.
- **Context Routing**: AI must stay within project boundaries (only load relevant files).
- **VCS Safety**: Only commit changes within `repo/` subdirectories. Metadata and session logs stay local.

---

## 📚 Onboarding & Guidance

Ensure users can effectively navigate and utilize the workspace:

- **Workspace Manual**: Ask general questions about PARA structure, schemas, or governance. The `para-kit` skill will guide you.
- **Documentation Manager**: Use **`/docs`** to generate, review, or publish project documentation.
- **Knowledge Capture**: Use **`/learn`** to package insights into `Areas/Learning/`, or **`/para-knowledge`** to save persistent patterns to the KI Store.
- **Kernel Rules**: Review immutable workspace laws at `Resources/ai-agents/kernel/`.

---

## Related

- `/para-workflow` - Workflow automation
- `/para-rule` - AI safety and standards
- `/config` - Metadata management
- `/open` - Session entry point
