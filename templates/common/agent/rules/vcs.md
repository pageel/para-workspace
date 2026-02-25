# Version Control Rules

> Agent governance rule for Git and version control safety.

## Scope

- [x] Global (applies to entire workspace)

## Rules

### 1. Golden Rule

- **MUST NOT** perform `git commit` or `git push` without explicit user approval.
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
