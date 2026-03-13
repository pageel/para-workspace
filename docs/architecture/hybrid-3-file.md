# Hybrid 3-File Architecture

> **Version**: 1.5.3 | **Last reviewed**: 2026-03-13

## Overview

The Hybrid 3-File Model solves the "Token Waste vs. Amnesia" problem for AI agents managing tasks. Instead of forcing the agent to read a massive backlog file every session, work is distributed across three specialized files.

## File Roles

```
artifacts/tasks/
├── backlog.md          # 📌 Operational Authority — single source of truth (active + archived)
├── sprint-current.md   # 🔥 Hot Lane — agent-writable buffer for ad-hoc quick tasks
└── done.md             # ✅ Historical Archive — plan-grouped, append-only log
```

| File                | Role                                                                             | Read/Write     |
| :------------------ | :------------------------------------------------------------------------------- | :------------- |
| `backlog.md`        | Operational Authority — all tasks (active tables + compressed Completed section) | Agent + User   |
| `sprint-current.md` | Hot Lane — ad-hoc quick tasks during coding session                              | Agent-writable |
| `done.md`           | Historical Archive — completed tasks grouped by plan, with origin tags           | Append-only    |

## Backlog Compression (`/backlog clean`)

Done items are **compressed, not deleted**. The `clean` action moves Done items from active tables into the `✅ Completed (Archived)` section (1 line per plan + IDs list).

**Lookup chain:**

```
backlog.md (✅ Completed: plan name + IDs)
    ↓ link
done.md (per-task detail, grouped by plan heading)
    ↓ link
plans/done/*.md (full plan: phases, architecture, DoD)
```

This preserves `backlog.md` as the **single source of truth** for all tasks while keeping it token-efficient.

## Operation Flow

### Two Parallel Streams

- **Strategic stream:** plan → backlog → done (`#backlog`)
- **Quick task stream:** session request → hot lane → done (`#session`) or promote → backlog

### Key Workflow Integration

| Workflow         | Role                                                                  |
| :--------------- | :-------------------------------------------------------------------- |
| `/open`          | Reads backlog Summary (~10 lines) + hot lane. Never the full backlog. |
| `/end`           | **Sole sync point** — Hot Lane Sync + Smart Suggest + plan check      |
| `/backlog clean` | Compress Done items into Completed section. Details → `done.md`       |
| `/plan review`   | Counts task IDs in `done.md` to measure Phase progress                |
| `/retro`         | Analyzes `done.md` — `#backlog` vs `#session` ratio for velocity      |

## Token Budget

| Source             | Tokens       | Condition                      |
| :----------------- | :----------- | :----------------------------- |
| project.md         | ~80-120      | Always                         |
| sprint-current.md  | ~50-100      | Always (if exists)             |
| backlog.md Summary | ~80-130      | Always (grep summary + active) |
| session log        | ~50-100      | Always (tail)                  |
| plan (if active)   | ~30-50       | Only if `active_plan` set      |
| SYNC.md            | ~50-100      | Only if `downstream` set       |
| **Total (simple)** | **~260-450** | No plan, no sync               |
| **Total (full)**   | **~360-640** | Plan + sync                    |

## Version History

| Aspect                 | v1.5.2 (Working Checkmarks) | v1.5.3 (Hot Lane)                |
| :--------------------- | :-------------------------- | :------------------------------- |
| sprint-current.md      | Mirror backlog (unused)     | Hot Lane — agent writes directly |
| Quick tasks            | Unstructured                | sprint-current.md = Hot Lane     |
| Sync point             | Multiple commands           | `/end` only                      |
| Ceremony during coding | `/backlog update` per task  | Zero                             |
| done.md structure      | Flat, date-grouped          | Plan-grouped with origin tags    |
| `/backlog clean`       | Delete from backlog         | Compress into Completed section  |

## References

- **Rule:** `hybrid-3-file-integrity.md` — C1 (Hot Lane), C2 (plan-grouped done.md), C3 (compress-not-delete), C5 (/end sync)
- **RFC-0002:** `rfcs/0002-hybrid-3-file-integrity.md`
- **Schema:** `kernel/schema/tasks.schema.md`
- **Kernel:** Invariant I2 (`kernel/invariants.md`)

---

_Published from `docs/architecture/hybrid-3-file.md` (Vietnamese internal) — v1.5.3_
