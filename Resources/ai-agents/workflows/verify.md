# /verify [task-name]

> Verify completion of a feature or task using a Walkthrough artifact.

## Steps

1. **Locate Walkthrough**:
   - Find the relevant file in `artifacts/walkthroughs/`.

2. **Execute Verification Checklist**:
   - Run every "Verify" step defined in the walkthrough.
   - For example: `npm run test`, `ls -la some/path`, etc.

3. **Compare Results**:
   - Verify that actual output matches "Expected Output" in the walkthrough.

4. **Record Evidence**:
   - Log the verification status in the current session file.
   - Update `artifacts/tasks.md` status.

## Success Criteria

- [ ] Checklist fully executed
- [ ] No regressions found
- [ ] Evidence recorded in session log
