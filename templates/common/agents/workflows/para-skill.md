---
description: Manage, create, and validate AI Agent skills with quality-driven Co-Author engine
source: catalog
---

# /para-skill [action] [name]

> **Workspace Version:** 1.7.6.3 (Governed Libraries)

> **Sidecar Architecture:** This workflow contains LOGIC ONLY. All supporting data
> (templates, checklists) is stored in the companion skill at
> `.agents/skills/para-skill/`. See `SKILL.md` §3 Resource Router for paths.
> The legacy `workflows/para-skill/` subfolder has been removed.

Specialized workflow to manage, create, and validate AI Agent skills within a PARA Workspace. Integrates a Co-Author engine that interviews users and applies quality best practices during skill creation.

## Actions

| Action | Description |
| :-- | :-- |
| `list` | Compare active skills vs. governed catalog |
| `add` | Create a new skill via guided Co-Author interview |
| `install` | Install or update a skill from the governed catalog |
| `validate` | Check a skill for PARA + quality compliance without making changes |
| `standardize` | Upgrade an existing skill to current standards |
| `test` | Run conversational eval on a skill with user-provided test prompts |

---

## Action: list

Compare skills currently active in `.agents/skills/` against the governed catalog.

### Steps

// turbo

**Step 1.** List active skills:

```bash
echo "ACTIVE SKILLS (.agents/skills):"
ls -1d .agents/skills/*/SKILL.md 2>/dev/null | xargs -I{} dirname {} | xargs -I{} basename {} | sort
echo ""
```

**Step 2.** Read `.agents/skills.md` (trigger index) if exists.

**Step 3.** Read `catalog.yml` from the governed catalog source (priority order) and `VERSIONS.yml` for versions:

1. `Projects/para-workspace/repo/templates/common/agents/skills/catalog.yml`
2. `Resources/references/para-workspace/templates/common/agents/skills/catalog.yml`

**Step 4.** Display comparison report:

```
SKILL CATALOG REPORT
| Skill          | Version | Status          |
| -------------- | ------- | --------------- |
| para-kit       | 1.1.0   | Installed       |
| formatting     | 1.1.0   | Installed       |
| my-custom-tool | —       | Untracked       |
```

- **Installed**: In catalog AND in `.agents/skills/`.
- **Not installed**: In catalog but missing locally.
- **Untracked**: Exists locally but NOT in catalog (user-created).

---

## Action: add [name] [--template TYPE]

Create a new skill via the **Co-Author Engine** — a guided process that produces a quality SKILL.md.

### Templates

| Template | Flag | Use case |
| :-- | :-- | :-- |
| `project` | `--template project` | Project DNA — conventions, naming, plan checklists |
| `tool` | `--template tool` | Utility/automation — scripts, file ops, transforms |
| _(default)_ | _(no flag)_ | Minimal — frontmatter + empty body |

### Steps

#### Step 0: Pre-flight

// turbo

1. Re-read `.agents/rules.md` (workspace rules index)
2. Re-read `.agents/skills.md` (workspace skills index)
3. Check project `agent.rules` / `agent.skills` — if true, re-read project indices
4. If project has `oss-compliance` rule, re-read it (content zoning, naming)

#### Step 1: Template Selection

If `--template` flag provided, use that template.
Otherwise, ask user:

```
SKILL TEMPLATE SELECTION
1. project  — Project DNA (conventions, naming, plan review checklist)
2. tool     — Utility/automation (scripts, commands, transforms)
3. minimal  — Empty SKILL.md with frontmatter only

Which template? (1/2/3)
```

#### Step 2: Draft-First Co-Author

> **Principle:** Propose a draft first, let user review — do NOT ask individual questions one by one.

**Phase A: Auto-scan context** (agent does this silently):

1. Read `project.md` — extract type, language, tags, goal
2. Read `.agents/rules/*.md` — extract project-specific constraints
3. Read existing `.agents/skills/` — check for patterns
4. Read `docs/` structure — detect documentation flow
5. Read `.para-workspace.yml` — get `preferences.language`

**Phase B: Generate draft** (agent writes the draft):

**If template = `project`:**

Read the project-profile template from `.agents/skills/para-skill/references/templates/project-profile.md`.
Fill all sections (§1-§6) based on scanned context:
- §1-§5: Fill directly from collected data
- §6: Extract checklist items from project rules + add standard checks
- Mark unknown fields with `[TBD]` for user to complete

**If template = `tool`:**

Read the tool-skill template from `.agents/skills/para-skill/references/templates/tool-skill.md`.
Fill based on user's original command intent.

**Phase C: Present for approval** (user decides):

```
SKILL DRAFT: [name]
━━━━━━━━━━━━━━━━━━━━
[Show full draft SKILL.md]
━━━━━━━━━━━━━━━━━━━━
Options:
  approve   — Proceed to create files
  edit      — Tell me what to change
  regenerate — Rescan and try again
```

If user says "edit", apply changes and re-present.
Only proceed to Step 3 after explicit approval.

**Fallback: Minimal Interview**

Only when project has NO `project.md` or context is extremely limited,
ask 3-5 core questions:
1. "What type of project is this and what language does it use?"
2. "Are there any special naming conventions?"
3. "What mistakes commonly occur when planning for this project?"

#### Step 3: Write SKILL.md

1. Read `.agents/skills/para-skill/references/skill-quality-checklist.md`
2. Draft the `SKILL.md` based on interview answers
3. Self-review against the quality checklist before presenting to user:
   - D1-D4: Is the description pushy enough?
   - C1-C2: Is the file under 500 lines?
   - W1-W3: Does it explain "why" and include examples?
4. Present draft to user for approval

#### Step 4: Create Files

// turbo

1. Create directory: `.agents/skills/[name]/`
2. Write `SKILL.md` to `.agents/skills/[name]/SKILL.md`
3. Create `scripts/` and `references/` subdirs if skill uses them

#### Step 5: Update Skills Index

Add entry to `.agents/skills.md`:

```markdown
| [Name] | [Trigger description] | skills/[name]/SKILL.md |
```

If project-level skill, update `Projects/[project-name]/.agents/skills.md` instead.

#### Step 6: Report

```
SKILL CREATED: [name]
Template:  [project | tool | minimal]
Location:  .agents/skills/[name]/SKILL.md
Lines:     [N] lines
Index:     Updated .agents/skills.md

Tip: Run /para-skill validate [name] to quality-check.
Tip: Run /para-skill test [name] to run conversational eval.
```

---

## Action: install [name]

Install a skill from the governed catalog into `.agents/skills/`.

### Steps

1. **Resolve source**: Find the skill in the catalog source directory.
2. **Check conflict**: If `.agents/skills/[name]/` already exists, delegate to `/install` workflow for conflict resolution (Overwrite / Merge / Rename / Cancel).
3. **Copy**: Install the skill directory into `.agents/skills/[name]/`.
4. **Update index**: Add or update entry in `.agents/skills.md`.
5. **Report**: Confirm installation with version info from `VERSIONS.yml`.

> **Note:** For complex merge scenarios, use `/merge` workflow directly.

---

## Action: validate [name]

Check a skill for PARA + quality compliance without making changes.

### Steps

// turbo

1. Read `.agents/skills/[name]/SKILL.md`.
2. Read `.agents/skills/para-skill/references/skill-quality-checklist.md`.
3. Run the **Dual Checklist** (read-only mode):

**PARA Structure (P1-P5):**

| # | Check | How |
|:--|:------|:----|
| P1 | YAML Frontmatter | Has `name`, `description`, `version`? |
| P2 | Folder Structure | Is it in `.agents/skills/[name]/SKILL.md`? |
| P3 | Skills Index | Is there a matching entry in `.agents/skills.md`? |
| P4 | Naming | Is the folder `kebab-case`? |
| P5 | Version | Is version SemVer format? |

**Quality (D1-D4, C1-C4, W1-W5, B1-B3, T1-T3, TM1-TM3):**

Run all 27 checks from `skill-quality-checklist.md`.

4. Output compliance report:

```
SKILL VALIDATION: [name]
P1-P5: PARA Structure     — 5/5
D1-D4: Description       — 3/4 (D2: not pushy enough)
C1-C4: Content Structure  — 4/4
W1-W5: Writing Style      — 5/5
B1-B3: Bundled Resources  — 3/3
T1-T3: Test Readiness     — 2/3 (T2: missing expected output)
TM1-TM3: Test Mode        — 3/3
Result: 25/27 pass | 2 warnings
Tip: Run /para-skill standardize [name] to fix.
```

---

## Action: standardize [name]

Upgrade an existing skill to current quality standards.

### Checklist

The agent reads `.agents/skills/[name]/SKILL.md` and applies fixes for each item:

| # | Check | Rule |
| :-- | :-- | :-- |
| 1 | **YAML Frontmatter** | Must have `name`, `description`, `version` |
| 2 | **Description Quality** | Must be >= 20 words, include trigger context, be "pushy" |
| 3 | **Progressive Disclosure** | Body must be < 500 lines; overflow to `references/` |
| 4 | **Writing Style** | Use imperative form, explain "why", include examples |
| 5 | **No Absolute Paths** | Remove any hardcoded filesystem paths |
| 6 | **Naming Convention** | Folder must be `kebab-case`, files lowercase |
| 7 | **Index Entry** | Must have matching entry in `.agents/skills.md` |

### Execution

1. Read the target skill file.
2. Run through the checklist above.
3. Present a **diff summary** of proposed changes.
4. Apply changes after user confirmation.

---

## Action: test [name]

Evaluate a skill's compliance and effectiveness. Supports either a fast conversational simulation or a rigorous execution via Sandbox + Open Agent Manager.

### Steps

1. Read `.agents/skills/[name]/SKILL.md`.
2. Ask the user to select the evaluation mode:

```
🧪 TEST MODE SELECTION: [skill-name]
  A. Quick Eval   — Simulate in this chat (fast, subjective eval)
  B. Sandbox Eval — Run via Open Agent Manager (real execution, documented)
Which mode? (A/B)
```

### Mode A: Quick Eval

If user selects A (Quick Eval):

1. Ask user for **2-3 realistic test prompts** — the kind of thing a real user would actually say:

```
CONVERSATIONAL EVAL: [name]
Provide 2-3 test prompts to evaluate this skill.
These should be realistic user requests, not synthetic tests.

Example for a project-profile skill:
  1. "Create a plan to add authentication to this project"
  2. "Name the branch for the new payment feature"

Your test prompts:
```

2. For each test prompt, **simulate** skill behavior:
   - Process the test prompt as if the skill were active.
   - Generate the output the agent would produce.

3. After each simulation, ask user to evaluate:

```
TEST RESULT: Prompt [N]
Prompt:  "[user's test prompt]"
Output:  [Agent's simulated response using the skill]

Rate: Pass | Needs work | Fail
Notes:
```

4. Aggregate results and suggest standardizing if failed.


### Mode B: Sandbox Eval

If user selects B (Sandbox Eval):

// turbo

1. Prepare the sandbox boundary:

```bash
mkdir -p sandbox/evals/[name]-$(date +%Y-%m-%d)
```

2. Guide the user to run the skill via Open Agent Manager:

```
📋 SANDBOX EVAL SETUP
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Open the "Open Agent Manager" panel and COPY-PASTE this entire block into the chat:

```text
Read and apply this skill file first:
[Absolute path to .agents/skills/[name]/SKILL.md]

After loading the rules, execute the following:
Test Mode: [enter your test scenario here, e.g., 'create a new branch']
```

Wait for the Agent to complete and generate the test-report.md.
Come back here and type: "conclude test"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📂 Sandbox ready at: sandbox/evals/[name]-[date]/
```

3. **Wait for user to type "conclude test".**

// turbo

4. When the user types "conclude test", find the sandbox output and test report:

```bash
# Check if test report exists
test -f sandbox/evals/[name]-$(date +%Y-%m-%d)/test-report.md && cat sandbox/evals/[name]-$(date +%Y-%m-%d)/test-report.md || echo "test-report.md not found"
```

5. Read the generated artifacts. Assess whether the Agent obeyed the structural rules of the SKILL.md.
6. Format the assessment into the `/research` Process template.
7. Save the research document and update the docs index:

```bash
mkdir -p docs/researches
mv sandbox/evals/[name]-$(date +%Y-%m-%d)/test-report.md docs/researches/eval-[name]-$(date +%Y-%m-%d).md
# Remind user to update docs/README.md manually or agent appends it
```

*(Agent also checks index and updates if needed).*

8. Clean up the sandbox container:

```bash
# Clean up extra artifacts
rm -rf sandbox/evals/[name]-$(date +%Y-%m-%d)/
```

9. Final Report:

```
🧪 SANDBOX EVAL COMPLETE: [skill-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📄 Research saved: docs/researches/eval-[name]-[date].md
📊 Rules compliance: [Pass / Fail]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💡 Next: /para-skill validate [name]
```

---

## Context Routing

- **Workspace skills** (`.agents/skills/`): Shared across all projects.
- **Project skills** (`Projects/[project-name]/.agents/skills/`): Project-specific, take priority over workspace skills.
- Projects MAY provide a lightweight `skills.md` index at `Projects/[project-name]/.agents/skills.md` for lazy loading.
- Agent loads skills **on demand** based on trigger matching, not upfront.

## Notes

- This workflow manages the **skill library** itself. For day-to-day skill usage, the agent loads skills automatically via trigger matching.
- The governed catalog (`catalog.yml`) lists officially supported skills, while `VERSIONS.yml` is the single source of truth for versions.
- User-created skills (not in catalog) are valid but considered **untracked**.

## Related

- `/para` — Master workspace controller
- `/para-rule` — Rule management (sister workflow)
- `/para-workflow` — Workflow management (sister workflow)
- `/install` — Generic installer with conflict resolution
