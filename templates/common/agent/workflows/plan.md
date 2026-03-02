---
description: Create an implementation plan for a project with architecture, phases, and timeline
source: catalog
---

# /plan [project-name] [action]

> **Workspace Version:** 1.4.1 (Governed Libraries)
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

## ✅ Definition of Done

[Copied from project.md for quick reference]
```

#### 10. Register plan in project.md

// turbo

Set the `active_plan` field in `Projects/[project-name]/project.md` frontmatter:

```yaml
active_plan: "plans/[plan-name].md"
```

> This enables `/open` and `/end` to locate the plan without scanning directories — saving tokens.
> Path is relative to `artifacts/`. Remove this field when the plan is completed or archived.

#### 11. Log in Session

// turbo

Append to the current session log at `Projects/[project-name]/sessions/YYYY-MM-DD.md`:

```markdown
### Plan Created

- **Plan**: `artifacts/plans/[plan-name].md`
- **Phases**: [N] phases defined
- **Timeline**: [N] days estimated
- **Code Reuse**: [% or list from reference projects]
```

---

## 📋 Action: review

Summarize an existing plan with status updates.

### Steps

// turbo

1. Read `active_plan` field from `Projects/[project-name]/project.md` to locate the plan file.
2. Display summary:

```
📋 PLAN REVIEW: [plan-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
| Phase   | Status        | Tasks  |
| ------- | ------------- | ------ |
| Phase 0 | ✅ Done       | 5/5    |
| Phase 1 | 🔨 In Progress| 3/5    |
| Phase 2 | ⏳ Pending    | 0/4    |
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Overall: 40% complete | Deadline: YYYY-MM-DD
```

3. Cross-reference with backlog to find items completed but not marked.

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

| Path                      | Purpose                                               |
| :------------------------ | :---------------------------------------------------- |
| `artifacts/plans/`        | Implementation plans, migration plans, redesign plans |
| `artifacts/tasks/`        | Backlog and task tracking                             |
| `artifacts/walkthroughs/` | Verification checklists                               |

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
- [ ] Session log updated

## Related

- `/new-project` — Initialize project (run before `/plan`)
- `/backlog` — Manage features and bugs
- `/open` — Start session with context loading
- `/verify` — Verify task completion against plan
- `/release` — Pre-release quality gate
