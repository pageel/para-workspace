---
description: Conduct a project retrospective before archiving or closing sprint
---

# /retro

> **Profile:** Dev
> **Version:** 1.0.0

Conduct a retrospective to learn from the sprint/project and optimize future work.

## Steps

### 1. Review Metrics

- **Tasks Completed**: [X]/[Y]
- **Bugs Found**: [N]
- **Time Spent**: [Days]

### 2. Analyze Friction (Beads)

//turbo

```bash
cat .beads/*.yaml
```

Check for any "Friction Beads" created during the project.

### 3. Graduation

Identify any logic patterns, code snippets, or rules that should be graduated to the global workspace:

- **Snippets** -> `Resources/Reference/code/`
- **Rules** -> `Areas/Infrastructure/rules/`

### 4. Archive

If the project is complete:

1. Move to `Archive/`.
2. Update `project.md` status to `archived`.
