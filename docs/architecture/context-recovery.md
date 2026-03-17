# Defense-in-Depth: Context Recovery After Truncation

> **Version**: 1.5.4 | **Last reviewed**: 2026-03-17

## Overview

AI Agents in long conversations experience **context truncation** — the system drops earlier context to stay within token limits. When this happens, the agent loses all rules loaded at session start, leading to silent rule violations.

PARA Workspace v1.5.4 implements a **4-layer Defense-in-Depth** strategy. No single layer is perfect; the strength lies in their combination.

## The Problem

After truncation, the agent may perform side-effects (git push, edit task files, modify system configs) **without remembering** the rules that govern those operations.

## 4 Layers of Protection

### Layer 1: Rule File — Context Recovery Protocol

`agent-behavior.md` Section 4 instructs the agent to re-read `.agent/rules.md` when context appears incomplete. Includes a **File-Level Guards** table mapping file patterns to required rules:

| File pattern              | MUST re-read before editing     |
| :------------------------ | :------------------------------ |
| `artifacts/tasks/done.md` | `hybrid-3-file-integrity.md` C2 |
| `artifacts/tasks/*.md`    | `hybrid-3-file-integrity.md`    |
| `.agent/rules/*.md`       | `governance.md`                 |
| `kernel/`, `.para/`       | `governance.md`                 |

**Strength:** Covers workflow bypass (direct file edits). **Extensible** — project rules MAY define additional guards in their own `rules.md` File Guards section.
**Weakness:** Passive — depends on agent recognizing context decay.

### Layer 2: Workflow Output — Safety Block

`/open` Step 8 report includes a compact rules reminder (~40 tokens) designed to survive in checkpoint summaries:

```
🛡️ SAFETY (persist across truncation):
- Git: Do NOT merge/branch/tag without user approval.
- Governance: Do NOT modify kernel/ or .para/.
```

**Strength:** Persists across truncation in checkpoint summaries.
**Weakness:** General reminder only, not file-specific.

### Layer 3: Workflow Pre-flight — Step 0

Seven workflows with side-effects include Step 0 that re-reads `rules.md` from disk:

`/push`, `/release`, `/end`, `/plan`, `/docs`, `/backlog`, `/retro`

**Strength:** Active — forces re-read from disk, not memory.
**Weakness:** Only triggers when agent **uses a workflow**. Bypassed workflows = bypassed pre-flight.

### Layer 4: File Guard Headers ⭐

Inline HTML comments at the top of protected files. The agent **must read the file before editing** — the guard is the first thing it sees:

```markdown
<!-- ⚠️ APPEND-ONLY: Write via /end or /backlog clean only (C2) -->
<!-- ⚠️ HOT LANE ONLY: No strategic tasks from backlog (C1) -->
```

Defined as constraint C6 in `hybrid-3-file-integrity.md`. Templates provided in `/new-project` workflow.

**Strength:** Closest to the violation point (**Proximity Principle**). Works even when agent has lost all context.
**Weakness:** Only covers files that have guard headers.

## Coverage Flow

```
Post-truncation agent action:
  │
  ├─ Agent detects decay? ──── YES ──▶ L1: re-read rules ✅
  │                              NO
  ├─ Safety Block in summary? ─ YES ──▶ L2: general reminder ✅
  │                              NO
  ├─ Uses workflow? ─────────── YES ──▶ L3: force re-read ✅
  │                              NO
  ├─ Opens file to edit? ────── YES ──▶ L4: sees guard header ✅
  │                              NO
  └─ ❌ Edge case → user catches → /learn
```

## Token Cost

Total: **~200-275 tokens/session** (~3-5% of session budget). Negligible cost for comprehensive protection.

## References

- `agent-behavior.md` Section 4 — Context Recovery + File-Level Guards
- `hybrid-3-file-integrity.md` C6 — File Guard Headers
- `context-rules.md` Rule #4 — File Guards format specification
- [Rule Layers Architecture](./rule-layers.md) — Workflow Coverage table
- [Hybrid 3-File Architecture](./hybrid-3-file.md) — C6 guard headers

---

_Published from `docs/architecture/context-recovery.md` — v1.5.4 (FEAT-47)_
