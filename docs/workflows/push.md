# /push Workflow

> **Version**: 1.5.0

The `/push` workflow commits and pushes code to GitHub with built-in safety checks: sensitive file scanning, build verification, auto-generated commit messages, and CHANGELOG updates.

> **Important:** This is the ONLY workflow that performs Git operations. `/end` does NOT commit or push.

## Commands

```
/push [project-name]                    # Default: Build & Test before push
/push [project-name] --quick            # Skip build (small text changes only)
/push [project-name] "feat: new thing"  # With explicit commit message
```

| Option    | Description                                    |
| :-------- | :--------------------------------------------- |
| `--quick` | Skip `npm run build` (small text changes only) |
| `--test`  | (Default) Run `npm run build` before commit    |

## Push Flow

```
Git status → Security scan → Build (optional) → Commit message → CHANGELOG → Commit & Push → Confirm
```

### 1. Check Git Status

Shows changed files via `git status`.

### 2. Security Scan (Mandatory)

Checks for `.gitignore` existence and scans for sensitive files (`.env`, `.pem`, `.key`, `.sqlite`, IDE settings). **Stops immediately** if sensitive files are detected.

### 3. Build & Test (Optional)

Runs `npm run build` unless `--quick` is specified. If build fails, stops and asks user to fix or force push.

### 4. Create Commit Message

Auto-generates from `git diff --stat` if not provided. Uses Conventional Commits: `feat:`, `fix:`, `docs:`, `style:`, `refactor:`, `chore:`.

### 5. Update CHANGELOG.md

Appends entry to `[Unreleased]` section if CHANGELOG exists.

### 6. Commit & Push

Executes `git add .`, `git commit`, and `git push`.

## Troubleshooting

| Error               | Solution                                    |
| :------------------ | :------------------------------------------ |
| `non-fast-forward`  | `git pull --rebase` then push again         |
| `Permission denied` | Check SSH key                               |
| `Build failed`      | Report error, ask user to fix or force push |

## Related

- [/end Workflow](./end.md) — Close session (does NOT push)
- [Workflow Documentation](../reference/workflows.md) — Workflow catalog

---

_Added in v1.5.0_
