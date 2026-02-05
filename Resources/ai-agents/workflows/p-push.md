---
description: Fast commit and push changes with verification
---

# /push [project-name] ["message"] [--quick]

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
