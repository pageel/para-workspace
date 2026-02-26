# Development Workflow Guide

> How the daily, planning, release, and operations workflows fit together.

## Overview

PARA Workspace organizes development into 4 workflow streams:

```
┌──────────────────────────────────────────────────────────────────────┐
│                                                                      │
│  0. PLANNING          1. DAILY DEV        2. RELEASE      3. OPS    │
│  ────────────         ──────────          ──────────      ────────  │
│  /plan create         /open               /release        /migrate  │
│     ↓                    ↓                   ↓            /inbox    │
│  /backlog sync        [coding]            /deploy                   │
│                          ↓                                          │
│                       /push                                         │
│                          ↓                                          │
│                       /end (+ plan check)                           │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 0. Planning Flow (New Projects)

Run **once** when starting a project with >5 tasks.

```
/new-project [name]
    ↓
/plan create          → artifacts/plans/implementation-plan.md
    ↓                    (sets active_plan in project.md)
/backlog sync         → Creates backlog items from plan phases
    ↓
/open [project]       → Start daily workflow
```

> Not every project needs a plan. See [Planning Guide](./planning.md) for decision criteria.

---

## 1. Daily Development Flow

This runs **every day** during active development.

```
/open [project]
    │
    │  📋 Load session log + backlog
    │  📐 Show current phase (if active_plan exists)
    │  💡 Suggest tasks (prioritize current phase)
    │
    ▼
[Coding & Testing]
    │
    ▼
/push ["message"]
    │
    ▼
/backlog update       → Mark tasks ✅ Done
    │
    ▼
/end
    │
    │  💾 Save session log
    │  📐 Check plan phase progress
    │  📊 Update SESSION_LOG.md
```

| Workflow          | Trigger          | Frequency    |
| :---------------- | :--------------- | :----------- |
| `/open`           | Start working    | 1x/day       |
| `/push`           | Feature/fix done | Multiple/day |
| `/backlog update` | Task done        | Per task     |
| `/end`            | Stop working     | 1x/day       |

---

## 2. Release Cycle Flow

This runs when **shipping a new version**.

```
/plan review          → Phase overview + progress
    ↓
/backlog review       → Task status for current phase
    ↓
[Development Sprint]  → 1-2 days per phase
    ↓
/release [project]    → CHANGELOG, Git tag, push
    ↓
/deploy               → Verify production
```

| Workflow          | Trigger           | Frequency    |
| :---------------- | :---------------- | :----------- |
| `/plan review`    | Big-picture check | Start/end    |
| `/backlog review` | Pick tasks        | Each session |
| `/release`        | Version ready     | Per phase    |
| `/deploy`         | Post-release      | Per release  |

---

## 3. Operations Flow

These run **as needed** (not daily).

| Workflow   | Purpose                      | When           |
| :--------- | :--------------------------- | :------------- |
| `/migrate` | Tech stack migration         | New project    |
| `/inbox`   | Categorize incoming files    | Weekly cleanup |
| `/install` | Install/update workflows     | After `update` |
| `/retro`   | Retrospective before archive | Project end    |

---

## How Artifacts Connect

```
project.md (active_plan → "plans/xxx.md")
    │
    │ points to
    ▼
Plan (artifacts/plans/)              ← HOW & ORDER
    │
    │ maps to
    ▼
Backlog (artifacts/tasks/backlog.md) ← WHAT & STATUS
    │
    │ completed tasks
    ▼
Session Log (sessions/YYYY-MM-DD.md) ← EVIDENCE
    │
    │ on release
    ▼
CHANGELOG → GitHub Release           ← PUBLIC RECORD
```

---

## Best Practices

### ✅ DO

- Always start with `/open` for context + current phase
- Commit often with `/push` (many small commits > 1 big commit)
- End with `/end` to save progress + check phase completion
- Use `/backlog update` to mark tasks done immediately
- New task discovered? → `/backlog add` FIRST, then code
- Use `grep` when reading plan in `/open`/`/end` — not the full file

### ❌ DON'T

- Skip `/open` and start coding blind
- Forget `/end` and lose context next day
- Read entire plan (500-800+ lines) in `/open` — grep headers only
- Jump to next Phase before current Phase is complete
- Start coding a new task without adding it to backlog first

---

## Related Docs

- [Planning Guide](./planning.md) — Plan + Backlog detailed guide
- [Workflow Documentation](./workflows.md) — Philosophy and catalog
- [CLI Reference](./cli.md) — Command-line tools
- [Architecture](./architecture.md) — Repo ↔ Workspace structure

---

_Added in v1.4.2_
