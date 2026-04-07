# Project Profile Template

> **Version:** 1.0.0 | **Last reviewed:** 2026-04-06
> Template used by `/para-skill add --template project` to generate a project-specific `SKILL.md`.
> Agent uses this template as a framework — scan context, generate draft, let user review.

---

## Usage

When user runs `/para-skill add [skill-name] --template project`:
1. Agent reads this template
2. Auto-scans project context (project.md, rules, docs/, etc.)
3. Fills the template sections based on scanned data
4. Presents complete SKILL.md draft for user to approve/edit

---

## Template Output

```markdown
---
name: project-profile
description: >
  Project-specific conventions, naming patterns, quality standards, and plan
  review checklist for [project-name]. Use this skill whenever creating plans,
  naming files, writing docs, running maintenance checklists, or reviewing
  plan quality for this project. Even if the user doesn't explicitly mention
  "conventions" or "standards", consult this skill for any project-level decision.
version: "1.0.0"
---

# Project Profile: [project-name]

> **Project Type:** [type]
> **Trigger:** Creating plans, naming files, writing docs, running maintenance checklists, or reviewing plan quality

This skill defines the **DNA** of this project — conventions that influence workspace-level workflows without modifying them.

## §1. Project Identity

| Field | Value |
|:------|:------|
| Type | `[type]` |
| Primary Language | [languages] |
| Doc Tone | `[formal-technical | conversational | tutorial-friendly]` |
| Doc Language | [en | vi | mixed] — per `preferences.language` |
| Build System | [command or "None"] |

## §2. Naming Conventions

### Plan Files
Pattern: `[describe your plan naming pattern]`

### Branches
Pattern: `[feat/topic | fix/topic | direct-to-main]`

### Commits
Pattern: `[describe your commit message format]`

## §3. Maintenance Patterns

### VCS Guardrails 🛡️

> **Trigger:** Before any raw `git commit` or `git push` command outside of `/push` or `/release` workflows.
- MUST explicitly re-read `.agents/rules/vcs.md` to ensure golden rule compliance, prevent secrets pushing, and enforce branch standards.

> Add additional project-specific checklists here that don't belong in global rules.
> Reference existing rules instead of duplicating content.

## §4. Quality Standards

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

## §5. Documentation Flow

> Describe the documentation flow for this project.
> Example: internal docs (VI) → public docs (EN) → website

## §6. Plan Review Checklist

> **Trigger:** AFTER any `/plan create` or `/plan update` — agent MUST run this checklist before presenting plan to user.
> **Purpose:** Catch logic errors, security gaps, missing scope, and token bloat BEFORE execution.
> **Defense:** If running `/plan create`, re-read this §6 AFTER writing plan to counter token decay.

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
   - [Which sections of the skill were applied, e.g., "§2 Naming Conventions"]
   
   ## Files Created
   - [List files created in sandbox/]
   
   ## Self-Assessment
   - [Did the skill provide useful guidance? What was ambiguous?]
   \```
```

---

## Co-Author Guide (Draft-First Approach)

> **Principle:** Agent scans context, proposes draft, user reviews. Do NOT ask individual questions one by one.

### Phase A: Auto-scan (agent does this silently)

Agent reads the following to gather information:
- `project.md` — type, language, tags, goal
- `.agents/rules/*.md` — project constraints
- `docs/` structure — documentation flow
- `.para-workspace.yml` — preferences.language
- Existing `.agents/skills/` — established patterns

### Phase B: Fill template

Agent fills §1-§6 based on scanned context:
- §1-§5: Fill directly from collected data
- §6: Extract checklist items from project rules + add standard checks
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
