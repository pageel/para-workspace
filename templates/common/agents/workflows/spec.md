---
description: Write a structured specification before coding — surface assumptions, define boundaries, get human approval
source: user
---

# /spec [project-name] [action] [--graph]

> **Workspace Version:** 1.9.3 (Architecture-Inherited)

Write a structured specification before any implementation begins. The spec is the shared source of truth between Agent and Developer — it defines what we're building, why, and how we'll know it's done.

**Core principle:** Code without a spec is guessing. A 15-minute spec prevents hours of rework.

## Actions

| Action | Description |
|:--|:--|
| `create` | Create a new spec for a feature, project, or significant change (default) |
| `review` | Review and validate an existing spec against current state |
| `update` | Update an existing spec when scope or decisions change |
| `reverse` | Generate a spec backward from existing code analyzing the codebase structures |

## Options

| Option | Description |
|:--|:--|
| `--graph` | Run Graph Pipeline (Build → Query → Impact Analysis) before spec writing to anchor scope and boundaries in the real codebase |

---

## 📋 Action: create

### When to Use

- Starting a new project or feature
- Requirements are ambiguous or incomplete
- The change touches multiple files or modules
- The task would take more than 30 minutes to implement

**When NOT to use:** Single-line fixes, typo corrections, or changes where requirements are unambiguous and self-contained. Use `/brainstorm` instead when the problem space is unclear and you need to explore options first.

### The Gated Workflow

Spec-driven development has two phases. Agent MUST NOT advance to the next phase until the current one is validated by the user.

```
SPECIFY ──→ USER APPROVAL ──→ SAVE SPEC
```

> 🛡️ **Gate Rule:** Agent presents the spec draft and WAITS for user approval before saving. Skipping this gate leads to premature decisions and rework.

### Steps

#### 0. Pre-flight

// turbo

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

> ⚠️ **Proactive Context & Trigger Check:** BEFORE writing any spec, YOU MUST:
> 1. Read the project's own domain skill at `Projects/[project-name]/.agents/skills/[project-name]/SKILL.md` (if it exists) to understand project-specific rules.
> 2. Read the Global CSA Skill at `.agents/skills/csa/SKILL.md` to ensure design decisions match G1, G2, G3 micro-anchoring guidelines.
> 3. Read specific skills related to the project's tech stack (detect stack via `project.md` tags/goal, `package.json`, or config files, and load relevant skills such as `wrangler`, `cloudflare`, `firebase-firestore`, etc., from `.agents/skills/` or plugins).
> 4. Scan workspace index triggers based on the intended target of your discussion.

```bash
# Context & Trigger Load (Anti-Cognitive-Bypass)
echo ""
echo "> ⚠️ Loading Project Skill: Projects/[project-name]/.agents/skills/[project-name]/SKILL.md"
cat Projects/[project-name]/.agents/skills/[project-name]/SKILL.md 2>/dev/null || echo "No project specific skill found."
echo ""
echo "> ⚠️ Loading Global CSA Skill: .agents/skills/csa/SKILL.md"
cat .agents/skills/csa/SKILL.md 2>/dev/null || echo "No global CSA skill found."
echo ""
echo "> ⚠️ Detecting and loading tech stack skills..."
# Load wrangler/cloudflare skill if tags match wrangler/cloudflare
grep -q -i -E "wrangler|cloudflare|worker" Projects/[project-name]/project.md 2>/dev/null && cat .agents/skills/wrangler/SKILL.md 2>/dev/null || true
# Load firebase/firestore skill if tags match firebase
grep -q -i -E "firebase|firestore" Projects/[project-name]/project.md 2>/dev/null && cat ~/.gemini/config/plugins/firebase/skills/firebase_firestore/SKILL.md 2>/dev/null || true
echo ""
echo "> ⚠️ Proactive Trigger Scan: .agents/rules.md & .agents/skills.md"
cat .agents/rules.md 2>/dev/null | head -n 30
cat .agents/skills.md 2>/dev/null | head -n 30
```

#### 0.5. Graph Context Pipeline (if --graph)

// turbo

If the `--graph` flag is provided, execute the graph intelligence pipeline BEFORE gathering context:

1. **Build Graph:** Run `/para-graph build [project-name]` to ensure graph data is up-to-date.
2. **Identify Target Nodes:** Use MCP tools `graph_query` and `graph_god_nodes` to locate architectural nodes and hot spots related to the spec topic.
3. **Deep Context:** Use MCP tools `graph_context_bundle` and `graph_edges` on the identified nodes to gather callers, callees, dependencies, and structural relationships.
4. **Impact Analysis:** Use `graph_impact_analysis` on relevant nodes to map upstream/downstream dependencies — essential for defining accurate scope boundaries and risk assessment.
5. **Inject Context:** Keep this graph intelligence in memory to ground the spec in the actual codebase structure, preventing scope creep and ensuring boundary definitions are architecturally sound.

#### 1. Context Gathering (Phase: SPECIFY)

// turbo

Read the project context to understand what we're building within:

> 🔍 **Memory-Assisted Spec:** Before gathering context, Agent SHOULD use `memory_search` to find past specs, decisions, and architectural patterns related to the spec topic. This prevents re-specifying resolved constraints.
> 🧠 **Brainstorm Inheritance:** If a brainstorm file related to the topic exists, the Agent MUST load and inherit its decisions.
> 📐 **System Design Inheritance:** The Agent MUST scan for existing system designs in `Projects/[project-name]/artifacts/sysdesigns/` and inherit the active system design structure (API payloads, database DDL, environment vars).

```bash
# Project contract
cat Projects/[project-name]/project.md

# Existing specs (avoid duplicates)
ls -t Projects/[project-name]/artifacts/specs/*.md 2>/dev/null | head -5

# Active System Designs
ls -t Projects/[project-name]/artifacts/sysdesigns/sysdesign-*.md 2>/dev/null | head -3

# Backlog context
grep -E "ToDo|In Progress|\- \[ \]" Projects/[project-name]/artifacts/tasks/backlog.md | head -10
```

#### 2. Surface Assumptions

> ⚠️ **MUST NOT skip this step.** This is the most critical part of the spec workflow.
> Implicit assumptions are the #1 source of rework. Surface them NOW, not during implementation.

Before writing any spec content, Agent MUST list what it is assuming:

```
ASSUMPTIONS I'M MAKING:
1. [Assumption about tech stack, based on project.md]
2. [Assumption about target users]
3. [Assumption about inherited system design from sysdesign-*.md]
4. [Assumption about scope boundaries]
→ Correct me now or I'll proceed with these.
```

**Rules:**
- Pull assumptions from `project.md` context (tech stack, dependencies) and the inherited `sysdesign-*.md`
- Flag any ambiguous requirement with a concrete default
- WAIT for user confirmation before proceeding

#### 3. Write Spec Document

> 🧩 **Sidecar Skill:** Load the spec template from `.agents/skills/spec/`.
> Read `SKILL.md` for the Router Table, then load `references/templates/feature-spec.md`.
> 
> 🛡️ **CSA Anchoring Standard:** When writing success criteria, database tables, or functional requirements, you MUST follow the Micro-Anchoring guidelines (G1, G2, G3) of the `csa` skill loaded during Pre-flight. Ensure each testable requirement has an inline HTML anchor (e.g., `<span id="csa-..."></span>`). DO NOT use aggregate blanket anchors.

Write the spec covering the core areas, inheriting from the system design:
- **System Design Inheritance:**
  - Inherit base folder structure (do not re-specify project topology).
  - Inherit API schemas and communication contracts (the spec only specifies feature-specific endpoint changes, error handlers, and business payloads).
  - Inherit database schemas (the spec only lists table migrations or new columns, inheriting the main ERD and indexes).

Spec core areas:
1. **Objective** — What we're building, why, who benefits, what success looks like
2. **Feature Details** — Specific UI changes, frontend logic, and functional behaviour
3. **Database Migrations** — List only new tables/columns or migrations needed for this feature
4. **API Changes** — List only new endpoints or payload field changes needed
5. **Testing Strategy** — Unit tests, integration tests, mock endpoints
6. **Boundaries** — Three-tier: Always do / Ask first / Never do

**Success Criteria** — Translate vague requirements into testable conditions.

#### 3.5. CSA Spec Self-Audit (MANDATORY)

> ⛔ **HARNESS GUARD:** Agent MUST complete this step BEFORE presenting the spec to the user for review. Skipping this step is a process violation.

After writing the spec with CSA anchors, Agent MUST perform a **self-audit** to verify anchor quality:

1. **Scan all anchors:** List every `<span id="csa-...">` in the spec draft.
2. **G1 Check (One-to-One):** For each anchor, verify it maps to exactly ONE design decision or functional requirement. If an H2/H3 heading contains a table with N distinct items, verify N separate anchors exist.
3. **G2 Check (Reverse Validation):** For each anchor that will bind to a code entity, ask: *"If I change this code file, would the ENTIRE content described by this anchor be affected?"* If only partially → flag for decomposition.
4. **G3 Check (No Blanket Anchors):** Verify NO anchor is placed at an aggregate-level heading (H1/H2) covering multiple unrelated concepts. Anchors must be at H3/H4 or inline.
5. **Present CSA Audit Summary** to user as part of the spec review:

```
🔍 CSA SELF-AUDIT:
   Total anchors: [N]
   G1 (One-to-One): [N/N] pass
   G2 (Reverse Validation): [N/N] pass
   G3 (No Blanket): [N/N] pass
   Violations found: [N] — [list fixes applied or proposed]
```

6. **Fix violations** before presenting to user. If a fix changes the spec structure significantly, re-run the audit.

#### 4. User Review & Save Gate

Present the complete spec AND CSA audit summary to the user and WAIT for approval.

```
📋 SPEC DRAFT: [feature-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Assumptions: [N] listed — all confirmed?
Core Areas:  6/6 covered
CSA Anchors: [N] placed (G1/G2/G3 verified ✅)
Open Questions: [N]

❓ Review the spec above.
   A → Approve and save spec (proceed to plan /plan)
   R → Request changes (tell me what to fix)
   B → Run /brainstorm on open questions/ambiguous areas
```

Agent MUST NOT proceed to saving until user explicitly approves (A).

#### 5. Save Spec File & Platform Pointer Mirroring

Save the spec file:
```bash
mkdir -p Projects/[project-name]/artifacts/specs
```
**Naming convention:** `spec-[YYYY-MM-DD]-[topic-slug].md`

##### 5.1. Update Specification Index (README.md)
Agent **MUST** register the newly created or updated spec file into the project's specification directory index at `Projects/[project-name]/artifacts/specs/README.md`:
1. If the index `README.md` does not exist, initialize it by copying the reference template located at `.agents/skills/spec/references/templates/specs-index-readme.md`.
2. Append or update the spec file entry in the registry table. Mark the CSA Status as `✅ CSA-ified` if the spec file contains CSA span anchors, or `⚠️ Uncurated` if it lacks anchors. In the `CSA Anchors` column, record only the count of spec anchors (e.g., `4 anchors`), do not list individual IDs.

##### 5.2. Platform Tracking Pointer
Once saved, the Agent **MUST overwrite and truncate** the platform files (`brain/implementation_plan.md`, `brain/task.md`, and `brain/walkthrough.md`), leaving **ONLY** the direct markdown link to the project spec file (`[spec-name](file:///Projects/[project-name]/artifacts/specs/spec-[YYYY-MM-DD]-[topic-slug].md)`) and the specific `TRACKER (link-only)` file guard comment at the bottom:
- In `brain/implementation_plan.md`:
  ```markdown
  [spec-name](file:///Projects/[project-name]/artifacts/specs/spec-[YYYY-MM-DD]-[topic-slug].md)

  <!-- ⚠️ FILE GUARD — Do not write any other content here. Focus only on reading and updating the linked project spec above. -->
  ```
- In `brain/task.md`:
  ```markdown
  - [ ] Spec is defined in [spec-name](file:///Projects/[project-name]/artifacts/specs/spec-[YYYY-MM-DD]-[topic-slug].md)

  <!-- ⚠️ FILE GUARD — Do not write any other content here. Focus only on reading and updating the linked project spec above. -->
  ```
- In `brain/walkthrough.md`:
  ```markdown
  Spec details are defined in [spec-name](file:///Projects/[project-name]/artifacts/specs/spec-[YYYY-MM-DD]-[topic-slug].md)

  <!-- ⚠️ FILE GUARD — Do not write any other content here. Focus only on reading and updating the linked project spec above. -->
  ```

#### 6. Choose Next Action

```
📋 SPEC COMPLETE: [feature-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Saved: artifacts/specs/spec-[YYYY-MM-DD]-[topic].md
   Status: Approved
   CSA: [N] anchors verified (G1/G2/G3 ✅ in Step 3.5)

💡 NEXT STEPS:
   A. 📐 /plan [project-name] — Create formal implementation plan (Agent MUST ask user to choose template: detail-plan.md, detail-plan-tdd.md, or detail-plan-hardened.md) (RECOMMENDED)
   B. 📥 /backlog [project-name] — Add tasks to backlog directly
   C. 🌀 /brainstorm [project-name] — Explore open questions or ambiguous areas before planning
   D. 📄 Keep as reference — Save but don't act yet

❓ Which option?
```

**Option A (Recommended):** Recommend the user to run `/plan [project-name]`. **Important:** The Agent MUST NOT auto-select or write the plan file. The Agent MUST ask the user to explicitly choose a plan template (e.g., `detail-plan.md`, `detail-plan-tdd.md`, `detail-plan-hardened.md`) in the chat and wait for confirmation.
**Option B:** Recommend using `/backlog` to manage simple changes.
**Option C:** Recommend `/brainstorm` when the spec has unresolved Open Questions or ambiguous areas that need deeper exploration before committing to a plan.
**Option D:** Keep as a static reference document.

> **Note:** CSA Audit is no longer an option here — it was already performed as a mandatory gate in Step 3.5 before user review.

#### 7. Log in Session

// turbo

Append to `Projects/[project-name]/sessions/YYYY-MM-DD.md`:

```markdown
### Spec Created

- **Spec**: `artifacts/specs/spec-[YYYY-MM-DD]-[topic].md`
- **Topic**: [feature name]
- **Status**: Approved
- **Next**: [chosen action from Step 6]
```

#### 7.5. Graph Memory Push (CONDITIONAL)

> **Gate:** Only trigger if project has `.beads/graph/` directory.

1. Check graph availability:
   ```bash
   test -d "Projects/[project-name]/.beads/graph" && echo "✅ Graph Memory available" || echo "⏭️ No graph — skip memory push"
   ```

2. **IF graph exists:**
   Push the spec creation summary via MCP `memory_push`:
   - **kind:** `spec-created`
   - **content:** Spec topic + key assumptions + boundary decisions
   - **sessionId:** `YYYY-MM-DD-spec-[topic]`
   - **metadata:** `{ "spec_file": "artifacts/specs/spec-[date]-[topic].md" }`

3. **Curate memory:** After pushing, call `memory_curate(projectName)` to consolidate raw memory events.

---

## 📋 Action: review

Review an existing spec against the current state of the project.

### Steps

1. List available specs:
   ```bash
   ls -t Projects/[project-name]/artifacts/specs/*.md 2>/dev/null
   ```

2. Read the selected spec file.

3. Cross-reference with current codebase state.

4. Display review:

```
📋 SPEC REVIEW: [spec-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
| Section | Status |
|:--|:--|
| Assumptions | [N/M] still valid |
| Success Criteria | [N/M] met |
| Boundaries | [any violations?] |
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Recommendation: [Continue | Update spec | Spec complete]
```

---

## ✏️ Action: update

Update an existing spec when scope or decisions change.

### Steps

1. Read the existing spec file.
2. Ask what changed:
   - Scope added/removed?
   - Assumptions invalidated?
   - New constraints?
3. Update the spec document.
4. Mark `Last Updated` with today's date.
5. Log the update in the session.

---

## 📋 Action: reverse

Generate a specification backward from an existing codebase by analyzing its structural components.

### When to Use

- Retrofitting an existing codebase that doesn't have spec coverage.
- Restructuring a module and needing to document its baseline design first.

### Steps

#### 0. Pre-flight
Perform pre-flight context checks. Load the CSA skill and relevant stack skills.

#### 0.5 Graph Context Pipeline (MANDATORY)
Run the graph pipeline to map the codebase. This is NOT optional for the reverse flow.
1. Build graph: `/para-graph build [project-name]`
2. Identify hot spots and target nodes using `graph_god_nodes` and `graph_query`.

#### 1. Context Gathering
Query details of the target module using `graph_context_bundle` and check for any overlap with existing specs.

#### 1.5 Entity Triage (MANDATORY)
1. Call `graph_spec_candidates` on the module/scope to obtain the spec candidates list.
2. Present the triage blueprint (Category A, B, C candidates) to the user.
3. ⛔ CHECKPOINT: Present the blueprint to the user in the chat and stop to await approval. Do not proceed to spec writing until the user confirms the candidates list.

#### 2. Surface Assumptions
Extract assumptions based on the existing code structure and design conventions.

#### 3. Write Spec Document
Write the spec file using the `reverse-spec.md` template. Populate the `## Reverse Adoption Context` section.

#### 3.5 CSA Self-Audit
Verify all anchors against the G1/G2/G3 rules.

#### 4. User Review & Save Gate
Present the spec and wait for approval.

#### 5. Save Spec File & Platform Pointer Mirroring
Save the spec into `Projects/[project-name]/artifacts/specs/archive/` (historical archive convention). Overwrite platform pointers with direct links.

#### 6. Choose Next Action
Suggest `/plan` or `/backlog` sync.

---

## 📁 Artifacts Convention

| Path | Purpose |
|:--|:--|
| `artifacts/specs/` | Active spec documents |
| `artifacts/specs/done/` | Completed/archived specs |
| `artifacts/sysdesigns/` | System designs / architecture blueprints |
| `artifacts/plans/` | Implementation plans (generated from specs via `/plan`) |
| `artifacts/tasks/` | Backlog and task tracking |

## Related

- `/brainstorm` — Explore problem space before specifying (upstream)
- `/sysdesign` — Design system architecture before features (upstream)
- `/plan` — Create formal implementation plan from spec (downstream)
- `/backlog` — Add spec tasks to project backlog
- `/verify` — Verify implementation against spec success criteria
