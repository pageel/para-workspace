---
description: Start a working session with context from previous logs and sync queue
source: catalog
---

# /open [project-name]

> **Workspace Version:** 1.5.3 (Hot Lane)

Start a new working session with full context from previous sessions.

## Steps

> **Constraint:** Read `.para-workspace.yml` at the workspace root to get the user's preferred language from `preferences.language` (e.g., `vi` for Vietnamese). **All output and the final report MUST be translated to this language.**

### 1. Identify project paths

```
Base: Projects/[project-name]/
├── repo/         # Source code (git root)
├── sessions/     # Session logs
├── artifacts/    # Tasks, backlog, and other generated files
├── docs/         # Project documentation
└── project.md      # Project contract (YAML)
```

### 2. Read project contract

//turbo

Read `Projects/[project-name]/project.md` to understand goal, deadline, status, and DoD.

### 2.5. Load rules indices

//turbo

#### 2.5a: Workspace rules (ALWAYS)

> This step is **MANDATORY** for every session, regardless of project.

Read `.agent/rules.md` — the workspace-level rules trigger index (~20 lines, ~200 tokens).

- This file lists all **global rules** with their trigger conditions.
- Agent memorizes the trigger table and loads specific rule files **on demand** during the session.
- **MUST NOT** skip this step. Global rules apply to ALL projects.

#### 2.5b: Project rules (CONDITIONAL)

> ⚠️ **Token optimization:** Use `project.md` (already read in Step 2) to gate this check. Only read the index file (~5–10 lines), NOT individual rule files.

Check `project.md` frontmatter for `has_rules: true` (or check if `Projects/[project-name]/.agent/rules.md` exists):

- **If `has_rules: true`** (or file exists) → Read the project rules index and note trigger conditions for the session.
- **Otherwise** → Skip. Zero I/O cost.

During the session, when performing an action that matches a trigger from **EITHER** index (workspace or project), the agent **MUST** read the corresponding rule file **BEFORE** acting.

### 3. Find and read latest session

//turbo

```bash
ls -t Projects/[project-name]/sessions/*.md | head -3
```

Read the latest session log for context on previous work.

### 4. Read task context — Token Optimized

//turbo

> ⚠️ **Token optimization:** Read backlog summary (~10 lines) + hot lane. NEVER read full backlog.

**Step 4a: Backlog Summary** (ALWAYS read)

```bash
grep -A 10 "Summary" Projects/[project-name]/artifacts/tasks/backlog.md
```

Also extract top active items:

```bash
grep -E "ToDo|In Progress" Projects/[project-name]/artifacts/tasks/backlog.md | head -5
```

**Step 4b: Hot Lane** (read IF EXISTS, graceful skip)

Check if `Projects/[project-name]/artifacts/tasks/sprint-current.md` exists:

- **If exists** → Read entire file (small, ~50-100 tokens). Note any pending `[ ]` items.
- **If not exists** → Skip. Report: `🔥 Hot Lane: trống (chưa có file)`

> **Rule:** `hybrid-3-file-integrity.md` C1 — sprint-current.md is the Hot Lane for quick tasks.

### 5. Read implementation plan — summary only (if active)

//turbo

> ⚠️ **Token optimization:** Only read plan if `project.md` frontmatter has `active_plan` field. Do NOT scan directories or read full plan.

Check the `active_plan` field from `project.md` (already loaded in Step 2):

- **If `active_plan` exists** (e.g., `active_plan: "plans/implementation-plan.md"`):
  1. **Extract phase headers only**:
     ```bash
     grep -n "^### Phase" Projects/[project-name]/artifacts/[active_plan]
     ```
  2. **Read the Backlog → Phase Mapping table** (~20-30 lines):
     ```bash
     grep -A 30 "Backlog.*Phase Mapping" Projects/[project-name]/artifacts/[active_plan]
     ```
  3. From the mapping, identify the **current phase** (first phase with incomplete items).
  4. Store phase context for the report in Step 8.

- **If `active_plan` is empty or missing** → Skip this step entirely. No plan overhead.

> 🛡️ **Progressive Disclosure:** Do NOT read `Resources/ai-agents/kernel/` or any architecture diagrams during `/open`. Keep the context ultra-light to save tokens and prevent attention decay.

### 6. 🔔 Check Sync Queue (Cross-Project Notifications)

//turbo

> ⚠️ **Token optimization:** Only read SYNC.md if `project.md` (loaded in Step 2) has `downstream` or `upstream` fields. If neither exists → skip entirely.

Check `project.md` frontmatter (already loaded in Step 2):

- **If `downstream` or `upstream` field exists:**
  1. Read `Areas/Workspace/SYNC.md`
  2. Filter rows where `Downstream` column matches `[project-name]` and Status is `🔴 Pending`
  3. If pending items found, display prominently:
     ```
     ⚠️ UPSTREAM CHANGES DETECTED:
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     | Source: [upstream-project] v[version]
     | Action: [what needs to be done]
     | Date:   [when it was logged]
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     ```
  4. Ask user: process or dismiss.
  5. Update `SYNC.md` accordingly. Auto-trim Completed to 5 most recent.

- **If neither field exists** → Skip. No sync overhead.

### 7. Check Git status

//turbo

```bash
cd Projects/[project-name]/repo && git status --short && git log -n 1 --oneline
```

### 8. Display report

```
🚀 Starting: [Project Name] | 📅 [YYYY-MM-DD]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 LAST SESSION: [Date] - [Focus]

✅ Completed:
- [Items from session log]

⏳ Pending TODO:
- [ ] [Pending items]

📐 CURRENT PHASE: [Phase N: Name]
   Progress: [N/M] tasks done | Timeline: [N days estimated]
   Next tasks:
   - [Backlog ID] [Story] — ⏳ Pending
   - [Backlog ID] [Story] — 🚀 ToDo
   (omit if no plan exists)

🔔 SYNC QUEUE: [N pending] / [0 if none]

📝 BACKLOG SUMMARY:
- High: [N] | Medium: [N] | Low: [N]
- Top items: [list 2-3 items from current phase]

🔥 HOT LANE:
- [Pending quick tasks from sprint-current.md]
- (or: "No pending quick tasks")

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 SUGGESTED ACTIONS:
1. [Priority 1 — from current phase if plan exists]
2. [Priority 2 — sync items if pending]
3. [Priority 3]

❓ What would you like to work on?
```

> **Note:** When a plan exists, Suggested Actions should prioritize tasks from the current phase. Do not suggest tasks from future phases unless the current phase is complete.

## Related

- `/end` — End session and log progress
- `/plan` — View or update implementation plan
- `/backlog` — View detailed backlog
- `/push` — Quick commit and push
