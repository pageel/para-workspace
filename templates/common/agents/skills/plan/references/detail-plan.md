# Detail Plan Template

> **Naming:** `v[ver/X.X.X]-[YYYY-MM-DD]-[topic].md` (e.g., `v1.7.0-2026-04-09-optimization.md`)
> `[ver]` = the version this plan **serves** (not necessarily a version that will be bumped).
> Plans that don't produce a version bump still use the current/target version for grouping.
> **Lifecycle:** Active → archived to `plans/done/` when completed.
> **Role:** IS `active_plan` in `project.md`.

````markdown
# [Plan Title]: [project-name]

> **Version:** 1.0 | **Created:** YYYY-MM-DD
> **Status:** 📝 Draft
> **Baseline:** [Reference project or context, if any]

<!-- ⚠️ STATUS GATE: Agent MUST NOT execute any Phase tasks while Status is "📝 Draft".
     Agent may only execute when Status is "🔨 Active".
     Status lifecycle: 📝 Draft → 🔨 Active → ✅ Done
     - 📝 Draft:   Plan is being written/reviewed. No project source file modifications allowed. Writing the project plan's markdown link into the platform's implementation_plan.md (forcing the agent to read the project plan) and running review audits ARE allowed.
     - 🔨 Active:  User has approved the plan. Execution permitted.
     - ✅ Done:    All phases completed. Ready for archive to plans/done/.
     Transition from Draft → Active requires explicit user approval.
     Transition from Active → Done requires Walkthrough completion + explicit user approval. -->

> ⛔ **STATUS GATE:** Agent MUST NOT execute Phase tasks while Status = "📝 Draft".
> Lifecycle: 📝 Draft → 🔨 Active → ✅ Done. Transition requires explicit user approval. Writing the project plan's markdown link into the platform's implementation_plan.md is permitted during Draft.

---

## References

> Brainstorm, research, predecessor plans.

| #   | File                    | Role          |
| :-- | :---------------------- | :------------ |
| B1  | [brainstorm-file](path) | [Description] |
| R1  | [research-file](path)   | [Description] |

## Brainstorm Sync & Heritage

> **Pre-requisite:** Before drafting this plan, Agent MUST read the related brainstorm decision file listed in B1.
>
> **Target Files & Blast Radius:** (Inherited from `decision.md` §2)
> **Testing Strategy & Mocking:** (Inherited from `decision.md` §4)

## Context Files & Indices Loaded

> ⛔ **MANDATORY CONTEXT BINDING:** Before executing this plan, Agent MUST read/reload all listed files to ensure full context and prevent workflow drift.

| Scope | File / Index | Purpose | Path |
| :--- | :--- | :--- | :--- |
| Workspace | `.agents/rules.md` | Workspace-level rules index (Trigger scan) | [rules.md](file:///absolute/path/to/workspace/.agents/rules.md) |
| Workspace | `.agents/skills.md` | Workspace-level skills index (Trigger scan) | [skills.md](file:///absolute/path/to/workspace/.agents/skills.md) |
| Project | `project.md` | Project Contract (Version, status, roadmap tracker) | [project.md](file:///absolute/path/to/project/project.md) |
| Project | `.agents/rules.md` | Project-level rules index (if exists) | [rules.md](file:///absolute/path/to/project/.agents/rules.md) |
| Project | `.agents/skills.md` | Project-level skills index (if exists) | [skills.md](file:///absolute/path/to/project/.agents/skills.md) |
| Specific | [Triggered Rules/Skills] | List of specifically triggered rules/skills for this plan | (e.g., `agent-behavior.md`, `tool-routing.md`, `vcs.md`) |
| MCP / Tools| [MCP Server / Tool Schema] | Loaded MCP schemas to support tasks | (e.g., `para-graph` schemas) |

## Architecture Overview & Execution Logic

[Component diagram + Tech stack table]

**Execution Logic Map:**

> ASCII flowchart showing Phase sequence, Guards, and Dependencies.
> Helps verify logic, security, and context coverage before execution.

## Implementation Phases

### Phase 0. Setup & Infrastructure ⚙️ `Difficulty: 🟢 Low`

<!-- ⚠️ MANDATORY: Agent MUST read project.md and reload .agents/rules.md + .agents/skills.md BEFORE executing any tasks here -->

> ⛔ **MANDATORY:** Re-read `project.md`, `.agents/rules.md`, `.agents/skills.md` BEFORE executing.

#### Implementation Plan

[Technical blueprint — specific file paths, line numbers, commands.
User reviews this artifact before Agent takes action.
Number steps as `X.Y` (X = Phase, Y = step).
Each step should specify: target file, exact operation, source reference if applicable.
Prefix each step with an Execution Ownership icon (see legend below).]

0.1 🤖 **[Step 1 name]** — [Detail: file path, line number, operation]
0.2 🤖 **[Step 2 name]** — [Detail: ...]



#### Task List

[Progress tracking checklist — Agent ticks items when completed.
1:N relationship with Implementation Plan — one plan step may spawn multiple tasks.
Example: step 1.1 in Plan produces task 1.1a (EN) and 1.1b (VI).
Carry the Execution Ownership icon from the Implementation Plan.]

<!-- Task format for brainstorm or spec (if proposed during audit/planning):
     - [ ] X.Y 🧠 **Brainstorm Needed:** [Topic] (Run /brainstorm or /spec workflow to clarify design before implementation)
     - [ ] X.Y 📝 **Spec Required:** [Feature] (Run /spec workflow to define API / Schema before writing production code) -->

[ ] 0.0 🤖 Graph Knowledge Preparation (if para-graph enabled)
[ ] 0.1 🤖 [Task description]
[ ] 0.2 🤖 [Task description]
- [ ] ⛔ CHECKPOINT: Agent MUST verify ALL tasks in Phase 0 are checked [x] AND get explicit User approval before proceeding to Phase 1.

---

### Phase 1. [Core Feature] ⚙️ `Difficulty: [🟢 Low | 🟡 Medium | 🔴 High]`

<!-- ⚠️ MANDATORY: Agent MUST reload .agents/rules.md + .agents/skills.md BEFORE modifying files or executing git commands -->

> ⛔ **MANDATORY:** Re-read `.agents/rules.md` + `.agents/skills.md` BEFORE modifying files.

> 🧪 **Testing Requirement:** If this Phase involves writing or executing tests, Agent MUST explicitly load and apply `.agents/skills/tdd/SKILL.md` (TDD Governance) before running test commands.

<!-- ⚠️ HARNESS GUARD (Phase 1 Risk): [Derived from Risks & Mitigations table. Leave empty if no risk mapped to this Phase.] -->

#### Implementation Plan

[Goal in 1-2 sentences.]

**Files:**
- Create: `exact/path/to/new_file.ts` (if applicable)
- Modify: `exact/path/to/existing_file.ts` (with line ranges if known)

**Graph Impact (if para-graph enabled):**
- God Nodes affected: [List of God nodes]
- Blast Radius: [Impact analysis/callers]
- Enrichment: [Nodes needing semantic enrichment]

1.1 🤖 **[Step name]** — [Detail: file path, line number, operation, source reference if applicable.]
1.2 👤 **[Step name]** — [Detail: destructive/external operation, Agent proposes → User approves.]

1.N-1 🤖 **Pre-commit Gate** — Run project's linter/compiler (e.g., `npm run lint`, `tsc`, `cargo check`) and resolve any type/lint problems before commit.
1.N 👤 **Git checkpoint Phase 1 — Commit**

```bash
git add [scope]
git commit -m "[conventional commit message]"
```
````

1.N+1 👤 **Git push** (only at last Phase or when remote sync is needed)

```bash
git push origin main
```

> **Execution Ownership Legend:**
> 🤖 = Agent auto-run (`SafeToAutoRun: true`) — safe, read-only, or non-destructive operations
> 👤 = User approval required (`SafeToAutoRun: false`) — destructive, external, or state-mutating operations
>
> **Heuristic:** Default to 👤 for: git ops, npm install/prune, file deletion, external API calls (gh, curl), deploy commands.
> Default to 🤖 for: build, test, lint, grep, view_file, dry-run verification.

#### Task List

[ ] 1.1 🤖 [Specific task — e.g. EN file]
[ ] 1.1b 🤖 [Specific task — e.g. VI file]
[ ] 1.2 👤 [Task requiring user approval]
[ ] ⛔ CHECKPOINT: Re-read `rules/vcs.md`. Confirm scope = local-only. Commit #N/M — DO NOT push.
[ ] 1.N-1 🤖 **Pre-commit Gate:** Run project's linter/compiler/tests (e.g., `npm run lint`, `npm test`) and resolve any problems. (If running tests, MUST use TDD skill).
[ ] 1.N 👤 **Git Checkpoint:** Commit changes with message `[feat/fix/chore]([scope]): [short description]`.
- [ ] ⛔ CHECKPOINT: Agent verification pass -> Verify that all previous tasks are successfully marked as done [x] in both this plan file and task.md (State Synchronization) -> Present the git diff & test results to the User (clearly stating: "I have completed [action, log files]. In addition, I have verified and marked all previous tasks as done. I propose that you approve running the commit command...") -> Receive explicit user approval before committing and proceeding to the next Phase.
[ ] 1.N+1 🤖 **Graph & Insight Update (if --graph):** Run `graph_enrich` for modified/new class/function nodes; and consider saving gotchas/lessons/decisions to the graph via `insight_push` (especially for feat or fix bug tasks).
[ ] ⛔ CHECKPOINT: Re-read `rules/vcs.md`. Agent MUST ask User for confirmation BEFORE pushing.
[ ] 1.N+2 👤 Git push origin main.


---

### Phase 2. [Next Feature] ⚙️ `Difficulty: [🟢 Low | 🟡 Medium | 🔴 High]`

[Repeat structure: MANDATORY + HARNESS GUARD + Implementation Plan + Task List + Git checkpoint]

> 💡 **Model Hint (conditional):** If this phase is `Difficulty: 🟢 Low` (documentation, formatting, changelog),
> add this hint: _"Consider switching to a lighter model (🟢 Gemini Flash, Claude Haiku) to save costs."_

> **Difficulty Rating Legend:**
> 🟢 Low = Documentation, formatting, config changes, version bumps — minimal reasoning needed
> 🟡 Medium = Code changes with clear patterns, refactoring, test writing — moderate reasoning
> 🔴 High = Architecture design, complex algorithms, security-critical code — deep reasoning required

---

## Backlog → Phase Mapping

| Backlog Item | Priority | Phase   |
| :----------- | :------- | :------ |
| [Item ID]    | 🔴 High  | Phase 1 |

> 💡 **[Optional] Complex & Meta-Project Add-ons:**
> If this plan is for an **Architecture Refactor** or a **Meta-Project (like PARA Workspace)**, insert:
>
> - **Execution Order**: Explicit dependency chain of tasks.
> - **Impact Analysis**: Blast radius across systems/workflows.
> - **Version Decision**: Justification for version bump level.

## Walkthrough (Completion Gate)

> Final verification checklist — only tick when ALL Phase Task Lists are complete.
> Equivalent to the Walkthrough artifact in Antigravity Planning mode.

[ ] All Task List items from Phase 0 → Phase N are [x] (including git commit + push).
[ ] [Project-specific checks: build pass, docs updated, governance rules...]
[ ] ⛔ CHECKPOINT (Walkthrough Completion): Agent MUST verify all above Walkthrough items are ticked [x] BEFORE proposing Status transition.
[ ] ⛔ CHECKPOINT (C7 Status Transition): Agent MUST NOT change Status to "✅ Done" or clear `active_plan` without explicit user approval. Agent presents the completed Walkthrough checklist → User verifies → User approves transition. Only AFTER user confirms → Agent sets Status and clears `active_plan`.
[ ] User approved Done transition.
[ ] Clear `active_plan` in `project.md`.

### Git Operation Summary

> Total plan: [N] git commits (local) + [M] git push (remote).
> Guards are inserted inline within Task Lists — agent encounters HARNESS GUARD immediately before each git operation.

| #   | Operation    | Phase      | Scope     | Guard                                |
| :-- | :----------- | :--------- | :-------- | :----------------------------------- |
| 1   | `git commit` | 1.N        | 🟢 Local  | HARNESS GUARD (VCS — Commit #1/N)    |
| N   | `git push`   | [last].N+1 | 🔴 Remote | HARNESS GUARD (VCS — Push Remote) 🛑 |

### Risks & Mitigations

> Risks serve as a source to reinforce guardrails at each Phase.
> When a new risk is discovered during execution → add it here → update the
> `<!-- ⚠️ MANDATORY -->` guard of the related Phase accordingly.

| Risk               | Mitigation            | Harness (related Phase) |
| :----------------- | :-------------------- | :---------------------- |
| [Risk description] | [Mitigation strategy] | [Phase N guard]         |

### Commit Consolidation Policy

| Squash allowed?  | Condition                              |
| :--------------- | :------------------------------------- |
| ⛔ No            | Each FEAT/BUG gets its own commit      |
| ⛔ Never         | Push — ALWAYS separate from commits    |

### Review & Audit Tracking

> Counter table to assess plan health. Update after each working session.

| Criteria                                          | Count | Last reviewed |
| :------------------------------------------------ | :---- | :------------ |
| Logic review (Phase sequence, Task coverage)      | 0     | —             |
| Security review (context guards, published-only)  | 0     | —             |
| Checklist review (completeness, no missing files) | 0     | —             |
| Build/Test pass                                   | 0     | —             |
| Project governance compliance (see below)         | 0     | —             |

#### Project Governance Checklist

> ⛔ **MANDATORY — Auto-generated at plan creation time.**
> Agent MUST scan project `.agents/rules.md` and `.agents/skills.md` indices
> and generate checklist items for each triggered rule/skill.
> This section is EMPTY if the project has no `agent.rules` / `agent.skills`.
>
> **Template — replace with actual items from project indices:**

```markdown
IF project has agent.rules: true OR agent.skills: true:

  Scan project .agents/rules.md → for each rule with matching trigger:
    [ ] [rule-name]: [key requirement from rule] (e.g., "maintenance.md: version sync across package.json + tool.manifest.yml")

  Scan project .agents/skills.md → for each skill with matching trigger:
    [ ] [skill-name]: [key requirement from skill] (e.g., "release: tarball includes dist/ + templates/ + tool.manifest.yml + package.json")

ELSE:
  (No project-specific governance — standard checklist only)
```

> **Why this matters:** Session v0.8.5 missed `tool.manifest.yml` version bump and `--version` flag
> because Review & Audit had no project-specific checks. This section prevents that class of error.

### Suggested Next Steps

- **Option A (Activate & Execute):** Run `/plan [project-name] dev` (or `/plan dev`) to begin automatic execution of the phases.
- **Option B (Sandbox Run):** Run `/vibecode loop` to execute tasks in a sandboxed/interactive loop.
- **Option C (Stress-test Plan):** Run `/qa [project-name] plan` (or `/qa plan`) to trigger a Red Team Q&A review before execution.

```

```
