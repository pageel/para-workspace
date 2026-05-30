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
| `session` | `references/session-quality-gate.md` | Phase start — Quality Gate proposal (TDD/graph/QA/hardened) |
| `session` | **§ Phase Context Reload** (below) | Phase start — Reload project rules/skills + tool-specific skills |
| all | `references/verification.md` | Verify step — project-type commands |

## References

| File | Purpose |
|:--|:--|
| `references/review-report.md` | Plan audit scorecard with Agent Learning Notes |
| `references/sandbox-report.md` | Sandbox diff report + companion check |
| `references/loop-config.md` | Exit criteria presets by project type |
| `references/loop-report.md` | Iteration log + lessons learned |
| `references/auto-queue.md` | Execution queue + progress tracker |
| `references/session-quality-gate.md` | Sensitive keywords registry + Quality Gate template for session phases |
| `references/verification.md` | Build/lint commands by tech stack |
| `scripts/session-manager.sh` | Dynamic session KI (vibecode_session) management helper script |

## Mode Chaining Guide

```text
Recommended chains:

  New plan:     review → loop --sandbox → apply → auto
  Quick fix:    loop (standalone, real project)
  Risky phase:  review → loop --sandbox [Phase N] → apply → auto --resume
  Quick peek:   loop --sandbox --max 1 (one-shot preview)
  Full dry-run: auto --sandbox (entire plan in sandbox)
  Free session: session (DSP draft → JIT phases → Quality Gate → commit)
  Targeted:     session refactor-auth (DSP with topic → Phase 1 ready)
  Hardened:     session --hardened (auto-detect + forced TDD on sensitive code)
```

## Phase Context Reload (Session Mode)

At the **start of every Phase** in session mode, Agent MUST reload context
to prevent drift in long sessions. This table defines WHAT to reload.

### Mandatory (EVERY Phase)

| # | What to reload | Path | Condition |
|:--|:--|:--|:--|
| 1 | Project rules index | `Projects/[project]/.agents/rules.md` | If exists |
| 2 | Project skills index | `Projects/[project]/.agents/skills.md` | If exists |
| 3 | Project domain skill | `Projects/[project]/.agents/skills/[project]/SKILL.md` | If exists |
| 4 | Project developer guidelines | `Projects/[project]/.agents/AGENTS.md` (or `agents.md` in root) | If exists |

### Conditional (based on activated Quality Tools)

| Activated Tool | Skill to load | Path |
|:--|:--|:--|
| 🧪 TDD | TDD Guidelines | `.agents/skills/tdd/SKILL.md` |
| 🔍 --graph | Graph Intelligence Router | `.agents/skills/para-graph/SKILL.md` |
| 🔒 --hardened | TDD Guidelines (co-required) | `.agents/skills/tdd/SKILL.md` |
| ⚗️ /brainstorm | Brainstorm Templates | `.agents/skills/brainstorm/SKILL.md` |
| 📋 /qa | QA Review Templates | `.agents/skills/qa/SKILL.md` |

> **Pattern:** The `/vibecode` workflow references this table at Step 2a (Context Reload).
> Agent reads the sidecar skill → follows the routing table → loads the right skills.
> This keeps the workflow file lean and the routing logic centralized here.

## Output Checklist

After execution, verify:

- [ ] Step 0 Pre-flight executed (rules + skills reloaded)
- [ ] Correct mode was used for the target task complexity
- [ ] All exit criteria explicitly defined (loop mode)
- [ ] User confirmed before real writes
- [ ] Phase gates respected (auto mode)
- [ ] Quality Gate and Pre-Code Checkpoint presented at EVERY Phase start (session mode — TDD/graph/QA/hardened)
- [ ] User approval obtained at Pre-Code Checkpoint and confirmed to run `/plan [project-name] dev` before making any code modifications
- [ ] Rollback mechanism available (loop: git stash, sandbox: delete)
- [ ] Path substitution correct (--sandbox: sandbox prefix)
- [ ] Bash scripts syntax-checked with `bash -n` (--sandbox)
- [ ] Sandbox cleaned up after completion
- [ ] Final report generated with file inventory + lessons learned
- [ ] Mandatory User confirmation obtained (suggesting `/plan [project-name] end`) before performing session teardown or archiving/cleaning plan files
