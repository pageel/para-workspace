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
> 2. Scan workspace index triggers based on the intended target of your discussion.

```bash
# Context & Trigger Load (Anti-Cognitive-Bypass)
echo ""
echo "> ⚠️ Loading Project Skill: Projects/[project-name]/.agents/skills/[project-name]/SKILL.md"
cat Projects/[project-name]/.agents/skills/[project-name]/SKILL.md 2>/dev/null || echo "No project specific skill found."
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

#### 4. User Review & Save Gate

Present the complete spec to the user and WAIT for approval.

```
📋 SPEC DRAFT: [feature-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Assumptions: [N] listed — all confirmed?
Core Areas:  6/6 covered
Open Questions: [N]

❓ Review the spec above.
   A → Approve and save spec (proceed to plan /plan)
   R → Request changes (tell me what to fix)
   B → Run /brainstorm on open questions/ambiguous areas
```

Agent MUST NOT proceed to saving until user explicitly approves (A).

#### 5. Save Spec File

// turbo

Save the spec to:

```bash
mkdir -p Projects/[project-name]/artifacts/specs
```

**Naming convention:** `spec-[YYYY-MM-DD]-[topic-slug].md`

#### 6. Choose Next Action

```
📋 SPEC COMPLETE: [feature-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Saved: artifacts/specs/spec-[YYYY-MM-DD]-[topic].md
   Status: Approved

💡 NEXT STEPS:
   A. 📐 /plan [project-name] — Create formal implementation plan from this spec (RECOMMENDED)
   B. 📥 /backlog [project-name] — Add tasks to backlog directly
   C. 📄 Keep as reference — Save but don't act yet

❓ Which option?
```

**Option A (Recommended):** Instruct the user to run `/plan [project-name]`.
**Option B:** Recommend using `/backlog` to manage simple changes.

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
