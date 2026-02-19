# /push [project-name] ["message"] [--quick]

> **Workspace Version:** 1.4.0

Fast commit and push changes to GitHub with verification.

## Usage

```
/push pageel-website             # Default: Build & Test before push
/push pageel-website --quick     # Quick push: Skip build/test
```

## Options

| Option    | Description                                                |
| :-------- | :--------------------------------------------------------- |
| `--quick` | Skip `npm run build` (Only use for small text changes)     |
| `--test`  | (Default) Run `npm run build` before commit to verify code |

## Steps

### 1. Check Git Status

// turbo

```bash
cd [project-path]/repo && git status
```

### 2. Check Ignore Files (MANDATORY - per vcs.md)

// turbo

```bash
# Check if ignore file exists
test -f .gitignore && echo "✅ Ignore file exists" || echo "❌ WARNING: No ignore file!"

# Scan for dangerous/IDE files being tracked (Includes .env, keys, and IDE settings)
git ls-files | grep -E '\.(env|pem|key|sqlite|db)$|id_rsa|credentials|secrets|\.vscode/|\.idea/' && echo "⚠️ WARNING: Sensitive files or IDE settings detected!" || echo "✅ No sensitive files detected"
```

**If issues are found:**

- Missing ignore file → Create template (see `.agent/rules/vcs.md`)
- Sensitive files found → STOP and warn user

### 3. (Optional) Build & Test

**Default or `--test` flag:** Run build to verify code before push.
**If `--quick` flag:** Skip this step.

// turbo

```bash
npm run build
```

If build fails, **MUST STOP** and report detailed errors to the user.
Ask user to:

1. Fix errors (Fix mode).
2. Ignore errors and force push (Force push mode - only if explicitly confirmed).

### 4. Create Commit Message

**If NO message:** Agent auto-generates based on `git diff --stat` and context.

**Convention:**

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `style:` - Formatting
- `refactor:` - Restructuring
- `chore:` - Maintenance

### 5. Update CHANGELOG.md

```markdown
## [Unreleased]

### Added

- [New feature]

### Fixed

- [Bug fix]
```

### 6. Commit & Push

// turbo

```bash
git add .
git commit -m "[message]"
```

// turbo

```bash
git push
```

### 7. Confirmation

```
✅ Pushed to GitHub!
📝 Commit: [hash] - [message]
📊 Files: [N] changed
📋 CHANGELOG: Updated
🔗 Vercel will auto-deploy
```

## Troubleshooting

| Error                   | Solution                                         |
| ----------------------- | ------------------------------------------------ |
| `non-fast-forward`      | `git pull --rebase` then push again              |
| `Permission denied`     | Check SSH key                                    |
| `Email privacy blocked` | Use `user@users.noreply.github.com`              |
| `Build failed`          | Report error to user to decide fix or force push |

## Notes

- Always update CHANGELOG.md before pushing
- Vercel auto-deploys when pushing to `main`
- Always Build/Test before pushing to ensure stability (unless `--quick`)
- **Always check ignore files before pushing** (see `.agent/rules/vcs.md`)
