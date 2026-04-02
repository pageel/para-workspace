---
description: Log session and close working day with PARA classification
source: catalog
---

# /end [project-name | all | workspace] [done]

> **Workspace Version:** 1.6.3 (Central Gate)
> **Constraint:** Read `.para-workspace.yml` at the workspace root to get the user's preferred language from `preferences.language` (e.g., `vi` for Vietnamese). **All output and the final report MUST be translated to this language.**

Summarize accomplishments and log them to the correct context (Project vs. Workspace).

| Option | Description                                                                                                      |
| :----- | :--------------------------------------------------------------------------------------------------------------- |
| `all`  | Close the working session for all modified projects in git status.                                               |
| `done` | (Optional) If the active plan (`active_plan`) is 100% complete, automatically remove this field in `project.md`. |

## Classification Rules

1. **Project Work**: Active development, bug fixes, or documentation for a specific project.
   - **Log Destination**: `Projects/[project-name]/sessions/YYYY-MM-DD.md`
2. **Workspace & Learning**: Refactoring workspace structure, creating learning artifacts, global standards, or infrastructure updates.
   - **Log Destination**: `Areas/Workspace/sessions/YYYY-MM-DD.md`

## Steps

### 0. Agent Indices Pre-flight

// turbo

Re-read `.agent/rules.md` to ensure rules context is loaded (guard against context truncation).

### 1. Classify & Identify Changes

// turbo

Review your task and determine if it belongs to a specific Project or a Global Area. List modified files.

### 2. Log Session

Create or append to the correct destination based on the rules above. Use "Session X" headers if multiple topics were covered.

Include:

- **What was done** (completed items, bullet list)
- **Pending TODOs** (carry-forward items for next session)
- **Downstream Impact** (if changes affect other projects)

### 3. Cross-Project Sync Queue

Check if the project has `downstream` dependencies in `project.md` (or metadata).
If yes, **append one row** to `Areas/Workspace/SYNC.md` under the `## Pending` table:

```markdown
| YYYY-MM-DD | [project-name] | [new-version] | [downstream-project] | [brief action needed] | 🔴 Pending |
```

### 3.5. Hot Lane Sync (sprint-current.md)

// turbo

> **Rule:** `hybrid-3-file-integrity.md` C5 — `/end` is the sole sync point for all task reconciliation.

**Step A: Process Quick Tasks** (from sprint-current.md)

1. Read `artifacts/tasks/sprint-current.md`. If file not exists → skip to Step B.
2. For each item marked `[x]` in `## Quick Tasks`:
   - Append to `artifacts/tasks/done.md` under today’s date header, with `#session` tag:
     ```markdown
     - [x] <task-description> #session
     ```
3. For each item still `[ ]` in `## Quick Tasks`:
   - Ask user: **“Giữ cho phiên sau?”** or **“Promote vào backlog?”**
   - If promote → add to `backlog.md` via normal format, remove from sprint-current
   - If keep → leave in sprint-current for next session
4. Clean sprint-current.md: remove all `[x]` items, keep `[ ]` items and `## Notes`.
5. Report: `🔥 Hot Lane: [N] quick tasks → done.md, [M] pending`

**Step B: Smart Suggest Strategic Tasks** (from session log)

1. Read session log written in Step 2 (current session’s work summary).
2. Extract any task IDs mentioned (FEAT-XX, BUG-XX patterns).
3. Cross-reference with `backlog.md` active items (grep for matching IDs).
4. For each match, suggest to user:
   ```
   💡 Phiên này bạn đã làm việc với:
   - FEAT-13: Safety Guardrails — Đánh dấu Done?
   - BUG-16: Inbox categorization — Đánh dấu Done?
   ```
5. For user-confirmed items:
   - Update status in `backlog.md` to `✅ Done (YYYY-MM-DD)`
   - Append to `done.md` with `#backlog` tag:
     ```markdown
     - [x] FEAT-13: Safety Guardrails #backlog
     ```
6. Report: `📝 Strategic: [N] tasks → done.md`

> **Ecosystem skip (v1.6.0+):** If project `type: ecosystem`, skip git-related suggestions (no repo to commit). Focus on plan progress and backlog updates only.

### 3.2. Strategy/Roadmap Change Detection

// turbo

> 🛡️ **Field-gated (v1.6.3):** Uses `strategy` and `roadmap` fields from `project.md` to gate scan.

**Pre-check:** Read `strategy` and `roadmap` fields from `project.md` (already loaded in Step 1).

- **IF BOTH fields are null/empty** → Skip entirely. Zero I/O. (Project has no strategy/roadmap → no changes to detect.)
- **IF EITHER field has value** → Continue:

1. Scan session log for file paths changed during this session
2. Check pattern match using resolved paths from fields:
   - Resolved strategy path → Strategy changed
   - Resolved roadmap path → Roadmap changed

3. **IF match found AND project has `satellites` or `downstream`:**
   ```
   📄 Strategy/Roadmap changed during this session.
      Downstream projects may need updates:
      - [satellite/downstream]: [brief action]
      Create SYNC entries? (y/n)
   ```

4. **IF match found AND project has `ecosystem` ref (satellite):**
   ```
   📄 Strategy changed at satellite.
      Sync up to ecosystem [name]? (y/n)
   ```

5. **IF no match** → Skip silently

### 3.3. Brainstorm Follow-up

// turbo

> 🛡️ **Detect brainstorm created during session → suggest next step (D9).**

1. Scan session log for `para-decisions/brainstorm-` file mentions
2. **IF brainstorm created in this session:**
   a. Read brainstorm file → check "Decision" section
   b. **IF "Decision: Pending":**
      ```
      💭 Brainstorm "[topic]" has no decision yet.
         Continue next session? (auto-carry to pending TODO)
      ```
   c. **IF decision made:**
      ```
      💭 Brainstorm "[topic]" has decisions.
         Next steps:
         ├── 📄 Update docs/strategy/? (if strategy topic)
         ├── 📐 Run /plan create? (if needs implementation)
         └── ✅ Already handled (skip)
      ```
3. **IF no brainstorm in session** → Skip silently

### 4. Check Plan Phase Progress (if active)

// turbo

> ⚠️ **Token optimization:** Only check if `project.md` has `active_plan` field (already read in Step 1). Skip entirely if missing.

If `active_plan` exists in `project.md`:

**Resolve plan path (v1.6.0+):**

```
IF active_plan starts with "@":
  1. Extract ecosystem: @{ecosystem}/plans/xxx.md → ecosystem = "{ecosystem}"
  2. Extract relative: plans/xxx.md
  3. Resolved path: Projects/{ecosystem}/artifacts/plans/xxx.md
ELSE:
  Local path: Projects/[project-name]/artifacts/[active_plan]
```

1. Extract current phase:
   ```bash
   grep -n "^### Phase" [resolved-plan-path]
   ```
2. Cross-reference with backlog — count ✅ Done items for the current phase.
3. Report phase status in the session log:

```markdown
### Plan Progress

- **Current Phase**: [Phase N: Name]
- **Progress**: [N/M] tasks done
- **Status**: [🔨 In Progress | 🎉 Phase Complete!]
```

4. If all items in the current phase are complete OR the user issues the command with the `done` keyword:
   - If the scenario is 100% complete:
     - Output: `🎉 Project Plan Complete! Cleaning up active_plan reference.`
     - **Action**: Remove the `active_plan` field from `project.md` to optimize context for future sessions.
   - If a midway phase is complete:
     - Output: `🎉 Phase [N] Complete! Phase [N+1] ready to start.`
5. If the scope or architecture changes during this session, suggest running `/plan update`.

**Step 4.5 — Roadmap Status Sync (v1.6.3 — field-gated):**

After reporting phase status:

1. **IF phase complete** (all tasks done):
   a. Check `roadmap` field from `project.md` (already loaded):
   b. **IF has value** → Resolve path (IF starts with `@` → cross-project: `Projects/{ecosystem}/...`, ELSE → local) → Update phase row: `Status` → `✅ Done`
   c. **IF null/empty** → Skip
   d. Note in session log: `- **Roadmap**: Phase [N] → ✅ Done`

2. **IF plan 100% complete** (done keyword or all phases):
   a. IF `roadmap` has value → Update roadmap phase + suggest next phase (like /plan review Step 6.5)
   b. IF `roadmap` is null → Skip

### 4.7. Knowledge Suggestion (CONDITIONAL)

> **Gate:** Only trigger if session ≥3 file mutations OR user mentions KI topic.
> **Governance:** KR1 — `/end` is an allowed suggestion hook (not a write gate).
> **Source:** Agent uses platform-injected KI summaries (auto-loaded at session start).

1. Scan session log for patterns suggesting valuable knowledge:
   - Major architectural decisions
   - Non-obvious gotchas or workarounds
   - Patterns applicable across projects
2. Cross-reference with platform-injected KI titles
3. **IF match found** (existing KI may need update):
   ```
   💡 SESSION KNOWLEDGE
   This session touched topics related to KI "[title]" (last updated [date]).
   Update this KI? (Y/N/Later)
   ```
4. **IF new insight** (no matching KI):
   ```
   💡 SESSION KNOWLEDGE
   New insight detected: [topic]
   Create KI? Run `/knowledge [topic]` (Y/N)
   ```
5. **IF no trigger** → Skip silently.

### 5. Update Master Index

// turbo

Append a summary line to the global index at `Areas/Workspace/SESSION_LOG.md`:

```markdown
| YYYY-MM-DD | [project-name] | [brief summary of session] |
```

## Related

- `/open` — Start session with context loading
- `/plan` — View or update implementation plan
- `/docs` — Strategy docs may trigger SYNC (Step 3.2)
- `/brainstorm` — Brainstorm follow-up (Step 3.3)
- `/backlog` — View and manage project tasks
- `/push` — Quick commit and push
- `/retro` — Project retrospective before archiving
