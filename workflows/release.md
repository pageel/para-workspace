---
description: Pre-release quality gate and verification
---

# /p-release

> **Workspace Version:** 1.4.0

> Pre-merge quality gate for production readiness.

## Steps

1. **Linting & Formatting**:
   - Run standard linters for the project stack.

2. **Test Suite**:
   - Execute all unit and integration tests.

3. **Log Audit**:
   - Ensure all key sessions for this release are properly logged.

4. **Changelog Update**:
   - Verify `CHANGELOG.md` reflects recent changes.

5. **Version Bump**:
   - Increment version in `.para-workspace.yml` if necessary.

## Checklist

- [ ] No lint errors
- [ ] Tests pass 100%
- [ ] Documentation updated
- [ ] Changelog updated
