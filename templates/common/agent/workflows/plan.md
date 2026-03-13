---
description: Create an implementation plan for a project with architecture, phases, and timeline
source: catalog
---

# /plan [project-name] [action]

> **Workspace Version:** 1.5.0 (Governed Libraries)
> **Constraint:** Read `.para-workspace.yml` at the workspace root to get the user's preferred language from `preferences.language` (e.g., `vi` for Vietnamese). **All output and the final plan document MUST be translated to this language.**

Create, review, or update a phased implementation plan for a PARA project.

## Actions

| Action   | Description                                           |
| :------- | :---------------------------------------------------- |
| `create` | Create a new implementation plan (default if omitted) |
| `review` | Review and summarize an existing plan                 |
| `update` | Update phases or status in an existing plan           |

---

## 📝 Action: create

Generate a comprehensive implementation plan based on the project contract, backlog, and optional reference projects.

### Steps

#### 1. Read Project Contract

// turbo

Read `Projects/[project-name]/project.md` to extract:

- **Goal** (from YAML frontmatter `goal`)
- **Deadline** (from `deadline`)
- **Definition of Done** (from `dod` list)
- **Dependencies** (from body section)
- **Key Decisions** (from body section)

#### 2. Read Backlog

// turbo

Read `Projects/[project-name]/artifacts/tasks/backlog.md` to understand:

- Feature scope (High / Medium / Low priority items)
- Known bugs or constraints
- Total item count and status distribution

#### 2.5. Check for Brainstorm Context (if exists)

// turbo

> ⚠️ **Token optimization:** One `ls` command + read at most 1 file.

```bash
ls -t Projects/[project-name]/artifacts/para-decisions/brainstorm-*.md 2>/dev/null | head -1
```

- **If brainstorm file found** → Read the most recent one. Use its Options Evaluated and Decision sections as baseline context for architecture and phase design.
- **If none found** → Skip. Zero overhead.

#### 2.6. Scan Learnings Index (Lessons Learned)

// turbo

> 🛡️ **Token Optimization:** Only read the index file (`Areas/Learning/README.md`, ~30 lines). Do NOT read all learning files.

1. Read `Areas/Learning/README.md` to get the list of available lessons.
2. Cross-reference lesson titles with the project's **tech stack** (from `project.md`) and **scope** of the features being planned.
3. **If matches found** (e.g., project uses Bash CLI → lessons on `cross-platform-bash`, `bash-cli-gotchas` are relevant):
   - Read only the matched learning files (max 3 files to limit tokens).
   - Extract **Key Learnings** and **Checklists** from each.
   - Store these as constraints for the Risk section in Step 9.
4. **If no matches** → Skip. No overhead.

> **Convention:** This step bridges `/learn` (captures lessons) with `/plan` (applies them). The goal is to prevent repeating past mistakes, not to read the entire knowledge base.

**Optional: Scan project docs index**

If `Projects/[project-name]/docs/README.md` exists, read it (~30-80 lines) to discover existing architecture docs, workflow docs, or design decisions. This prevents re-designing what's already documented. Skip if file doesn't exist.

#### 3. Analyze Reference Projects (Optional)

If the project contract references another project (in Dependencies or Key Decisions), analyze its codebase:

1. Read the reference project's `project.md` and source code.
2. Identify **reusable code** (services, utilities, patterns).
3. Document what can be **ported directly** vs. what needs **modification**.

> **Convention:** Only analyze references explicitly mentioned in the project contract. Do NOT auto-discover unrelated projects.

#### 4. Design Data Schema

If the project involves data storage (database, JSON files, APIs), define:

- **Schema structure** with field types and descriptions
- **Example data** (valid JSON/YAML sample)
- **Relationships** between entities

> Use code blocks with `jsonc` language tag for schemas with comments.

#### 5. Design Architecture

Create an architecture overview:

- **Component diagram** (ASCII art — do NOT use Mermaid or external tools)
- **Technology stack table** (Component | Technology | Deploy Target)
- **Data flow** between components

> 🛡️ **Progressive Disclosure:** You may selectively read specific files in `Resources/ai-agents/kernel/` (e.g., `invariants.md`, `heuristics.md`) if you need strict architectural guidance for this step. Do NOT scan the entire kernel directory at once.

#### 6. Define Phases

Break the project into sequential phases. Each phase should:

- Have a clear **goal** (one sentence)
- Include a **task table** with numbered items
- Estimate **time** (in days or hours)
- List **output/deliverables**

**Phase structure rules:**

| Rule        | Description                                                   |
| :---------- | :------------------------------------------------------------ |
| Phase 0     | Always "Setup & Infrastructure" — scaffold, init dependencies |
| Phase N     | Core feature phases — build in dependency order               |
| Final Phase | Always "Polish & Extras" — error handling, README, CI/CD      |

> **Guideline:** Aim for 4-7 phases total. Each phase should be completable in 1-2 days.

#### 7. Map Code Reuse

If reference projects were analyzed (Step 3), create a **Code Reuse Table**:

```markdown
## 📦 Code Reuse from [reference-project]

| Source File        | Function/Module  | Action        | Notes                     |
| :----------------- | :--------------- | :------------ | :------------------------ |
| `path/to/file.ts`  | `functionName()` | Port directly | Proven, no changes needed |
| `path/to/other.ts` | `ClassName`      | Modify        | Remove KV dependency      |
```

#### 8. Cross-reference Backlog

Map each High/Medium priority backlog item to the phase where it will be implemented:

```markdown
## 🔗 Backlog → Phase Mapping

| Backlog Item          | Priority | Phase   |
| :-------------------- | :------- | :------ |
| GitHub Storage Engine | High     | Phase 1 |
| Admin Dashboard       | High     | Phase 3 |
```

#### 8.5. Rule Impact Check

// turbo

> ⚠️ **Auto-detect:** If any plan task modifies files in `rules/` or `kernel/`, add sync tasks automatically.

1. Scan all phase tasks — check if any target file matches:
   - `templates/common/agent/rules/*.md`
   - `kernel/invariants.md`, `kernel/heuristics.md`, `kernel/schema/*.md`
   - `rfcs/*.md` that reference rules

2. **If rule changes detected:**
   a. Auto-add to final phase: "Sync workspace `.agent/rules/` from repo templates"
   b. Check if project has `.agent/rules.md` (rules index) — if yes, add task:
   "Update `.agent/rules.md` trigger conditions to match new rule constraints"
   c. Display warning:

   ```
   ⚠️  This plan modifies governance rules.
       Final phase will include:
       - Workspace rule sync (.agent/rules/)
       - Rules index update (if .agent/rules.md exists)
   ```

3. **If no rule changes** → Skip silently.

> **Why:** Rule changes in repo templates must be synced to workspace. Missing this step causes agent behavior drift.

#### 9. Write Plan File

// turbo

Save the plan to:

```
Projects/[project-name]/artifacts/plans/[plan-name].md
```

**Naming convention:** Use descriptive names (e.g., `implementation-plan.md`, `migration-plan.md`, `v2-redesign-plan.md`).

**Plan document structure:**

```markdown
# [Plan Title]: [project-name]

> **Version:** 1.0 | **Created:** YYYY-MM-DD
> **Baseline:** [Reference project or context, if any]

---

## 📐 Architecture Overview

[Component diagram + Tech stack table]

## 📊 Data Schema

[Schema definition with examples]

## 🗓 Implementation Phases

### Phase 0: Setup & Infrastructure

[Tasks, timeline, output]

### Phase 1: [Core Feature]

[Tasks, timeline, output]

...

### Phase N: Polish & Extras

[Tasks, timeline, output]

## 📦 Code Reuse (if applicable)

[Reuse table from reference projects]

## 🔗 Backlog → Phase Mapping

[Cross-reference table]

## ⚠️ Risks & Lessons Applied

[Risk table with mitigations]

> If Step 2.5 found relevant lessons, list them here:
>
> - **Source:** `Areas/Learning/[lesson-name].md`
> - **Constraint applied:** [What checklist or pattern was incorporated into this plan]

## ✅ Definition of Done

[Copied from project.md for quick reference]
```

#### 10. Ask to Activate Plan

Present the plan summary and ask the user:

```
📐 PLAN READY: [plan-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Phases: [N] | Timeline: [N] days | Tasks: [N]
File:   artifacts/plans/[plan-name].md

❓ Activate this plan now?
   Y → Set as active_plan + run /backlog sync (recommended)
   N → Save only — activate later with /plan update
```

**If user confirms (Y):**

// turbo

1. Set `active_plan` in `project.md` frontmatter:

```yaml
active_plan: "plans/[plan-name].md"
```

2. Immediately suggest `/backlog sync`:

```
⚠️  Plan activated. Run `/backlog sync` to map plan phases to backlog items.
    This enables `/plan review` and `/retro` to track progress by Phase.
```

> **Why:** Without `/backlog sync`, `/plan review` cannot measure progress by Phase. This step is MANDATORY per RFC-0002 C4.

**If user declines (N):**

Skip activation. Plan is saved but not active. User can activate later via `/plan update`.

> Path is relative to `artifacts/`. Remove `active_plan` field when the plan is completed or archived.

#### 11. Log in Session

// turbo

Append to the current session log at `Projects/[project-name]/sessions/YYYY-MM-DD.md`:

```markdown
### Plan Created

- **Plan**: `artifacts/plans/[plan-name].md`
- **Phases**: [N] phases defined
- **Timeline**: [N] days estimated
- **Activated**: Yes/No
- **Next**: Run `/backlog sync` to map phases (if activated)
```

---

## 📋 Action: review

Summarize an existing plan with status updates, using `done.md` for accurate progress tracking.

### Steps

// turbo

1. Read `active_plan` field from `Projects/[project-name]/project.md` to locate the plan file.
2. Read `Projects/[project-name]/artifacts/tasks/done.md` to get the list of completed task IDs with dates.
3. Cross-reference `done.md` completed IDs with the plan's **Backlog → Phase Mapping** table.
4. Display summary:

```
📋 PLAN REVIEW: [plan-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
| Phase   | Status         | Tasks  | Source    |
| ------- | -------------- | ------ | --------- |
| Phase 0 | ✅ Done        | 5/5    | done.md   |
| Phase 1 | 🔨 In Progress | 3/5    | backlog   |
| Phase 2 | ⏳ Pending     | 0/4    | —         |
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Overall: 40% complete | Deadline: YYYY-MM-DD
```

5. If a phase reaches 100% → suggest running `/retro` for phase review.
6. If ALL phases reach 100% → generate review + archive the plan:
   a. Move plan file to `artifacts/plans/done/[plan-name].md`
   b. **Create completion review** at `artifacts/plans/done/[plan-name]-review.md`:
   - Task-by-task completion status (verified against `done.md`)
   - Phase summary with dates
   - Items deferred or skipped (with reason)
   - Bonus work done outside plan scope
     c. Remove `active_plan` field from `project.md`
     d. Suggest running `/retro` for full project retrospective
     e. Log: `Plan [plan-name] archived to plans/done/ (with review)`

> **Why review in `done/`?** Keeps plan + evidence together. `/retro` only needs to read one directory. Review lives in the project (not conversation brain) so it persists across sessions.

> **Why archive?** Completed plans in `artifacts/plans/` waste tokens when agents scan the directory. Moving to `done/` keeps the active plans directory lean.

---

## ✏️ Action: update

Modify an existing plan (add phases, update status, revise timeline).

### Steps

1. Read `active_plan` from `project.md` to locate the plan file.
2. Ask user what to update:
   - Add/remove/reorder phases
   - Update task status within a phase
   - Revise timeline estimates
   - Add new code reuse discoveries
3. Apply changes and increment the plan version (e.g., `1.0` → `1.1`).
4. Log the update in the current session.

---

## 📁 Artifacts Convention

| Path                      | Purpose                                                      |
| :------------------------ | :----------------------------------------------------------- |
| `artifacts/plans/`        | Active plans + `done/` (archived plans + completion reviews) |
| `artifacts/tasks/`        | Backlog and task tracking                                    |
| `artifacts/walkthroughs/` | Task verification checklists (from `/verify`)                |

> Plans are **living documents** — update them as the project evolves. Use the `update` action to keep them in sync with actual progress.

## Output Checklist

- [ ] Project contract analyzed
- [ ] Backlog items mapped to phases
- [ ] Architecture designed with component diagram
- [ ] Data schema defined (if applicable)
- [ ] Phases defined (4-7 phases recommended)
- [ ] Code reuse documented (if reference projects exist)
- [ ] Plan saved to `artifacts/plans/`
- [ ] `active_plan` field set in `project.md`
- [ ] `/backlog sync` suggested (or auto-triggered)
- [ ] Session log updated

## Related

- `/brainstorm` — Explore ideas before planning (auto-discovered by Step 2.5)
- `/new-project` — Initialize project (run before `/plan`)
- `/backlog` — Manage features and bugs
- `/open` — Start session with context loading
- `/verify` — Verify task completion against plan
- `/release` — Pre-release quality gate
