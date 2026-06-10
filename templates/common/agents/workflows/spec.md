---
description: Write a structured specification before coding — surface assumptions, define boundaries, get human approval
source: user
---

# /spec [project-name] [action] [--graph]

> **Workspace Version:** 1.7.15

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

## 📝 Action: create

### When to Use

- Starting a new project or feature
- Requirements are ambiguous or incomplete
- The change touches multiple files or modules
- An architectural decision needs to be made
- The task would take more than 30 minutes to implement

**When NOT to use:** Single-line fixes, typo corrections, or changes where requirements are unambiguous and self-contained. Use `/brainstorm` instead when the problem space is unclear and you need to explore options first.

### The Gated Workflow

Spec-driven development has four phases. Agent MUST NOT advance to the next phase until the current one is validated by the user.

```
SPECIFY ──→ PLAN ──→ TASKS ──→ IMPLEMENT
   │          │        │          │
   ▼          ▼        ▼          ▼
 Human      Human    Human      Human
 reviews    reviews  reviews    reviews
```

> 🛡️ **Gate Rule:** Each phase produces a concrete output. Agent presents output and WAITS for user approval before advancing. Skipping a gate leads to premature decisions and rework.

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
> 🧠 **Brainstorm Inheritance:** If a brainstorm file related to the topic exists (checked via `ls` below), the Agent MUST load and inherit its decisions, using them to pre-populate Rationale and Architecture sections.

```bash
# Project contract
cat Projects/[project-name]/project.md

# Existing specs (avoid duplicates)
ls -t Projects/[project-name]/artifacts/specs/*.md 2>/dev/null | head -5

# Backlog context
grep -E "ToDo|In Progress|\- \[ \]" Projects/[project-name]/artifacts/tasks/backlog.md | head -10

# Previous brainstorms (may contain decisions)
ls -t Projects/[project-name]/artifacts/para-decisions/brainstorm-*.md 2>/dev/null | head -3
```

#### 2. Surface Assumptions

> ⚠️ **MUST NOT skip this step.** This is the most critical part of the spec workflow.
> Implicit assumptions are the #1 source of rework. Surface them NOW, not during implementation.

Before writing any spec content, Agent MUST list what it is assuming:

```
ASSUMPTIONS I'M MAKING:
1. [Assumption about tech stack, based on project.md]
2. [Assumption about target users]
3. [Assumption about data model or storage]
4. [Assumption about deployment target]
5. [Assumption about scope boundaries]
→ Correct me now or I'll proceed with these.
```

**Rules:**
- Pull assumptions from `project.md` context (tech stack, dependencies)
- Identify implicit requirements the user hasn't stated
- Flag any ambiguous requirement with a concrete default
- **Brainstorm Trigger:** If the user rejects core assumptions or demands complex architecture clarification, the Agent SHOULD propose switching to the `/brainstorm` workflow to explore alternatives.
- WAIT for user confirmation before proceeding

#### 3. Write Spec Document

> 🧩 **Sidecar Skill:** Load the spec template from `.agents/skills/spec/`.
> Read `SKILL.md` for the Router Table, then load `references/templates/feature-spec.md`.

Write the spec covering these **six core areas**:

| # | Area | What to include |
|:--|:--|:--|
| 1 | **Objective** | What we're building, why, who benefits, what success looks like |
| 2 | **Commands** | Full executable commands (build, test, lint, dev) — not just tool names |
| 3 | **Project Structure** | Where source code lives, where tests go, where docs belong |
| 4 | **Code Style** | One real code snippet showing the style beats 3 paragraphs describing it |
| 5 | **Testing Strategy** | Framework, test location, coverage, which test levels for which concerns |
| 6 | **Boundaries** | Three-tier: Always do / Ask first / Never do |

**Additional sections:**
- **Success Criteria** — Specific, testable conditions (reframe vague requirements)
- **Open Questions** — Anything unresolved that needs human input

**Reframing rule:** When receiving vague requirements, translate them into concrete conditions:

```
REQUIREMENT: "Make the dashboard faster"

REFRAMED SUCCESS CRITERIA:
- Dashboard LCP < 2.5s on 4G connection
- Initial data load completes in < 500ms
- No layout shift during load (CLS < 0.1)
→ Are these the right targets?
```

#### 4. User Review — Gate 1 (SPECIFY → PLAN)

Present the complete spec to the user and WAIT.

```
📋 SPEC DRAFT: [feature-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Assumptions: [N] listed — all confirmed?
Core Areas:  6/6 covered
Open Questions: [N]

❓ Review the spec above.
   A → Approve and proceed to Plan phase
   R → Request changes (tell me what to fix)
   Q → Answer open questions first
   B → Run /brainstorm on open questions/ambiguous areas
```

Agent MUST NOT proceed until user explicitly approves (A).

#### 5. Technical Plan (Phase: PLAN)

With the validated spec, generate a technical implementation plan:

1. **Components & Dependencies** — Identify major components and their relationships
2. **Implementation Order** — What must be built first (dependency graph)
3. **Risks & Mitigations** — What could go wrong and how to prevent it
4. **Parallel vs Sequential** — What can be built simultaneously
5. **Verification Checkpoints** — How to validate between phases

> The plan should be reviewable: the user should be able to say "yes, that's the right approach" or "no, change X."

#### 6. User Review — Gate 2 (PLAN → TASKS)

```
📐 PLAN READY: [feature-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Components: [N] | Risks: [N] identified
Order: [dependency summary]

❓ Review the plan above.
   A → Approve and proceed to Task breakdown
   R → Request changes
   B → Run /brainstorm on architecture options (evaluate pros/cons)
```

#### 7. Task Breakdown (Phase: TASKS)

Break the plan into discrete, implementable tasks:

- Each task completable in a single focused session
- Each has explicit acceptance criteria
- Each includes a verification step (test, build, manual check)
- Tasks ordered by dependency, not by importance
- No task should require changing more than ~5 files

**Task format:**

```markdown
- [ ] Task [N]: [Description]
  - Acceptance: [What must be true when done]
  - Verify: [How to confirm — test command, build, manual check]
  - Files: [Which files will be touched]
  - Size: [XS|S|M|L — if L, break down further]
```

**Task sizing:**

| Size | Files | Scope |
|:--|:--|:--|
| XS | 1 | Single function or config change |
| S | 1-2 | One component or endpoint |
| M | 3-5 | One feature slice |
| L | 5-8 | Too large — break it down further |

Add explicit checkpoints after every 2-3 tasks:

```markdown
## Checkpoint: After Tasks 1-3
- [ ] All tests pass
- [ ] Application builds without errors
- [ ] Core flow works end-to-end
- [ ] Review with human before proceeding
```

#### 8. User Review — Gate 3 (TASKS → IMPLEMENT)

```
📋 TASKS READY: [feature-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Tasks: [N] | Checkpoints: [N]
Estimated scope: [summary]

❓ Review the tasks above.
   A → Approve — save spec and begin implementation
   R → Request changes to tasks
```

#### 9. Save Spec File

// turbo

Save the complete spec (all 4 phases) to:

```bash
mkdir -p Projects/[project-name]/artifacts/specs
```

**Naming convention:** `spec-[YYYY-MM-DD]-[topic-slug].md`

The spec file contains all four phase outputs in one document:
1. Spec (assumptions + 6 core areas)
2. Plan (components + order + risks)
3. Tasks (breakdown + checkpoints)
4. Metadata (status, created date, reviewed date)

#### 10. Choose Next Action

```
📋 SPEC COMPLETE: [feature-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Saved: artifacts/specs/spec-[YYYY-MM-DD]-[topic].md
   Status: Approved
   Tasks:  [N] defined | Checkpoints: [N]

💡 NEXT STEPS:
  A. 📐 /plan — Create formal implementation plan from this spec
  B. 📥 /backlog — Add tasks to backlog directly
  C. 🔨 Start implementing — Execute tasks in order
  D. 📄 Keep as reference — Save but don't act yet

❓ Which option?
```

**Option A:** Suggest `/plan [project-name]`. The `/plan` workflow will discover the spec.
**Option B:** Run `/backlog add` for each task from the breakdown.
**Option C:** Begin executing Task 1, following the gated checkpoint model.
**Option D:** Spec is saved. User can return to it later.

#### 11. Log in Session

// turbo

Append to `Projects/[project-name]/sessions/YYYY-MM-DD.md`:

```markdown
### Spec Created

- **Spec**: `artifacts/specs/spec-[YYYY-MM-DD]-[topic].md`
- **Topic**: [feature name]
- **Tasks**: [N] tasks defined
- **Status**: Approved
- **Next**: [chosen action from Step 10]
```

#### 11.5. Graph Memory Push (CONDITIONAL)

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
   - **metadata:** `{ "spec_file": "artifacts/specs/spec-[date]-[topic].md", "tasks": N }`

3. **Curate memory:** After pushing, call `memory_curate(projectName)` to consolidate raw memory events into semantic slices.

4. **IF no graph** → Skip silently.

---

## 📋 Action: review

Review an existing spec against the current state of the project.

### Steps

1. List available specs:
   ```bash
   ls -t Projects/[project-name]/artifacts/specs/*.md 2>/dev/null
   ```

2. Read the selected spec file.

3. Cross-reference with current codebase state:
   - Which tasks are already implemented?
   - Have any assumptions changed?
   - Are success criteria still valid?

4. Display review:

```
📋 SPEC REVIEW: [spec-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
| Section | Status |
|:--|:--|
| Assumptions | [N/M] still valid |
| Tasks | [N/M] completed |
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
   - Timeline changes?
3. Update the spec document.
4. Mark `Last Updated` with today's date.
5. Re-validate affected tasks (add/remove/reorder as needed).
6. Log the update in the session.

> **Living document principle:** The spec belongs in version control alongside the code.
> An outdated spec is still better than no spec. Update it, don't discard it.

---

## 📁 Artifacts Convention

| Path | Purpose |
|:--|:--|
| `artifacts/specs/` | Active spec documents |
| `artifacts/specs/done/` | Completed/archived specs |
| `artifacts/plans/` | Implementation plans (generated from specs via `/plan`) |
| `artifacts/tasks/` | Backlog and task tracking |

## Common Rationalizations

| Rationalization | Reality |
|:--|:--|
| "This is simple, no spec needed" | Simple tasks don't need *long* specs, but they still need acceptance criteria. A two-line spec is fine. |
| "I'll write the spec after I code" | That's documentation, not specification. The spec's value is in forcing clarity *before* code. |
| "The spec will slow us down" | A 15-minute spec prevents hours of rework. |
| "Requirements will change anyway" | That's why the spec is a living document. An outdated spec is still better than no spec. |

## Red Flags

- Starting to write code without any written requirements
- Implementing features not in any spec or task list
- Making architectural decisions without documenting them
- Skipping the spec because "it's obvious what to build"
- Agent proceeding past a gate without user approval

## Related

- `/brainstorm` — Explore problem space before specifying (upstream)
- `/plan` — Create formal implementation plan from spec (downstream)
- `/backlog` — Add spec tasks to project backlog
- `/docs` — Architecture docs may feed spec context
- `/verify` — Verify implementation against spec success criteria
