---
description: Manage workspace metadata and configuration
source: catalog
---

# /para-config [action]

> **Workspace Version:** 1.5.0 (Governed Libraries)

Manage the workspace configuration stored in `.para-workspace.yml` and related settings.

## Actions

| Action | Description |
| :-- | :-- |
| `show` | Display current workspace configuration |
| `update` | Update a specific configuration value |
| `add-project` | Register a new project in the workspace config |

## Steps

### show

// turbo

Read `.para-workspace.yml` and display a formatted overview:

```
⚙️ WORKSPACE CONFIGURATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Name:        [workspace-name]
Version:     [version]
Language:    [language]
Date Format: [preferences.date_format] (or "YYYY-MM-DD" if not set)
Profile:     [profile]
Projects:    [list of registered projects]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### update

1. Ask: Which key to update? (e.g., `language`, `preferences.date_format`, `profile`)
2. Read current value from `.para-workspace.yml`.
3. If updating `preferences.date_format`, suggest common options:
   - `YYYY-MM-DD` — ISO 8601 (default, recommended)
   - `DD/MM/YYYY` — European / Vietnamese
   - `MM/DD/YYYY` — US
   > ⚠️ This only affects **content display dates**. Filenames always use `YYYY-MM-DD` per naming rule §6.
4. Apply new value and write back.
5. Confirm the change.

### add-project

1. Ask: Project name?
2. Verify the project directory exists at `Projects/[project-name]/`.
3. Add to the projects list in `.para-workspace.yml`.
4. Confirm registration.

## Related

- `/para` — Master workspace controller
- `/open` — Start session (reads config for language preference)
- `naming.md` §6 — Date format convention (filenames vs content display)
