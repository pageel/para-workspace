# Version Control Rules

**GOLDEN RULE:** AI Agents DO NOT perform `git commit` or `git push` during normal feature/fix workflows without explicit user approval. You MUST ask for permission first, unless using approved workflows like `/push`, `/deploy`, or `/release`.

## 1. Ignore Before Commit

Git-related workflows (like `/push`, `/deploy`, `/release`) **MUST** check `.gitignore` before operations.

### Mandatory Ignores

```
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

### PROHIBITION

**AI Agents MUST NEVER create `.env.local` or any `.env` file containing real data.**

- Use `env.example.txt` for templates.
- Ask the USER to configure secrets in their environment (Vercel, etc.) or .env file manually.

### Dangerous File Check

Files that must NEVER be committed:

- `.env*` (API keys, credentials)
- `*.pem`, `*.key` (Private keys)
- `id_rsa*` (SSH keys)
- `*.sqlite`, `*.db` (Databases)
- `credentials.json` (Service accounts)

## 2. Git Scope Separation

**CORE PRINCIPLE:** Strictly separate Workspace Data from Project Data.

### Workspace Data (Shared)

Files in `sessions/`, `docs/` (root), `_inbox/`, `Archive/` belong to the Workspace level.

- **PROHIBITED**: Do NOT `git add` these files into a specific Project's repo.
- **Reason**: These contain personal logs, strategy, and work-in-progress that should not leak into application code.

### Project Data (Application)

Only files inside `Projects/[project-name]/` are subject to project-level Git operations.

- **Action**: Always verify `Cwd` is correct before running `git commit`.

## 3. Workflow Integration

When running `/push` or `/deploy`, the agent must:

1. **Check Ignore**: Ensure `.gitignore` exists.
2. **Scan**: Check for sensitive files being tracked.
3. **Warn**: Alert the user if sensitive files are found.
