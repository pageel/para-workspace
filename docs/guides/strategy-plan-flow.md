# Strategy → Plan Flow Guide (v1.6.1)

> **Version**: 1.6.1 | **Last reviewed**: 2026-03-23

## Overview

v1.6.1 adds a **3-tier planning model** to 4 workflows (`/docs`, `/plan`, `/open`, `/end`), allowing projects to scale from a single plan to a full strategy system — with zero configuration. Everything is detected via **filesystem conventions**.

---

## The 3-Tier Model

```text
┌─────────────────────────────────────────────────────────────┐
│ Tier 1: docs/strategy/          WHY + WHAT  (opt-in)       │
│         ├── strategy.md          Overall strategy           │
│         └── strategy-*.md        Branch-specific strategy   │
├─────────────────────────────────────────────────────────────┤
│ Tier 2: plans/*-roadmap.md      HOW (overview)  (opt-in)   │
│         Living index — phases → links to detail plans       │
│         Never archived, never set as active_plan            │
├─────────────────────────────────────────────────────────────┤
│ Tier 3: plans/*.md              HOW (detail)   (always)    │
│         Task-level phases — IS active_plan                  │
│         Archived to plans/done/ when complete               │
└─────────────────────────────────────────────────────────────┘
```

Use as many tiers as your project needs:

| Project Size         | Tier 1 (Strategy) | Tier 2 (Roadmap) | Tier 3 (Detail) |
|:---------------------|:-------------------|:------------------|:-----------------|
| Small (1-2 features) | —                  | —                 | 1 plan           |
| Medium (CLI, app)    | optional           | ✅                | multiple plans   |
| Ecosystem (meta)     | ✅                 | ✅                | per satellite    |

---

## End-to-End Flow

```text
/brainstorm  ──▶  /docs new     ──▶  /plan create  ──▶  /open & /end
(ideation)        (strategy/)         (roadmap/plan)     (context + sync)
```

### Step-by-Step

1. **Brainstorm** (`/brainstorm`) — Option D smart-routes to `/docs` for strategy creation.
2. **Create Strategy** (`/docs new`) — Step 3.5 detects `docs/strategy/` or suggests creation.
3. **Create Roadmap** (`/plan create`) — Step 2.8 asks: Roadmap or Detail Plan? Choose 🗺️ Roadmap.
4. **Create Detail Plan** (`/plan create`) — Step 2.8 detects existing roadmap → suggests next phase. Step 2.9 loads strategy + roadmap context.
5. **Daily Dev** (`/open`) — Loads strategy summary (~30 tokens), roadmap overview (~40 tokens), pending brainstorms (~20 tokens). Cascade warning (D10) if strategy is newer than roadmap.
6. **End Session** (`/end`) — Step 3.2 detects strategy/roadmap changes → SYNC entries. Step 3.3 suggests next steps for new brainstorms. Step 4.5 auto-updates roadmap phase status.
7. **Plan Complete** (`/plan review`) — Archives detail plan, updates roadmap phase → ✅ Done, suggests creating next phase's detail plan.

---

## Key Decisions

| #   | Decision                             | Resolution                          |
|:----|:-------------------------------------|:------------------------------------|
| D7  | Brainstorm vs Strategy priority      | Strategy wins — skip older brainstorm |
| D10 | Strategy change cascade              | Date compare → warn if roadmap stale |
| D4  | `active_plan` scope                  | Detail plans only, never roadmap    |
| D6  | `/brainstorm` Option F "Strategy"?   | No — smart routing via Option D     |

## Filesystem Detection

No configuration or schema fields needed — all tiers are detected by file existence:

| Tier     | Detection Pattern                  | Used By                           |
|:---------|:-----------------------------------|:----------------------------------|
| Strategy | `docs/strategy/` directory exists  | `/docs`, `/plan`, `/open`, `/end` |
| Roadmap  | `plans/*-roadmap.md` glob match    | `/plan`, `/open`, `/end`          |
| Detail   | `plans/*.md` (non-roadmap)         | All workflows (via `active_plan`) |

## Roadmap Rules

- **Naming:** `[scope]-roadmap.md` (e.g., `ecosystem-roadmap.md`)
- **Never** set as `active_plan`
- **Never** archived to `done/`
- **Auto-updated** when a detail plan is activated or completed

## Related

- [Meta-Project Guide](./meta-project.md) — Ecosystem setup (v1.6.0)
- [Development Workflow](./development.md) — Daily dev flow
- [Plan Knowledge Context](./plan-knowledge-context.md) — Step 2.7 in /plan

---

_Last updated: 2026-03-23_
