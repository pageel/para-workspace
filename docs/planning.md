# Planning & Backlog Guide

> How to use `/plan` and `/backlog` together to manage your projects effectively.

## Overview

PARA Workspace provides two complementary tools for project management:

| Tool           | Purpose                                             | Analogy                        |
| :------------- | :-------------------------------------------------- | :----------------------------- |
| **`/plan`**    | Strategic roadmap — **HOW** to build, in what order | Blueprint of a house           |
| **`/backlog`** | Tactical tracker — **WHAT** to do, current status   | Today's construction checklist |

You don't always need both. Use this guide to decide.

---

## When to Use What

| Scenario                    | Plan?  | Backlog? |
| :-------------------------- | :----- | :------- |
| New project, >5 tasks       | ✅ Yes | ✅ Yes   |
| Small project, <5 tasks     | ❌ No  | ✅ Yes   |
| Bug fixes / maintenance     | ❌ No  | ✅ Yes   |
| Major architecture refactor | ✅ Yes | ✅ Yes   |
| Adding a single feature     | ❌ No  | ✅ Yes   |

**Rule of thumb:** Every project needs a backlog. Only create a plan when you need phased architecture decisions.

---

## Project Lifecycle

```
/new-project
     ↓
/plan create        (if needed — architecture, phases, schemas)
     ↓
/backlog add        (populate from plan phases)
     ↓
┌──────────── Daily Loop ────────────┐
│                                     │
│  /open   → context + current phase  │
│     ↓                               │
│  Pick tasks → Code → Test → Commit  │
│     ↓                               │
│  /backlog update → mark done        │
│     ↓                               │
│  /end    → log session + phase check│
│                                     │
└─────────────────────────────────────┘
     ↓
/retro → /archive   (when all phases complete)
```

---

## How Plan & Backlog Connect

The plan defines **phases** (ordered by dependencies). The backlog tracks **items** (ordered by priority). They connect through a **mapping table**:

```
Plan                              Backlog
┌──────────────────┐              ┌──────────────────┐
│ Phase 0: Setup   │ ←──maps to──→ │ CI-01, CI-02     │
│ Phase 1: API     │ ←──maps to──→ │ CI-03, CI-04     │
│ Phase 2: Auth    │ ←──maps to──→ │ AU-01, AU-02     │
│ Phase 3: UI      │ ←──maps to──→ │ UI-01, UI-02     │
└──────────────────┘              └──────────────────┘

Plan tells you ORDER → "Do Phase 1 before Phase 2"
Backlog tells you STATUS → "CI-03 is ✅ Done, CI-04 is 🔨 In Progress"
```

### The `active_plan` Field

When a plan exists, register it in `project.md` frontmatter:

```yaml
---
goal: "My project goal"
status: "active"
active_plan: "plans/implementation-plan.md" # ← path relative to artifacts/
---
```

This enables `/open` and `/end` to automatically detect your current phase without scanning directories — saving agent tokens.

---

## Daily Session Flow

### Step 1: Open (`/open`)

```
🚀 Starting: my-project | 📅 2026-02-26
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 LAST SESSION: Completed API proxy setup
📐 CURRENT PHASE: Phase 2: Authentication     ← from plan
   Progress: 2/5 tasks done
   Next: AU-03 (Role permissions), AU-04 (Change password)
📥 BACKLOG: High: 3 | Medium: 4 | Low: 2
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 SUGGESTED: Work on AU-03 (current phase, high priority)
```

The agent reads your plan (headers only — not the full document) to show which phase you're in and what tasks are next.

### Step 2: Work

Pick 2-3 tasks from the current phase. Code, test, commit.

### Step 3: Update (`/backlog update`)

```
/backlog domain-pictures update
→ AU-03: ⏳ Pending → ✅ Done (2026-02-26)
→ AU-04: ⏳ Pending → 🔨 In Progress
```

### Step 4: Close (`/end`)

```
/end domain-pictures
→ Session logged to sessions/2026-02-26.md
→ Plan Progress: Phase 2 — 4/5 tasks done
→ 🎉 Almost there! 1 task remaining in Phase 2.
```

When all tasks in a phase are done, the agent announces:

```
🎉 Phase 2 Complete! Phase 3: Dashboard UI ready to start.
```

---

## Golden Rules

| #   | Rule                                   | Why                                                                                                |
| :-- | :------------------------------------- | :------------------------------------------------------------------------------------------------- |
| 1   | **Read plan at start, rarely edit**    | Only change when scope/architecture shifts. Don't edit daily.                                      |
| 2   | **Update backlog every session**       | Mark done, add new tasks, adjust priority.                                                         |
| 3   | **Session log = evidence**             | Record what you ACTUALLY did — not what you planned.                                               |
| 4   | **Phase = natural sprint**             | Each phase ≈ 1-2 days. Don't skip ahead.                                                           |
| 5   | **New task? Add to backlog first**     | Don't start coding immediately. Log it, evaluate priority.                                         |
| 6   | **Use `grep`, don't read entire plan** | Plans can be 500-800+ lines. `/open` and `/end` use `grep` to read only phase headers (~30 lines). |

---

## Syncing Plan & Backlog

Use `/backlog sync` to keep both artifacts aligned:

```
/backlog my-project sync

🔄 BACKLOG ↔ PLAN SYNC
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
| Phase   | Mapped | Missing |
| ------- | ------ | ------- |
| Phase 0 | 5/5    | 0       |
| Phase 1 | 4/6    | 2 ⚠️    |
| Phase 2 | 0/5    | 5 ⚠️    |
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️ 7 plan tasks not yet in backlog.
→ Auto-create backlog items? (y/n)
```

### When to Sync

| Event                  | Action                                  |
| :--------------------- | :-------------------------------------- |
| Plan just created      | Run `/backlog sync` to populate backlog |
| New backlog item added | Agent asks which Phase it belongs to    |
| All phase items done   | Agent announces phase completion        |
| Plan scope changed     | Run `/backlog sync` to find gaps        |

---

## Workflow Commands Reference

| Command             | Action               | When to Use                |
| :------------------ | :------------------- | :------------------------- |
| `/plan create`      | Create new plan      | Start of a new project     |
| `/plan review`      | Show phase progress  | Need big-picture view      |
| `/plan update`      | Modify plan          | Architecture/scope changed |
| `/backlog review`   | Show task summary    | Every session start        |
| `/backlog add`      | Add new item         | Discovered new task        |
| `/backlog update`   | Change item status   | Completed or started work  |
| `/backlog sync`     | Align with plan      | After plan changes         |
| `/backlog evaluate` | ICE score priorities | Need to reprioritize       |

---

## Related

- [Workflow Documentation](./workflows.md) — Philosophy and catalog overview
- [Architecture](./architecture.md) — Repo ↔ Workspace structure
- [CLI Reference](./cli.md) — Command-line tools

---

_Added in v1.4.2_
