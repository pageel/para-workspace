---
description: Fast commit and push changes with verification
---

# /p-push [project-name] ["message"] [--quick]

> **Workspace Version:** 1.3.1 (PARA Architecture)

Standardized commit and push logic for PARA workspaces.

## Steps

### 1. Pre-Commit Check

Check git status and sensitive files (keys, env).

### 2. Build (Optional)

Run `npm run build` unless `--quick` is used.

### 3. Commit

Auto-generate message if missing. Append to CHANGELOG.md.

### 4. Push

Push to GitHub.
