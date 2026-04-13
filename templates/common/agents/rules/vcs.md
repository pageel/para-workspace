---
description: Git operations — commit, push, merge, branch, tag, PR safety rules
trigger: always_on
glob:
---

# Version Control Rules

<!-- ⚠️ GOVERNED — /para-rule only. Overwritten by para update -->

> Agent governance rule for Git and version control safety.

## Scope

- [x] Global (applies to entire workspace)

## Rules

### 1. Golden Rule

- **MUST NOT** perform `git commit` or `git push` without explicit user approval.
- **MUST** set `SafeToAutoRun: false` for any auto-generated `git commit` or `git push` tool calls to trigger explicit UI consent popup.
- **Exception**: Approved workflows (`/push`, `/release`) include built-in user confirmation.

### 2. Ignore Before Commit

**MUST** verify `.gitignore` exists and covers mandatory patterns before any git operation.

#### Mandatory Ignores

```gitignore
# Dependencies
node_modules/

# Build output
dist/
build/
.next/
.astro/

# Platform-specific
.vercel/
.wrangler/

# Environment files (CRITICAL - secrets)
.env
.env.local
.env.*.local
*.local

# IDE & Editor
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store
Thumbs.db
```

### 3. Secrets Prohibition

- **MUST NEVER** create `.env.local` or any `.env` file containing real credentials.
- **SHOULD** use `env.example.txt` for templates.
- **MUST** direct the user to configure secrets manually.

#### Dangerous Files (MUST NEVER be committed)

- `.env*` (API keys, credentials)
- `*.pem`, `*.key` (Private keys)
- `id_rsa*` (SSH keys)
- `*.sqlite`, `*.db` (Databases)
- `credentials.json` (Service accounts)

### 4. Git Scope Separation

- **MUST NOT** `git add` workspace data (`sessions/`, `_inbox/`, `Archive/`) into a project's repo.
- **MUST** verify `Cwd` is inside `Projects/[project-name]/repo/` before running git commands.

### 5. Workflow Integration

When running `/push` or `/release`, **MUST**:

1. Check `.gitignore` exists.
2. Scan for sensitive files being tracked.
3. Warn the user if sensitive files are found.
4. **STOP** if critical secrets are detected — never force-push.

### 6. Branch & Merge Safety

#### 6a. Branch Creation

- **MUST** propose branch creation and get user approval before executing.
- **MUST NOT** auto-create branches — branching is a user decision.
- **Example**: "Tôi đề xuất tạo branch `feature/xyz`, bạn đồng ý không?"

#### 6b. Merge Prohibition

- **MUST NOT** perform `git merge` into `main` (or primary branch) locally.
- **MUST** use Pull Request (PR) for all merges into `main`.
- **Exception**: User explicitly requests local merge.

#### 6c. Pull Request

- **MUST NOT** create a Pull Request (`gh pr create`) without explicit user approval.
- **SHOULD** propose PR title and body, then ask user to confirm.

#### 6d. Post-Merge

- After PR merge, **MUST** ask user to test before tagging a release.
- **MUST NOT** auto-tag versions — tagging is a user decision.

#### Summary Flow

```
Branch:  propose → user approves → create
Code:    develop on branch → push branch
PR:      propose → user approves → create PR
Merge:   user merges on GitHub (not local)
Tag:     user tests → propose tag → user approves
```
