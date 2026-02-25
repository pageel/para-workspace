---
description: Pre-release quality gate and verification
---

# /release [project-name]

> **Workspace Version:** 1.4.1 (Governed Libraries)

Pre-merge quality gate for production readiness.

## Steps

### 1. Linting & Formatting

// turbo

Run standard linters for the project stack:

```bash
cd Projects/[project-name]/repo && npm run lint 2>/dev/null || echo "No lint script found"
```

### 2. Test Suite

// turbo

Execute all unit and integration tests:

```bash
cd Projects/[project-name]/repo && npm test 2>/dev/null || echo "No test script found"
```

### 3. Build Verification

// turbo

```bash
cd Projects/[project-name]/repo && npm run build 2>/dev/null || echo "No build script found"
```

### 4. Log Audit

Ensure all key sessions for this release are properly logged:

- Check `Projects/[project-name]/sessions/` for recent entries.
- Verify the current session covers all changes being released.

### 5. Changelog Update

Verify `CHANGELOG.md` reflects recent changes. If not, update it with:

```markdown
## [version] - YYYY-MM-DD

### Added

- [New features]

### Fixed

- [Bug fixes]

### Changed

- [Modifications]
```

### 6. Version Bump

If applicable, increment version in:

- `Projects/[project-name]/project.md` (version field)
- `Projects/[project-name]/repo/VERSION` (if exists)
- `Projects/[project-name]/repo/package.json` (if applicable)

### 7. Milestone Check

Review milestones in `project.md` frontmatter:

- If this release completes a milestone, update its status to `done` and add `shipped_in: "[version]"`.
- If this release is part of an `in-progress` milestone, confirm it stays `in-progress`.
- Update the public roadmap (e.g., README) to reflect shipped milestones.

## Checklist

- [ ] No lint errors
- [ ] Tests pass 100%
- [ ] Build succeeds
- [ ] Documentation updated
- [ ] Changelog updated
- [ ] Version bumped

## Related

- `/push` — Commit and push to GitHub
- `/verify` — Verify specific task completion
- `/end` — End session and log progress
