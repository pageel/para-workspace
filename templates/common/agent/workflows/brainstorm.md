---
description: Brainstorm context, issues, and solutions before formal planning
source: catalog
---

# /brainstorm [project-name] [topic]

> **Workspace Version:** 1.5.0 (Governed Libraries)

Collaborative troubleshooting and ideation for a project. Use this workflow to explore problem spaces, evaluate potential solutions, and clarify thinking before committing to a formal implementation plan (`/plan`).

## Steps

> **Constraint:** Read `.para-workspace.yml` at the workspace root to get the user's preferred language from `language` (e.g., `vi` for Vietnamese). **All output and the final report MUST be translated to this language.**

### 1. Context Gathering

// turbo

First, understand the core topic and the project's current state.

```bash
# Check for existing seeds
test -f Projects/[project-name]/.beads/seeds.md && cat Projects/[project-name]/.beads/seeds.md || echo "No seeds.md found."
```

```bash
# Check for previous brainstorm outputs
ls -t Projects/[project-name]/artifacts/para-decisions/brainstorm-*.md 2>/dev/null | head -3 || echo "No previous brainstorms."
```

- Ask the user to elaborate on the problem, constraints, or goals of the `[topic]`.
- Identify key requirements and potential friction points.
- _Wait for user input if needed before proceeding._

### 2. Ideation & Exploration

Generate 3-5 distinct perspectives, solutions, or root causes related to the topic. For each option, concisely outline:

- **Concept:** What is this approach?
- **Pros:** Why it might work.
- **Cons/Risks:** Potential drawbacks or technical challenges.

### 3. Refinement & Evaluation

Collaborate with the user to evaluate the options:

- Eliminate unviable ideas.
- Combine overlapping concepts.
- Drill down into the technical, architectural, or operational details of the most promising approach.

### 4. Save Structured Output

// turbo

Save the brainstorm analysis to a structured decision file:

```bash
mkdir -p Projects/[project-name]/artifacts/para-decisions
```

Save to `Projects/[project-name]/artifacts/para-decisions/brainstorm-[topic]-[YYYY-MM-DD].md`:

```markdown
# Brainstorm: [Topic]

> **Date:** YYYY-MM-DD | **Project:** [project-name]

## Problem Statement

[1-2 sentences]

## Options Evaluated

### Option 1: [Name]

- **Concept:** ...
- **Pros:** ...
- **Cons:** ...

### Option 2: [Name]

...

## Decision

[Selected approach and rationale — or "Pending" if still incubating]

## Next Steps

[What action to take]
```

### 5. Choose Next Action

Present all options and ask the user how to proceed:

```
📋 BRAINSTORM COMPLETE: [topic]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Saved: artifacts/para-decisions/brainstorm-[topic]-[date].md

💡 NEXT STEPS:
  A. 🌱 Save to Seeds — Incubate further in .beads/seeds.md
  B. 📐 Proceed to /plan — Formalize into implementation plan
  C. 📥 Add to /backlog — Create simple tasks directly
  D. 📝 Save as project doc — Keep as reference in docs/
  E. 🎓 Extract to /learn — Reusable lesson for other projects

❓ Which option? (A/B/C/D/E)
```

**Option A: Save to Seeds**

Append a summary reference to `.beads/seeds.md`:

```markdown
## Brainstorm: [topic] (YYYY-MM-DD)

- Full analysis: `artifacts/para-decisions/brainstorm-[topic]-[date].md`
- Status: Incubating
```

**Option B: Proceed to Plan**

Suggest: `/plan [project-name]`

The `/plan` workflow will automatically discover the brainstorm output.

**Option C: Add to Backlog**

Suggest: `/backlog [project-name]`

**Option D: Save as Project Doc**

// turbo

Copy or condense the brainstorm analysis into `Projects/[project-name]/docs/`:

1. Save as `docs/[topic]-analysis.md`
2. Update Doc Index (`docs/README.md`) with the new entry

**Option E: Extract as Learning**

Suggest: `/learn [project-name]`

Extract the reusable insight (not the project-specific details) into `Areas/Learning/`.

## Related

- `/plan` — Formalize decisions into actionable implementation phases
- `/backlog` — Create tasks directly if brainstorming yields simple actions
- `/docs` — Save analysis as project documentation
- `/learn` — Extract reusable knowledge for other projects
- `/retro` — Reflect on past issues to inform new brainstorming
