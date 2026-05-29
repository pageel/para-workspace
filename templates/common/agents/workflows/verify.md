---
description: Verify task completion using walkthroughs
source: catalog
---

# /verify [project-name] [task-name]

> **Workspace Version:** 1.5.0 (Governed Libraries)

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

#### 2.5. Graph-Assisted Blast Radius Check (CONDITIONAL)

> **Gate:** Only trigger if project has `.beads/graph/` directory.

IF graph exists, use `graph_impact_analysis` on the primary changed entity to verify all affected areas have been covered by the walkthrough:

1. Identify the main function/class that was changed from the walkthrough description.
2. Run `graph_impact_analysis(nodeId, direction: "upstream", depth: 2)` to list all callers.
3. Cross-check: Are all upstream callers covered by test steps in the walkthrough?
4. **IF uncovered callers found** → Flag as potential gap:
   ```
   ⚠️ BLAST RADIUS GAP: [caller-name] depends on changed code but is not tested in walkthrough.
   ```
5. **Pattern Verify (Step G, para-graph §4.2):** If the change involves inline code patterns (e.g., error handling, logging), run `grep_search` to verify all pattern occurrences are covered by the walkthrough.

IF no graph → Skip. Proceed with manual verification only.

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
