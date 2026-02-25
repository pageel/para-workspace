---
description: Manage workspace metadata and configuration
source: catalog
---

# /config [action]

> **Workspace Version:** 1.4.1 (Governed Libraries)

Manage the workspace configuration stored in `.para-workspace.yml` and related settings.

## Actions

| Action        | Description                                    |
| :------------ | :--------------------------------------------- |
| `show`        | Display current workspace configuration        |
| `update`      | Update a specific configuration value          |
| `add-project` | Register a new project in the workspace config |

## Steps

### show

// turbo

Read `.para-workspace.yml` and display a formatted overview:

```
⚙️ WORKSPACE CONFIGURATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Name:       [workspace-name]
Version:    [version]
Language:   [preferences.language]
Projects:   [list of registered projects]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### update

1. Ask: Which key to update? (e.g., `preferences.language`, `version`)
2. Read current value from `.para-workspace.yml`.
3. Apply new value and write back.
4. Confirm the change.

### add-project

1. Ask: Project name?
2. Verify the project directory exists at `Projects/[project-name]/`.
3. Add to the projects list in `.para-workspace.yml`.
4. Confirm registration.

## Related

- `/para` — Master workspace controller
- `/open` — Start session (reads config for language preference)
