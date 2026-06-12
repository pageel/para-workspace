---
description: Start a working session with context from previous logs and sync queue
source: catalog
---

# /open [project-name]

> **Workspace Version:** 1.6.3 (Central Gate)

Start a new working session with full context from previous sessions.

## Steps

> **Constraint:** Read `.para-workspace.yml` at the workspace root to resolve the user's preferred language.
> Resolution priority:
> 1. If `language` is a map: 
>    - chat language = `language.chat` (fallback: `language.default` -> "en")
>    - thinking language = `language.thinking` (fallback: `language.default` -> "en")
>    - artifacts language = `language.artifacts` (fallback: `language.default` -> "en")
> 2. If `language` is a string: chat & thinking & artifacts language = `language`
> 3. If `language` is undefined, look for `preferences.language` (legacy)
> 4. Default ultimate fallback: "en"
> All output (chat response) MUST be translated to the chat language, all internal reasoning (<thought>) MUST be written in the thinking language, and all generated files in artifacts/ (plans, tasks, qa) MUST follow the artifacts language.

### 1. Identify project paths

```
Base: Projects/[project-name]/
├── repo/         # Source code (git root)
├── sessions/     # Session logs
├── artifacts/    # Tasks, backlog, and other generated files
├── docs/         # Project documentation
└── project.md      # Project contract (YAML)
```

> **Path Resolution Convention (v1.6.3):**
>
> Three fields in `project.md` use path references: `strategy`, `roadmap`, `active_plan`.
> All three support `@{ecosystem}/` cross-project prefix. Resolution rules:
>
> ```
> IF value is null/empty → skip (zero I/O)
> IF value starts with "@":
>   Extract: @{ecosystem}/{relative_path}
>   strategy    → Projects/{ecosystem}/{relative_path}
>   roadmap     → Projects/{ecosystem}/artifacts/{relative_path}
>   active_plan → Projects/{ecosystem}/artifacts/{relative_path}
> ELSE (local):
>   strategy    → Projects/[project-name]/{value}
>   roadmap     → Projects/[project-name]/artifacts/{value}
>   active_plan → Projects/[project-name]/artifacts/{value}
> ```
>
> `strategy` resolves from **project root** (lives in `docs/`).
> `roadmap` and `active_plan` resolve from **artifacts/** (lives in `artifacts/plans/`).

### 2. Read project contract

//turbo

Read `Projects/[project-name]/project.md` to understand goal, deadline, status, and DoD.

**Ecosystem detection (v1.6.0+, updated v1.7.6):**

After reading `project.md`, check the `type` field:

- **If `type: ecosystem`** → Pure coordinator, no code. Note `satellites` list for the report (Step 8). Do NOT read satellite project.md files (token optimization). Skip git (Step 7).
- **If `type: meta-project`** → Product that ALSO coordinates satellites. Note `satellites` list for the report (Step 8). DO run git (Step 7).
- **If `ecosystem` field exists** (on a satellite) → Note the parent ecosystem name for `@` prefix resolution.
- **Otherwise** → Standard project, proceed normally.

**Strategy context (v1.6.3 — field-gated):**

Check the `strategy` field from `project.md` (already loaded above):

- **IF null, empty, or missing** → Skip. Zero I/O.
- **IF has value** → Resolve path (see Path Resolution Convention above):
  ```bash
  head -10 [resolved-strategy-path]
  ```
  Extract: title + first blockquote → ~30 tokens max.
  - **IF file not found** → Log warning: `⚠️ strategy field points to missing file. Run /docs to fix or clear field.`
- Store for report (Step 8)

### 2.5. Load workspace agent indices (ALWAYS)

//turbo

```bash
# Check Vibecode Session Memory at startup (detect unfinished sessions)
SESSION_FILE="${HOME}/.gemini/antigravity-ide/knowledge/vibecode_session/artifacts/session.md"
if grep -q "Status.*Active" "$SESSION_FILE" 2>/dev/null; then
  echo "⚠️ DETECTED ACTIVE CODING SESSION:"
  grep -E "Active Plan:|Current Phase:|Project:" "$SESSION_FILE" 2>/dev/null
fi
```

> This step is **MANDATORY** for every session, regardless of project.
> **MUST NOT** skip. Global rules and skills apply to ALL projects.

Read both workspace-level index files:

1. `.agents/rules.md` — workspace rules trigger index (~20 lines, ~200 tokens)
2. `.agents/skills.md` — workspace skills trigger index (~10 lines, ~100 tokens)

Agent memorizes both trigger tables and loads specific rule/skill files **on demand** during the session.

### 2.6. Load project agent indices (CONDITIONAL)

//turbo

> ⚠️ **Token optimization:** Use `project.md` (already read in Step 2) to gate this check. Only read the index file (~5–10 lines), NOT individual rule/skill files.

Check `project.md` frontmatter for agent config (v1.6.2+, with backward compat):

```
IF agent.rules exists and is true  → Read project .agents/rules.md (new schema)
ELIF has_rules is true             → Read project .agents/rules.md (legacy, backward compat)
ELSE                               → Skip rules. Zero I/O cost.

IF agent.skills exists and is true → Read project .agents/skills.md
ELSE                               → Skip skills. Zero I/O cost.
```

### 2.7. Knowledge Items context

> Platform auto-injects KI summaries. No file I/O needed.

From injected KI data, match scope to project. Store matched slugs for report (Step 8).

#### ✅ Agent Index Completion Gate

> ⚠️ Agent MUST verify ALL checks before proceeding to Step 3.
> If any "true" field was not loaded → READ NOW before continuing.

| # | Check | Source | Required |
| :-- | :-- | :-- | :-- |
| 1 | Workspace rules loaded? | `.agents/rules.md` | ALWAYS |
| 2 | Workspace skills loaded? | `.agents/skills.md` | ALWAYS |
| 3 | Project rules resolved? | `agent.rules` field in project.md | IF true |
| 4 | Project skills resolved? | `agent.skills` field in project.md | IF true |

**Proactive Trigger Check (v1.6.2+):**

During the session, BEFORE performing any action that edits files, runs commands, creates artifacts, or brainstorms technical solutions:

1. Scan workspace `rules.md` trigger table
2. Scan workspace `skills.md` trigger table
3. Scan project `rules.md` trigger table (if loaded)
4. Scan project `skills.md` trigger table (if loaded)
5. **IF match found → read the rule/skill file BEFORE acting**

> Principle: Check THEN act — never act THEN check.

### 3. Find and read latest session

//turbo

```bash
ls -t Projects/[project-name]/sessions/*.md | head -3
```

Read the latest session log for context on previous work.

### 3.5. Check Pending Brainstorms

// turbo

> ⚗️ **Token budget:** 1 grep, ~20 tokens max (D8).

1. Check for brainstorms with pending decisions:
   ```bash
   grep -l "Decision.*Pending\|Decision: Pending" Projects/[project-name]/artifacts/para-decisions/brainstorm-*.md 2>/dev/null
   ```

2. **IF found:**
   - Extract filename → topic + date
   - Store for report (Step 8):
     `💭 BRAINSTORM PENDING: [topic] (YYYY-MM-DD)`

3. **IF not found** → Skip

### 3.6. Graph Memory Injection (Compact Memory)

// turbo

> ⚗️ **Token budget:** ~150 tokens max. Only loads summary.

Check if Compact Memory exists:
```bash
test -f "Projects/[project-name]/.beads/graph/memory-slices.jsonl" || test -f "Projects/[project-name]/repo/.beads/graph/memory-slices.jsonl"
```

- **If exists:**
  1. Read the MCP resource `memory_summary` (or read the generated `memory-log.md` file from `.beads/graph/` or fallback to `memory_summary.md` at root) to inject core architectural decisions and rules into the session context.
  2. Use `memory_search` with a broad query (project name + "architecture" or "decision") to surface the most relevant past session insights. Limit to 5 results for token efficiency.
- **If not exists** → Skip silently. No memory overhead.

### 4. Read task context — Memory-First (Anti-Truncation)

> ⚠️ **Anti-Truncation Architecture:** Read task state from Graph Memory first to avoid bash output truncation. Fallback to file reading only if memory is stale or missing.

**Step 4a: Memory Search (MCP)**
1. Call MCP tool `memory_search(projectName, "task-state-snapshot", limit=1)`.
2. **IF snapshot found:** Use `content` and `metadata` for the report. Proceed to Step 4b for verification.
3. **IF NOT found:** Proceed to Step 4c (Fallback File Read).

**Step 4b: Lightweight Verification (Bash)**

//turbo

If memory snapshot was found, verify it hasn't become stale:
```bash
wc -l Projects/[project-name]/artifacts/tasks/sprint-current.md 2>/dev/null
grep -c "ToDo\|In Progress" Projects/[project-name]/artifacts/tasks/backlog.md 2>/dev/null
```
- Compare actual line counts vs `metadata.sprint_current_lines` and `metadata.backlog_active_lines` from the snapshot.
- **IF mismatch (delta > 3):** Discard memory, proceed to Step 4c.
- **IF match:** Skip Step 4c.

**Step 4c: Fallback File Read (Legacy)**

//turbo

Only if memory was missing or stale:
```bash
grep -A 10 "Summary" Projects/[project-name]/artifacts/tasks/backlog.md 2>/dev/null
grep -E "ToDo|In Progress" Projects/[project-name]/artifacts/tasks/backlog.md 2>/dev/null | head -5
cat Projects/[project-name]/artifacts/tasks/sprint-current.md 2>/dev/null || echo "🔥 Hot Lane: empty (no file)"
```

### 5. Read implementation plan — summary only (if active)

//turbo

> ⚠️ **Token optimization:** Only read plan if `project.md` frontmatter has `active_plan` field. Do NOT scan directories or read full plan.

Check the `active_plan` field from `project.md` (already loaded in Step 2):

**Resolve plan path (v1.6.3 — see Path Resolution Convention above):**

Resolve `active_plan` using the shared convention defined after Step 1.
The resolved path points to the plan file to read.

- **If `active_plan` exists** (local or `@` cross-project):
  > ⚠️ **Platform Tracker Exemption for Macro Documents (v1.9.2):**
  > If the resolved plan path matches macro document naming (contains `roadmap`, `strategy`, `spec`, or `brainstorm`), it is a macro-level document.
  > - **MUST NOT** create or sync platform-level `task.md` or `implementation_plan.md` files in the brain folder.
  > - Skip setting up active tracking tasks in the brain folder.
  > - Still extract phase headers for the report in Step 8 if applicable.

  1. **Extract phase headers only**:
     ```bash
     grep -n "^### Phase" [resolved-plan-path]
     ```
  2. **Read the Backlog → Phase Mapping table** (~20-30 lines):
     ```bash
     grep -A 30 "Backlog.*Phase Mapping" [resolved-plan-path]
     ```
  3. From the mapping, identify the **current phase** (first phase with incomplete items).
  4. Store phase context for the report in Step 8.
  5. If `@` prefix was used, note: `📐 Plan source: @{ecosystem}` in report.

- **If `active_plan` is empty or missing** → Skip this step entirely. No plan overhead.

> 🛡️ **Progressive Disclosure:** Do NOT read `Resources/ai-agents/kernel/` or any architecture diagrams during `/open`. Keep the context ultra-light to save tokens and prevent attention decay.

### 5.5. Roadmap Context Loading

// turbo

> ⚗️ **Token budget:** ~80 tokens max. **Field-gated** (v1.6.3).

Check the `roadmap` field from `project.md` (already loaded in Step 2):

- **IF null, empty, or missing** → Skip. Zero I/O.
- **IF has value** → Resolve path (see Path Resolution Convention above):
  1. Extract Phases Overview table:
     ```bash
     grep -E "^\| [0-9]" [resolved-roadmap-path] | head -10
     ```
  2. Count: total phases, done, active, planned
  3. Store for report (Step 8)
  4. **IF file not found** → Log warning: `⚠️ roadmap field points to missing file. Run /plan to fix or clear field.`

> **Relationship with Step 5 (active_plan):**
> - Step 5 loads DETAIL plan (task-level context)
> - Step 5.5 loads ROADMAP (phase-level overview)
> - Both display in report, in separate sections

**Strategy cascade detection (v1.6.3 — field-gated):**

IF BOTH `strategy` AND `roadmap` fields have non-null values:

1. Resolve both paths, then compare dates:
   ```bash
   stat -c %Y [resolved-strategy-path]   # strategy modified time
   stat -c %Y [resolved-roadmap-path]    # roadmap modified time
   ```

2. **IF strategy.mtime > roadmap.mtime:**
   → Strategy NEWER than roadmap → may be outdated
   → Store warning for report:
   ```
   ⚠️ Strategy updated after roadmap. Roadmap may need review.
      Run /plan review or /plan update?
   ```

3. **IF roadmap >= strategy** → OK, skip

IF EITHER field is null → Skip cascade check entirely. Zero I/O.

### 5.6. Scan for Draft Plans

// turbo

> ⚗️ **Token budget:** 1 grep, ~30 tokens max.

Scan for any implementation plans that are in Draft status in the project's plans directory:

```bash
grep -l -E "Status.*Draft" Projects/[project-name]/artifacts/plans/*.md 2>/dev/null
```

- **IF found:**
  1. Extract plan filenames and titles.
  2. Store the list of draft plans for the report (Step 8):
     `📝 DRAFT PLAN: [plan-name](file:///absolute/path/to/plan)`
- **IF not found** → Skip.

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

**Skip condition (v1.6.0+):** If `type: ecosystem` (detected in Step 2) → skip this step entirely. Ecosystem projects do not have a `repo/` directory.
Note: `meta-project` type DOES have `repo/` — do NOT skip git for meta-projects.

```bash
# Only for standard and meta-project types (type != ecosystem):
cd Projects/[project-name]/repo && git status --short && git log -n 1 --oneline
```

### 8. Display report

```
🚀 Starting: [Project Name] | 📅 [YYYY-MM-DD]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 LAST SESSION: [Date] - [Focus]

✅ Completed:
- [Items from session log]

📄 STRATEGY: [one-line summary from docs/strategy/strategy.md]
   (omit if no strategy docs)

🗺️ ROADMAP: [name] ([N] phases: [done]✅ [active]🔨 [planned]📋)
   Current: Phase [N]: [Name] (vX.Y)
   Next:    Phase [N+1]: [Name] — [has plan / needs /plan create]
   ⚠️ Strategy updated after roadmap — needs review?
   (omit if no roadmap)

📐 ACTIVE PLAN: [plan-name]
   Phase [X/Y] | Progress: [N/M] tasks | Timeline: [est]
   (omit if no active plan)

📝 DRAFT PLAN: [plan-name]
   → Review and transition status to Active to execute
   (omit if no draft plans)

💭 BRAINSTORM PENDING: [topic] (YYYY-MM-DD)
   → /brainstorm to continue, or /plan to formalize
   (omit if no pending brainstorms)

📚 KNOWLEDGE: [N] KIs matched
- [slug] — [title] (scope: [scope], purpose: [purpose])
- (omit if no .para/knowledge/index.md)

🔔 SYNC QUEUE: [N pending] / [0 if none]

📝 BACKLOG SUMMARY:
- High: [N] | Medium: [N] | Low: [N]
- Top items: [list 2-3 items from current phase]

🧠 GRAPH MEMORY: [Available / None]
   [If Available, insert 2-3 bullet points of critical architectural decisions injected from memory-log.md (or memory_summary.md fallback)]

🔥 HOT LANE:
- [Pending quick tasks from sprint-current.md]
- (or: "No pending quick tasks")

🛡️ SAFETY (persist across truncation):
- Git: Do NOT merge/branch/tag without user approval. Read rules/vcs.md first.
- Governance: Do NOT modify Resources/ai-agents/ (read-only).
- Recovery: If rules/skills forgotten → re-read .agents/rules.md + .agents/skills.md.
- Knowledge: KIs are auto-injected by platform at session start.
- Proactive: BEFORE any side-effect → scan trigger tables → load matching rules/skills.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 SUGGESTED ACTIONS:
1. [Priority 1 — from active plan current phase]
2. [Priority 2 — brainstorm pending / strategy cascade / sync]
3. [Priority 3 — roadmap next phase if plan nearly done]

❓ What would you like to work on?
```

> **Priority logic for Suggested Actions:**
> 1. Active plan tasks (if any)
> 2. 📝 Draft plan review (if draft plans detected)
> 3. ⚠️ Strategy cascade / SYNC pending (if any)
> 4. 💭 Pending brainstorms (if any)
> 5. 📐 Roadmap next phase — only when no active plan
> 6. 🔥 Hot lane items
>
> 🔗 **Display constraint:** When suggesting an action that refers to a specific document (e.g., a detail plan, brainstorm file, roadmap, or hot lane file), **MUST** include a clickable markdown file link to that document so the user can open it instantly. (Format: `[filename](file:///absolute/path/to/file)`)

## Related

- `/end` — End session and log progress
- `/plan` — View or update implementation plan
- `/docs` — Strategy docs loaded in Step 2 ext
- `/brainstorm` — Pending brainstorms detected in Step 3.5
- `/backlog` — View detailed backlog
- `/push` — Quick commit and push
