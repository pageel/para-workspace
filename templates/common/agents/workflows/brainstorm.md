---
description: Brainstorm context, issues, and solutions before formal planning
source: catalog
---

# /brainstorm [project-name] [topic] [--graph]

> **Workspace Version:** 1.8.5 (Graph Intelligence)

Collaborative troubleshooting and ideation for a project. Use this workflow to explore problem spaces, evaluate potential solutions, and clarify thinking before committing to a formal implementation plan (`/plan`).

## Options

| Option | Description |
|:--|:--|
| `--graph` | Run Graph Pipeline (Build → Query → Bundles) to anchor brainstorm in real codebase architecture |

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

### 1. Graph Context Pipeline (if --graph)

// turbo

If the `--graph` flag is provided, execute the graph intelligence pipeline BEFORE gathering other context:

1. **Build Graph:** Run `/para-graph build [project-name]` to ensure graph data is up-to-date.
2. **Identify Target Nodes:** Use MCP tool `graph_query` to locate architectural nodes related to the `[topic]`.
3. **Deep Context:** Use MCP tools `graph_context_bundle` and `graph_edges` on the identified nodes to gather callers, callees, dependencies, and assess blast radius.
4. **Inject Context:** Keep this graph intelligence in memory to ground the brainstorm in the actual codebase structure, preventing hallucinations.

### 2. Context Gathering

// turbo

First, understand the core topic and the project's current state.

> ⚠️ **Proactive Context & Trigger Check:** BEFORE brainstorming ANY solution, YOU MUST:
> 1. Read the project's own domain skill at `Projects/[project-name]/.agents/skills/[project-name]/SKILL.md` (if it exists) to understand project-specific rules.
> 2. Read the project's custom agent instructions at `Projects/[project-name]/.agents/AGENTS.md` (if it exists) to understand project-specific persona/guidelines.
> 3. Scan workspace index triggers based on the intended target of your discussion (e.g. "editing repo/").

```bash
# Context & Trigger Load (Anti-Cognitive-Bypass)
echo ""
echo "> ⚠️ Loading Project Skill: Projects/[project-name]/.agents/skills/[project-name]/SKILL.md"
cat Projects/[project-name]/.agents/skills/[project-name]/SKILL.md 2>/dev/null || echo "No project specific skill found."
echo ""
echo "> ⚠️ Loading Project Agent Persona: Projects/[project-name]/.agents/AGENTS.md"
cat Projects/[project-name]/.agents/AGENTS.md 2>/dev/null || echo "No project specific agent persona found."
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

### 3. Domain Skill Loading (Auto)

> When brainstorm topic intersects with sysdesign or spec domains, Agent MUST load
> the relevant skills to ground the brainstorm in established patterns and constraints.

**Detection Logic:** Agent scans the `[topic]` keywords to determine domain relevance:

| Keywords detected | Domain | Load actions |
|:--|:--|:--|
| architecture, infra, deploy, database, API, schema, security, auth, topology, scale, migration, edge, workers | **Sysdesign** | Load sysdesign skill + existing sysdesigns |
| feature, spec, scope, acceptance criteria, user story, behavior, requirement, UI, form, flow | **Spec** | Load spec skill + existing specs |
| csa, audit, double-binding, para-doc, anchor, conflict | **CSA** | Load csa skill + spec skill |
| Both or unclear | **Both** | Load both |

**Sysdesign domain loading:**

```bash
# Load sysdesign pattern catalog for architecture-relevant brainstorms
echo "=== Sysdesign Skill: Pattern Catalog ==="
cat .agents/skills/sysdesign/SKILL.md 2>/dev/null | head -60
echo ""
echo "=== Project existing sysdesigns ==="
ls -t Projects/[project-name]/artifacts/sysdesigns/sysdesign-*.md 2>/dev/null | head -5
for f in $(ls -t Projects/[project-name]/artifacts/sysdesigns/sysdesign-*.md 2>/dev/null | head -2); do
  echo "--- $(basename $f) ---"
  head -30 "$f"
  echo ""
done
```

> After loading, Agent SHOULD identify which architecture pattern(s) are relevant
> and read the full pattern file from `.agents/skills/sysdesign/references/architecture-patterns/`
> to inform alternatives evaluation.

**Spec domain loading:**

```bash
# Load spec context for feature-relevant brainstorms
echo "=== Project existing specs ==="
ls -t Projects/[project-name]/artifacts/specs/spec-*.md 2>/dev/null | head -5
for f in $(ls -t Projects/[project-name]/artifacts/specs/spec-*.md 2>/dev/null | head -2); do
  echo "--- $(basename $f) ---"
  head -30 "$f"
  echo ""
done
```

**CSA domain loading:**

```bash
# Load csa guidelines for audit & link-relevant brainstorms
echo "=== CSA Skill: Audit Guidelines ==="
cat .agents/skills/csa/SKILL.md 2>/dev/null | head -60
```

> **Rationale:** Brainstorm decisions feed directly into sysdesign and spec.
> Loading these skills ensures the brainstorm produces decisions compatible with
> established patterns, avoids contradicting existing designs, and uses the correct
> vocabulary/structure that sysdesign/spec workflows expect.

- Ask the user to elaborate on the problem, constraints, or goals of the `[topic]`.
- Identify key requirements and potential friction points.
- _Wait for user input if needed before proceeding._

### 4. Ideation & Exploration

Generate 3-5 distinct perspectives, solutions, or root causes related to the topic. For each option, concisely outline:

- **Concept:** What is this approach?
- **Pros:** Why it might work.
- **Cons/Risks:** Potential drawbacks or technical challenges.

> 🔍 **Graph-Assisted Ideation (if `--graph`):** During exploration, Agent SHOULD
> actively use MCP tools to validate or challenge ideas against the real codebase:
> - `graph_query` — Find nodes related to proposed changes
> - `graph_god_nodes` — Identify architectural hot spots (most connected nodes) to assess risk
> - `graph_impact_analysis` — Assess blast radius of each option
> - `graph_context_bundle` — Pull callers/callees to check feasibility
> - `graph_edges` — Verify dependency assumptions
> - `memory_search` — Search past decisions, patterns, and friction points related to the topic
> - `memory_push` — Log key insights or architectural observations discovered during ideation

### 5. Refinement & Evaluation

> ⚠️ **MUST NOT skip this step.** Agent MUST present the options to the user and
> wait for explicit feedback before proceeding to Step 6. Skipping refinement
> leads to premature decisions and consent violations.

Collaborate with the user to evaluate the options:

- Eliminate unviable ideas.
- Combine overlapping concepts.
- Drill down into the technical, architectural, or operational details of the most promising approach.
- _Wait for user confirmation that refinement is complete before saving._

> 🔍 **Graph-Assisted Refinement (if `--graph`):** When drilling into a specific
> option, Agent SHOULD use `graph_context_bundle` on the target node to pull
> source code and verify the proposed change is architecturally sound.
> Agent SHOULD also use `memory_search` to check for past friction or decisions
> on similar patterns, and `memory_push` to persist the refinement rationale.

### 6. Save Structured Output

// turbo

> 🧩 **Sidecar Skill:** Load document templates from `.agents/skills/brainstorm/`.
> Read `SKILL.md` for the Router Table, then load the template file needed:
> - **Open brainstorm** → `references/templates/brainstorm.md`
> - **Finalized decision (General)** → `references/templates/decision.md`
> - **Finalized decision (Architectural/ADR)** → `references/templates/adr.md`
> - **Research extraction** → `references/templates/research.md`

> ⚠️ **Status Check:** Agent MUST determine or ask the user:
> - **Open**: An ongoing exploration — findings will accumulate over time.
> - **Decided**: A final choice is made — the brainstorm is concluded.

#### Path A — Open Brainstorm (living document)

```bash
mkdir -p Projects/[project-name]/artifacts/brainstorms
```

- **Filename:** `brainstorm-[topic-slug].md` (prefix yes, date NO — living document)
- **Template:** `brainstorm.md` from Sidecar Skill
- **Append rule:** If a file with the same topic already exists, Agent MUST append a new `### YYYY-MM-DD` entry to the Running Log section instead of creating a new file. Agent SHOULD also update the Synthesis section.

Save to `Projects/[project-name]/artifacts/brainstorms/brainstorm-[topic-slug].md`.

#### Path B — Finalized Decision (frozen document)

```bash
mkdir -p Projects/[project-name]/artifacts/para-decisions
```

- **Filename:** `brainstorm-[YYYY-MM-DD]-[topic-slug].md` (WITH date — backward compatible)
- **Template:** `decision.md` from Sidecar Skill
- **Cross-ref:** If this decision evolved from an Open brainstorm, add the brainstorm path in the header.

Save to `Projects/[project-name]/artifacts/para-decisions/brainstorm-[YYYY-MM-DD]-[topic].md`.

#### File 2 — Research (Extract Paradigm — user consent required)

> ⚠️ **MUST ask user before creating File 2.** Agent MUST NOT auto-create
> the Research file. Present the evaluation to the user and wait for consent.

**Evaluate whether to propose extraction:**

- **Threshold:** Brainstorm content ≥ **500 lines** OR ≥ 5 refinement rounds
- **Below threshold:** Save Decision only. Do NOT propose Research extraction.
- **Above threshold:** Present to user:

```
📊 BRAINSTORM SIZE: [N] lines, [N] refinement rounds

This brainstorm exceeds the extraction threshold (500+ lines).
I recommend extracting detailed analysis into a standalone Research document.

⚠️ EXTRACT PARADIGM:
  - Brainstorm file: KEPT INTACT (not modified)
  - Research file: NEW file created via COPY + TRANSFORM
  - No content is removed from the original brainstorm.

Proceed with Research extraction? (y/n)
```

**If user confirms (y):**

```bash
mkdir -p Projects/[project-name]/docs/researches
```

Save to `Projects/[project-name]/docs/researches/[topic]-[YYYY-MM-DD].md`
using the **Research template** from the Sidecar Skill.

**If user declines (n):** Skip. Save Decision only.

### 7. Graph Memory Push (CONDITIONAL)

> **Gate:** Only trigger if (1) project has `.beads/graph/` directory AND (2) brainstorm is **Decided** (Path B).
> Open brainstorms (Path A) are NOT pushed — they are still evolving.

1. Check graph availability:
   ```bash
   test -d "Projects/[project-name]/.beads/graph" && echo "✅ Graph Memory available" || echo "⏭️ No graph — skip memory push"
   ```

2. **IF graph exists AND decision finalized:**
   Push the decision summary via MCP `memory_push`:
   - **kind:** `brainstorm-decision`
   - **content:** Decision title + chosen approach + key rationale (from the Decision section)
   - **sessionId:** `YYYY-MM-DD-brainstorm-[topic]`
   - **metadata:** `{ "topic": "[topic]", "decision_file": "artifacts/para-decisions/brainstorm-[date]-[topic].md", "options_considered": N }`

   Agent calls `memory_push(projectName, kind, content, sessionId, metadata)`.

3. **Curate memory:** After pushing, call `memory_curate(projectName)` to consolidate raw memory events into semantic slices for future sessions.

4. **IF no graph OR open brainstorm** → Skip silently.

### 8. Choose Next Action

> Agent MUST analyze the brainstorm context and **recommend exactly ONE option** as the primary
> next step, with clear rationale. Other options are listed as alternatives.

**Recommendation Engine — Signal Analysis:**

Agent evaluates these signals to determine the best next action:

| Signal | Source | Weight |
|:--|:--|:--|
| Domain keywords | Step 3 (Domain Skill Loading) | 🔴 High |
| Decision scope | Is the decision cross-cutting or feature-scoped? | 🔴 High |
| Project state | Does sysdesign/spec/plan already exist for this project? | 🟡 Medium |
| Reversibility | One-way door → needs more formalization | 🟡 Medium |

**Decision Matrix:**

| Condition | Recommended Option |
|:--|:--|
| Sysdesign keywords detected + no sysdesign exists for project | **I** → `/sysdesign create` |
| Sysdesign keywords detected + sysdesign already exists | **I** → `/sysdesign update` or **H** → `/spec create` |
| Spec keywords detected + sysdesign exists | **H** → `/spec create` |
| Spec keywords detected + no sysdesign exists | **I** → `/sysdesign create` first (architecture before features) |
| Decision is a one-way door (high reversibility cost) | **G** → `/qa` stress-test first |
| Topic is exploratory, no clear decision yet | **A** → Save to Seeds |
| Decision is implementation-ready, scope is clear | **B** → `/plan create` |
| Decision yields simple, atomic tasks | **C** → `/backlog add` |

**Output Format:**

```
📋 BRAINSTORM COMPLETE: [topic]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Decision: artifacts/para-decisions/brainstorm-[YYYY-MM-DD]-[topic].md
📂 Research: docs/researches/[topic]-[YYYY-MM-DD].md  ← (if extracted)

💡 NEXT STEPS:

  A. 🌱 Save to Seeds — Incubate further in .beads/seeds.md

  B. 📐 Proceed to /plan — Formalize into implementation plan

  C. 📥 Add to /backlog — Create simple tasks directly

  D. 📝 Save as project doc — Keep as reference in docs/

  E. 🎓 Extract to /learn — Reusable lesson for other projects

  F. 📄 Extract to docs/researches — Standalone research document

  G. 🔴 Stress-test with /qa — Red Team review before committing

  H. 📝 Proceed to /spec — Write structured specification

  I. 📐 Proceed to /sysdesign — Design system architecture

⭐ RECOMMENDATION: [X] — [1-sentence rationale based on context analysis]

❓ Proceed with [X], or choose another option?
```

> **Rule:** Agent MUST conclude the options list with a `⭐ RECOMMENDATION` line
> that picks exactly ONE option and explains WHY based on the brainstorm context.
> The rationale must reference concrete signals (e.g., "detected architecture keywords",
> "no sysdesign exists yet", "one-way door decision needs stress-testing").

**Option A: Save to Seeds**

Append a summary reference to `.beads/seeds.md`:

```markdown
## Brainstorm: [topic] (YYYY-MM-DD)

- Decision: `artifacts/para-decisions/brainstorm-[YYYY-MM-DD]-[topic].md`
- Research: `docs/researches/[topic]-[YYYY-MM-DD].md` ← (if large)
- Status: Incubating
```

**Option B: Proceed to Plan**

Suggest: `/plan [project-name] create`

> ⚠️ **Workflow Transition Rule:** The Agent MUST NOT begin creating or structuring the plan here. The Agent MUST cleanly close the `/brainstorm` workflow and wait for the user to trigger `/plan`. The `/plan` workflow has its own strict context-loading and template-selection checkpoints (Step 0 to 2.8) that MUST NOT be bypassed or combined.

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

**Option F: Extract as Research Document**

// turbo

Extract detailed analysis into a standalone research document for future reference:

```bash
mkdir -p Projects/[project-name]/docs/researches
```

1. Save analysis as `docs/researches/[topic]-[YYYY-MM-DD].md` using the Research template from Step 6
2. Add cross-reference header pointing back to the brainstorm Decision file

> **When to use:** The brainstorm produced valuable analysis data (benchmarks, comparisons, prototypes) worth preserving separately, but didn't trigger the Extract threshold in Step 6.

**Option G: Stress-test with /qa**

Suggest: `/qa [project-name] [topic]`

Run the QA Red Team workflow to stress-test the brainstorm findings before committing to a plan or implementation. Particularly valuable when the brainstorm involves architectural decisions or security-sensitive changes.

**Option H: Proceed to Spec**

Suggest: `/spec [project-name] create`

> ⚠️ **Workflow Transition Rule:** The Agent MUST NOT begin creating the spec here. The Agent MUST cleanly close the `/brainstorm` workflow and wait for the user to trigger `/spec`. The `/spec` workflow will automatically detect and inherit the brainstorm context to pre-populate assumptions and boundaries.

**Option I: Proceed to Sysdesign**

Suggest: `/sysdesign [project-name] create`

> ⚠️ **Workflow Transition Rule:** The Agent MUST NOT begin creating the sysdesign here. The Agent MUST cleanly close the `/brainstorm` workflow and wait for the user to trigger `/sysdesign`. The `/sysdesign` workflow will automatically load brainstorm decisions via Step 3.5 (Load Existing Decisions) and inherit architectural constraints.

> **When to suggest:** Brainstorm topic was about infrastructure, deployment, database selection, API design, security architecture, or any cross-cutting architectural concern. The decision produced here becomes a constraint that `/sysdesign` will reference via `decisions: []` metadata.

## Related

- `/sysdesign` — Design system architecture from brainstorm decisions (downstream, architectural)
- `/spec` — Write structured specification before coding (downstream, feature-level)
- `/plan` — Formalize decisions into actionable implementation phases
- `/backlog` — Create tasks directly if brainstorming yields simple actions
- `/qa` — Stress-test brainstorm findings before committing
- `/docs` — Save analysis as project documentation
- `/learn` — Extract reusable knowledge for other projects
- `/retro` — Reflect on past issues to inform new brainstorming
