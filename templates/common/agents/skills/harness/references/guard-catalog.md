# Guard Catalog

> Classification of all guard types used across PARA Workspace artifacts.
> Agent references this catalog when generating `<!-- ⚠️ ... -->` comments.

## Guard Types

| Guard Type | Syntax | Placement | Purpose |
|:--|:--|:--|:--|
| STATUS GATE | `<!-- ⚠️ STATUS GATE: ... -->` | Plan file header (after frontmatter) | Block Phase execution while plan Status is `📝 Draft` |
| MANDATORY | `<!-- ⚠️ MANDATORY: ... -->` | First line after Phase heading | Force Agent to reload rules/skills indices before any side-effect |
| HARNESS GUARD | `<!-- ⚠️ HARNESS GUARD (Risk): ... -->` | After MANDATORY, before Implementation Plan | Warn about specific risk mapped from Risks & Mitigations table |
| CHECKPOINT | `⛔ CHECKPOINT: [action]` | Inside Task List, before git/status tasks | Break momentum bias — force Agent to execute checkpoint action before continuing. For phase transitions, MUST explicitly demand running the MCP tool `project_session_compact`, reading the updated `session.md` using `view_file` to reload context, and obtaining explicit User approval. Pre-commit safety checkpoints MUST also explicitly dictate: (1) running `node .agents/skills/plan/scripts/check-phase-tasks.js <plan> <phase>` and verifying exit code 0, AND (2) verifying that all implemented tasks in the active plan/phase are marked as completed (`[x]`) in the plan file, and (if graph/mcp is enabled) running `project_snapshot`, `project_diff`, and `graph_audit_csa` tools. |
| PHASE START BASELINE | `<!-- ⚠️ PHASE START BASELINE: ... -->` | After MANDATORY, before Implementation Plan (in Phase ≥ 1) | Force Agent to STOP and propose `/brainstorm`, `/qa`, `/spec`, or `/research` as a design baseline before coding. Agent MUST wait for user response. |
| FILE GUARD | `<!-- ⚠️ [TYPE] — [constraint] -->` | After file title or YAML frontmatter | Protect file integrity (APPEND-ONLY, HOT LANE, READ-ONLY, etc.) |
| WORKFLOW GATE | `<!-- ⚠️ WORKFLOW GATE: ... -->` | Before a critical workflow step | Prevent Agent from skipping an important step |
| SECTION GUARD | `<!-- ⚠️ SECTION GUARD (Scope Isolation): Agent MUST ONLY modify this section. DO NOT delete, truncate, or edit unrelated sections. -->` | Before System Design & Document Section Headings | Scope isolation: Protect unrelated sections from accidental deletion/truncation |
| CONTEXT RECOVERY | `<!-- ⚠️ CONTEXT RECOVERY: ... -->` | End of long artifacts (>500 lines) | Remind Agent to reload context if attention has decayed |
| POST-BASELINE | `⛔ POST-BASELINE APPROVAL: Agent MUST end turn here.` | After pre-code tool output in vibecode session phase task list | Force turn boundary between design baseline completion and code execution — prevents brainstorm→code auto-chaining |

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
| TRACKER (link-only) | `<!-- ⚠️ FILE GUARD — Do not write any other content here. Focus only on reading and updating the linked project plan above. -->` | `brain/implementation_plan.md`, `brain/task.md`, `brain/walkthrough.md` |

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
   - Commit: `<!-- ⚠️ HARNESS GUARD (VCS — Commit #N/M [Scope]): Agent MUST re-read rules/vcs.md, verify all implemented tasks are checked [x] in the plan, and commit. -->`
   - Push: `<!-- ⚠️ HARNESS GUARD (VCS — Push Remote): 🛑 STOP HERE. Agent MUST ask User confirmation. -->`
7. `git commit` and `git push` MUST be **separate task items** — never combined into one task. This ensures each operation has its own guard and can be individually approved.
8. **Status transition guard:** Walkthrough section MUST enforce that all tasks are completed BEFORE proposing completion. Agent MUST NOT propose or change plan Status to `✅ Done` or clear `active_plan` without explicit user approval after Walkthrough is fully checked. Format:
   - `<!-- ⚠️ HARNESS GUARD (Status Transition → Done): 🛑 STOP HERE. Walkthrough MUST be completed BEFORE proposing Done. Agent MUST NOT change Status without user approval. -->`
9. **Walkthrough cleanup:** After running verification commands, Agent MUST identify all newly generated untracked or ignored files by comparing `git status --ignored --porcelain` with the initial snapshot. Agent MUST NOT delete them silently. Instead, Agent MUST present the list to the User, ask whether each file is junk (to be deleted) or a missed plan file (to be committed), and only proceed with cleanup after explicit User confirmation.
10. **Graph-First Policy:** If the project utilizes the Code-Knowledge Graph (e.g., via `para-graph`), Agent MUST:
    - Add a task in Phase 0 to run `/para-graph build` to synchronize Graph Memory.
    - Add an inline HARNESS GUARD in Execution Phases before modifying critical code: `<!-- ⚠️ HARNESS GUARD (Graph-First Policy): Agent MUST call mcp_para-graph_graph_context_bundle for node [NodeID] BEFORE modifying the code to understand its full dependencies. -->`
11. **Graph Knowledge Preparation:** Agent MUST explicitly list "Graph Knowledge Preparation" as a required Phase 0 task in all detail plans if the project supports Graph.
12. **TDD Strict Cycle:** If the plan uses TDD, Agent MUST enforce the "TDD Strict Cycle" using `tdd-test.sh` to record evidence before every commit.
13. **Post-Draft Audit Checkpoint:** When a detail plan is created, Agent MUST stop at the checkpoint immediately after writing the Draft file (with review counters initialized to `0` and date as `—`) and explicitly ask the User for permission to run the Quality Audit and edit the draft plan. Agent MUST NOT auto-run the audit or write `Passed` / `Count: 1` before receiving explicit confirmation.
14. **PR Protocol Guard:** If project rules (`maintenance.md`) enforce Feature Branch & Auto-Merge PR Protocol, Phase N tasks MUST explicitly specify feature branch creation (`git checkout -b`) and PR creation (`gh pr create --auto --squash`) instead of direct `git push` to `main`.
15. **Phase Start Baseline Gate:** Every Phase ≥ 1 in ANY plan type (Session, Detail, TDD, Hardened) MUST have the Agent propose a design baseline check before coding. Agent MUST present options: `/brainstorm` (clarify architecture), `/qa` (stress-test requirements), `/spec` (write/update specification), `/research` (investigate unknowns). Agent MUST STOP and wait for user selection before proceeding to code. Skipping without user response is a workflow violation.
16. **Pre-Git Task Done Script Gate:** Every pre-commit CHECKPOINT in ANY plan type MUST instruct the Agent to run `node .agents/skills/plan/scripts/check-phase-tasks.js <plan-file> <phase-number>` and verify exit code 0. If the script returns exit 1, Agent MUST list the unchecked tasks and resolve them before proposing git commit.
17. **Post-Baseline Approval Gate:** When ANY pre-code tool (`/brainstorm`, `/qa`, `/spec`, `/research`) completes during a vibecode session phase, Agent MUST save the output artifact, present summary to user, and **STOP calling tools (end turn)**. Agent MUST NOT proceed to code modifications until explicit user approval is received in a new turn. This prevents the Agent from auto-chaining brainstorm → code in a single turn, which is a sovereignty violation. Plan templates SHOULD generate a visible `⛔ POST-BASELINE APPROVAL` checkpoint item between the baseline task and the first code task in each Phase ≥ 1.

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
