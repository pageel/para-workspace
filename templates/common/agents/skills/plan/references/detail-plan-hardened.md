# Detail Plan Hardened Template

> **Naming:** `v[ver/X.X.X]-[YYYY-MM-DD]-[topic].md` (e.g., `v1.7.0-2026-04-09-optimization.md`)
> `[ver]` = the version this plan **serves** (not necessarily a version that will be bumped).
> Plans that don't produce a version bump still use the current/target version for grouping.
> **Lifecycle:** Active → archived to `plans/done/` when completed.
> **Role:** IS `active_plan` in `project.md`.
> **Methodology:** Hardened — Detail Plan structure + Mandatory Audit Gate + Selective TDD injection.

````markdown
# [Plan Title]: [project-name]

> **Version:** 1.0 | **Created:** YYYY-MM-DD
> **Status:** 📝 Draft
> **Baseline:** [Reference project or context, if any]
> **Methodology:** Hardened (Detail + Selective TDD)

<!-- ⚠️ STATUS GATE: Agent MUST NOT execute any Phase tasks while Status is "📝 Draft".
     Agent may only execute when Status is "🔨 Active".
     Status lifecycle: 📝 Draft → 🔨 Active → ✅ Done
     - 📝 Draft:   Plan is being written/reviewed. No file modifications allowed.
     - 🔨 Active:  User has approved the plan. Execution permitted.
     - ✅ Done:    All phases completed. Ready for archive to plans/done/.
     Transition from Draft → Active requires explicit user approval.
     Transition from Active → Done requires Walkthrough completion + explicit user approval. -->

> ⛔ **STATUS GATE:** Agent MUST NOT execute Phase tasks while Status = "📝 Draft".
> Lifecycle: 📝 Draft → 🔨 Active → ✅ Done. Transition requires explicit user approval.

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

---

## Post-Draft Audit Gate

<!-- ⚠️ HARDENED PLAN: Agent MUST complete this audit BEFORE activating the plan.
     This gate is triggered automatically after Step 9 (plan creation).
     Agent MUST NOT skip this section. -->

> ⛔ **MANDATORY AUDIT:** After writing the Draft, Agent MUST:
> 1. Announce to User that Draft is ready and audit is required.
> 2. Wait for User confirmation before proceeding.
> 3. Reload ALL project rules + skills (full scan, not just triggered).
> 4. Execute the audit checklist below.
> 5. Classify tasks for TDD injection.
> 6. Present final plan with audit results to User.

### Audit Checklist

| Dimension | Status | Notes |
| :-- | :-- | :-- |
| **Logic Review** — Phase sequence makes sense, no circular dependencies | ⬜ | |
| **Security Review** — Context guards, no exposed secrets, published-only data | ⬜ | |
| **Governance Compliance** — Project maintenance rules, version sync, release process | ⬜ | |
| **Completeness** — All target files accounted for, no orphan steps | ⬜ | |
| **Risk Coverage** — Every risk in Risks table has a corresponding Harness Guard | ⬜ | |
| **Brainstorm Sync** — Plan matches the target files, risks, and TDD proposals from brainstorm | ⬜ | |
| **Brainstorm & Spec Scope Check** — Propose if any task/phase needs separate brainstorm or spec to ensure safety | ⬜ | |

### Project Governance Reload

> Agent MUST list which rules and skills were reloaded during audit:

```markdown
Reloaded Rules:
  - [ ] [rule-name]: [key finding or "compliant"]

Reloaded Skills:
  - [ ] [skill-name]: [key finding or "compliant"]
```

### Audit Result

> Agent writes a brief summary of findings here after completing the audit.

**Result:** [PASS / PASS WITH NOTES / FAIL — requires plan revision]
**Notes:** [Brief audit findings, if any]

---

## TDD Task Classification

<!-- ⚠️ HARDENED PLAN: Agent MUST classify ALL implementation tasks BEFORE activation.
     Tasks classified as 🧪 TDD will have Red-Green-Refactor cycles injected.
     Tasks classified as 📝 Standard follow normal Detail Plan flow. -->

> ⛔ **MANDATORY:** Agent MUST present this classification table to User for approval
> BEFORE injecting TDD cycles into the plan.
>
> **Note:** Task classification is initialized directly from the proposal in `decision.md` §4 (Test Strategy & TDD Recommendations).

### Classification Criteria

| Type | Icon | When to apply |
| :-- | :-- | :-- |
| 🧪 TDD | `🧪` | Logic changes, algorithms, data transforms, bug fixes, security-critical code, API changes |
| 📝 Standard | `📝` | Documentation, config changes, version bumps, changelog, formatting, git operations |

### Task Classification Table

| Task ID | Task Name | Type | Rationale |
| :-- | :-- | :-- | :-- |
| [1.1] | [Task description] | [🧪 / 📝] | [Why this classification - mapping back to brainstorm proposal] |

### TDD Strategy & Testing Rules

> ⛔ **MANDATORY:** If any tasks are classified as 🧪 TDD, Agent MUST define the testing strategy here.

*   **Test Location:** [Where should test files be saved? (e.g., `tests/`, `__tests__/`, next to source files)]
*   **Test Runner / Command:** [How to run the tests? (e.g., `npm run test`, `npx vitest run path/to/file`)]
*   **Testing Rules & Naming:** [Any specific rules for naming test files or blocks? (e.g., `*.test.ts`, `describe` blocks structure)]
*   **Cleanup Policy:** [Should mock files or temporary test data be cleaned up after testing?]
*   **Required Skills:** [Agent MUST load `.agents/skills/tdd/SKILL.md` before executing TDD tasks]

---

## Implementation Phases

### Phase 0. Setup & Infrastructure ⚙️ `Difficulty: 🟢 Low`

<!-- ⚠️ MANDATORY: Agent MUST read project.md and reload .agents/rules.md + .agents/skills.md BEFORE executing any tasks here -->

> ⛔ **MANDATORY:** Re-read `project.md`, `.agents/rules.md`, `.agents/skills.md` BEFORE executing.

#### Implementation Plan

[Setup testing environments, dependencies, infrastructure. No production logic.]

0.1 🤖 **[Step 1 name]** — [Detail: file path, line number, operation]
0.2 🤖 **[Step 2 name]** — [Detail: ...]



#### Task List

<!-- Task format for brainstorm or spec (if proposed during audit/planning):
     - [ ] X.Y 🧠 **Brainstorm Needed:** [Topic] (Run /brainstorm or /spec workflow to clarify design before implementation)
     - [ ] X.Y 📝 **Spec Required:** [Feature] (Run /spec workflow to define API / Schema before writing production code) -->

- [ ] 0.0 🤖 Graph Knowledge Preparation (if para-graph enabled)
- [ ] 0.1 🤖 [Task description]
- [ ] 0.2 🤖 [Task description]
- [ ] 0.3 🤖 **TDD Repo Before Snapshot** (run `git status --ignored --porcelain` & `git log -n 1 --oneline` and save to `artifacts/tests/tdd-repo-before-[date].log`)
- [ ] ⛔ CHECKPOINT: Agent MUST verify ALL tasks in Phase 0 are checked [x] AND get explicit User approval before proceeding to Phase 1.

---

### Phase 1. [Core Feature] ⚙️ `Difficulty: [🟢 Low | 🟡 Medium | 🔴 High]`

<!-- ⚠️ MANDATORY: Agent MUST reload .agents/rules.md + .agents/skills.md BEFORE modifying files or executing git commands -->

> ⛔ **MANDATORY:** Re-read `.agents/rules.md` + `.agents/skills.md` BEFORE modifying files.

> 🧪 **Testing Requirement:** If this Phase contains tasks classified as 🧪 TDD,
> Agent MUST load `.agents/skills/tdd/SKILL.md` and follow Red-Green-Refactor cycle.

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

#### 🧪 TDD Task Block (for tasks classified as TDD)

> Insert this block for each task classified as 🧪 TDD in the Classification Table.

**TDD Cycle for Task [X.Y]:**

- [ ] 1. 🔴 **RED: Write Failing Test**
  ```typescript
  // Test code targeting specific behavior
  ```
- [ ] 2. 🔴 **Verify FAIL**
  ```bash
  bash .agents/skills/tdd/scripts/tdd-test.sh [test-command] [test-file]
  ```
  - Expected: FAIL due to missing code/logic. Evidence auto-logged to `artifacts/tests/tdd-evidence.log`.
- [ ] 3. 🟢 **GREEN: Write Minimal Code**
  - Implement minimum required logic to pass the test above (No extra features).
- [ ] 4. 🟢 **Verify PASS**
  ```bash
  bash .agents/skills/tdd/scripts/tdd-test.sh [test-command] [test-file]
  ```
  - Expected: PASS without warnings. Evidence auto-logged.
- [ ] 5. 🤖 **TDD Gate:** Recheck `tdd-evidence.log`
  - [ ] Log shows 🔴 FAIL (Logic error, not syntax)
  - [ ] Log shows 🟢 PASS (Green state)
  - [ ] (If missing FAIL) 🛑 Revert code, rewrite RED test.

#### 📝 Standard Task Block (for tasks classified as Standard)

> Use normal Detail Plan task format (Implementation Plan + Task List checkbox).

#### Task List

- [ ] 1.1 [🧪/📝] [Task description]
- [ ] 1.2 [🧪/📝] [Task description]
- [ ] 🤖 **Compare Git Drift:** Compare current repo state with `artifacts/tests/tdd-repo-before-[date].log` to identify newly generated untracked or ignored files in this phase.
- [ ] ⛔ CHECKPOINT: Re-read `rules/vcs.md`. Confirm scope = local-only. Commit #N/M — DO NOT push.
- [ ] 1.N-1 🤖 **Pre-commit Gate:** Run project's linter/compiler/tests and resolve any problems.
- [ ] 🤖 **Compare Git Drift (Pre-commit):** Compare final changes against snapshot before commit to prevent committing junk.
- [ ] 1.N 👤 **Git Checkpoint:** Commit changes with message `[feat/fix/chore]([scope]): [short description]`.
- [ ] ⛔ CHECKPOINT: Agent verification pass -> Verify that all previous tasks are successfully marked as done [x] in both this plan file and task.md (State Synchronization) -> Present the git diff & test results to the User (clearly stating: "I have completed [action, log files]. In addition, I have verified and marked all previous tasks as done. I propose that you approve running the commit command...") -> Receive explicit user approval before committing and proceeding to the next Phase.
- [ ] 1.N+1 🤖 **Graph & Insight Update (if --graph):** Run `graph_enrich` for modified/new class/function nodes; and consider saving gotchas/lessons/decisions to the graph via `insight_push` (especially for feat or fix bug tasks).
- [ ] ⛔ CHECKPOINT: Re-read `rules/vcs.md`. Agent MUST ask User for confirmation BEFORE pushing.
- [ ] 1.N+2 👤 Git push origin main.

---

### Phase 2. [Next Feature / Refactoring] ⚙️ `Difficulty: [🟢 Low | 🟡 Medium | 🔴 High]`

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

- [ ] All Task List items from Phase 0 → Phase N are [x] (including git commit + push).
- [ ] Post-Draft Audit Gate completed with PASS result.
- [ ] All 🧪 TDD tasks have evidence in `artifacts/tests/tdd-evidence.log`.
- [ ] All tests pass with pristine output (no errors/warnings).
- [ ] **TDD Drift Verification & Cleanup:** Compare current repo state with `git status --ignored --porcelain` snapshot in `tdd-repo-before-[date].log` to identify newly generated untracked or ignored files. Agent MUST present the list to User and ask whether to delete them (if junk) or commit them (if missed in plan) before proceeding with cleanup.
- [ ] [Project-specific checks: build pass, docs updated, governance rules...]
- [ ] ⛔ CHECKPOINT (Walkthrough Completion): Agent MUST verify all above Walkthrough items are ticked [x] BEFORE proposing Status transition.
- [ ] ⛔ CHECKPOINT (C7 Status Transition): Agent MUST NOT change Status to "✅ Done" or clear `active_plan` without explicit user approval. Agent presents the completed Walkthrough checklist → User verifies → User approves transition. Only AFTER user confirms → Agent sets Status and clears `active_plan`.
- [ ] User approved Done transition.
- [ ] Clear `active_plan` in `project.md`.

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
| ⛔ No            | Each FEAT/BUG gets its own commit. TDD tasks use `tdd(scope):` prefix |
| ⛔ Never         | Push — ALWAYS separate from commits    |

> **Audit trail:** TDD compliance is verified via `artifacts/tests/tdd-evidence.log` (auto-generated by
> `tdd-test.sh`), not via separate git commits. Agent MUST pass TDD Gate before committing.

### Review & Audit Tracking

> Counter table to assess plan health. Update after each working session.
> **Note:** Initial audit count starts at 1 (from Post-Draft Audit Gate).

| Criteria                                          | Count | Last reviewed |
| :------------------------------------------------ | :---- | :------------ |
| Logic review (Phase sequence, Task coverage)      | 1     | [audit-date]  |
| Security review (context guards, published-only)  | 1     | [audit-date]  |
| Checklist review (completeness, no missing files) | 1     | [audit-date]  |
| Build/Test pass                                   | 0     | —             |
| Project governance compliance (see below)         | 1     | [audit-date]  |

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

### Suggested Next Steps

- **Option A (Activate & Execute):** Run `/plan [project-name] dev` (or `/plan dev`) to begin automatic execution of the phases.
- **Option B (Sandbox Run):** Run `/vibecode loop` to execute tasks in a sandboxed/interactive loop.
- **Option C (Stress-test Plan):** Run `/qa [project-name] plan` (or `/qa plan`) to trigger a Red Team Q&A review before execution.

```

```
