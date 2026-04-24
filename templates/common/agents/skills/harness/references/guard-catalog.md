# Guard Catalog

> Classification of all guard types used across PARA Workspace artifacts.
> Agent references this catalog when generating `<!-- ⚠️ ... -->` comments.

## Guard Types

| Guard Type | Syntax | Placement | Purpose |
|:--|:--|:--|:--|
| STATUS GATE | `<!-- ⚠️ STATUS GATE: ... -->` | Plan file header (after frontmatter) | Block Phase execution while plan Status is `📝 Draft` |
| MANDATORY | `<!-- ⚠️ MANDATORY: ... -->` | First line after Phase heading | Force Agent to reload rules/skills indices before any side-effect |
| HARNESS GUARD | `<!-- ⚠️ HARNESS GUARD (Risk): ... -->` | After MANDATORY, before Implementation Plan | Warn about specific risk mapped from Risks & Mitigations table |
| CHECKPOINT | `⛔ CHECKPOINT: [action]` | Inside Task List, before git/status tasks | Break momentum bias — force Agent to execute checkpoint action before continuing |
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
- **Task List (inline):** HARNESS GUARD goes **on the line immediately before** the task item it protects. Agent reads Task List sequentially — guard MUST be at the point of encounter, not in a separate section.

## Generation Rules

1. Every Phase in a Detail Plan MUST have a MANDATORY guard.
2. HARNESS GUARD is added ONLY when a risk from the Risks & Mitigations table maps to that Phase.
3. HARNESS GUARD content MUST reference the specific risk name, not generic text.
4. FILE GUARD content MUST reference the specific rule constraint (e.g., C1, C2, I9).
5. Guards are HTML comments — invisible to readers but visible to Agent context window.
6. **VCS inline guards:** Every task item containing `git commit` or `git push` MUST have a HARNESS GUARD on the line immediately above it. Format:
   - Commit: `<!-- ⚠️ HARNESS GUARD (VCS — Commit #N/M [Scope]): Agent MUST re-read rules/vcs.md. [Local/Remote] commit. -->`
   - Push: `<!-- ⚠️ HARNESS GUARD (VCS — Push Remote): 🛑 STOP HERE. Agent MUST ask User confirmation. -->`
7. `git commit` and `git push` MUST be **separate task items** — never combined into one task. This ensures each operation has its own guard and can be individually approved.
8. **Status transition guard:** Walkthrough section MUST include a HARNESS GUARD before `Clear active_plan` task. Agent MUST NOT change plan Status to `✅ Done` or clear `active_plan` without explicit user approval. Format:
   - `<!-- ⚠️ HARNESS GUARD (Status Transition → Done): 🛑 STOP HERE. Agent MUST NOT change Status without user approval. -->`
9. **Walkthrough cleanup:** After running verification commands that generate output files (e.g., `build`, `cli run`), Agent MUST delete the generated artifacts and verify `.gitignore` covers all output patterns. Untracked generated files MUST NOT remain in the repo after Walkthrough.
10. **Graph-First Policy:** If the project utilizes the Code-Knowledge Graph (e.g., via `para-graph`), Agent MUST:
    - Add a task in Phase 0 to run `/para-graph build` to synchronize Graph Memory.
    - Add an inline HARNESS GUARD in Execution Phases before modifying critical code: `<!-- ⚠️ HARNESS GUARD (Graph-First Policy): Agent MUST call mcp_para-graph_graph_context_bundle for node [NodeID] BEFORE modifying the code to understand its full dependencies. -->`

## Dual-Format Convention (v1.7.16)

> Every guard SHOULD exist in **two formats** simultaneously:
> 1. **HTML comment** — backward compat + machine parsing
> 2. **Visible blockquote** — visible when rendered + Agent visual recognition

**Dual-Format syntax:**

```markdown
<!-- ⚠️ [GUARD_TYPE]: [detail] -->

> ⛔ **[GUARD_TYPE]:** [short human-readable summary]
```

**Rules:**
- STATUS GATE, MANDATORY, and VCS HARNESS GUARD **MUST** use Dual-Format.
- CHECKPOINT items use **visible format only** (they are task items, not comments).
- FILE GUARD may remain HTML-only (backward compat with existing files).
- The visible blockquote MUST appear on the line **immediately after** the HTML comment.

## Commit Consolidation Policy Convention (v1.7.16)

> Plans SHOULD include a `### Commit Consolidation Policy` section after Git Operation Summary.

**Rules:**
- Agent MAY consolidate commits if editing the same file across adjacent Phases, but MUST note the reason in the commit message.
- Agent MUST NEVER consolidate commits containing `git push`.
- Each FEAT/BUG SHOULD have its own commit for traceability.
