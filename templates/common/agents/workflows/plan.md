---
description: Create an implementation plan for a project with architecture, phases, and timeline
source: catalog
---

# /plan [project-name] [action] [--graph] [--project]

> **Workspace Version:** 1.9.2 (Graph Intelligence + Project Context)
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
>
> 🔴 **CRITICAL INVARIANT:** Before executing any action under this workflow, the Agent **MUST** explicitly read the **Implementation Plan Guidelines** KI (`implementation_plan`) at [implementation_plan_rules.md](~/.gemini/antigravity-ide/knowledge/implementation_plan/artifacts/implementation_plan_rules.md) to understand the strict boundary, format, and rules of platform and project plans.


Create, review, or update a phased implementation plan for a PARA project.

## Actions

| Action | Description |
|:--|:--|
| `create` | Create a new implementation plan (default if omitted) |
| `review` | Review and summarize an existing plan |
| `update` | Update phases or status in an existing plan |
| `dev` | Start or continue executing the active plan |
| `end` | Complete and archive the active plan |

## Options

| Option | Description |
|:--|:--|
| `--graph` | Run Graph Pipeline (Build → God Nodes → Enrich) before planning to maximize architectural context |
| `--project` | Default for `create`. Load project-level `.agents/rules/` and `.agents/skills/` context before planning to ensure governance-aware plan generation |
| `--phase` | Default for `dev`. Strictly execute the plan phase by phase, verifying task completion before moving to the next phase |
| `--tdd` | Force strict Test-Driven Development mode. Agent MUST use `detail-plan-tdd.md` template for creation and load `.agents/skills/tdd/SKILL.md` during execution |
| `--hardened` | Hardened Plan mode. Agent uses `detail-plan-hardened.md` template, runs mandatory Post-Draft Audit Gate (logic, security, governance), classifies tasks for selective TDD injection, and presents audit results before activation |

---

## 📝 Action: create

Generate a comprehensive implementation plan based on the project contract, backlog, and optional reference projects.

### Steps

#### 0. Agent Indices Pre-flight

// turbo

> **Layer 3 defense:** Even if `/open` loaded indices at session start, long conversations
> cause attention decay. Force-load here to guarantee rules/skills awareness during planning.

```bash
# Context & Trigger Load (Anti-Cognitive-Bypass)
echo ""
echo "> ⚠️ Loading Project Skill: Projects/[project-name]/.agents/skills/[project-name]/SKILL.md"
cat Projects/[project-name]/.agents/skills/[project-name]/SKILL.md 2>/dev/null || echo "No project specific skill found."
echo ""
echo "> ⚠️ Proactive Trigger Scan: Workspace Indices"
cat .agents/rules.md 2>/dev/null | head -n 30
cat .agents/skills.md 2>/dev/null | head -n 30
echo ""
echo "> ⚠️ Proactive Trigger Scan: Project Indices"
cat Projects/[project-name]/.agents/rules.md 2>/dev/null | head -n 30
cat Projects/[project-name]/.agents/skills.md 2>/dev/null | head -n 30
```

#### 0.5. Graph Context Pipeline (if --graph)

// turbo

If the `--graph` flag is provided, execute an INTERACTIVE Graph Preparation Phase BEFORE creating the plan:

1. **Build Graph:** Run `/para-graph build [project-name]` to ensure graph data is up-to-date.
2. **Identify & Analyze Nodes:** Use MCP tools (`graph_god_nodes`, `graph_query`, `graph_context_bundle`, `graph_impact_analysis`, `graph_edges`) to deeply analyze the core files and God nodes related to the feature.
3. **Enrich:** For any unenriched God nodes found, use `graph_enrich` to document their semantic meaning.
4. **Interactive Report & Template Suggestion:** Pause the workflow and present a Chat Report to the user containing:
   - The impact analysis and blast radius of the proposed changes.
   - A question asking if the user wants to analyze any other aspects/nodes before generating the plan.
   - **Template Suggestion:** Based on the graph complexity, suggest the most appropriate plan template:
     - `detail-plan-tdd.md`: Strongly suggest if the changes involve heavy logic, complex impact radius, or core mechanics.
     - `detail-plan.md`: Suggest for standard UI, configuration, or simple features.
     - `detail-plan-docs.md`: Suggest if the changes are purely documentation.
5. ⛔ **CHECKPOINT (Interactive Pause):** Agent MUST STOP here. ONLY AFTER the user confirms the context is sufficient and explicitly selects a template, Agent may proceed to Step 1 to generate the plan file. Do NOT auto-generate the plan without user consent.

#### 1. Read Project Contract

// turbo

Read `Projects/[project-name]/project.md` to extract:

- **Goal** (from YAML frontmatter `goal`)
- **Deadline** (from `deadline`)
- **Definition of Done** (from `dod` list)
- **Dependencies** (from body section)
- **Key Decisions** (from body section)

#### 1.5. Load Project Context (default for create, or if --project)

// turbo

> 🛡️ **Rationale:** Project-specific rules and skills impose hard constraints on plan design.
> Loading them early (before architecture/phase design) prevents creating plans that
> violate project governance or miss available tooling.

From Step 1, check `project.md` for `agent` map:

1. **IF `agent.rules: true`** (or legacy `has_rules: true`):
   - Read `Projects/[project-name]/.agents/rules.md` (project rules index, ~5-10 lines).
   - **MANDATORY DETAIL READ:** For each triggered rule matching the plan scope, the Agent MUST explicitly use the `view_file` tool to read the full content of the rule file (e.g., `.agents/rules/maintenance.md`). Do NOT guess or hallucinate the rule content based on the filename.
   - Store as **hard constraints** for Phase definition (Step 6) and Risk section (Step 9).
   - Example: If `maintenance.md` specifies "Tarball release requires tool.manifest.yml version bump", the plan MUST explicitly include a task to update `tool.manifest.yml`.

2. **IF `agent.skills: true`**:
   - Read `Projects/[project-name]/.agents/skills.md` (project skills index, ~5-10 lines).
   - **MANDATORY DETAIL READ:** If any skill trigger matches the plan scope, the Agent MUST explicitly use `view_file` to read the full `SKILL.md` content before proceeding.
   - If relevant skills are found and read → note them in the plan as **available tooling** (e.g., Harness Guards).

3. **Store results** as constraints that flow into:
   - Step 5 (Design Architecture) — respect existing patterns
   - Step 6 (Define Phases) — include governance tasks per rule requirements
   - Step 9 (Risk & Mitigations) — flag missing guards

> **Convention:** This step replaces the previous Phase D (Rules Constraints) in Step 2.7.
> By loading project context immediately after the contract, plan design is governance-aware from the start.

#### 2. Read Backlog

// turbo

Read `Projects/[project-name]/artifacts/tasks/backlog.md` to understand:

- Feature scope (High / Medium / Low priority items)
- Known bugs or constraints
- Total item count and status distribution

#### 2.5. Check for Brainstorm Context (if exists)

// turbo

> ⚗️ **Token optimization:** One `ls` + conditional read. Strategy priority logic (D7).

> 🔍 **Memory-Assisted Planning:** Before reading brainstorm files, Agent SHOULD use `memory_search` to find past decisions, friction points, and architectural patterns related to the plan scope. This prevents re-debating resolved issues.

```bash
ls -t Projects/[project-name]/artifacts/para-decisions/brainstorm-*.md 2>/dev/null | head -1
```

- **If brainstorm file found:**
  1. Extract brainstorm date from filename (YYYY-MM-DD)
  2. Check `strategy` field from `project.md` (already loaded in Step 1):
     - **IF strategy has value:**
       - Resolve path (IF starts with `@` → cross-project: `Projects/{ecosystem}/...`, ELSE → local)
       - Extract strategy "Last reviewed" date
       - **IF brainstorm.date <= strategy.lastReviewed** → Skip brainstorm
         (already distilled into strategy — D7)
       - **IF brainstorm.date > strategy.lastReviewed** → Read BOTH
         (brainstorm has info not yet distilled into strategy)
     - **IF strategy is null/empty** → Read brainstorm (current behavior)
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

#### 2.7. Scan Project Knowledge Base

// turbo

> 🛡️ **Token Optimization:** Index-first approach. Read index files only (~80 lines), then selectively read max 3 detail files based on relevance match. Total budget: ~300-600 tokens.

**Phase A: Internal Docs Index** (ALWAYS check)

Check if `Projects/[project-name]/docs/README.md` exists:

- **If exists** → Read it (~80 lines). Extract:
  - Architecture docs list → store as "existing architecture" (for Step 5)
  - RFCs list with status → store as "active constraints" (for Step 6, 9)
  - Guides list → store as "established patterns" (avoid re-inventing)
- **If not exists** → Skip. Zero overhead.

**Phase B: Active RFCs** (read IF Phase A found RFCs)

From Phase A, identify RFCs with status `✅ Implemented` or `📋 Planned`:

- Read max 2 most relevant RFCs (based on plan scope match).
- Extract **constraints** and **decisions** that affect plan design.
- Store as hard constraints for Phase definition (Step 6) and Risk section (Step 9).

> **Rule:** Never design a plan phase that contradicts an Implemented RFC.

**Phase C: Architecture Overview** (read IF Phase A found architecture docs)

From Phase A, if architecture docs exist:

- Read the **overview** doc only (1 file, ~60 lines).
- Extract: component diagram, tech stack, data flow.
- Use as baseline for Step 5 (Design Architecture) — **EXTEND, don't replace**.

> **Convention:** This step ensures `/plan` builds on existing project knowledge rather than re-designing from scratch. It bridges `docs/` (captures decisions) with `/plan` (applies them).

**Phase D: Rules Constraints** (Promoted to Step 1.5)

> **v1.8.6:** Project rules and skills loading has been promoted to **Step 1.5** (Load Project Context).
> This ensures governance constraints are available BEFORE architecture design, not buried deep in the knowledge scan.
>
> **D1 (Workspace Rules)** is still handled by Step 0 (Pre-flight).
> **D2 (Project Rules)** and **D3 (Project Skills)** are now handled by Step 1.5.
>
> **Rule:** Both workspace and project rules/skills can impose constraints on plan phases. Always check before designing.

**Phase E: Knowledge Items** (platform-injected — no file I/O)

From platform-injected KI summaries, cross-reference with plan scope:
- `pitfall` KIs → add to Risks section (Step 9)
- `playbook` KIs → reference in relevant Phase tasks
- Note matched KI slugs for traceability (`Based on KI: [slug]`)

#### 2.8. Plan Type Selection

> 🛡️ **Generic:** Applies to ALL projects, not just ecosystem.

**Auto-detect context (v1.6.3 — field-gated):**

1. Check `roadmap` field from `project.md` (already loaded in Step 1):
   - **IF has value** → Resolve path (IF starts with `@` → cross-project: `Projects/{ecosystem}/...`, ELSE → local). Roadmap exists, suggest Detail Plan for next phase.
   - **IF null/empty** → Both options open

2. Check `strategy` field from `project.md`:
   - **IF has value** → Note: "Strategy docs found, plan should align"
   - **IF null/empty** → Skip

3. Count active plans:
   ```bash
   ls Projects/[project-name]/artifacts/plans/*.md 2>/dev/null \
     | grep -v roadmap | grep -v done | wc -l
   ```

**Present choice:**

```text
📐 What type of plan to create?

1. 🗺️ Roadmap — Phases + timeline overview (multi-version/feature index)
2. 📋 Detail Plan — Tasks + implementation details (1 version/feature)
3. 📋 Detail Plan (Hardened) — Detail Plan + Mandatory Audit + Selective TDD
4. ⚡ Session Plan (DSP) — Dynamic lightweight session plan for fast coding (vibecode) with auto-commits

Context:
  📄 Strategy: [exists: N files / none]
  🗺️ Roadmap: [exists: X phases, Y done / none]
  📋 Detail Plans: [N active, M archived]
```

> ⛔ **CHECKPOINT (Interactive Pause):** Agent MUST STOP here and ask the user which plan type to create. Do NOT guess or proceed to generating the plan until the user responds.

**If roadmap exists → smart suggest:**

```text
📐 Roadmap: roadmap-[name].md (N phases)

Next phase without detail plan:
→ Phase [N]: [Name] (vX.Y) — 📋 Planned

Create Detail Plan for Phase [N]? (y/n)
```

> **Roadmap naming convention:** `roadmap-[scope].md`. Never `active_plan`.
> **Detail plan:** Standard `*.md` (non-roadmap). IS `active_plan`, archived to `plans/done/` when done.

#### 2.9. Strategy & Roadmap Context Loading

// turbo

> ⚗️ **Only runs when Step 2.8 chose "Detail Plan" AND roadmap/strategy fields have values.**

**A. Roadmap phase context** (if `roadmap` field has value):

1. Resolve roadmap path from `roadmap` field (IF starts with `@` → cross-project: `Projects/{ecosystem}/...`, ELSE → local)
2. Extract target phase row:
   ```bash
   grep -A 2 "Phase [N]" [resolved-roadmap-path]
   ```
3. Store: phase scope, version, deliverables → baseline for Step 6

**B. Strategy context** (if `strategy` field has value AND not loaded by Step 2.5):

1. Resolve strategy path from `strategy` field
2. Extract strategy link from roadmap header:
   ```bash
   grep "Strategy:" [resolved-roadmap-path]
   ```
3. IF link found → grep summary (~2 lines header + blockquote)
4. Store as design constraint for Step 5 (Architecture)

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

> 🛡️ **Architecture Baseline:** If Step 2.7 Phase C found an existing architecture overview, **EXTEND** it rather than creating from scratch. Reference the existing diagram and add new components/flows as needed. If no existing architecture was found, create a new one.

> 🛡️ **Progressive Disclosure:** You may selectively read specific files in `Resources/ai-agents/kernel/` (e.g., `invariants.md`, `heuristics.md`) if you need strict architectural guidance for this step. Do NOT scan the entire kernel directory at once.

#### 6. Define Phases

Break the project into sequential phases. Each phase should:

- Have a clear **goal** (one sentence)
- Include a **task table** with numbered items
- Estimate **time** (in days or hours)
- List **output/deliverables**

**Phase structure rules:**

| Rule | Description |
|:--|:--|
| Phase 0 | Always "Setup & Infrastructure" — scaffold, init dependencies |
| Phase N | Core feature phases — build in dependency order |
| Final Phase | Always "Polish & Extras" — error handling, README, CI/CD |

> **Guideline:** Aim for 4-7 phases total. Each phase should be completable in 1-2 days.

#### 7. Map Code Reuse

If reference projects were analyzed (Step 3), create a **Code Reuse Table**:

```markdown
## 📦 Code Reuse from [reference-project]

| Source File | Function/Module | Action | Notes |
|:--|:--|:--|:--|
| `path/to/file.ts` | `functionName()` | Port directly | Proven, no changes needed |
| `path/to/other.ts` | `ClassName` | Modify | Remove KV dependency |
```

#### 8. Cross-reference Backlog

Map each High/Medium priority backlog item to the phase where it will be implemented:

```markdown
## 🔗 Backlog → Phase Mapping

| Backlog Item | Priority | Phase |
|:--|:--|:--|
| GitHub Storage Engine | High | Phase 1 |
| Admin Dashboard | High | Phase 3 |
```

#### 8.5. Rule Impact Check

// turbo

> ⚠️ **Auto-detect:** If any plan task modifies files in `rules/` or `kernel/`, add sync tasks automatically.

1. Scan all phase tasks — check if any target file matches:
   - `templates/common/agents/rules/*.md`
   - `kernel/invariants.md`, `kernel/heuristics.md`, `kernel/schema/*.md`
   - `rfcs/*.md` that reference rules

2. **If rule changes detected:**
   a. Auto-add to final phase: "Sync workspace `.agents/rules/` from repo templates"
   b. Check if project has `.agents/rules.md` (rules index) — if yes, add task:
   "Update `.agents/rules.md` trigger conditions to match new rule constraints"
   c. Display warning:

   ```
   ⚠️  This plan modifies governance rules.
       Final phase will include:
       - Workspace rule sync (.agents/rules/)
       - Rules index update (if .agents/rules.md exists)
   ```

3. **If no rule changes** → Skip silently.

> **Why:** Rule changes in repo templates must be synced to workspace. Missing this step causes agent behavior drift.

#### 8.6. Determine Target Version

1. Read `VERSION` file (if exists in repo) or `project.md` to get current project version.
2. Determine if the plan warrants a PATCH, MINOR, or MAJOR bump based on scope.
   - If purely R&D, speculative, or undefined scope: use wildcard (e.g., `1.x.x`).
   - Otherwise, calculate exact target version to include in the plan's filename logic (Step 9).

#### 9. Write Plan File

// turbo

Save the plan to:

```
Projects/[project-name]/artifacts/plans/[plan-name].md
```

**Naming convention:**
- **Detail Plan (Versioned):** `v[ver]-[YYYY-MM-DD]-[topic].md` (e.g., `v1.7.11-2026-04-09-optimization.md`)
- **Detail Plan (Wildcard/R&D):** `v[X.X.X]-[YYYY-MM-DD]-[topic].md` (e.g., `v1.x.x-2026-04-09-version-bumper.md`)
- **Roadmap:** `roadmap-[topic].md` (e.g., `roadmap-core.md`)
- **Session Plan (DSP):** `v[ver]-[YYYY-MM-DD]-session-[topic].md` (e.g., `v1.x.x-2026-05-23-session-refactor-auth.md`)

**Plan document structure:**

> 🧩 **Sidecar Skill:** Load the plan template from the `plan` skill:
> - **Detail Plan** → read `.agents/skills/plan/references/detail-plan.md`
> - **Roadmap** → read `.agents/skills/plan/references/roadmap.md`
>
> Use the template as the document structure. Fill in each section with data gathered from Steps 1-8.

> ⚠️ **Status Gate:** New plans MUST be created with `Status: 📝 Draft` (Except Session Plans, which are created directly with `Status: 🔨 Active`).
> Agent MUST NOT execute any Phase tasks nor modify project files while Status is Draft (except for active Session Plans).
> Status transitions to `🔨 Active` ONLY at Step 10 after explicit user approval.

#### 9.5. Pre-Checklist Context Reload (Staged Drill-down)

// turbo

> 🛡️ **Layer 4 defense (Anti-Token-Decay):** Before writing the final Checklist, force reload context to avoid losing mandatory governance tasks (like Version Bump or Sync) due to context truncation.

**Execute these sub-steps sequentially:**
1. **A. Reload Indices (Soft Dump):** Run the `cat` commands from Step 0 to dump workspace + project Index tables into memory.
2. **B. Drill-down Project Rules:** If Step A triggers any project-specific rules, read them.
3. **C. Drill-down Project Skills:** If Step A triggers any project-specific skills, read them.
4. **D. Run Plan Review Protocols:** Explicitly analyze checklist dependencies from governance files (e.g. `maintenance.md`).
5. **E. Re-read Plan References:** Re-read the brainstorm files loaded in Step 2.5 to ensure the plan structure doesn't contradict past brainstorm decisions.

#### 9.6. Propose Draft Plan

**Protocol:**
1. **Present & Track:** Agent presents the draft plan summary of the newly created plan to the User for review (including phases, timeline, and newly created/modified target files). To satisfy the platform's planning mode consent gate, the Agent writes the markdown link of the actual project plan file (`[plan-name](file:///Projects/[project-name]/artifacts/plans/[plan-name].md)`) into the platform's `brain/implementation_plan.md`, forcing the agent trigger to read the actual project plan rather than the platform's ephemeral file, and syncs the phase tasks into the platform's `brain/task.md`. At this point, the `Post-Draft Audit Gate` checklist in the plan file remains empty (`⬜` and `PENDING`).
   * **Exemption Rule (v1.9.2):** If the plan name represents a macro-level document (contains `roadmap`, `strategy`, `spec`, or `brainstorm`), it is **fully exempted** from Platform Tracker synchronization. In this case, the Agent **MUST NOT** write to or create any `implementation_plan.md` or `task.md` files in the platform's `brain/` folder.
2. **Propose Preliminary Approval & Audit:** Ask the User for initial layout approval and propose running the Review Audit.
   ```
   📐 DRAFT PLAN READY: [plan-name]
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Status: 📝 Draft (Unaudited)
   Phases: [N] | Tasks: [N] | File: [path]

   ❓ Do you approve the preliminary layout of this draft plan? If approved, I will write the plan's markdown link into implementation_plan.md (if not exempted) and run the Review Audit.
      Y → Layout approved, write plan link to platform implementation_plan.md (unless exempted), and run Review Audit (Step 9.7)
      N → Refine the draft based on feedback
   ```
3. **Response:** Only proceed to Step 9.7 if User confirms (Y). If the User provides feedback, modify the draft plan and present again.

#### 9.7. Post-Draft Audit Gate

**Purpose:** Force a comprehensive quality audit of the preliminary approved draft plan before activation.

**Protocol:**

1. **RELOAD:** Reload ALL project rules + skills (full scan):
   ```bash
   # Full project governance reload
   cat Projects/[project-name]/.agents/rules.md 2>/dev/null
   cat Projects/[project-name]/.agents/skills.md 2>/dev/null
   # Read EVERY rule and skill file listed (not just triggered)
   ```
   Focus areas: `maintenance.md`, release checklists, version sync rules.

2. **AUDIT:** Perform an independent quality review of the plan across 5 dimensions:
   - **Logic:** Phase sequence makes sense? No circular dependencies?
   - **Security:** Security controls in place? No hardcoded or leaked tokens?
   - **Governance:** Project maintenance rules satisfied? Version sync points covered?
   - **Completeness:** All target files to be created/modified are accounted for?
   - **Risk Coverage:** High risks mapped to corresponding Harness Guards?

3. **CLASSIFY & INJECT (TDD):** Classify each task in the plan:
   - 🧪 **TDD:** Complex logic changes, algorithms, API endpoints. Inject Red-Green-Refactor cycles and load `.agents/skills/tdd/SKILL.md`.
   - 📝 **Standard:** UI tweaks, documentation, version bumps, changelog. Keep standard task format.

4. **UPDATE FILE:** Write the audit results directly to the plan file. If the template used does not contain the audit section (e.g. standard `detail-plan.md` or `roadmap.md`), the Agent MUST append the `## Post-Draft Audit Gate` section and the `## TDD Task Classification` table at the bottom of the plan file.
   - Update checklist statuses in the `## Post-Draft Audit Gate` table from `⬜` to `✅ Passed`.
   - Update the `## TDD Task Classification` table.
   - Set `Audit Result` from `PENDING` to `PASSED` and increment the review counter by 1.

5. **Report:** Present the detailed audit report to the User and proceed to Step 10 for activation.

#### 10. Complete Plan Creation

Present the plan creation summary and next step options to the User:

```
📐 AUDITED PLAN READY: [plan-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Status: 📝 Draft (Audited & Verified)
Phases: [N] | Timeline: [N] days | Tasks: [N]
File:   artifacts/plans/[plan-name].md

Next Steps:
  A. /plan [project-name] dev   → Activate plan & start execution (auto-sets active_plan)
  B. /vibecode loop             → Sandbox/interactive execution loop
  C. /qa [project-name] plan    → Stress-test plan with Red Team Q&A review
```

> **Note:** `/plan dev` automatically handles activation (sets Status to `🔨 Active`,
> sets `active_plan` in `project.md`, and runs `/backlog sync`). There is no separate
> activation step — the user simply runs dev when ready.

**Cross-project plan storage (v1.6.0+):**

If building a plan for a satellite project AND the plan is stored in the
ecosystem meta-project, note in the summary:

```
📐 This plan is stored in the ecosystem meta-project @{ecosystem}.
   When /plan dev runs, active_plan will be set as:
   active_plan: "@{ecosystem}/plans/[plan-name].md"
```

> Path is relative to `artifacts/`. Remove `active_plan` field when the plan is completed or archived.

**NEW — Roadmap auto-update (v1.6.3 — field-gated):**

After setting `active_plan`, check the `roadmap` field from `project.md`:

1. **IF `roadmap` has value:**
   - Resolve path (IF starts with `@` → cross-project: `Projects/{ecosystem}/...`, ELSE → local)
   - Find phase row matching this detail plan (by name or version)
   - Update: `Detail Plan` column → link to new plan file
   - Update: `Status` column → `🔨 Active`
   - Log: `📐 Roadmap updated: Phase [N] → Active`

2. **IF `roadmap` is null/empty** → Skip

**NEW — Roadmap field lifecycle (v1.6.3):**

When creating a NEW roadmap (Step 2.8 chose "Roadmap"):

1. After saving the roadmap file, set `roadmap` field in `project.md`:
   ```yaml
   roadmap: plans/roadmap-[scope].md
   ```
2. If creating for a satellite from ecosystem, suggest:
   ```yaml
   roadmap: "@{ecosystem}/plans/roadmap-[scope].md"
   ```
3. Log: `📐 roadmap field set in project.md`

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

#### 11.5. Graph Memory Push (CONDITIONAL)

> **Gate:** Only trigger if project has `.beads/graph/` directory.

1. Check graph availability:
   ```bash
   test -d "Projects/[project-name]/.beads/graph" && echo "✅ Graph Memory available" || echo "⏭️ No graph — skip memory push"
   ```

2. **IF graph exists:**
   Push the plan creation summary via MCP `memory_push`:
   - **kind:** `plan-created`
   - **content:** Plan name + phase count + key scope decisions
   - **sessionId:** `YYYY-MM-DD-plan-[topic]`
   - **metadata:** `{ "plan_file": "artifacts/plans/[plan-name].md", "phases": N, "activated": true/false }`

3. **Curate memory:** After pushing, call `memory_curate(projectName)` to consolidate raw memory events into semantic slices.

4. **IF no graph** → Skip silently.

---

## 📋 Action: review

Summarize an existing plan with status updates, using `done.md` for accurate progress tracking.

### Steps

// turbo

1. Read `active_plan` field from `Projects/[project-name]/project.md` to locate the plan file.

**Resolve plan path (v1.6.3):**

Resolve `active_plan` from `project.md` (IF starts with `@` → cross-project: `Projects/{ecosystem}/artifacts/{path}`, ELSE → local: `Projects/[project-name]/artifacts/{value}`).
The resolved path points to the plan file to read.

2. Read `Projects/[project-name]/artifacts/tasks/done.md` to get the list of completed task IDs with dates.
3. Cross-reference `done.md` completed IDs with the plan's **Backlog → Phase Mapping** table.
4. Display summary:

```
📋 PLAN REVIEW: [plan-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
| Phase | Status | Tasks | Source |
|---|---|---|---|
| Phase 0 | ✅ Done | 5/5 | done.md |
| Phase 1 | 🔨 In Progress | 3/5 | backlog |
| Phase 2 | ⏳ Pending | 0/4 | — |
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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

**Step 6.5 — Roadmap Lifecycle (v1.6.3 — field-gated):**

After archiving a completed plan (Step 6):

1. Check `roadmap` field from `project.md`:
2. **IF has value:**
   - Resolve path (IF starts with `@` → cross-project: `Projects/{ecosystem}/...`, ELSE → local)
   a. Update completed phase: `Status` → `✅ Done`
   b. Find next phase with `Status: 📋 Planned` (no detail plan)
   c. **IF next phase found:**
      ```
      📐 ROADMAP: Phase [N] complete!

      Next: Phase [N+1]: [Name] (vX.Y) — no detail plan yet

      💡 Run /plan create to create detail plan for Phase [N+1]?
         Scope (from roadmap): [deliverables list]
      ```
   d. **IF all phases done:**
      ```
      🎉 ROADMAP COMPLETE! All phases done.
         Run /retro for retrospective?
      ```
3. **IF null/empty** → Skip (zero I/O)


---

## ✏️ Action: update

Modify an existing plan (add phases, update status, revise timeline).

### Steps

#### 0.5. Graph Context Pipeline (if --graph)

If the `--graph` flag is provided, execute the same Graph Pipeline (Build → God Nodes → Enrich) as defined in the `create` action to refresh architectural context before modifying the plan.

1. Read `active_plan` from `project.md` to locate the plan file.
2. Ask user what to update:
   - Add/remove/reorder phases
   - Update task status within a phase
   - Revise timeline estimates
   - Add new code reuse discoveries
3. Apply changes and increment the plan version (e.g., `1.0` → `1.1`).
4. Log the update in the current session.

---

## 🚀 Action: dev

Start or continue executing the active plan in the project.

### Steps

1. **Locate Plan:** Read `project.md` to find `active_plan` or search `artifacts/plans/` for the latest plan file.
   - IF the found plan is a Draft (`Status: 📝 Draft`): Automatically update its Status to `🔨 Active`, set `active_plan` in `project.md` to point to it, run `/backlog sync` (if not exempted), and proceed with execution.
     - **Platform Tracker Exemption (v1.9.2):** If the plan name contains `roadmap`, `strategy`, `spec`, or `brainstorm`, skip the creation/sync of platform-level `task.md` or `implementation_plan.md` in the brain folder.
     - **Cross-project (v1.6.0+):** If plan file is in an ecosystem meta-project (`@{ecosystem}/plans/...`), set `active_plan` as a cross-project reference:
       ```yaml
       active_plan: "@{ecosystem}/plans/[plan-name].md"
       ```
     - **Roadmap sync (v1.6.3):** After activation, check `roadmap` field in `project.md`. If set, find the matching phase row and update Status → `🔨 Active` + link to plan file (see Step 10 Roadmap auto-update in create action for details).
   - IF the found plan is already Active (`Status: 🔨 Active`) or does not require activation: Load the plan and proceed.
2. **Load Plan Methodology Skills:** Scan the loaded plan file. Check the `Methodology` or `Required Skill` blockquotes. If the plan specifies a specific methodology (e.g., Strict TDD), or if a flag like `--tdd` is passed, the Agent MUST load the corresponding `.agents/skills/[skill-name]/SKILL.md` into context before executing any code.
3. **Phase Execution:** If `--phase` flag is present (which is default for this action), execute the plan strictly phase by phase.
4. **Task Verification & Checkpoints:** The Agent MUST read and obey inline `⛔ CHECKPOINT` guards. When transitioning phases, the Agent CANNOT move to the next phase unless ALL tasks in the current phase are actually marked as completed `[x]`, OR the user explicitly grants permission to skip the remaining tasks. Do not auto-assume tasks are done.
5. **Execution:** Proceed with performing the coding or related operations defined in the current pending tasks.
6. **Strict TDD & Commit Gate Protocol (MANDATORY):** If the plan employs TDD (Test-Driven Development) methodology or has tasks classified as `🧪 TDD`, the Agent **MUST** strictly follow this execution order before proposing any `git commit` or `git push`:
   a. **Log Evidence:** Run test files using the TDD evidence logger script (`tdd-test.sh`). Confirm that `artifacts/tests/tdd-evidence.log` contains a `status: FAIL` entry before the `status: PASS` entry for the respective test file.
   b. **Checkbox Update:** Check off (`[x]`) the completed tasks in the active plan file and the system `task.md` (skip updating `task.md` if the active plan is a macro document exempted from the Platform Tracker).
   c. **Type Safety:** Run `npx astro check` (or language-equivalent static type analysis) and resolve all type errors (0 Errors).
   d. **Build Test:** Run `npm run build` and ensure the project builds successfully.
   e. **Commit Trigger:** Propose a `git commit` ONLY after steps (a) through (d) are successfully completed. Triggering or proposing a commit without satisfying all these conditions is a workflow violation.

---

## 🏁 Action: end

Finalize the active plan by performing a strict completion audit, syncing backlogs, and archiving.

### Steps

1. **Phase Completion Check:** Verify that all tasks across all phases of the plan are marked as completed `[x]`.
2. **Walkthrough Checklist Check:** Ensure all items in the Walkthrough Completion Gate are checked off.
3. **Backlog Sync & Clean (MANDATORY):** The Agent MUST proactively execute the logic of `/backlog sync` and `/backlog clean` to update the operational authority BEFORE archiving:
   - Append the completed plan and its tasks to `artifacts/tasks/done.md`.
   - Update `artifacts/tasks/backlog.md`: Compress the plan into the `✅ Completed (Archived)` section, remove any mapped Active/Bug IDs from the upper tables, and update the Summary counts.
4. **User Approval:** Present the completion status and ask for explicit approval to transition the plan to `✅ Done` and clear `active_plan` in `project.md`.
5. **Archive (Post-Approval):** AFTER user approval, the Agent MUST:
   a. Change plan `Status` to `✅ Done`.
   b. Move the plan file to `artifacts/plans/done/`.
   c. Remove the `active_plan` field from `project.md`.
   d. Suggest reviewing and updating the project's (or meta-project's) roadmap (if one exists) to reflect the newly completed plan.
6. **Quarantine Test Evidence & TDD Logs:**
   // turbo
   ```bash
   # Archive TDD evidence log (rename with plan version before quarantine)
   # TDD Skill spec: artifacts/tests/tdd-evidence.log → tdd-evidence-<version>.log
   PLAN_VER=$(grep -oE 'v[0-9]+\.[0-9]+[0-9.]*' "$(ls artifacts/plans/done/*-$(date +%Y-%m-%d)*.md 2>/dev/null | head -1)" 2>/dev/null | head -1)
   if [[ -f "artifacts/tests/tdd-evidence.log" ]]; then
     SUFFIX="${PLAN_VER:-$(date +%Y-%m-%d)}"
     mv "artifacts/tests/tdd-evidence.log" "artifacts/tests/tdd-evidence-${SUFFIX}.log"
     echo "📋 TDD evidence archived as tdd-evidence-${SUFFIX}.log"
   fi
   # Also check .beads/ (legacy location — some projects wrote here by mistake)
   if [[ -f ".beads/tdd-evidence.log" ]]; then
     mkdir -p artifacts/tests
     mv ".beads/tdd-evidence.log" "artifacts/tests/tdd-evidence-${PLAN_VER:-legacy}.log"
     echo "📋 Migrated .beads/tdd-evidence.log → artifacts/tests/"
   fi
   # Quarantine all test artifacts to tmp/
   if [[ -d "artifacts/tests" ]]; then mkdir -p artifacts/tests/tmp; for f in artifacts/tests/*; do if [[ -e "$f" && "$f" != "artifacts/tests/tmp" ]]; then mv "$f" "artifacts/tests/tmp/$(basename "$f")" 2>/dev/null || true; fi; done; echo "🧹 Test artifacts quarantined"; fi
   ```
7. **Graph Build, Enrichment & Insight Curation (MANDATORY INSIGHT GATE):**
   If the project uses `para-graph`, execute `/para-graph build [project-name]` to update the structural Code-Knowledge Graph with the new features, and use `graph_enrich` to update semantic summaries of modified nodes.
   
   **Insight Curation (Replacing general /learn recommendation):**
   At the end of the plan, the Agent MUST actively review the session history to identify any newly resolved bugs, lessons, or gotchas.
   - Propose 1-2 structured insights (lessons, gotchas, or risks) to the user.
   - Offer the following options to store the insights:
     1. **Store to Code-Graph:** Use MCP `insight_push` to save directly to the project's knowledge database (if `para-graph` is available).
     2. **Store to Local Files (Fallback):** Append to `.beads/seeds.md` or create a new file in `docs/researches/` (if `para-graph` is not available).
     3. **Ignore:** If no new reusable insights were discovered.

---

## 📁 Artifacts Convention

| Path | Purpose |
|:--|:--|
| `artifacts/plans/` | Active plans + `done/` (archived plans + completion reviews) |
| `artifacts/tasks/` | Backlog and task tracking |
| `artifacts/walkthroughs/` | Task verification checklists (from `/verify`) |

> Plans are **living documents** — update them as the project evolves. Use the `update` action to keep them in sync with actual progress.

## Roadmap Plan Template

> 🧩 **Sidecar Skill:** Load from `.agents/skills/plan/references/roadmap.md`
> See the `plan` skill for the full template and naming conventions.

## Output Checklist

> 🧩 **Sidecar Skill:** Load from `.agents/skills/plan/SKILL.md` — "Output Checklist" section.

## Related

- `/brainstorm` — Explore ideas before planning (auto-discovered by Step 2.5)
- `/docs` — Strategy documents feed planning context (Step 2.9)
- `/new-project` — Initialize project (run before `/plan`)
- `/backlog` — Manage features and bugs
- `/open` — Start session with context loading
- `/verify` — Verify task completion against plan
- `/release` — Pre-release quality gate
