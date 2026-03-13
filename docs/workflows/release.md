# /release Workflow

> **Version**: 1.5.0

The `/release` workflow is a pre-merge quality gate for production readiness. It runs through 7 automated checks before a release can proceed.

## Commands

```
/release [project-name]
```

## Release Gate Flow

```
Lint → Test → Build → Log audit → Changelog → Version bump → Milestone check
```

### 1. Linting & Formatting

Runs `npm run lint` to catch code quality issues.

### 2. Test Suite

Executes all unit and integration tests via `npm test`.

### 3. Build Verification

Confirms production build succeeds via `npm run build`.

### 4. Log Audit

Verifies all key sessions for this release are properly logged in `sessions/`.

### 5. Changelog Update

Checks `CHANGELOG.md` reflects recent changes. Creates entries if missing.

### 6. Version Bump

Increments version in: `project.md`, `VERSION`, `package.json`, and `README.md` (badges/footer).

### 7. Milestone Check

Reviews milestones in `project.md`. If this release completes a milestone, updates its status to `done` with `shipped_in` version. Updates public roadmap.

## Checklist

- [ ] No lint errors
- [ ] Tests pass 100%
- [ ] Build succeeds
- [ ] Documentation updated
- [ ] Changelog updated
- [ ] Version bumped

## Related

- [/push Workflow](./push.md) — Commit and push to GitHub
- [/verify Workflow](./verify.md) — Verify specific task completion
- [Workflow Documentation](../reference/workflows.md) — Workflow catalog

---

_Added in v1.5.0_
