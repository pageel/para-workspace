---
description: Execution mode controller for AI Agent coding — loop, auto, and review modes with --sandbox flag
trigger: coding, plan execution, building features, review plan
glob:
source: user
---

# /vibecode [mode] [target]

> **Workspace Version:** 1.7.14

Execution mode controller that defines HOW the Agent approaches code work. Each mode provides a different strategy for plan execution, testing, and quality assurance.

## Modes

| Mode | Description | Use case |
| :-- | :-- | :-- |
| `loop` | Iterative refinement — repeat until zero errors | Critical features, complex logic |
| `auto` | Fully automated — execute plan phases sequentially | Well-defined plans, routine tasks |
| `review` | Plan audit — check logic, security, token budget | Before executing any plan |
| `session` | Dynamic session loop — JIT Phase creation, mandatory Quality Gate (/brainstorm, /qa, TDD, --graph, --hardened), auto-commit after checkpoints | Fast coding, bug fixes, ad-hoc changes |

### Global Flag: `--sandbox`

Append `--sandbox` to ANY mode to redirect all writes to `Projects/_playground/vibecode-sandbox/`. After success, user explicitly chooses to apply results or discard.

| Command | Behavior |
| :-- | :-- |
| `loop Phase 0` | Iterative on real project (max 5) |
| `loop Phase 0 --sandbox` | Iterative in sandbox (max 5) |
| `loop Phase 0 --sandbox --max 1` | **One-shot sandbox preview** |
| `auto plan.md` | Full plan execution on real project |
| `auto plan.md --sandbox` | Full plan execution in sandbox |
| `review plan.md` | One-shot read-only audit (no file writes) |
| `review plan.md --sandbox` | **Iterative review+fix** in sandbox (default max 3) |
| `review plan.md --sandbox --max 5` | Review+fix with custom max iterations |
| `session topic` | Start dynamic session plan & execute in milestones |
| `session topic --tdd` | Start dynamic session with forced TDD mode |
| `session` | Start DSP Draft (no topic) — phases added JIT as user requests goals |
| `session --graph` | Start DSP Draft with graph-aware phases |
| `session --hardened` | Start DSP Draft with auto-detect + forced TDD on sensitive code |

### Mode Chaining

Modes can be chained for full lifecycle coverage:

```text
review → loop --sandbox → apply → auto
  │           │              │       │
  │           │              │       └─ Execute remaining phases on real project
  │           │              └─ User confirms, copy sandbox → repo/
  │           └─ Iterate in sandbox until zero errors
  └─ Audit plan: logic, security, token, governance
```

**Common patterns:**
- `review` → `loop --sandbox` → `auto`: Full assurance path (recommended for new plans)
- `review` → `auto`: Skip sandbox, execute directly after audit
- `loop --sandbox` (standalone): Safe iterative build — best for first-time execution
- `loop --sandbox --max 1` (standalone): Quick one-shot preview
- `loop` (standalone): Fix a specific broken task on real project

---

## Step 0: Pre-flight (ALL modes)

> **MANDATORY** — Agent MUST execute this before entering any mode.

// turbo

```bash
PROJECT="[project-name]"
echo "=== VIBECODE PRE-FLIGHT ==="
echo "Project: $PROJECT"
echo "Mode: [mode]"
echo "Target: [target]"

# Verify project exists
test -d "Projects/$PROJECT" && echo "✅ Project exists" || echo "❌ Project not found!"

# Active plan
grep -o 'active_plan:.*' "Projects/$PROJECT/project.md" 2>/dev/null || echo "⚠️ No active plan"

# Start Dynamic Session KI Memory (Only for execution modes, not read-only review)
if [ "[mode]" != "review" ]; then
  PLAN_PATH=$(grep -oP 'active_plan:\s*"\K[^"]+' "Projects/$PROJECT/project.md" 2>/dev/null || grep -oP "active_plan:\s*\K[^\s]+" "Projects/$PROJECT/project.md" 2>/dev/null || echo "N/A")
  bash .agents/skills/vibecode/scripts/session-manager.sh start "$PROJECT" "$PLAN_PATH" "[target]"
fi
```

Agent MUST then:
1. Read the project's own domain skill at `Projects/[project-name]/.agents/skills/[project-name]/SKILL.md` (if exists) to understand project-specific rules
2. Read `.agents/rules.md` (workspace rules trigger index)
3. Read `.agents/skills.md` (workspace skills trigger index)
4. Read `Projects/[project-name]/project.md`
5. Read sidecar skill: `.agents/skills/vibecode/SKILL.md`
6. Read `Projects/[project-name]/.beads/seeds.md` (if exists) — prior loop patterns for Adaptive Loop context
7. IF graph exists: use `memory_search` to find past vibecode loop results, error patterns, and architectural decisions related to the target

---

## 🔄 Mode: loop [target] [--max N] [--sandbox]

> **Purpose:** Iteratively execute a task/phase until it passes ALL verification checks. Zero errors guaranteed.
> **Target:** Plan phase, task ID, or scope description.
> **Max iterations:** Default 5. Override with `--max N`.
> **Sandbox flag:** Add `--sandbox` to run inside `_playground/vibecode-sandbox/` instead of real project.

### Sandbox vs Normal Loop

| Aspect | `loop` (normal) | `loop --sandbox` |
|:--|:--|:--|
| **File writes** | Real project (`repo/`) | Sandbox (`_playground/vibecode-sandbox/`) |
| **Rollback** | `git stash` | Delete sandbox (disposable) |
| **Verify commands** | Run in `repo/` | Run in sandbox (may need adaptation) |
| **After success** | Done — files already in place | User chooses: apply to real project or discard |
| **Best for** | Known-safe changes, bug fixes | First-time execution, complex logic, risky changes |

### Steps

#### 1. Define Exit Criteria

Load template from `skills/vibecode/references/loop-config.md`.

Agent presents exit criteria to user:

```markdown
## 🔄 LOOP CONFIGURATION

**Target:** [Phase/Task description]
**Max iterations:** [N, default 5]
**Environment:** 🧪 Sandbox | 🔨 Real project
**Project type:** [auto-detect from package.json, project.md, etc.]

### Exit Criteria (ALL must pass)
- [ ] [Build/syntax command] exits 0
- [ ] [Lint command] exits 0 (if applicable)
- [ ] [Custom criteria from plan]

### Stop Conditions
- Max iterations reached → Report + ask user
- Same error 3 times → Escalate (architecture issue)
- Error count INCREASED → Rollback
```

User MUST confirm before loop starts.

#### 2. Environment Setup

**If `--sandbox`:**

// turbo

```bash
PROJECT="[project-name]"
SANDBOX="Projects/_playground/vibecode-sandbox"
mkdir -p "$SANDBOX"
cd "Projects/$PROJECT/repo" 2>/dev/null && find . -type d | head -50 | while read d; do
  mkdir -p "../../../$SANDBOX/$d"
done
echo "🧪 SANDBOX LOOP: All writes go to $SANDBOX"
# Copy files marked MODIFY in plan
# cp Projects/$PROJECT/repo/path/to/file $SANDBOX/path/to/file
```

Agent MUST replace file paths: `Projects/[project]/repo/X` → `Projects/_playground/vibecode-sandbox/X`

**If normal (no --sandbox):**

Before EACH iteration:

```bash
cd Projects/[project-name]/repo
git stash push -m "vibecode-iter-[N]-$(date +%H%M%S)" 2>/dev/null || true
```

#### 3. Execute Iteration

```
🔄 ITERATION [N/MAX]
━━━━━━━━━━━━━━━━━━━━━
```

**3a. Execute task** — Agent performs the coding work.

**3b. Verify** — Run verification commands from `skills/vibecode/references/verification.md`:

// turbo

```bash
cd Projects/[project-name]/repo
echo "=== VERIFY ITERATION [N] ==="
[BUILD_COMMAND] 2>&1 | tail -30
echo "EXIT CODE: $?"
```

**3c. Analyze:**

| Result | Action |
|:--|:--|
| ✅ All exit criteria pass | → **EXIT LOOP** → Step 5 (Final Report) |
| ❌ Errors found | → Log → Step 3c½ |

**3c½. Pattern Scan** (from iteration 2+):

Before fixing, Agent MUST group all errors and identify patterns:

```markdown
### Error Pattern Analysis (Iteration N)

| # | Pattern | Instances | Root file | Strategy |
|:--|:--|:--|:--|:--|
| P1 | [Error code/message pattern] | [N files] | [likely cause] | Batch fix / Individual |
| P2 | [Different pattern] | [N files] | [likely cause] | Batch fix / Individual |
| -- | Unique (no pattern) | [N] | — | Individual |
```

**Decision rules:**
- Pattern with ≥ 3 instances → **Batch fix** (fix root cause once, all instances resolve)
- Pattern with 2 instances → Agent judges: same root cause? → batch, else individual
- Unique errors → Individual fix as usual

> **Why:** Prevents the common anti-pattern of fixing error #1, verifying, fixing error #2, verifying... which wastes 1 iteration per error. Pattern-aware fixing can resolve 5 errors in 1 iteration.

**3d. Fix errors — Strategy Escalation:**

Agent MUST use a different strategy based on iteration depth:

| Iteration | Strategy | Behavior |
|:--|:--|:--|
| 1–2 | 🟢 **Direct Fix** | Fix specific lines/files from error output. Fast, local changes. Use batch fix for patterns found in 3c½. |
| 3 | 🟡 **Root Cause Analysis** | PAUSE. Agent MUST write a 1-sentence "Root cause hypothesis" based on error history from iter 1-2 BEFORE making any code change. Fix the hypothesis, not the symptoms. |
| 4 | 🔴 **Refactor Approach** | Agent is allowed to change design — move logic between files, split/merge modules, change interfaces. Only if iter 3 hypothesis points to architecture issue. |
| 5 | ⚫ **Escalate to User** | Agent presents: (a) what was tried, (b) what failed, (c) 2-3 alternative approaches for user to choose. No more autonomous fixing. |

> **Root Cause Hypothesis format (iteration 3):**
> ```
> 🔍 ROOT CAUSE HYPOTHESIS (iter 3):
> "[errors X, Y, Z] all stem from [hypothesis] because [evidence from iter 1-2]"
> → Fix target: [specific file/module/interface to change]
> ```

**3e. Guard checks — Convergence Signals:**

After EACH iteration (starting from iter 2), Agent evaluates:

| Signal | Trend | Meaning |
|:--|:--|:--|
| Error count | ↓ decreasing | ✅ Converging |
| Error count | → stagnant (same for 2 iters) | ⚠️ Strategy Escalation needed |
| Error count | ↑ increased | 🔴 ROLLBACK immediately |
| New error types appeared | Yes | ⚠️ Fix may have introduced side effects |
| Previously fixed error returned | Yes | 🔴 Regression — ROLLBACK |

**Stop conditions (ANY triggers):**
- `iteration == max` → STOP, report
- Same error repeated 3× → STOP, escalate to user (architecture issue)
- Error count INCREASED → ROLLBACK (`git stash pop`), STOP
- Regression detected (fixed error returned) → ROLLBACK, STOP
- 2 consecutive stagnant iterations → Force Strategy Escalation or STOP

→ Return to Step 3a.

#### 4. Rollback (if needed)

**If `--sandbox`:** Delete sandbox and re-create from scratch:

```bash
rm -rf Projects/_playground/vibecode-sandbox/
echo "🔙 Sandbox reset. Re-run setup from Step 2."
```

**If normal:** Restore from git stash:

```bash
cd Projects/[project-name]/repo
git stash pop
echo "🔙 Rolled back to pre-iteration state."
```

#### 5. Final Report

Load template from `skills/vibecode/references/loop-report.md`.

```markdown
## 🔄 VIBECODE LOOP REPORT

**Target:** [description]
**Iterations:** [N/MAX]
**Environment:** 🧪 Sandbox | 🔨 Real project
**Status:** ✅ Complete | ⚠️ Partial | ❌ Failed

### Iteration Log
| # | Strategy | Action | Errors | Fixed | Patterns |
|:--|:--|:--|:--|:--|:--|
| 1 | 🟢 Direct | Initial implementation | 0→3 | — | P1: type mismatch (×3) |
| 2 | 🟢 Direct | Batch-fix P1 (root: missing generic) | 3→1 | 2 | Unique: import path |
| 3 | 🟢 Direct | Fix import path | 1→0 | 1 | — |

### Exit Criteria
- [x] Build succeeds
- [x] No lint errors

### Files Modified (across all iterations)
[list with line counts]

### Lessons Learned
[Agent writes what patterns caused errors and how they were fixed]
```

**5b. Knowledge Extraction** (optional — suggest if ≥ 2 error patterns found):

IF the loop encountered ≥ 2 distinct error patterns across all iterations:

```
📚 KNOWLEDGE EXTRACTION
━━━━━━━━━━━━━━━━━━━━━━━━
Found [N] recurring error patterns during this loop.
Saving to .beads/seeds.md prevents repeating these in future sessions.

Patterns to save:
  1. [Pattern description] → [Fix approach]
  2. [Pattern description] → [Fix approach]

Save to .beads/seeds.md? (y/n)
```

IF user confirms:

```markdown
## Loop Patterns: [target] (YYYY-MM-DD)

| Pattern | Fix | Source |
|:--|:--|:--|
| [error pattern] | [fix approach] | vibecode loop iter N |
```

Append to `Projects/[project-name]/.beads/seeds.md` (create if not exists).

> **Cross-session benefit:** Next time `/vibecode loop` runs, Step 0 Pre-flight
> reads `seeds.md` → Agent starts with prior knowledge → fewer iterations needed.

**5c. Graph Memory Push** (CONDITIONAL — if graph exists):

IF project has `.beads/graph/` directory:
1. Push loop summary via MCP `memory_push`:
   - **kind:** `vibecode-loop`
   - **content:** Target + iterations + exit status + patterns found
   - **sessionId:** `YYYY-MM-DD-vibecode-[target]`
   - **metadata:** `{ "iterations": N, "status": "complete|partial|failed", "patterns": ["P1", ...] }`
2. Call `memory_curate(projectName)` to consolidate memory events.

// turbo

```bash
# Reset Dynamic Session KI Memory
bash .agents/skills/vibecode/scripts/session-manager.sh stop
```

**If `--sandbox` and status = ✅ Complete:**

```
🔄 Sandbox loop complete. Options:
  1. ✅ Apply to real project → Copy sandbox files to repo/
  2. 🔍 Review diff → Show sandbox vs source comparison
  3. 🔄 Re-run → Reset sandbox, try again
  4. ❌ Discard → Clean sandbox, do nothing
```

**Apply to real project** (option 1):

Agent copies each file from sandbox to its real location:

```bash
# For each file in sandbox:
cp Projects/_playground/vibecode-sandbox/path/to/file Projects/[project-name]/repo/path/to/file
```

Then cleanup sandbox:

// turbo

```bash
rm -rf Projects/_playground/vibecode-sandbox/
echo "🧹 Sandbox cleaned. Files applied to real project."
```

---

## ⚡ Mode: auto [plan-ref]

> **Purpose:** Fully automated plan execution. Agent reads plan phases sequentially, executes each task, verifies, and moves on.
> **Target:** Plan file path (e.g., `plans/v1.7.15-pr-review-workflow.md`).

### Steps

#### 1. Build Execution Queue

Load template from `skills/vibecode/references/auto-queue.md`.

Agent parses plan phases → builds sequential queue → presents to user.

User MUST confirm before auto-execution starts.

#### 2. Execute Sequentially

For each task in the queue:

**2a. Context reload** — At Phase boundaries, reload rules as mandated by plan `<!-- DO NOT MODIFY -->` blocks.

**2b. Execute task** — Agent performs the work.

**2c. Verify** — Run build/lint if applicable.

**2d. Update queue status:**

```
⚡ AUTO [N/Total] ━━━━━━━━━━━━━━━━━━━━━━━━
Phase [X]: ✅ Complete
Phase [Y]: 🔨 Task 2/4
```

**2e. Phase gate** — After completing all tasks in a phase:
- Run verification if plan defines it
- Ask user: "Phase N complete. Continue to Phase N+1?" (y/n)

#### 3. Error Handling

| Scenario | Action |
|:--|:--|
| Task fails | Retry once → if still fails, **auto-switch to loop mode** for that task |
| Build fails | Switch to loop mode automatically |
| Token budget low | PAUSE, save progress to `sprint-current.md`, resume next turn |
| Context truncation | STOP, save progress, user resumes with `/vibecode auto [ref] --resume PhaseN` |

#### 4. Completion Report

```markdown
## ⚡ VIBECODE AUTO REPORT

**Plan:** [title]
**Status:** ✅ Complete | ⏸ Paused at Phase N

### Execution Summary
| Phase | Tasks | Status | Notes |
|:--|:--|:--|:--|
| Phase 0 | 5/5 | ✅ | — |
| Phase 1 | 4/4 | ✅ | — |
| Phase 2 | 3/8 | ⏸ | Token budget |

### Files Modified [full list with line counts]

### Lessons Learned
[What went well, what needed loop-mode fallback, unexpected issues]
```

// turbo

```bash
# Reset Dynamic Session KI Memory
bash .agents/skills/vibecode/scripts/session-manager.sh stop
```

---

## ⚡ Mode: session [topic] [--tdd] [--qa] [--graph] [--hardened]

> **Purpose:** Dynamic session-based development. Code in milestones (sprint-lets), run checkpoints, auto-commit code, and proactively receive quality tool suggestions (/brainstorm, /qa, TDD, --graph, --hardened) as requirements evolve. Supports JIT Phase creation for free-form coding sessions.
> **Target:** Session topic/slug (e.g., `refactor-auth`). If omitted, creates a DSP Draft with no predefined goals.
> **Global flag:** `--sandbox` confines writes to sandbox and requires explicit copy on success.

### Command Variants

| Command | Behavior |
|:--|:--|
| `session [topic]` | Start DSP with topic → Phase 1 ready (existing behavior) |
| `session [topic] --tdd` | Start DSP with topic, force TDD mode on all phases |
| `session` (no args) | Start DSP Draft → phases added JIT as user requests goals |
| `session --graph` | Start DSP Draft with graph-aware phases |
| `session --hardened` | Start DSP Draft with auto-detect + forced TDD on sensitive code |

### Steps

#### 1. Session Initialization

**Load references & Project Context (MANDATORY):**
- Read `skills/vibecode/references/session-quality-gate.md` (Quality Gate template + sensitive keywords)
- Read `skills/plan/references/session-plan.md` (DSP templates)
- **Project Governance Load:** Agent MUST read the project contract (`Projects/[project-name]/project.md`), project indices (`.agents/rules.md` and `.agents/skills.md`), and the project-level developer guidelines (`.agents/AGENTS.md` or `agents.md` if they exist).
- **CRITICAL DETAIL READ:** Agent MUST use the `view_file` tool to read the full contents of all rules, skills, and developer guidelines (`.agents/AGENTS.md` or `agents.md`) relevant to the project *at this initialization moment* before generating the DSP file.

**Branch A — Topic-Based DSP** (`/vibecode session [topic]`):

1. **Auto-Create DSP File:** Agent creates a dynamic session plan using **Template A**:
   `Projects/[project-name]/artifacts/plans/v1.x.x-[YYYY-MM-DD]-session-[topic].md` (or exact version if known).
2. **Activate Immediately:** Save the file with `Status: 🔨 Active` (skipping the preliminary draft audit gate).
3. **Queue Initial Milestone:** Identify the first task/milestone to complete and add it as `Phase 1` in the DSP file.
4. → Proceed to **Step 2 (Quality Gate)** for Phase 1.

**Branch B — DSP Draft** (`/vibecode` or `/vibecode session`):

1. **Determine Sequence Number:**
   ```bash
   # Scan existing DSP Draft files for today
   ls artifacts/plans/v1.x.x-session-$(date +%Y-%m-%d)-*.md 2>/dev/null \
     | grep -oP '\d{2}(?=\.md$)' \
     | sort -n | tail -1
   # If empty → NN=01, else → NN = max + 1 (zero-padded)
   ```
2. **Auto-Create DSP Draft:** Create file using **Template B**:
   `Projects/[project-name]/artifacts/plans/v1.x.x-session-[YYYY-MM-DD]-[NN].md`
3. **Activate Immediately:** Save with `Status: 🔨 Active`, empty milestone queue.
4. **Wait for User:** Agent announces session is ready and waits for user to request a specific goal.
5. → Proceed to **Step 1b (Intent Detection)** to listen for goals.

#### 1b. Intent Detection (Branch B only — JIT Phase Creation)

When running in DSP Draft mode, Agent actively listens for action intent in user messages.

**Detection keywords** (loaded from `references/session-quality-gate.md`):
- Vietnamese: `thêm`, `sửa`, `fix`, `tạo`, `xóa`, `refactor`, `chỉnh`, `cập nhật`...
- English: `add`, `create`, `remove`, `fix`, `update`, `change`, `modify`, `refactor`...

**When action intent detected:**

```
🎯 DETECTED GOAL: "[extracted goal from user message]"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Create Phase [N] for this goal? (y/n/refine)
```

**Rules:**
- Agent MUST ask user confirmation before creating a Phase — NEVER auto-create silently.
- Agent MUST NOT interpret questions or discussions as action requests.
- If unsure whether user wants action or discussion → ASK, don't assume.
- User can say "refine" to adjust the goal description before creating the Phase.

**After user confirms:**
- **MANDATORY CONTEXT RELOAD:** Agent MUST reload project rules and skills indices immediately, identify rules/skills relevant to the new phase, and use the `view_file` tool to read their details and the project-level developer guidelines (`.agents/AGENTS.md` or `agents.md` if they exist) *at the exact moment the phase is created* (before presenting the Quality Gate or drafting phase tasks).
- Then proceed to **Step 2 (Quality Gate)**.

#### 2. Phase-Level Quality Gate (MANDATORY — ALL phases, ALL branches)

> ⛔ **CHECKPOINT:** Agent MUST present this gate at the START of EVERY Phase.
> This gate is NON-SKIPPABLE even for trivial tasks.

**2a. Context Reload (MANDATORY):** At the start of EVERY Phase, Agent MUST:
1. Read the **§ Phase Context Reload** table in `skills/vibecode/SKILL.md`
2. Execute the **Mandatory** reload list (project rules, skills, domain skill)
3. Execute the **Conditional** reload list based on tools activated in the Quality Gate

> **Why:** Long sessions cause context drift. Reloading at Phase boundaries ensures
> the Agent has fresh project rules, domain knowledge, and tool-specific guidance.
> The sidecar skill centralizes all routing — the workflow only says WHEN, the skill says WHAT.

**2b. Pre-analysis:** Before presenting the gate, Agent performs:
- Scan user's goal description against the **Sensitive Keywords Registry** (from `references/session-quality-gate.md`).
- If `--graph` is available: run `graph_impact_analysis` on target files to determine blast radius.
- **Pattern Verify (Step G, para-graph §4.2):** If analysis involves inline code patterns, run `grep_search` to cross-validate file counts against graph estimates.
- Estimate task complexity (🟢 Low / 🟡 Medium / 🔴 High).

**2c. Present Quality Gate:**

```
📋 PHASE [N] QUALITY GATE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Goal: [Phase goal description]

Proposed quality tools for this phase:

  Pre-code (run BEFORE coding):
  ⚗️ /brainstorm   → [✅ Recommended | ⚪ Optional] — [Reason]
  📋 /qa           → [✅ Recommended | ⚪ Optional] — [Reason]

  During dev (activate WHILE coding):
  🧪 TDD Mode      → [✅ Recommended | ⚪ Optional] — [Reason]
  🔍 --graph       → [✅ Recommended | ⚪ Optional] — [Reason]
  🔒 --hardened    → [✅ Recommended | ⚪ Optional] — [Reason]

💡 Recommended flow: brainstorm → QA stress-test → then code with TDD + --graph
Select tools to activate: (all / pick / none)
```

**2d. Auto-recommend logic** (from `references/session-quality-gate.md`):
- `/brainstorm` → YES if architecture unclear, multiple valid approaches, new patterns
- `/qa` → YES if complex business logic, security-critical, edge cases likely
- `TDD` → YES if logic-heavy, DB/API changes, business rules
- `--graph` → YES if blast radius ≥ 3 files, cross-module dependency
- `--hardened` → YES if sensitive keyword detected (password, auth, token, etc.)
- If `--hardened` → TDD is **automatically co-recommended** (defense-in-depth)

**2e. Execute pre-code tools** (if user selected):
1. **`/brainstorm` first** (if selected): Run focused 3-turn brainstorm → log decision in Phase's `⚗️ Brainstorm Log`
2. **`/qa` second** (if selected): Run stress-test review → issues found feed into implementation steps
3. Update the plan file to ensure all proposed file modifications are documented in `Proposed Changes` and all tasks are listed in the implementation checklist.

**2f. ⛔ PRE-CODE CHECKPOINT (MANDATORY):**
Before writing any code or making any file modifications for Phase N, Agent MUST:
1. Present the detailed `Proposed Changes` and the checklist of tasks for Phase N.
2. Suggest and confirm with the User to use the workflow `/plan [project-name] dev` to formally transition/continue the plan execution.
3. Specifically wait for the User's explicit confirmation and approval to begin coding.
4. **CRITICAL:** Do NOT run any code modification or file writing commands until the User explicitly confirms they want to proceed with coding (e.g. by approving this checkpoint or running `/plan [project-name] dev`). Writing code before this checkpoint is strictly prohibited.

**User has final say — Agent only recommends, never forces.**

#### 3. Milestone Execution Loop (Code by Milestone)

For each milestone (Phase N) in the session plan:

**3a. Boundary-Locked Code Work:**
- Agent locks scope: performs coding changes only within target files designated for the current milestone. Do NOT bleed changes into unrelated components.
- If TDD is active: Follow RED → GREEN → REFACTOR cycle (load `.agents/skills/tdd/SKILL.md`).
- If `--graph` is active: Use `graph_context_bundle` for upstream/downstream awareness.
- If `--hardened` is active: Apply Audit Gate mini-checklist (sanitization, auth checks, secret scan).

**3b. Checkpoint & Verification Gate:**
- Run verification tests/lints automatically.
- Present test results and Git diff to the User.
- ⛔ **CHECKPOINT (Interactive Pause):** Wait for User confirmation that the milestone is successful.

**3c. Commit & Track Gate:**
- Upon User confirmation, Agent automatically executes git commit:
  ```bash
  git commit -m "session([topic]): [phase goal]"
  ```
- Retrieve commit SHA and write it next to Phase N in the DSP plan file. Mark the Phase `[x] Complete`.
- Update the `Quality Tools` column with actually-used tools.

#### 4. Dynamic Append (Scope Evolution)

If the user wants to add new tasks or fix a bug discovered during the session:
1. Append the new requirement to the `⏳ Pending Queue` as `Phase N+1` in the DSP file.
2. Resume the execution loop from **Step 2 (Quality Gate)** for `Phase N+1`.
*Ensure a single phase contains no more than 3-4 tasks or 150 LOC to maintain tight commit feedback loops.*

#### 5. Session Teardown

// turbo

```bash
# Reset Dynamic Session KI Memory
bash .agents/skills/vibecode/scripts/session-manager.sh stop
```

⛔ **MANDATORY CHECKPOINT:**
Upon running `/end` or declaring the session finished, Agent MUST NOT perform teardown actions automatically.
1. Agent MUST present the completed session summary to the User.
2. Agent MUST suggest running the workflow `/plan [project-name] end` to formally audit, sync, and archive the plan.
3. Agent MUST wait for explicit User confirmation to close the vibecode session.
4. **PROHIBITED:** Syncing tasks to `done.md`, archiving the plan file (DSP), or clearing the active plan in `project.md` before the User explicitly approves ending the vibecode session (e.g. by confirming or running `/plan [project-name] end`) is strictly forbidden.

Once approved:
1. **Compress & Sync:** Extract all completed phases and append them to `artifacts/tasks/done.md` with the `#session` tag and the recorded Commit SHAs.
2. **Archive:** Move the DSP file to `artifacts/plans/done/`.
3. **Graph Update:** Rebuild code graph using `/para-graph build` and run `graph_enrich` to document the newly introduced code nodes.

---

## 📋 Mode: review [plan-ref] [--sandbox] [--max N]

> **Purpose:** Audit a plan for completeness, logic errors, security gaps, and token feasibility BEFORE execution.
> **Target:** Plan file path (e.g., `plans/v1.7.15-pr-review-workflow.md`).
> **Sandbox flag:** Add `--sandbox` to enable iterative review+fix. Agent creates a `review-` prefixed copy next to the original plan, fixes issues on the copy, loops until all checks pass, then outputs diff for user to apply or discard.
> **Max iterations:** Default 3. Override with `--max N`.

### Working Copy Convention

With `--sandbox`, Agent creates a review copy **in the same directory** as the original:

```text
artifacts/plans/
├── v1.7.15-pr-review-workflow.md           ← original (NEVER modified)
└── review-v1.7.15-pr-review-workflow.md    ← working copy (Agent edits here)
```

**Why same directory?** Agent stays in the same folder context — no path confusion, easy `diff`, and plan references (relative paths to brainstorms, backlog) remain valid.

### Review Modes

| Command | Behavior |
|:--|:--|
| `review plan.md` | One-shot audit — read-only report, no file changes |
| `review plan.md --sandbox` | Iterative review+fix in sandbox (max 3 default) |
| `review plan.md --sandbox --max 5` | Review+fix with custom max iterations |

### Steps

#### 1. Load Plan

// turbo

```bash
PROJECT="[project-name]"
PLAN="Projects/$PROJECT/artifacts/[plan-ref]"
echo "=== PLAN REVIEW ==="
test -f "$PLAN" && echo "✅ Plan found: $PLAN ($(wc -l < "$PLAN") lines)" || echo "❌ Plan not found!"
```

Agent reads the entire plan file.

**If `--sandbox`:**

// turbo

```bash
PLAN_DIR=$(dirname "$PLAN")
PLAN_NAME=$(basename "$PLAN")
REVIEW_COPY="$PLAN_DIR/review-$PLAN_NAME"
cp "$PLAN" "$REVIEW_COPY"
echo "🧪 Review copy created: $REVIEW_COPY"
echo "   Original will NOT be modified."
echo "   Agent works on review- copy from this point."
```

Agent works on the `review-` prefixed copy from this point forward. All edits target `review-[plan-name].md`, never the original.

#### 2. Structural Check

Agent validates the plan against these mandatory sections:

| # | Section | Required? | Check |
|:--|:--|:--|:--|
| 1 | References | ✅ | At least 1 reference to brainstorm/research |
| 2 | Architecture Overview | ✅ | Diagram or description present |
| 3 | Implementation Phases | ✅ | At least 1 phase with task table |
| 4 | File Inventory | ✅ | CREATE/MODIFY list with Phase assignment |
| 5 | Risks & Mitigations | ✅ | At least 1 risk identified |
| 6 | Checklist | ✅ | Pre-completion + Post-completion sections |
| 7 | Backlog Mapping | 🟡 | Should have FEAT-ID linked |
| 8 | Version Decision | 🟡 | PATCH/MINOR/MAJOR proposed |

#### 3. Logic Review

Agent checks for:

| # | Check | How |
|:--|:--|:--|
| L1 | **Phase dependency errors** | Does Phase N depend on Phase N-1 output? Are dependencies explicit? |
| L2 | **File Inventory completeness** | Every file mentioned in tasks MUST appear in File Inventory |
| L3 | **Circular references** | No task references itself or creates self-modifying loops |
| L4 | **Missing preconditions** | Each phase describes what must exist before it starts |
| L5 | **Backlog sync** | FEAT-ID in plan matches backlog entry |

#### 4. Security Review

Agent checks for:

| # | Check | How |
|:--|:--|:--|
| S1 | **Input sanitization** | Any user input (branch names, file paths) is sanitized before shell use |
| S2 | **Secret exposure** | No API keys, passwords, or `.env` patterns in plan content |
| S3 | **Absolute paths** | No hardcoded absolute paths (`/media/`, `/home/`, `/Users/`) |
| S4 | **Governance file access** | If plan touches `rules/`, `kernel/` → escalation noted |
| S5 | **Self-referencing** | Plan doesn't modify its own review/execution tooling |
| S6 | **VCS safety** | Plan specifies `SafeToAutoRun: false` for git operations |

#### 5. Token Budget Estimation

Agent calculates:

```markdown
### Token Budget Estimate

| Phase | Tasks | Files (create) | Files (modify) | Est. total lines | Fit in 1 turn? |
|:--|:--|:--|:--|:--|:--|
| Phase 0 | N | X | Y | ~Z lines | ✅/❌ |
| Phase 1 | N | X | Y | ~Z lines | ✅/❌ |
| ...     | ... | ... | ... | ... | ... |
| **Total** | **N** | **X** | **Y** | **~Z lines** | **N turns needed** |

**Overhead per turn:** ~8-12K tokens (system prompt + rules + KI)
**Rule of thumb:** 1 turn ≈ 500 lines of productive file I/O
```

#### 6. Governance Compliance

Agent loads `maintenance.md` JIT and checks:

| # | Rule | Status |
|:--|:--|:--|
| G1 | New Workflow → catalog.yml entry? | ✅/❌ |
| G2 | New Workflow → VERSIONS.yml entry? | ✅/❌ |
| G3 | New Workflow → docs reference? | ✅/❌ |
| G4 | Dogfooding → edits in `repo/` first? | ✅/❌ |
| G5 | English-first in `repo/` files? | ✅/❌ |
| G6 | Pre-flight blocks in phase headers? | ✅/❌ |

#### 7. Review Report (Output)

Load template from `skills/vibecode/references/review-report.md`.

```markdown
## 📋 VIBECODE REVIEW REPORT

**Plan:** [title]
**File:** [path]
**Reviewed:** [timestamp]

### Summary
| Category | Score | Issues |
|:--|:--|:--|
| Structure | ✅ 8/8 | — |
| Logic | 🟡 4/5 | L3: [detail] |
| Security | ✅ 6/6 | — |
| Token Budget | 🟡 | ~3 turns needed |
| Governance | ✅ 6/6 | — |
| **Overall** | **🟡 Proceed with caution** | 1 issue to fix |

### Issues Found
| # | Category | Severity | Detail | Fix suggestion |
|:--|:--|:--|:--|:--|
| 1 | Logic | 🟡 | [description] | [how to fix] |

### Recommendations
- [Actionable recommendation 1]
- [Actionable recommendation 2]

### Next Steps
Choose:
  1. ✅ Fix issues → re-review (`/vibecode review [ref]`)
  2. 🔄 Sandbox review+fix → `/vibecode review [ref] --sandbox`
  3. 🔄 Sandbox loop → `/vibecode loop [Phase 0] --sandbox`
  4. ⚡ Auto execution → `/vibecode auto [ref]`
  5. ❌ Reject plan → needs redesign
```

#### 7b. Auto-fix Loop (only with `--sandbox`)

If `--sandbox` flag is set AND issues were found:

**Issue Classification:**

| Severity | Action | Examples |
|:--|:--|:--|
| 🟢 Auto-fixable | Agent fixes silently in sandbox copy | Missing FEAT-ID in backlog mapping, missing `SafeToAutoRun: false`, File Inventory incomplete, typo in section names, Version Decision blank |
| 🟡 Need confirmation | Agent proposes fix, shows diff, asks user | Logic dependency errors, token budget split, security gap mitigation, missing precondition tasks |
| 🔴 Cannot auto-fix | Agent flags, user must redesign | Circular reference, scope creep, missing prerequisite plan |

**Loop flow:**

```
🔄 REVIEW FIX ITERATION [N/3]
━━━━━━━━━━━━━━━━━━━━━━━━━
```

1. **Auto-fix** all 🟢 issues in `review-` copy (log changes)
2. **Propose** fixes for 🟡 issues → show diff → ask user per issue
3. **Block** on 🔴 issues → report to user, cannot proceed
4. **Re-review** `review-` copy (Steps 2-6 again)
5. If still issues → repeat (max N iterations, default 3)
6. If all checks 🟢 OR only 🔴 remain → EXIT

**Exit criteria:** All review categories = ✅, or only 🔴 issues remain (user must handle), or max iterations reached.

#### 7c. Sandbox Review Report + Diff

After loop completes (only with `--sandbox`):

```markdown
## 📋 VIBECODE REVIEW+FIX REPORT

**Plan:** [title]
**Original:** `artifacts/plans/[plan-file]`
**Review copy:** `artifacts/plans/review-[plan-file]`
**Iterations:** [N/MAX]

### Fix Summary
| # | Issue | Severity | Action | Status |
|:--|:--|:--|:--|:--|
| 1 | Missing FEAT-ID | 🟢 | Auto-fixed | ✅ |
| 2 | Logic dep error | 🟡 | User confirmed fix | ✅ |
| 3 | Architecture issue | 🔴 | Cannot auto-fix | ⚠️ User must handle |

### Diff (Original → Fixed Plan)
[Agent shows diff between original and sandbox copy]

### Final Review Score
| Category | Before | After |
|:--|:--|:--|
| Structure | 🟡 6/8 | ✅ 8/8 |
| Logic | 🟡 3/5 | ✅ 5/5 |
| Security | ✅ 6/6 | ✅ 6/6 |
```

**User Decision:**

```
📋 Review+Fix complete. Options:
  1. ✅ Apply fixed plan → Overwrite original with review copy
  2. 🔍 View full diff → See line-by-line changes (original vs review-)
  3. 🔄 Re-run → Delete review copy, start over
  4. ❌ Discard → Keep original, delete review copy
```

**Apply** (option 1):

```bash
PLAN_DIR="Projects/[project]/artifacts/plans"
cp "$PLAN_DIR/review-[plan-file]" "$PLAN_DIR/[plan-file]"
rm "$PLAN_DIR/review-[plan-file]"
echo "✅ Fixed plan applied. Review copy cleaned."
```

**Diff** (option 2):

// turbo

```bash
PLAN_DIR="Projects/[project]/artifacts/plans"
diff "$PLAN_DIR/[plan-file]" "$PLAN_DIR/review-[plan-file]" || true
```

**Discard** (option 4):

// turbo

```bash
rm "Projects/[project]/artifacts/plans/review-[plan-file]"
echo "🧹 Review copy deleted. Original unchanged."
```

---

## 💡 Mode Comparison

| Aspect | review | review --sandbox | loop --sandbox | loop | auto | auto --sandbox | session | session --sandbox |
|:--|:--|:--|:--|:--|:--|:--|:--|:--|
| **Target** | Plan file | Plan file | Source code | Source code | Plan phases | Plan phases | Source code & DSP | Source code & DSP |
| **File writes** | None | Sandbox (plan) | Sandbox (code) | Real project | Real project | Sandbox | Real project | Sandbox |
| **Iterations** | 1 | Max 3 | Max 5 | Max 5 | 1/task | 1/task | 1/milestone | 1/milestone |
| **Quality Gate** | N/A | N/A | N/A | N/A | N/A | N/A | ✅ Every Phase (TDD/graph/QA/brainstorm/hardened) | ✅ Every Phase |
| **Context Reload** | N/A | N/A | N/A | N/A | Phase boundary | Phase boundary | ✅ Every Phase (via sidecar) | ✅ Every Phase (via sidecar) |
| **Auto-fix** | No | 🟢 auto, 🟡 ask, 🔴 block | Build/lint | Build/lint | Build/lint | Build/lint | Build/lint | Build/lint |
| **Adaptive Loop** | N/A | N/A | ✅ Pattern Scan | ✅ Pattern Scan | Fallback to loop | Fallback to loop | ✅ Pattern Scan | ✅ Pattern Scan |
| **Knowledge** | N/A | N/A | ✅ seeds.md | ✅ seeds.md | N/A | N/A | ✅ done.md & Graph | ✅ done.md & Graph |
| **Rollback** | N/A | Delete sandbox | Delete sandbox | git stash | Phase stash | Delete sandbox | git checkout/stash | Delete sandbox |
| **After success** | Recommend mode | Apply fixed plan or discard | Apply code or discard | Done | Done | Apply or discard | Auto-commit & SHA | Apply & Auto-commit |
| **Safety** | 🟢 Highest | 🟢 High | 🟢 High | 🟡 Medium | 🟡 Medium | 🟢 High | 🟡 Medium | 🟢 High |

> **Tip:** `loop --sandbox --max 1` = quick one-shot preview (equivalent to old "test" mode)

## Security Notes

- **review mode (no sandbox)**: Pure read-only analysis. No file writes, no commands beyond `test -f` and `cat`.
- **review --sandbox**: Plan copied to sandbox. Auto-fix 🟢 issues silently, propose 🟡 fixes with user confirm, block on 🔴. Max 3 review iterations. Original plan untouched until user applies.
- **--sandbox flag (loop/auto)**: All code writes confined to `_playground/vibecode-sandbox/`. Agent MUST substitute paths. Bash scripts MUST pass `bash -n`.
- **loop mode (no sandbox)**: Agent MUST `git stash` before each iteration. Max iterations prevents infinite loops.
- **auto mode**: User confirmation required before start AND between phases. Auto-fallback to loop on failures.
- **All modes**: `SafeToAutoRun: false` for destructive commands. `// turbo` only for read-only.

## Related

- `/plan` — Create implementation plans (input for `auto` and `review` modes)
- `/pr-review` — Review contributor PRs
- `/push` — Commit and push after successful execution
- `/verify` — Verify task completion using walkthroughs
