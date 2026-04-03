# Defense-in-Depth: Context Recovery After Truncation

> **Version**: 1.7.4 | **Last reviewed**: 2026-04-03

## Overview

AI Agents in long conversations experience **context truncation** — the system drops earlier context to stay within token limits. When this happens, the agent loses all rules loaded at session start, leading to silent rule violations.

PARA Workspace implements a **4-layer Defense-in-Depth** strategy. No single layer is perfect; the strength lies in their combination.

## The Problem

After truncation, the agent may perform side-effects (git push, edit task files, modify system configs) **without remembering** the rules that govern those operations.

## 4 Layers of Protection

### Layer 1: Rule File — Context Recovery Protocol

`agent-behavior.md` Section 4 instructs the agent to re-read `.agents/rules.md` + `.agents/skills.md` (v1.6.2+) when context appears incomplete. **Proactive Trigger Check**: BEFORE any side-effect, scan ALL trigger tables. Includes a **File-Level Guards** table mapping file patterns to required rules:

| File pattern              | MUST re-read before editing     |
| :------------------------ | :------------------------------ |
| `artifacts/tasks/done.md` | `hybrid-3-file-integrity.md` C2 |
| `artifacts/tasks/*.md`    | `hybrid-3-file-integrity.md`    |
| `.agents/rules/*.md`       | `governance.md`                 |
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

`/push`, `/release`, `/end`, `/plan`, `/docs`, `/backlog`, `/retro`, `/knowledge` (v1.7.0+)

**Strength:** Active — forces re-read from disk, not memory.
**Weakness:** Only triggers when agent **uses a workflow**. Bypassed workflows = bypassed pre-flight.

### Layer 4: File Guard Headers ⭐

Inline HTML comments at the top of protected files. The agent **must read the file before editing** — the guard is the first thing it sees.

**4 Guard Types:**

| Type | Scope | Guard template |
|:--|:--|:--|
| `TASK` | `artifacts/tasks/` | `<!-- ⚠️ APPEND-ONLY — /end or /backlog clean only (C2) -->` |
| `TASK` | `artifacts/tasks/` | `<!-- ⚠️ HOT LANE ONLY — No backlog tasks here (C1) -->` |
| `TASK` | `artifacts/tasks/` | `<!-- ⚠️ OPERATIONAL AUTHORITY — Mutations via /backlog only (C3) -->` |
| `KERNEL` | `kernel/`, `Resources/ai-agents/kernel/` | `<!-- ⚠️ READ-ONLY SNAPSHOT — Do NOT modify (I9) -->` |
| `GOVERNED` | `.agents/rules/` | `<!-- ⚠️ GOVERNED — /para-rule only. Overwritten by para update -->` |
| `WORKSPACE` | `Areas/Workspace/` | `<!-- ⚠️ APPEND-ONLY — via /end only -->` |

**Position convention:**

- Files with YAML frontmatter: after closing `---`, before `# Title`
- Files without YAML: after `# Title` (line 3)

Defined as constraint C6 in `hybrid-3-file-integrity.md`. Templates provided in `/new-project` workflow.

**Strength:** Closest to the violation point (**Proximity Principle**). Works even when agent has lost all context. Covers kernel, rules, tasks, and workspace files.
**Weakness:** Only covers files that have guard headers. Migration needed for pre-v1.5.4 projects.

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
- [Knowledge System](./knowledge-system.md) — KI governance (v1.7.0+)

---

_Last updated: 2026-04-03 (FEAT-61: v1.7.4)_
