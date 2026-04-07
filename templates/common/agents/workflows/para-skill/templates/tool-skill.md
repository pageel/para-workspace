# Tool Skill Template

> **Version:** 1.0.0 | **Last reviewed:** 2026-04-06
> Template used by `/para-skill add --template tool` to generate a utility/automation `SKILL.md`.
> Suitable for: script automation, code generation, file processing, data transformation.

---

## Usage

When user runs `/para-skill add [skill-name] --template tool`:
1. Agent reads this template
2. Auto-scans project context or uses user's intent from command
3. Fills the template based on available context
4. Presents complete SKILL.md draft for user to approve/edit

---

## Template Output

```markdown
---
name: [skill-name]
description: >
  [Describe function + specific trigger context. Must be "pushy" enough so
  the Agent proactively uses the skill when appropriate. Include implicit
  use cases too.]
version: "1.0.0"
---

# [Skill Name]

> **Purpose:** [One-sentence purpose]
> **Trigger:** [When this skill activates — list specific contexts]

## Workflow

[Step-by-step instructions in imperative form]

### Step 1: [Action]
[Specific instructions]

### Step 2: [Action]
[Specific instructions]

## Input / Output

### Input
- **Format:** [text | file | JSON | ...]
- **Example:**
\```
[Realistic input example]
\```

### Output
- **Format:** [text | file | JSON | ...]
- **Example:**
\```
[Expected output example]
\```

## Edge Cases

[List special cases and how to handle them]

## Scripts (if any)

> Read `scripts/[script-name].sh` when [specific condition].

## References (if any)

> Read `references/[ref-name].md` for [specific domain/framework].

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
   - [Which sections of the skill were applied, e.g., "Step 1"]
   
   ## Files Created
   - [List files created in sandbox/]
   
   ## Self-Assessment
   - [Did the skill provide useful guidance? What was ambiguous?]
   \```
```

---

## Co-Author Guide (Draft-First)

### Phase A: Auto-scan
Agent reads `project.md` and user's command intent to determine:
- What the skill should do
- What tools/commands it needs
- Expected input/output format

### Phase B: Fill template
Agent generates draft based on context. Marks unknowns with `[TBD]`.

### Phase C: Present draft
Show complete SKILL.md to user for approval/edit.

### Fallback: Minimal Interview
Only when context is insufficient, ask core questions:
1. "What should this skill help the Agent do?"
2. "When should it trigger? (what user phrases/contexts)"
3. "What's the expected output format?"
