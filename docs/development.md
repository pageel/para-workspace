# Development Workflow Guide

> **Version**: 1.5.3 | How the daily, planning, release, and operations workflows fit together.

## Overview

PARA Workspace organizes development into 4 workflow streams:

```
┌──────────────────────────────────────────────────────────────────────┐
│                                                                      │
│  0. PLANNING          1. DAILY DEV        2. RELEASE      3. OPS    │
│  ────────────         ──────────          ──────────      ────────  │
│  /plan create         /open               /release        /retro    │
│     ↓                    ↓                   ↓            /inbox    │
│  /backlog sync        [coding + hot lane]                           │
│                          ↓                                          │
│                       /push                                         │
│                          ↓                                          │
│                       /end (sync + plan check)                      │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

## Daily Flow

```
/open → [code + hot lane] → /push → /end (sync)
```

- **`/open`**: Loads session log, backlog summary, Hot Lane, current phase.
- **Hot Lane** (`sprint-current.md`): Agent-writable buffer for quick tasks. Write `- [ ]` when tasks emerge, tick `[x]` when done.
- **`/push`**: Commit + push to GitHub.
- **`/end`**: Sole sync point. Hot Lane Sync moves `[x]` → `done.md`, suggests marking strategic tasks Done.

> No need to run `/backlog update` mid-session. `/end` handles all sync.

## Artifacts

```
project.md (active_plan, has_rules)
    → Plan (plans/)            ← HOW & ORDER
    → Backlog (backlog.md)     ← WHAT & STATUS
    → Hot Lane (sprint-current.md) ← AD-HOC BUFFER
    → Done (done.md)           ← RECORD (#backlog + #session)
    → Session Log              ← EVIDENCE
    → CHANGELOG                ← PUBLIC RECORD
```

Completed plans archive to `plans/done/` with a completion review alongside.

## CLI: update vs install

| Command          | Action               | Use when                  |
| :--------------- | :------------------- | :------------------------ |
| `./para update`  | `git pull` + install | Need latest from GitHub   |
| `./para install` | Sync local only      | Source already up-to-date |

> ⚠️ `install` does NOT pull. Use `update` for latest version.

## Best Practices

**DO**: Start with `/open` · Commit often with `/push` · Quick tasks → `sprint-current.md` · End with `/end`  
**DON'T**: Skip `/open` · Forget `/end` · Run `/backlog update` mid-session · Read full plan in `/open`

## Related

- [Planning Guide](./planning.md) — Plan + Backlog workflow
- [Workflows](./workflows.md) — Catalog and philosophy
- [CLI Reference](./cli.md) — Command-line tools

---

_Updated in v1.5.3 (Hot Lane, /end Sync Point, CLI distinction)_
