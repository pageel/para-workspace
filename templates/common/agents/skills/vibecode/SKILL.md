---
name: Vibecode Execution Templates
description: Sidecar data for /vibecode workflow — verification checklists, exit criteria templates, and report formats loaded just-in-time.
trigger: /vibecode workflow execution
glob:
source: user
---

# Skill: Vibecode Execution Templates

> Sidecar Skill for the `/vibecode` workflow. Contains execution templates,
> verification checklists, and report formats that the Agent loads **only when
> executing a specific mode**.
>
> **Pattern:** Workflow = Logic → Sidecar Skill = Data Router.
> The `/vibecode` workflow instructs the Agent to read this skill at mode-start time.

## When to Load

| Mode | File to load | When |
|:--|:--|:--|
| `review` | `references/review-report.md` | Step 7 — Generate review report |
| `loop` | `references/loop-config.md` | Step 1 — Define exit criteria |
| `loop` | `references/loop-report.md` | Step 5 — Generate final report |
| `auto` | `references/auto-queue.md` | Step 1 — Build execution queue |
| `--sandbox` | `references/sandbox-report.md` | After sandbox loop/auto — Generate diff report |
| all | `references/verification.md` | Verify step — project-type commands |

## References

| File | Purpose |
|:--|:--|
| `references/review-report.md` | Plan audit scorecard with Agent Learning Notes |
| `references/sandbox-report.md` | Sandbox diff report + companion check |
| `references/loop-config.md` | Exit criteria presets by project type |
| `references/loop-report.md` | Iteration log + lessons learned |
| `references/auto-queue.md` | Execution queue + progress tracker |
| `references/verification.md` | Build/lint commands by tech stack |

## Mode Chaining Guide

```text
Recommended chains:

  New plan:     review → loop --sandbox → apply → auto
  Quick fix:    loop (standalone, real project)
  Risky phase:  review → loop --sandbox [Phase N] → apply → auto --resume
  Quick peek:   loop --sandbox --max 1 (one-shot preview)
  Full dry-run: auto --sandbox (entire plan in sandbox)
```

## Output Checklist

After execution, verify:

- [ ] Step 0 Pre-flight executed (rules + skills reloaded)
- [ ] Correct mode was used for the target task complexity
- [ ] All exit criteria explicitly defined (loop mode)
- [ ] User confirmed before real writes
- [ ] Phase gates respected (auto mode)
- [ ] Rollback mechanism available (loop: git stash, sandbox: delete)
- [ ] Path substitution correct (--sandbox: sandbox prefix)
- [ ] Bash scripts syntax-checked with `bash -n` (--sandbox)
- [ ] Sandbox cleaned up after completion
- [ ] Final report generated with file inventory + lessons learned
