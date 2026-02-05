---
description: Master PARA Workspace management workflow for agents. Use this to standardize, review, or initialize projects.
---

# /para

> **Workspace Version:** 1.3.1 (PARA Architecture)

This workflow guides the agent through workspace-level PARA maintenance.

### 1. Identify Target

- If no specific project is mentioned, run `./para status` to identify projects needing migration or review (e.g., status is `[Unknown]` or deadline is missing).

### 2. Standardization (Migration)

// turbo

- For any folder that isn't yet in `Projects/` or lacks a v1.3 `project.md` (YAML), run:
  ```bash
  ./para migrate <folder_name>
  ```

### 3. Project Initialization

- To start a new project from scratch, use:
  ```bash
  ./para scaffold <new_project_name>
  ```

### 4. Health Check

- Run `./para status` to confirm everything is correctly indexed.

### 5. Task Sync

- Review the `artifacts/tasks.md` of the active project and ensure it reflects the current reality.

### 6. VCS Boundary (Git Rule)

- For any operation, ONLY perform `git commit` or `git push` if changes were made within the `repo/` subdirectory of a project.
- Changes to metadata folders (`docs/`, `sessions/`, `artifacts/`) or project-level files (like `project.md`) should NOT be committed unless the repository strictly tracks them (e.g., in `repo/docs/`).
