# Guard Catalog

> Classification of all guard types used across PARA Workspace artifacts.
> Agent references this catalog when generating `<!-- ⚠️ ... -->` comments.

## Guard Types

| Guard Type | Syntax | Placement | Purpose |
|:--|:--|:--|:--|
| STATUS GATE | `<!-- ⚠️ STATUS GATE: ... -->` | Plan file header (after frontmatter) | Block Phase execution while plan Status is `📝 Draft` |
| MANDATORY | `<!-- ⚠️ MANDATORY: ... -->` | First line after Phase heading | Force Agent to reload rules/skills indices before any side-effect |
| HARNESS GUARD | `<!-- ⚠️ HARNESS GUARD (Risk): ... -->` | After MANDATORY, before Implementation Plan | Warn about specific risk mapped from Risks & Mitigations table |
| FILE GUARD | `<!-- ⚠️ [TYPE] — [constraint] -->` | After file title or YAML frontmatter | Protect file integrity (APPEND-ONLY, HOT LANE, READ-ONLY, etc.) |
| WORKFLOW GATE | `<!-- ⚠️ WORKFLOW GATE: ... -->` | Before a critical workflow step | Prevent Agent from skipping an important step |
| CONTEXT RECOVERY | `<!-- ⚠️ CONTEXT RECOVERY: ... -->` | End of long artifacts (>500 lines) | Remind Agent to reload context if attention has decayed |

## File Guard Subtypes

> These are standard FILE GUARD variants defined in `hybrid-3-file-integrity.md` §C6.

| Subtype | Template | Scope |
|:--|:--|:--|
| TASK (append) | `<!-- ⚠️ APPEND-ONLY — /end or /backlog clean only (C2) -->` | `artifacts/tasks/done.md` |
| TASK (hot lane) | `<!-- ⚠️ HOT LANE ONLY — No backlog tasks here (C1) -->` | `artifacts/tasks/sprint-current.md` |
| TASK (authority) | `<!-- ⚠️ OPERATIONAL AUTHORITY — Mutations via /backlog only (C3) -->` | `artifacts/tasks/backlog.md` |
| KERNEL | `<!-- ⚠️ READ-ONLY SNAPSHOT — Do NOT modify (I9) -->` | `kernel/`, `Resources/ai-agents/kernel/` |
| GOVERNED | `<!-- ⚠️ GOVERNED — /para-rule only. Overwritten by para update -->` | `.agents/rules/` |
| WORKSPACE | `<!-- ⚠️ APPEND-ONLY — via /end only -->` | `Areas/Workspace/` |

## Placement Convention

- **Files with YAML frontmatter:** Guard goes **after** closing `---`, **before** `# Title`.
- **Files without YAML:** Guard goes after `# Title` (line 3).
- **Plan phases:** MANDATORY first → HARNESS GUARD(s) second → blank line → content.

## Generation Rules

1. Every Phase in a Detail Plan MUST have a MANDATORY guard.
2. HARNESS GUARD is added ONLY when a risk from the Risks & Mitigations table maps to that Phase.
3. HARNESS GUARD content MUST reference the specific risk name, not generic text.
4. FILE GUARD content MUST reference the specific rule constraint (e.g., C1, C2, I9).
5. Guards are HTML comments — invisible to readers but visible to Agent context window.
