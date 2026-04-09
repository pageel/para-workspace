---
description: Brainstorm context, issues, and solutions before formal planning
source: catalog
---

# /brainstorm [project-name] [topic]

> **Workspace Version:** 1.7.9.1 (Cognitive Bypass Fix)

Collaborative troubleshooting and ideation for a project. Use this workflow to explore problem spaces, evaluate potential solutions, and clarify thinking before committing to a formal implementation plan (`/plan`).

## Steps

> **Constraint:** Read `.para-workspace.yml` at the workspace root to get the user's preferred language from `language` (e.g., `vi` for Vietnamese). **All output and the final report MUST be translated to this language.**

### 1. Context Gathering

// turbo

First, understand the core topic and the project's current state.

> ⚠️ **Proactive Trigger Check:** BEFORE brainstorming ANY solution that concerns code changes or deployment, YOU MUST scan index triggers based on the intended target of your discussion (e.g. "editing repo/").

```bash
# Tier-1 Index Force Load (Anti-Cognitive-Bypass v1.7.9.1)
echo ""
echo "> ⚠️ Proactive Trigger Scan: .agents/rules.md & .agents/skills.md"
cat .agents/rules.md 2>/dev/null | head -n 30
cat .agents/skills.md 2>/dev/null | head -n 30
```

```bash
# Check for existing seeds
test -f Projects/[project-name]/.beads/seeds.md && cat Projects/[project-name]/.beads/seeds.md || echo "No seeds.md found."
```

```bash
# Check for previous brainstorm decisions
ls -t Projects/[project-name]/artifacts/para-decisions/brainstorm-*.md 2>/dev/null | head -3 || echo "No previous brainstorms."
```

```bash
# Check for previous decisions
ls -t Projects/[project-name]/artifacts/para-decisions/decision-*.md 2>/dev/null | head -3 || echo "No previous decisions."
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

**Evaluate output size before saving:**

- **Small brainstorm** (≤ 80 lines, ≤ 2 options, no data tables): Save 1 file only (Decision)
- **Large brainstorm** (> 80 lines, ≥ 3 options, has data tables/risk analysis/prototypes): Save 2 files (Decision + Research)

> **Naming convention:** `{type}-{YYYY-MM-DD}-{topic-slug}.md`
> - `type`: `brainstorm` or `decision`
> - Date ALWAYS right after type prefix
> - `topic-slug`: kebab-case, ≤5 words

```bash
mkdir -p Projects/[project-name]/artifacts/para-decisions
```

#### File 1 — Decision (always saved)

Save to `Projects/[project-name]/artifacts/para-decisions/brainstorm-[YYYY-MM-DD]-[topic].md`:

```markdown
# Brainstorm: [Topic]

> **Date:** YYYY-MM-DD | **Project:** [project-name]
> **Research:** `docs/researches/[topic]-[YYYY-MM-DD].md` ← (only if large brainstorm)

## Problem

[1-2 sentences]

## Options

| # | Option | Key Trade-off | Score |
|---|---|---|---|
| 1 | [Name] | [Pro vs Con] | |
| 2 | [Name] | [Pro vs Con] | |

## Decision

[Selected approach and rationale — or "Pending" if still incubating]

### Key Principles

1. ...
2. ...

## Next Steps

1. ...
```

#### File 2 — Research (large brainstorm only)

```bash
mkdir -p Projects/[project-name]/docs/researches
```

Save to `Projects/[project-name]/docs/researches/[topic]-[YYYY-MM-DD].md`:

```markdown
# Research: [Topic]

> **Date:** YYYY-MM-DD | **Project:** [project-name]
> **Decision file:** `artifacts/para-decisions/brainstorm-[YYYY-MM-DD]-[topic].md`

## 1. Context & Data

[Raw data, statistics, measurements]

## 2. Analysis

[Detailed breakdown, anatomy, line-by-line if needed]

## 3. Options Evaluated

### Option 1: [Name]
- **Concept:** ...
- **Pros:** ...
- **Cons/Risks:** ...

## 4. Chosen Option — Deep Dive

[Prototype, diagrams, risk matrix, implementation details]

## 5+. Supplementary

[Ecosystem impact, related patterns, future evolution]
```

### 5. Choose Next Action

Present all options and ask the user how to proceed:

```
📋 BRAINSTORM COMPLETE: [topic]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Decision: artifacts/para-decisions/brainstorm-[YYYY-MM-DD]-[topic].md
📂 Research: docs/researches/[topic]-[YYYY-MM-DD].md  ← (if large)

💡 NEXT STEPS:
  A. 🌱 Save to Seeds — Incubate further in .beads/seeds.md
  B. 📐 Proceed to /plan — Formalize into implementation plan
  C. 📥 Add to /backlog — Create simple tasks directly
  D. 📝 Save as project doc — Keep as reference in docs/
  E. 🎓 Extract to /learn — Reusable lesson for other projects
  F. 📚 Extract to /para-knowledge — Persistent KI (if KI system exists)
  G. 📄 Extract to docs/researches — Standalone research document

❓ Which option? (A/B/C/D/E/F/G)
```

**Option A: Save to Seeds**

Append a summary reference to `.beads/seeds.md`:

```markdown
## Brainstorm: [topic] (YYYY-MM-DD)

- Decision: `artifacts/para-decisions/brainstorm-[YYYY-MM-DD]-[topic].md`
- Research: `docs/researches/[topic]-[YYYY-MM-DD].md` ← (if large)
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

**Option F: Extract as Knowledge Item**

> KI system is a standard workspace component (v1.7.0+).

Suggest: `/para-knowledge [topic]`

Extract the insight as a persistent Knowledge Item (cross-session, cross-project).

> **System KI hint:** If the insight relates to PARA Workspace architecture,
> governance, or cross-project patterns, suggest `/para-knowledge system [topic]` instead.

**Option G: Extract as Research Document**

// turbo

Extract detailed analysis into a standalone research document for future reference:

```bash
mkdir -p Projects/[project-name]/docs/researches
```

1. Save analysis as `docs/researches/[topic]-[YYYY-MM-DD].md` using the Research template from Step 4
2. Add cross-reference header pointing back to the brainstorm Decision file

> **When to use:** The brainstorm produced valuable analysis data (benchmarks, comparisons, prototypes) worth preserving separately, but didn't trigger the automatic Dual Output threshold in Step 4.

## Related

- `/plan` — Formalize decisions into actionable implementation phases
- `/backlog` — Create tasks directly if brainstorming yields simple actions
- `/docs` — Save analysis as project documentation
- `/learn` — Extract reusable knowledge for other projects
- `/retro` — Reflect on past issues to inform new brainstorming
