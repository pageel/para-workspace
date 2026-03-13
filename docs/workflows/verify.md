# /verify Workflow

> **Version**: 1.5.0

The `/verify` workflow confirms that a feature or task is complete by executing a structured Walkthrough artifact checklist. It runs tests, checks outputs, and records evidence.

## Commands

```
/verify [project-name] [task-name]
```

## Verification Flow

```
Locate walkthrough → Execute checklist → Compare results → Record evidence
```

### 1. Locate Walkthrough

Finds the relevant walkthrough in `artifacts/walkthroughs/`. If none exists, offers to create one from the task description.

### 2. Execute Verification Checklist

Runs every "Verify" step defined in the walkthrough (tests, builds, file checks).

### 3. Compare Results

Matches actual output against expected output:

- ✅ Match → Step passes
- ❌ Mismatch → Flagged as regression

### 4. Record Evidence

Logs verification status in the session file and updates `backlog.md` status.

## Success Criteria

- [ ] Checklist fully executed
- [ ] No regressions found
- [ ] Evidence recorded in session log
- [ ] Backlog status updated

## Related

- [/backlog Workflow](./backlog.md) — Update task status
- [/release Workflow](./release.md) — Pre-release quality gate
- [Workflow Documentation](../reference/workflows.md) — Workflow catalog

---

_Added in v1.5.0_
