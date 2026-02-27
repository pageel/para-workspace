---
description: Start a working session with context from previous logs and sync queue
source: catalog
---

# /open [project-name]

> **Workspace Version:** 1.4.1 (Governed Libraries)

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

### 3. Find and read latest session

//turbo

```bash
ls -t Projects/[project-name]/sessions/*.md | head -3
```

Read the latest session log for context on previous work.

### 4. Read backlog (if exists)

//turbo

> ⚠️ **Token optimization:** Use the `view_file` tool to read the entire `Projects/[project-name]/artifacts/tasks/backlog.md` file. Do NOT use `grep` or `head` bash commands to parse it. Instead, extract the task counts directly from the `📊 Summary` table at the bottom of the file.

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

> Do NOT read architecture diagrams, data schemas, or code samples during `/open`.

### 6. 🔔 Check Sync Queue (Cross-Project Notifications)

//turbo

Read `Areas/Workspace/SYNC.md` and **filter rows** where the `Downstream` column matches `[project-name]` and Status is `🔴 Pending`.

If there are pending sync items, display them prominently:

```
⚠️ UPSTREAM CHANGES DETECTED:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
| Source: [upstream-project] v[version]
| Action: [what needs to be done]
| Date:   [when it was logged]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After presenting the sync items, ask the user whether they want to **process** the changes (update code/content) or simply **dismiss** them (mark as read).

Once the user decides, automatically update `SYNC.md`:

- Move the row from `## Pending` to `## Completed` (remove the Status column).
- **IMPORTANT:** Auto-trim the `## Completed` table, keeping only the **5 most recent** entries. Delete older rows to prevent file bloat and save system tokens.

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

📥 BACKLOG SUMMARY:
- High: [N] | Medium: [N] | Low: [N]
- Top items: [list 2-3 items from current phase]

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
