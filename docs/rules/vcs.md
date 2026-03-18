# VCS — Version Control Rules

> **Version**: 1.5.4

Comprehensive Git safety rules. Ensures the agent NEVER commits, pushes, merges, or creates branches without user consent. The longest rule (6 sections) because Git is the highest-risk area.

## Scope

- **Type**: Global (all projects)
- **Priority**: 🔴 Critical
- **Trigger**: `git commit`, `push`, `merge`, `branch`, `tag`, or PR operations

## Rules

### 1. Golden Rule

MUST NOT perform `git commit` or `git push` without explicit user approval. Exception: trusted workflows (`/push`, `/release`) with built-in confirmation.

### 2. Ignore Before Commit

MUST verify `.gitignore` exists and covers mandatory patterns: `node_modules/`, `dist/`, `build/`, `.next/`, `.env`, `.env.local`, `.vscode/`, `.DS_Store`.

### 3. Secrets Prohibition

MUST NEVER create `.env.local` or any `.env` file with real credentials. Dangerous files that MUST NEVER be committed: `.env*`, `*.pem`, `*.key`, `id_rsa*`, `*.sqlite`, `credentials.json`.

### 4. Git Scope Separation

MUST NOT `git add` workspace data (`sessions/`, `_inbox/`, `Archive/`) into a project's repo. MUST verify `Cwd` is inside `Projects/[project-name]/repo/`.

### 5. Workflow Integration

When running `/push` or `/release`: check `.gitignore`, scan for sensitive files, warn user, STOP if critical secrets detected.

### 6. Branch & Merge Safety (v1.5.4)

| Sub-rule | Constraint |
|:---------|:-----------|
| **6a. Branch Creation** | MUST propose and get user approval before creating |
| **6b. Merge Prohibition** | MUST NOT `git merge` into `main` locally — use PR |
| **6c. Pull Request** | MUST NOT create PR without user approval |
| **6d. Post-Merge** | MUST ask user to test before tagging a release |

**Summary flow:**

```
Branch:  propose → user approves → create
Code:    develop on branch → push branch
PR:      propose → user approves → create PR
Merge:   user merges on GitHub (not local)
Tag:     user tests → propose tag → user approves
```

## Related

- [Agent Behavior](./agent-behavior.md) — Context Recovery includes VCS triggers
- [Governance](./governance.md) — Repository Protection (I10)
- **Source**: `templates/common/agent/rules/vcs.md`
