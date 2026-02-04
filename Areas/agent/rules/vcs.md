# Version Control Rules

**GOLDEN RULE:** AI Agent MUST NOT `git commit` or `git push` without user info, unless running a specific workflow like `/push`.

## 1. Ignore Files

Always check `.gitignore` before operations.

**Mandatory Ignores:**

```
node_modules/
dist/
.env
.env.*
.DS_Store
.vscode/
_secrets/
```

## 2. Git Scope

**Workspace vs Project:**

- **Workspace Data** (`Areas/`, `Resources/`, `Archive/`): Generally tracked in the workspace repo (this repo).
- **Project Code** (`Projects/[name]/repo`): TRACKED IN SEPARATE REPOS.
  - DO NOT `git add` inside a sub-repo from the workspace root.
  - ALWAYS `cd` into `Projects/[name]/repo` before running git commands for that project.

## 3. Safety Checks

// turbo

```bash
# Check for sensitive files
git ls-files | grep -E "\.(env|pem|key|db|sqlite)$"
```
