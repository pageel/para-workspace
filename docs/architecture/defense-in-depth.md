# Defense-in-Depth: Agent Rule Compliance After Truncation

> **Version**: 1.7.11 | **Last reviewed**: 2026-04-10

## Overview

AI agents in long conversations experience **context truncation** — the platform drops earlier context to stay within token limits. When this happens, the agent silently loses all rules loaded at session start.

PARA Workspace implements a **4-layer Defense-in-Depth** strategy to ensure rule compliance survives truncation. No single layer is perfect; the strength lies in their combination and independence. Layer 3 (Physical Force) is the only layer that **breaks the circular dependency** — strengthened with the Soft Dump mechanism since v1.7.9.1.

## The Core Problem: Circular Dependency

Rules tell the agent to re-read rules when context is lost. But if the agent has lost context, it has also **forgotten the rule that tells it to re-read rules**:

```
Agent loses context → Forgets "re-read rules" rule → Doesn't re-read → Violates rules
```

This circular dependency is why a single-layer approach fails. Each layer below addresses this from a different angle.

---

## Layer 1: Rule File — Context Recovery Protocol

**File:** `agent-behavior.md` §4

The agent is instructed to re-read `.agents/rules.md` when it detects context decay. Detection signals:

1. **Truncation notice** — platform explicitly says context was truncated
2. **Forgotten rules** — agent can't recall specific rule details
3. **Long conversation** — session exceeds typical length

**Recovery chain:** Detect decay → Read workspace `rules.md` + `skills.md` (v1.6.2+) → Read project indices (if `agent.rules`/`agent.skills`: true) → Load specific rule/skill files on demand.

**Proactive Trigger Check** (v1.6.2+): BEFORE any side-effect, scan ALL trigger tables (workspace + project, rules + skills). If match found → read rule/skill BEFORE acting.

**File-Level Guards** table maps file patterns to rules that MUST be re-read before editing:

| File pattern | MUST re-read before editing |
| :-- | :-- |
| `artifacts/tasks/done.md` | `hybrid-3-file-integrity.md` C2 |
| `artifacts/tasks/*.md` | `hybrid-3-file-integrity.md` |
| `.agents/rules/*.md` | `governance.md` |
| `kernel/`, `.para/` | `governance.md` |

**Extensible:** Project rules MAY define additional guards in `Projects/<name>/.agents/rules.md`.

**Strength:** Covers workflow bypass (direct file edits). Two-Tier loading saves ~80% tokens. Proactive Trigger Check provides pre-action scanning.
**Weakness:** Passive — depends on agent recognizing it has lost context (circular dependency).

---

## Layer 2: Workflow Output — Safety Block

**File:** `/open` Step 8 report template

The `/open` report includes a compact rules reminder (~40 tokens) positioned near the **end** of the report output. This placement is strategic:

```
/open report output:
  ┌─────────────────────────────────┐
  │  📋 Project status             │  ← Truncated first (oldest)
  │  📊 Backlog summary            │
  │  🛡️ SAFETY BLOCK              │  ← Survives longest (newest)
  └─────────────────────────────────┘
```

**Safety Block content** (3 lines, principle-based):

```
🛡️ SAFETY (persist across truncation):
- Git: Do NOT merge/branch/tag without user approval.
- Governance: Do NOT modify kernel/ or .para/.
- Recovery: If rules feel incomplete → re-read .agents/rules.md
```

**Why only `/open`?** Other workflows have Layer 3 (Pre-flight). `/open` is the session-start workflow that generates the baseline context — the only output that persists across the entire session.

**Strength:** Persists in checkpoint summaries. Zero agent effort required.
**Weakness:** General reminder only. Platform-dependent — truncation strategy varies.

---

## Layer 3: Workflow Pre-flight — Step 0 + Soft Dump

**Files:** 8 workflows with side-effects + 3 ideation workflows

The **only layer that breaks the circular dependency**:

```
Agent runs /push → Step 0 FORCES re-read rules.md → Rules restored → Safe execution
```

Step 0 is a **mandatory first step** in workflows that perform side-effects:

| Workflow | Side-effect risk | Pre-flight type |
|:--|:--|:--|
| `/push` | Git commit, push | Step 0 passive |
| `/release` | Version bump, tag | Step 0 passive |
| `/end` | Task file mutations | Step 0 passive |
| `/plan` | Plan file creation | Step 0 + **Soft Dump** |
| `/docs` | File generation | Step 0 + **Soft Dump** |
| `/backlog` | Task mutations | Step 0 passive |
| `/retro` | Archive operations | Step 0 passive |
| `/para-knowledge` | KI write/update (v1.7.0+) | Step 0 passive |
| `/brainstorm` | Decision + research docs | **Soft Dump** (v1.7.9.1) |

### Soft Dump Payload (v1.7.9.1 — Physical Force)

Workflows with **high ideation + low trigger awareness** (especially `/brainstorm`, `/plan`, `/docs`) are susceptible to **Cognitive Bypass** — the agent skips rule-reading steps to jump directly into thinking.

Passive text reminders ("Re-read rules.md") **failed in v1.7.9** because the agent still skipped them.

**Solution: Inject mandatory bash script** (Soft Dump) — the agent must RUN the command, data flows from disk into the context window, impossible to ignore:

```bash
# Tier-1 Index Force Load (Anti-Cognitive-Bypass v1.7.9.1)
cat .agents/rules.md 2>/dev/null | head -n 30
cat .agents/skills.md 2>/dev/null | head -n 30
```

**Principle:** Agent cannot ignore data already present in the context window → 100% governance compliance.

**`// turbo`** annotation → auto-run, zero friction.

**Why it works:** The agent reads the workflow file from disk → sees Step 0 / Soft Dump → executes it → rules are loaded fresh. No dependency on agent memory.

**Strength:** Active. Breaks circular dependency. Fresh from disk. Defeats Cognitive Bypass.
**Weakness:** Only triggers when agent uses a workflow. Direct file edits bypass this. ~200 tokens overhead per Soft Dump workflow.

---

## Layer 4: File Guard Headers ⭐

**Files:** Protected files across the workspace

The **strongest layer** — based on the **Proximity Principle**: the guard is embedded in the file the agent must open before editing.

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

- Files with YAML frontmatter: guard goes **after** closing `---`, **before** `# Title`
- Files without YAML: guard goes after `# Title` (line 3)

**Why it's the strongest:**

1. **Zero dependencies** — no memory, no workflow, no platform needed
2. **Proximity Principle** — closest to the violation point
3. **Hidden when rendered** — HTML comments don't affect document appearance
4. **Token-compact** — ~10-13 tokens per guard

Defined as constraint C6 in `hybrid-3-file-integrity.md`.

**Strength:** Works even when agent has lost ALL context. Covers kernel, rules, tasks, and workspace files.
**Weakness:** Only protects files that have guard headers. Pre-v1.5.4 projects need migration.

---

## Coverage Matrix

```
Action                          L1   L2   L3   L4
────────────────────────────────  ──   ──   ──   ──
Agent runs /push                ⚠️   ✅   ✅   —
Agent runs /brainstorm          ⚠️   —   ✅⭐ —    ← Soft Dump
Agent runs /end                 ⚠️   ✅   ✅   ✅
Agent edits done.md directly    ✅   —    —    ✅  ← L4 is the last defense
Agent modifies kernel file      ✅   ✅   —    ✅
Agent edits rules file          ✅   —    —    ✅
Free-form request (no workflow) ⚠️   —    —    ✅  ← Only L4 catches this
```

> ⭐ = Soft Dump (Physical Force) — stronger than passive Step 0.

## Token Budget

| Layer | Per-session cost | When |
|:--|:--|:--|
| L1 | ~200 tokens | Rules index read |
| L2 | ~40 tokens | In /open report |
| L3 passive | ~30 tokens | Per workflow invoke |
| L3 Soft Dump | ~200 tokens | /brainstorm, /plan, /docs |
| L4 | ~10-13 tokens/file | When file is opened |
| **Total** | **~400-600 tokens** | **~3-5% of session budget** |

## File Map

| Layer | Implementation files |
|:--|:--|
| L1 | `agent-behavior.md` §4, `context-rules.md` Rule 4, `.agents/rules.md`, `.agents/skills.md` |
| L2 | `/open` Step 8 report template |
| L3 | Step 0 in `/push`, `/release`, `/end`, `/plan`, `/docs`, `/backlog`, `/retro` |
| L4 | `hybrid-3-file-integrity.md` C6, guard headers in `kernel/`, `.agents/rules/`, `artifacts/tasks/`, `Areas/Workspace/` |

## References

- [Context Recovery](./context-recovery.md) — Concise 4-layer overview
- [Rule Layers Architecture](./rule-layers.md) — Two-Tier loading + workflow coverage
- [Hybrid 3-File Architecture](./hybrid-3-file.md) — C6 guard headers
- [Sidecar Skill Pattern](./sidecar-skill.md) — Separating logic from data (v1.7.8+)
- [Knowledge System](./knowledge-system.md) — KI governance (v1.7.0+)
- `hybrid-3-file-integrity.md` C6 — Guard type taxonomy
- `agent-behavior.md` §4 — Context Recovery protocol + File-Level Guards

---

_Last updated: 2026-04-10 (FEAT-70: v1.7.11.1 docs publish)_
