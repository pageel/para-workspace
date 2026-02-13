---
description: Master PARA Workspace management workflow. Standardize, configure, and maintain the workspace health.
---

# /para

> **Workspace Version:** 1.4.0

This is the master controller workflow for the PARA Workspace. Use it to audit, configure, and extend the workspace capabilities.

### 1. Workspace Intelligence & Audit

- Run `./para status` to get a bird's-eye view of all projects.
- **Rules & Workflows Stats**: Monitor the density of automation vs. standard rules across projects.
- **Stalled Projects**: Identify projects with no activity in 7 days and propose a `/p-retro` or task update.

### 2. Configuration & Customization (`./para config`)

- **Workflow Prefix**: Check or change the prefix (default `p-`) using `./para config get/set workflows.prefix`.
- **Environment Context**: Ensure settings are correctly applied to the workspace.

### 3. Catalog Management (Rules & Workflows)

Manage the "Core Skills" of the workspace by syncing from the library:

- **Workflows (`./para work`)**:
  - `list`: Show available workflows in `.agent/workflows/`.
  - `install <name>`: Install to root `.agent/workflows/`.
  - **MERGE (`-m`)**: Use `install <name> -m` to blend catalog updates into your customized workflows without losing your specific tweaks.
- **Rules (`./para rule`)**:
  - `list`: Show available rules in `.agent/rules/`.
  - `install <name>`: Install to root `.agent/rules/`.

### 4. Lifecycle Operations

// turbo

- **Standardization**: Migrate non-PARA folders using `./para migrate <folder>`.
- **Scaffolding**: Create new high-performance project structures with `./para scaffold <name>`.
- **Archiving**: Graduate projects to `Archive/` after a `/p-retro` to extract Beads and Patterns.

### 5. Context Routing & Guardrules

- **RFC-0003**: Enforce strict context boundaries. Don't let the agent load unrelated files.
- **VCS Boundary**: Only commit changes within `repo/` subdirectories. Metadata and sessions stay local unless otherwise specified.
- **Versioning**: Follow kernel versioning policy (see VERSIONING.md).
  - **Level 1 (MAJOR)**: Any jump to a new MAJOR version MUST have a formal **Implementation Plan** and align with the public **Roadmap**.

---

_Tip: Use `/para status` as your first step in any session to understand the current "Ground Truth"._
