# Project Profile Template

> **Version:** 1.1.0 | **Last reviewed:** 2026-04-07
> Template used by `/para-skill add --template project` to generate a project-specific `SKILL.md`.
> Agent uses this template as a framework — scan context, generate draft, let user review.

---

## Usage

When user runs `/para-skill add [skill-name] --template project`:
1. Agent reads this template
2. Auto-scans project context (project.md, rules, docs/, etc.)
3. Fills the template sections based on scanned data
4. Presents complete SKILL.md draft for user to approve/edit

**Naming rule:** The skill name MUST equal the project name (from `project.md`).
Example: project `my-app` → skill name `my-app`, folder `.agents/skills/my-app/`.

---

## Template Output

```markdown
---
name: [project-name]
description: >
  Core DNA and Sub-Skills Router for the [project-name] project.
  This is the Single Source of Truth — agent MUST read this skill FIRST for ANY task
  involving this project. Even if the user doesn't explicitly mention "conventions"
  or "standards", consult this skill for every project-level decision.
version: "1.0.0"
---

# Project Profile: [project-name]

> **Project Type:** See `project.md`
> **Trigger:** Any task within this project — content authoring, plan creation, builds, rule changes.

This skill defines the **DNA** of this project — conventions that influence workspace-level workflows without modifying them.

## §1. Project Identity

> **Volatile fields** (version, status, deadline, upstream, type, primary language)
> already live in `project.md`. Agent MUST read `project.md` for those — do NOT
> duplicate them here. This section only captures **stable conventions** that
> rarely change and are not covered by `project.md`.

| Field            | Value                                          |
|:-----------------|:-----------------------------------------------|
| Framework        | [framework or "N/A"]                           |
| Doc Tone         | `[formal-technical | conversational | tutorial-friendly]` |
| Doc Language     | [ISO 639-1 code] — per `preferences.language` in `.para-workspace.yml` |
| Build System     | [command or "None"]                            |

## §2. Sub-Skills Router (Progressive Disclosure)

> **AGENT INSTRUCTION:** MANDATORY CHECK. You MUST scan this routing table.
> If your current task matches any condition below, you MUST use the `view_file`
> tool to read ALL corresponding files BEFORE creating plans or writing code.
> Do NOT bypass this step or assume the process from memory.
>
> **Fallback:** If no condition matches, proceed with §3–§7 of this skill
> as normal. The router only adds depth — it never blocks.

| If task involves...                     | MUST read FIRST                                    |
|:----------------------------------------|:---------------------------------------------------|
| [Condition matching project rules]      | `.agents/rules/[rule-file].md`                     |
| [Condition matching sub-skills]         | `.agents/skills/[sub-skill]/SKILL.md`              |

> Agent: auto-populate this table by scanning `.agents/rules/` and
> `.agents/skills/` during Phase A (context scan). Each rule/skill
> with a clear trigger condition gets a row here.

## §3. Naming Conventions

### Plan Files
Pattern: `[describe your plan naming pattern]`

### Branches
Pattern: `[feat/topic | fix/topic | direct-to-main]`

### Commits
Pattern: `[describe your commit message format]`

## §4. Maintenance Patterns

### VCS Guardrails 🛡️

> **Trigger:** Before any raw `git commit` or `git push` command outside of `/push` or `/release` workflows.
- MUST explicitly re-read `.agents/rules/vcs.md` to ensure golden rule compliance, prevent secrets pushing, and enforce branch standards.

> Add additional project-specific checklists here that don't belong in global rules.
> Reference existing rules instead of duplicating content.

## §5. Quality Standards

### Build & Test
\```bash
# Build
[build command or "N/A"]

# Test
[test command or "N/A"]
\```

### Verification after changes
\```bash
# Add project-specific verification commands
\```

## §6. Documentation Flow

> Describe the documentation flow for this project.
> Example: internal docs (VI) → public docs (EN) → website

## §7. Plan Review Checklist

> **Trigger:** AFTER any `/plan create` or `/plan update` — agent MUST run this checklist before presenting plan to user.
> **Purpose:** Catch logic errors, security gaps, missing scope, and token bloat BEFORE execution.
> **Defense:** If running `/plan create`, re-read this §7 AFTER writing plan to counter token decay.

### A. Logic & Dependency Check
- [ ] **Phase ordering:** Are phases in correct dependency order?
- [ ] **Circular references:** No phase depends on a later phase's output
- [ ] **Missing cleanup:** If creating files, is there a verify/cleanup phase?

### B. Security & Safety Check
- [ ] **Secrets check:** No `.env`, credentials, or tokens in plan scope
- [ ] [Add project-specific security checks]

### C. Completeness Scan
- [ ] **Impact count verified:** Does stated number match actual scan?
- [ ] [Add project-specific completeness checks]

### D. Token Efficiency Check
- [ ] **Plan size:** < 200 lines for release plan, < 300 for complex multi-feature
- [ ] **No duplicate info:** Architecture overview doesn't repeat task details
- [ ] **References over repetition:** Large sections link to separate files

### E. Revision History
- [ ] Plan has `📝 Revision History` section
- [ ] `Risks & Lessons Applied` section present

## 🧪 Test Mode (Sandbox Override)

> **Trigger:** User includes "Test Mode" or explicitly asks to evaluate/test this skill.

When in Test Mode, STRICTLY follow these overrides:

1. **No Live Edits:** Do NOT modify files outside the sandbox directory.
2. **Containment:** Route ALL outputs into `[PROJECT_ROOT]/sandbox/evals/[skill-name]-[YYYY-MM-DD]/`.
   *(Where `[PROJECT_ROOT]` is the project containing this skill)*
3. **Execute Task:** Carry out the user's prompt as if this skill were active in production.
4. **Generate Report:** After completing the task, create `test-report.md` in the sandbox folder:

   \```markdown
   # Test Report: [skill-name]
   > Date: YYYY-MM-DD | Prompt: "[user's prompt]"
   
   ## Actions Taken
   - [List each action performed]
   
   ## Skill Rules Invoked
   - [Which sections of the skill were applied, e.g., "§2 Sub-Skills Router"]
   
   ## Files Created
   - [List files created in sandbox/]
   
   ## Self-Assessment
   - [Did the skill provide useful guidance? What was ambiguous?]
   \```

---

## Examples

### ✅ Correct: Agent follows Router before task

User asks: _"[Example task relevant to project]"_

Agent behavior:
1. Reads this skill (triggered by skills.md index)
2. Scans §2 Router → matches relevant condition
3. Reads the corresponding rule/sub-skill file
4. Executes task with full context from both skill and rule
5. Runs §7 Plan Review Checklist (if creating/reviewing a plan)

### ❌ Incorrect: Agent skips Router

User asks: _"[Same example task]"_

Agent behavior:
1. Reads this skill
2. **Skips §2 Router** — assumes it already knows the process
3. Misses project-specific constraints from rules
4. Produces output that violates project conventions

---

## Test Prompts

> For use with `/para-skill test [project-name]` (Quick Eval mode).

| # | Prompt | Expected behavior | Type |
|:--|:-------|:------------------|:-----|
| 1 | "[Task that triggers Router]" | Agent reads §2 Router → loads correct rule → applies §7 Checklist | `subjective` |
| 2 | "[Task that tests naming conventions]" | Agent applies §3 Naming Conventions correctly | `objective` |
| 3 | "[Task that tests build/verification]" | Agent runs §5 Quality Standards commands | `objective` |
```

---

## Co-Author Guide (Draft-First Approach)

> **Principle:** Agent scans context, proposes draft, user reviews. Do NOT ask individual questions one by one.

### Phase A: Auto-scan (agent does this silently)

Agent reads the following to gather information:
- `project.md` — type, language, tags, goal
- `.agents/rules/*.md` — project constraints (for §2 Router population)
- `.agents/skills/` — existing sub-skills (for §2 Router population)
- `docs/` structure — documentation flow
- `.para-workspace.yml` — preferences.language

### Phase B: Fill template

Agent fills §1-§7 based on scanned context:
- §1: Fill from collected data (stable fields only, NOT volatile)
- §2: Auto-populate Router table from `.agents/rules/` + `.agents/skills/` scan
- §3-§6: Fill from project patterns and existing conventions
- §7: Extract checklist items from project rules + add standard checks
- Examples: Generate from Router conditions
- Test Prompts: Generate from §2-§5 trigger scenarios
- Mark unknown fields with `[TBD]` for user to complete

### Phase C: Present draft

Show complete SKILL.md draft to user. Options:
- **approve** — Create files
- **edit** — User specifies changes
- **regenerate** — Rescan and retry

### Fallback: Minimal Interview

Only when project has NO `project.md` or context is extremely limited,
ask 3-5 core questions:
1. "What type of project is this and what language does it use?"
2. "Are there any special naming conventions?"
3. "What mistakes commonly occur when planning for this project?"
