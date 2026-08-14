---
description: Brainstorm context, issues, and solutions before formal planning
source: catalog
---

# /brainstorm [project-name] [topic] [--graph] [--deep] [--contributes-to [paths]]

> 🧠 **DEEP REASONING (CoT) GUARD:** IF `--deep` or `--cot` flag is provided, OR topic matches auto-trigger keywords (see Step 4), Agent MUST load `.agents/skills/deep-reasoning/SKILL.md` and execute the 4-Phase CoT Protocol with Multi-Dimensional Scoring Matrix before generating and evaluating options.

> **Workspace Version:** 1.9.8 (CoT + MCP Integration + Process Transparency)

Collaborative troubleshooting and ideation for a project. Use this workflow to explore problem spaces, evaluate potential solutions, and clarify thinking before committing to a formal implementation plan (`/plan`).

## Options

| Option | Description |
|:--|:--|
| `--graph` | Run Graph Pipeline (Build → Query → Bundles) to anchor brainstorm in real codebase architecture |
| `--deep` | Activate Deep Reasoning Protocol (`deep-reasoning` skill) for 4-phase CoT analysis |
| `--contributes-to [paths]` | Link this brainstorm to destination documents (e.g., specs, sysdesigns, researches). Automatically updates the target files with the detailed analysis and diagrams. |
| `--resume-qa [path]` | Path to QA Report file. Links brainstorm decision back to QA report and auto-triggers QA resume recommendation upon conclusion. |

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

> 🏥 **Research Health Check (v1.9.8 — if `--deep` + project has research):**
> BEFORE ideation, Agent MUST check if the project has existing research documents (≥500 lines) related to the topic.
> IF found → Execute the Research Health Check protocol from `/research` workflow §1.5:
> - Read Decision Tracker → report progress + stale questions
> - Suggest highest priority open Q
> - Apply Graduation Gate (≥80% closed → suggest `/plan create`)
> This ensures brainstorm sessions on long research topics start with full awareness of prior progress.

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

> 🧠 **Deep Reasoning Protocol Check:**
> Agent MUST activate the 4-phase CoT reasoning cycle (Decompose ➔ Diverge ➔ Red-Team ➔ Converge) IF any of the following conditions are true:
> 1. `--deep` or `--cot` flag is explicitly provided.
> 2. Topic matches **auto-trigger keywords** (see detection table below).
> 3. Agent detects the topic involves a **one-way door** decision (irreversible architectural or data change).
>
> When activated, Agent MUST load `.agents/skills/deep-reasoning/SKILL.md` and follow the full 4-phase protocol.

#### 4a. Auto-Trigger Detection Table

| Keywords detected in topic | Trigger level | Action |
|:--|:--|:--|
| security, auth, encryption, RBAC, CSRF, XSS, secrets | 🔴 Always | MUST activate CoT |
| migration, breaking change, one-way door, data loss | 🔴 Always | MUST activate CoT |
| architecture, infrastructure, database schema, topology | 🟡 Suggest | SHOULD activate CoT, ask user if not `--deep` |
| refactor, redesign, rewrite, deprecate | 🟡 Suggest | SHOULD activate CoT, ask user if not `--deep` |
| performance, scalability, caching, load balancing | 🟡 Suggest | SHOULD activate CoT, ask user if not `--deep` |
| config, env, deploy, CI/CD | 🟢 Optional | Agent MAY suggest `--deep` if complexity is high |

> **Rule:** If 🔴 keywords are detected and `--deep` was NOT explicitly provided, Agent MUST auto-activate CoT and inform the user: "🧠 Auto-activating Deep Reasoning — topic involves [keyword category]."

#### 4b. MCP-Enriched CoT Pipeline (if project has graph)

> **Gate:** Check `test -d "Projects/[project-name]/.beads/graph"` OR `test -d "Projects/[project-name]/repo/.beads/graph"`.
> If graph exists → MCP tools MUST be used to ground CoT phases in real codebase data.
> If no graph → CoT runs as pure reasoning protocol (no MCP calls).

When graph is available, Agent integrates MCP tools into each CoT phase:

| CoT Phase | MCP Tool | Purpose |
|:--|:--|:--|
| **Phase 1: Decompose** | `graph_query` | Locate architectural nodes related to topic |
| **Phase 1: Decompose** | `memory_search` | Retrieve past decisions and friction on similar topics |
| **Phase 2: Diverge** | `graph_impact_analysis` | Assess blast radius of each approach |
| **Phase 2: Diverge** | `graph_god_nodes` | Identify hot spots (most connected nodes) to gauge risk |
| **Phase 2: Diverge** | `graph_context_bundle` | Pull callers/callees for feasibility checks |
| **Phase 3: Red-Team** | `graph_edges` | Verify dependency assumptions against real graph |
| **Phase 3: Red-Team** | `insight_search` | Surface outstanding risks/gotchas for the area |
| **Phase 4: Converge** | `memory_push` | Persist CoT decision with `kind: "cot-decision"` |

> **Token Guard:** Limit MCP calls to **max 5 per phase** to prevent token bloat. Prioritize `graph_impact_analysis` and `memory_search` as highest-value calls.

> 🔄 **Empty Graph Early Exit (v1.9.7.1):**
> After Phase 1 MCP calls (`graph_query` + `memory_search`), Agent MUST evaluate the results:
> - **IF both return empty** (`[]` / `count: 0`) → Graph exists but has no relevant data for this topic.
>   - Agent MUST downgrade to **pure reasoning** for Phase 2-3 (skip remaining MCP calls).
>   - Agent MUST log: `"⏭️ Graph empty for topic — MCP skipped for Phase 2-3, continuing as pure reasoning."`
>   - Phase 4 `memory_push` is still executed (to persist the CoT decision).
> - **IF any result is non-empty** → Continue MCP-enriched pipeline normally.

#### 4c. Standard Ideation (all modes)

Generate 3-5 distinct perspectives, solutions, or root causes related to the topic. For each option, concisely outline:

- **Concept:** What is this approach?
- **Pros:** Why it might work.
- **Cons/Risks:** Potential drawbacks or technical challenges.

> When CoT is active, Agent MUST structure options as the 3 canonical approaches:
> **A (Conservative)**, **B (Balanced/Optimal)**, **C (Aggressive/Redesign)** — and score them using the 5D Scoring Matrix from the deep-reasoning skill.

> 🔍 **Graph-Assisted Ideation (if `--graph` without `--deep`):** During exploration, Agent SHOULD
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

> ⛔ **CHECKPOINT (CoT Sessions — v1.9.7.1):** When CoT was active in Step 4, Agent has already
> converged on a recommended approach in Phase 4. However, CoT convergence is NOT user approval.
> Agent **MUST** still present the CoT results (approaches, scores, recommendation) to the user
> and **STOP calling tools** until the user explicitly confirms, modifies, or rejects the recommendation.
> Auto-proceeding from CoT Phase 4 to Step 6 without user input is a **sovereignty violation**.

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

> 🧠 **CoT Output Requirement (v1.9.8 — Process Transparency):**
> IF Deep Reasoning (CoT) was active during this brainstorm session (Step 4), Agent **MUST**:
>
> **A. Phase Logging (MANDATORY):** Include the full phase-by-phase documentation in the brainstorm artifact:
>   - `## Step 0: Tier Detection Log` — Tier result table (3-layer scores)
>   - `## Phase 1: Problem Decomposition & Invariants` — Root problem, sub-problems, invariants
>   - `## Phase 2: Divergent Exploration & Scoring` — 3 approaches, 5D Scoring Matrix
>   - `## Phase 3: Red-Team & Stress Testing` — Stress tests, trade-off matrix
>   - `## Phase 4: Convergence & Decision` — Selected approach, rationale, next steps
>
> **B. Summary Blocks (MANDATORY):** Include BOTH:
>   - `### 🧠 Deep Reasoning Summary (CoT)` — Root Problem, Scoring Matrix, Trade-Offs, Door Type
>   - `### 🔍 Kiểm Toán Suy Luận Linh Hoạt` (Audit Trail) — Tier, Budget, Reentry, Confidence
>   - MCP Evidence (if graph was available): list of graph nodes queried, blast radius data, past decisions surfaced
>
> **C. Phase Skip Warning:** If any phase was skipped, Agent MUST include: `> ⚠️ PHASE SKIPPED: [Phase Name] — Reason: [why]`
>
> The Phase Logging sections are placed **before** the Summary blocks. The CoT Summary section is placed **after** the Options/Analysis section and **before** the Decision section in both brainstorm and decision templates.
> IF CoT was NOT active → omit all CoT sections entirely.
>
> ⛔ **Harness Guard Cross-Reference:** See `deep-reasoning/SKILL.md` v2.2.0 §Process Transparency Harness Guard for the authoritative Guard 1-3 definitions. This workflow requirement is the enforcement mechanism.

> 🛠️ **Ecosystem Traceability & Integration Rule (v1.8.7):**
> 1. **YAML Metadata:** In the brainstorm file's YAML frontmatter, the Agent **MUST** record the `contributes_to: [ "relative/path/to/target1.md", "relative/path/to/target2.md" ]` array field if run with the `--contributes-to [paths]` flag or if related specifications, system designs, or research documents are detected.
> 2. **Sequential Integration into Targets:** If target links are identified in `contributes_to`:
>    - The Agent **MUST** read the target files.
>    - For Research, Specs, or Sysdesigns, insert a new sequential detail section: `### Brainstorm: [Topic Name] (YYYY-MM-DD)` into the corresponding section (e.g. ## Diagnostics Design in Specs, ## Observability in Sysdesigns, or before the Conclusion).
>    - The inserted content MUST be **highly detailed**, including: the problem context of the discussion, the Options & Trade-offs considered, **all ASCII/Mermaid diagrams generated in the session**, and the finalized Decision.
>    - This ensures the target files act as unified knowledge entities, containing the complete and detailed contribution process of all brainstorms.

#### Path A — Open Brainstorm (living document)

```bash
mkdir -p Projects/[project-name]/artifacts/brainstorms
```

- **Filename:** `brainstorm-[topic-slug].md` (prefix yes, date NO — living document)
- **Template:** `brainstorm.md` from Sidecar Skill
- **Append rule:** If a file with the same topic already exists, Agent MUST append a new `### YYYY-MM-DD` entry to the Running Log section instead of creating a new file. Agent SHOULD also update the Synthesis section.
- **Link-Only Pointer Specification (Platform Tracker Exemption):**
  - Save the detailed brainstorm file directly inside the project directory: `Projects/[project-name]/artifacts/brainstorms/brainstorm-[topic-slug].md`.
  - **MUST NOT** write detailed brainstorm contents directly into the platform-level artifact file in the `brain/` directory of the IDE.
  - Instead, create the platform-level file (e.g. `brainstorm_[topic-slug].md`) as a **Link-Only Pointer** containing only the `<!-- TRACKER (link-only) -->` header comment and a clickable Markdown link pointing to the physical brainstorm file in the project. All other detailed sections MUST be omitted/deleted from the platform file to avoid content duplication and token bloat.

#### Path B — Finalized Decision (frozen document)

```bash
mkdir -p Projects/[project-name]/artifacts/para-decisions
```

- **Filename:** `brainstorm-[YYYY-MM-DD]-[topic-slug].md` (WITH date — backward compatible)
- **Template:** `decision.md` from Sidecar Skill
- **Cross-ref:** If this decision evolved from an Open brainstorm, add the brainstorm path in the header.
- **Link-Only Pointer Specification (Platform Tracker Exemption):**
  - Save the detailed decision file directly inside the project directory: `Projects/[project-name]/artifacts/para-decisions/brainstorm-[YYYY-MM-DD]-[topic-slug].md`.
  - **MUST NOT** write detailed decision contents directly into the platform-level artifact file in the `brain/` directory of the IDE.
  - Instead, create the platform-level file (e.g. `brainstorm_[topic-slug].md`) as a **Link-Only Pointer** containing only the `<!-- TRACKER (link-only) -->` header comment and a clickable Markdown link pointing to the physical decision file in the project. All other detailed sections MUST be omitted/deleted from the platform file to avoid content duplication and token bloat.

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

2. **IF graph exists AND decision finalized (new decision, not append):**
   Push the decision summary via MCP `memory_push`:
   - **kind:** `brainstorm-decision`
   - **content:** Decision title + chosen approach + key rationale (from the Decision section)
   - **sessionId:** `YYYY-MM-DD-brainstorm-[topic]`
   - **metadata:** `{ "topic": "[topic]", "decision_file": "artifacts/para-decisions/brainstorm-[date]-[topic].md", "options_considered": N }`

   Agent calls `memory_push(projectName, kind, content, sessionId, metadata)`.

   > **Append vs New Decision (v1.9.7.1):** IF this session appended to an existing brainstorm file (Running Log entry)
   > AND the file status was already `Decided` before this session → skip `brainstorm-decision` push
   > (decision already persisted in a prior session). Only push `cot-decision` if CoT was active.

3. **IF CoT was active during this session (Step 4):**
   Push a separate CoT decision node via MCP `memory_push`:
   - **kind:** `cot-decision`
   - **content:** Root Problem + Selected Approach + 5D Weighted Score + Critical Trade-Offs (from the CoT Summary section)
   - **sessionId:** `YYYY-MM-DD-brainstorm-[topic]`
   - **metadata:** `{ "cotDepth": 4, "scoringDimensions": 5, "selectedApproach": "[A/B/C]", "weightedScore": [N.NN], "doorType": "[one-way/two-way]", "mcp_evidence": [true/false] }`

   > This creates a dedicated `cot-decision` node in the knowledge graph, enabling future sessions to retrieve architectural reasoning context via `memory_search(query, category: "cot-decision")`.

4. **Curate memory:** After pushing, call `memory_curate(projectName)` to consolidate raw memory events into semantic slices for future sessions.

5. **IF no graph OR open brainstorm** → Skip silently.

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

  J. 🔄 Resume QA Session — Return to /qa with completed brainstorm finding (--resume-qa)

⭐ RECOMMENDATION: [X] — [1-sentence rationale based on context analysis]

> **QA Handback Override Rule:** IF `--resume-qa [path]` flag is present OR `qa_context` is active, the Agent MUST automatically set `⭐ RECOMMENDATION: Option J (Resume QA Session)` with the auto-generated command `/qa resume [qa-report-path]`.

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
