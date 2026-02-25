---
description: Verify task completion using walkthroughs
---

# /verify [project-name] [task-name]

> **Workspace Version:** 1.4.1 (Governed Libraries)

Verify completion of a feature or task using a Walkthrough artifact.

## Steps

### 1. Locate Walkthrough

// turbo

Find the relevant walkthrough file:

```bash
ls Projects/[project-name]/artifacts/walkthroughs/ 2>/dev/null || echo "No walkthroughs directory found"
```

If no walkthrough exists, offer to create one based on the task description.

### 2. Execute Verification Checklist

Run every "Verify" step defined in the walkthrough. For example:

```bash
cd Projects/[project-name]/repo
npm run test        # Run tests
npm run build       # Verify build
ls -la some/path    # Check file existence
```

### 3. Compare Results

Verify that actual output matches "Expected Output" in the walkthrough:

- ✅ Match → Step passes
- ❌ Mismatch → Flag as regression

### 4. Record Evidence

Log the verification status in the current session file:

```markdown
## Verification: [task-name]

- **Status**: ✅ Passed / ❌ Failed
- **Steps Executed**: N/N
- **Regressions**: None / [list]
```

Update `Projects/[project-name]/artifacts/tasks/backlog.md` status accordingly.

## Success Criteria

- [ ] Checklist fully executed
- [ ] No regressions found
- [ ] Evidence recorded in session log
- [ ] Backlog status updated

## Related

- `/backlog` — Update task status
- `/release` — Pre-release quality gate
- `/push` — Commit and push verified changes
