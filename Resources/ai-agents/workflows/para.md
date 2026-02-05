---
description: Master PARA Workspace management workflow for agents. Use this to standardize, review, or initialize projects.
---

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
