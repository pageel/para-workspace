# Detail Plan TDD Template

> **Naming:** `v[ver/X.X.X]-[YYYY-MM-DD]-[topic]-tdd.md` (e.g., `v1.7.0-2026-04-09-optimization-tdd.md`)
> **Goal:** Strict Test-Driven Development (TDD) planning, utilizing the Red-Green-Refactor cycle.
> **Role:** Used as an alternative to `detail-plan.md` for projects requiring high reliability and test coverage.

````markdown
# [Plan Title]: [project-name]

> **Version:** 1.0 | **Created:** YYYY-MM-DD
> **Status:** 📝 Draft
> **Baseline:** [Reference project or context, if any]
> **Methodology:** Strict TDD (Red-Green-Refactor)

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

## Architecture & Test Strategy

[Component diagram + Tech stack table]

**Test Strategy & Rules:**

- **Framework:** [e.g., Vitest, Jest]
- **Test Location:** [Where should test files be saved? (e.g., `tests/`, `__tests__/`, next to source files)]
- **Test Runner / Command:** [How to run the tests? (e.g., `npm run test`, `npx vitest run path/to/file`)]
- **Testing Rules & Naming:** [Any specific rules for naming test files or blocks? (e.g., `*.test.ts`, `describe` blocks structure)]
- **Cleanup Policy:** [Should mock files or temporary test data be cleaned up after testing?]
- **Required Skills:** [Agent MUST load `.agents/skills/tdd/SKILL.md` before executing TDD tasks]
  [Describe testing layers: Unit, Integration, E2E. Mention testing frameworks used.]

### Execution Rules & Environment Guards

> ⛔ **MANDATORY NVM PATH GUARD:** Due to the Headless Bash environment, `node` and `npm` are NOT in the default `$PATH`. Agent MUST read the `node_path` value from the workspace root `.para-workspace.yml` and prepend `export PATH="<node_path_value>:$PATH" && ` before running ANY `npm` or `node` command in this plan.

## Context Files & Indices Loaded

> ⛔ **MANDATORY CONTEXT BINDING:** Before executing this plan, Agent MUST read/reload all listed files to ensure full context and prevent workflow drift.

| Scope       | File / Index               | Purpose                                                   | Path                                                              |
| :---------- | :------------------------- | :-------------------------------------------------------- | :---------------------------------------------------------------- |
| Workspace   | `.agents/rules.md`         | Workspace-level rules index (Trigger scan)                | [rules.md](file:///absolute/path/to/workspace/.agents/rules.md)   |
| Workspace   | `.agents/skills.md`        | Workspace-level skills index (Trigger scan)               | [skills.md](file:///absolute/path/to/workspace/.agents/skills.md) |
| Project     | `project.md`               | Project Contract (Version, status, roadmap tracker)       | [project.md](file:///absolute/path/to/project/project.md)         |
| Project     | `.agents/rules.md`         | Project-level rules index (if exists)                     | [rules.md](file:///absolute/path/to/project/.agents/rules.md)     |
| Project     | `.agents/skills.md`        | Project-level skills index (if exists)                    | [skills.md](file:///absolute/path/to/project/.agents/skills.md)   |
| Specific    | [Triggered Rules/Skills]   | List of specifically triggered rules/skills for this plan | (e.g., `agent-behavior.md`, `tool-routing.md`, `vcs.md`)          |
| MCP / Tools | [MCP Server / Tool Schema] | Loaded MCP schemas to support tasks                       | (e.g., `para-graph` schemas)                                      |

## CSA Spec Mapping Table

> 💡 **OPTIONAL FOR CSA PROJECTS:** Map every Spec Anchor ID from the baseline spec file to its corresponding Phase, Task, and Target File.
> This table is verified automatically by the Plan Dev Gate and Post-Draft Audit Gate.

| Spec ID | Phase / Task | Target File | Note / Description |
| :--- | :--- | :--- | :--- |
| `csa-example-id` | Phase 1.1 | `src/example.ts` | Example implementation |

**Execution Logic Map:**

> ASCII flowchart showing Phase sequence, Guards, and Dependencies.

## Implementation Phases (TDD Bite-sized Tasks)

> ⚠️ **TDD IRON LAW:** NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST.
> Each Task must be small and self-contained within a git commit.

### Phase 0. Setup & Infrastructure ⚙️ `Difficulty: 🟢 Low`

<!-- ⚠️ MANDATORY: Agent MUST read project.md and reload .agents/rules.md + .agents/skills.md BEFORE executing any tasks here -->

> ⛔ **MANDATORY:** Re-read `project.md`, `.agents/rules.md`, `.agents/skills.md` BEFORE executing.

#### Implementation Plan

> ⚠️ **SECURITY WARNING:** Before writing any tests, Agent MUST verify or configure proper Mocks for external network requests and databases to prevent accidental mutations of real data during test execution.

[Setup testing environments, test runners, or dependency updates. No production logic.]

0.1 🤖 **Define Test Architecture** — Verify project conventions and update the Test Strategy section above with Location and Execution Command.
0.2 🤖 **Configure Mocks** — Set up global mocks or test environments if needed.

#### Task List

<!-- Task format for brainstorm or spec (if proposed during audit/planning):
     - [ ] X.Y 🧠 **Brainstorm Needed:** [Topic] (Run /brainstorm or /spec workflow to clarify design before implementation)
     - [ ] X.Y 📝 **Spec Required:** [Feature] (Run /spec workflow to define API / Schema before writing production code) -->

- [ ] 0.0 🤖 Graph Knowledge Preparation (if para-graph enabled)
- [ ] 0.1 🤖 [Task description]
- [ ] 0.2 🤖 [Task description]
- [ ] 0.3 🤖 **MCP Project Directory Snapshot** (if para-graph/mcp is available, invoke the `project_snapshot` MCP tool to capture the baseline configuration, rules, and workspace knowledge)
- [ ] 0.4 🤖 **Project Directory Junk Audit** (if para-graph/mcp is available, invoke the `project_snapshot` MCP tool with `auditJunk: true` to check for physical junk files before starting work)
- [ ] 0.5 🤖 **TDD Repo Before Snapshot** (run `git status --ignored --porcelain` & `git log -n 1 --oneline` and save to `artifacts/tests/tdd-repo-before-[date].log`)
- [ ] 0.6 🤖 **Session Context Compaction** (if para-graph/mcp is available, invoke the `project_session_compact` MCP tool to capture and write all rules, skills, and project contract to Vibecode Session KI)
- [ ] ⛔ CHECKPOINT: Agent MUST verify ALL tasks in Phase 0 are checked [x], run the MCP tool `project_session_compact` to update session memory, read the updated `session.md` using `view_file` to reload context, and obtain explicit User approval in the chat to transition to Phase 1.

---

### Phase 1. [Core Feature] ⚙️ `Difficulty: [🟡 Medium | 🔴 High]`

<!-- ⚠️ MANDATORY: Agent MUST reload .agents/rules.md + .agents/skills.md BEFORE modifying files or executing git commands -->

> ⛔ **MANDATORY:** View details of specific rules, skills, agents.md, or project.md in the KI necessary for this phase BEFORE modifying files.

<!-- ⚠️ HARNESS GUARD (Phase 1 Risk): [Derived from Risks & Mitigations table. Leave empty if no risk mapped to this Phase.] -->

#### Task 1.1: [Behavior / Component Name]

**Files:**

- Create: `exact/path/to/new_feature.ts` (if applicable)
- Modify: `exact/path/to/existing_feature.ts` (with line ranges if known)
- Test: `exact/path/to/feature.test.ts`

**Graph Impact (if para-graph enabled):**

- God Nodes affected: [List of God nodes]
- Blast Radius: [Impact analysis/callers]
- Enrichment: [Nodes needing semantic enrichment]

**TDD Cycle:**

- [ ] 1.0 **Pre-flight:** Read TDD Guidelines (skills/tdd/SKILL.md) and CSA Compliance (skills/csa/SKILL.md) to initialize the development cycle.
- [ ] 1. 🔴 **RED: Write Failing Test**
  ```typescript
  // Example code block testing specific behavior
  test("should return correct format", () => {
    // ...
  });
  ```
- [ ] 2. 🔴 **Verify FAIL**
  ```bash
  bash .agents/skills/tdd/scripts/tdd-test.sh npm test exact/path/to/feature.test.ts
  ```

  - Expected: FAIL due to missing code/logic. Evidence auto-logged to `artifacts/tests/tdd-evidence.log`.
- [ ] 3. 🟢 **GREEN: Write Minimal Code**
  - Implement minimum required logic in `feature.ts` to pass the test above (No extra features).
- [ ] 3.5 🤖 📐 **CSA Bind:** Add `// @para-doc [#csa-[anchor-id]]` comment directly above the declaration of the new class/function/endpoint.
- [ ] 4. 🟢 **Verify PASS**
  ```bash
  bash .agents/skills/tdd/scripts/tdd-test.sh npm test exact/path/to/feature.test.ts
  ```

  - Expected: PASS without warnings. Evidence auto-logged.
- [ ] 5. 🤖 **TDD Gate:** Recheck `tdd-evidence.log`
  - [ ] Log shows 🔴 FAIL (Logic error, not syntax)
  - [ ] Log shows 🟢 PASS (Green state)
  - [ ] (If missing FAIL) 🛑 Revert code, rewrite RED test.
- [ ] 5.5 🤖 **Pre-commit Gate:** Run project's linter/compiler (e.g., `npm run lint`) and resolve any type/lint problems.
- [ ] 5.6 🤖 **Pre-commit Physical Snapshot Gate & CSA Compliance Gate (MCP):** If graph/mcp is available, run MCP tools `project_snapshot` (to take a snapshot), `project_diff` (to detect physical drift), and `graph_audit_csa` (with `planScope: "[active-plan-path]"` to verify plan-scoped spec coverage is 100% and bind introduced code entities).
- [ ] 6. 👤 **Git Checkpoint:** Commit changes with message `tdd(feature): [Behavior] — red-green verified`.
- [ ] ⛔ CHECKPOINT: Agent verification pass -> Verify that all previous tasks are successfully marked as done [x] in both this plan file and task.md (State Synchronization) -> Present the git diff & test results to the User (clearly stating: "I have completed [action, log files]. In addition, I have verified and marked all previous tasks as done. I propose that you approve running the commit command...") -> Receive explicit user approval before committing.
- [ ] 🤖 **Graph & Insight Update (if --graph):** Run `graph_enrich` for modified/new class/function nodes; and consider saving gotchas/lessons/decisions to the graph via `insight_push` (especially for feat or fix bug tasks).

#### Task 1.2: [Next Behavior / Component Name]

**Files:**

- Create: `exact/path/to/new_feature.ts` (if applicable)
- Modify: `exact/path/to/existing_feature.ts` (with line ranges if known)
- Test: `exact/path/to/feature.test.ts`

**Graph Impact (if para-graph enabled):**

- God Nodes affected: [List of God nodes]
- Blast Radius: [Impact analysis/callers]
- Enrichment: [Nodes needing semantic enrichment]

**TDD Cycle:**

- [ ] 1. 🔴 **RED: Write Failing Test**
- [ ] 2. 🔴 **Verify FAIL** (`bash .agents/skills/tdd/scripts/tdd-test.sh ...`)
- [ ] 3. 🟢 **GREEN: Write Minimal Code**
- [ ] 4. 🟢 **Verify PASS** (`bash .agents/skills/tdd/scripts/tdd-test.sh ...`)
- [ ] 5. 🤖 **TDD Gate:** Recheck `tdd-evidence.log`
  - [ ] Log shows 🔴 FAIL (Logic error, not syntax)
  - [ ] Log shows 🟢 PASS (Green state)
  - [ ] (If missing FAIL) 🛑 Revert code, rewrite RED test.
- [ ] 5.5 🤖 **Pre-commit Gate:** Run project's linter/compiler (e.g., `npm run lint`) and resolve any type/lint problems.
- [ ] 5.6 🤖 **Pre-commit Physical Snapshot Gate & CSA Compliance Gate (MCP):** If graph/mcp is available, run MCP tools `project_snapshot` (to take a snapshot), `project_diff` (to compare changes against baseline snapshot to detect physical drift / M9 compliance), and `graph_audit_csa` (to verify spec coverage meets the project's configured threshold and bind introduced code entities).
- [ ] 6. 👤 **Git Checkpoint:** Commit changes with message `tdd(scope): [Behavior]`.
- [ ] ⛔ CHECKPOINT: Agent verification pass -> Verify that all previous tasks are successfully marked as done [x] in both this plan file and task.md (State Synchronization) -> Present the git diff & test results to the User (clearly stating: "I have completed [action, log files]. In addition, I have verified and marked all previous tasks as done. I propose that you approve running the commit command...") -> Run the MCP tool `project_session_compact` to update session memory -> Read the updated `session.md` using `view_file` to reload context -> Obtain explicit User approval in the chat to transition to the next Phase.
- [ ] 🤖 **Graph & Insight Update (if --graph):** Run `graph_enrich` for modified/new class/function nodes; and consider saving gotchas/lessons/decisions to the graph via `insight_push` (especially for feat or fix bug tasks).

---

### Phase 2. [Refactoring & Cleanup] ⚙️ `Difficulty: 🟢 Low`

<!-- ⚠️ MANDATORY: Agent MUST reload .agents/rules.md + .agents/skills.md BEFORE modifying files or executing git commands -->

> ⛔ **MANDATORY:** View details of specific rules, skills, agents.md, or project.md in the KI necessary for this phase BEFORE modifying files.

<!-- ⚠️ HARNESS GUARD (Phase 2 Risk): [Derived from Risks & Mitigations table. Leave empty if no risk mapped to this Phase.] -->

> Only execute when ALL test suites are passing (Green).
> Goal: DRY, algorithmic optimization, NO new behaviors.

#### Task 2.1: Refactor [Component]

- [ ] 1. 🟣 **REFACTOR:** Clean up and restructure code.
- [ ] 2. 🟢 **Verify PASS:** Re-run entire test suite (`bash .agents/skills/tdd/scripts/tdd-test.sh npm run test`) to ensure no regressions.
- [ ] 3. 👤 **Git Checkpoint:** Commit changes with message `refactor: cleanup [Component] implementation`.
- [ ] ⛔ CHECKPOINT: Agent verification pass -> Verify that all previous tasks are successfully marked as done [x] in both this plan file and task.md (State Synchronization) -> Present the git diff & test results to the User (clearly stating: "I have completed [action, log files]. In addition, I have verified and marked all previous tasks as done. I propose that you approve running the commit command...") -> Run the MCP tool `project_session_compact` to update session memory -> Read the updated `session.md` using `view_file` to reload context -> Obtain explicit User approval in the chat to transition to the next Phase.
- [ ] 🤖 **Graph & Insight Update (if --graph):** Run `graph_enrich` for modified/new class/function nodes; and consider saving gotchas/lessons/decisions to the graph via `insight_push` (especially for feat or fix bug tasks).

---

## Backlog → Phase Mapping

| Backlog Item | Priority | Phase   |
| :----------- | :------- | :------ |
| [Item ID]    | 🔴 High  | Phase 1 |

## Walkthrough (Completion Gate)

> Final verification checklist — only tick when ALL Phase Task Lists are complete.

- [ ] All Task List items from Phase 0 → Phase N are ticked `[x]`.
- [ ] Every new function/method has a corresponding test.
- [ ] 100% tests pass with pristine output (no errors/warnings).
- [ ] **CSA Quality Verification:** Run the **Global** CSA compliance audit (invoke `graph_audit_csa` MCP tool without `planScope` or run `npx para-graph audit csa` without `--plan-scope`) to verify global Spec-to-Code coverage meets the project's configured threshold (csa.spec_threshold in project.md) and zero dangling spec edges (if CSA is applicable).
- [ ] **MCP Snapshot Diff Evaluation:** Run `project_snapshot` (at completion) and `project_diff` MCP tools to evaluate physical directory drift and verify the integrity of protected files.
- [ ] **TDD Drift Verification & Cleanup:** Compare current repo state with `git status --ignored --porcelain` snapshot in `tdd-repo-before-[date].log` to identify newly generated untracked or ignored files. Agent MUST present the list to User and ask whether to delete them (if junk) or commit them (if missed in plan) before proceeding with cleanup.
- [ ] **Code-Graph Sync:** Update source code graph via command: `npx para-graph build <project-name>` (if --graph is enabled).
- [ ] [Project-specific checks: build pass, docs updated, governance rules...]
- [ ] **KI Template Sync (M7/KR8):** IF project has `repo/templates/knowledge/`, verify KI template content reflects current version changes. Check metadata.json has valid `version` + `para_version`. Run `ki sync` if updated.
- [ ] ⛔ CHECKPOINT (Walkthrough Completion): Agent MUST verify all above Walkthrough items are ticked [x] BEFORE proposing Status transition.
- [ ] ⛔ CHECKPOINT (C7 Status Transition): Agent MUST NOT change Status to "✅ Done" without user approval.
- [ ] User approved Done transition.
- [ ] Clear `active_plan` in `project.md`.

## Git Operation Summary

> Total plan: [N] git commits (local) + [M] git push (remote).

| #   | Operation    | Phase      | Scope     | Guard                                |
| :-- | :----------- | :--------- | :-------- | :----------------------------------- |
| 1   | `git commit` | 1.1        | 🟢 Local  | HARNESS GUARD (VCS — Commit #1/N)    |
| N   | `git push`   | [last].N+1 | 🔴 Remote | HARNESS GUARD (VCS — Push Remote) 🛑 |

## Risks & Mitigations

| Risk               | Mitigation            | Harness (related Phase) |
| :----------------- | :-------------------- | :---------------------- |
| [Risk description] | [Mitigation strategy] | [Phase N guard]         |

## Commit Consolidation Policy

| Squash allowed? | Condition                                                                               |
| :-------------- | :-------------------------------------------------------------------------------------- |
| ⛔ No           | Each TDD cycle gets its own commit (1 commit = test + production, prefix `tdd(scope):`) |
| ⛔ Never        | Push — ALWAYS separate from commits                                                     |

> **Audit trail:** TDD compliance is verified via `artifacts/tests/tdd-evidence.log` (auto-generated by
> `tdd-test.sh`), not via separate git commits. Agent MUST pass TDD Gate before committing.

## Review & Audit Tracking

| Criteria                                          | Count | Last reviewed |
| :------------------------------------------------ | :---- | :------------ |
| Logic review (Phase sequence, Task coverage)      | 0     | —             |
| Security review (context guards, published-only)  | 0     | —             |
| Checklist review (completeness, no missing files) | 0     | —             |
| Build/Test pass                                   | 0     | —             |
| Project governance compliance (see below)         | 0     | —             |

#### Project Governance Checklist

```markdown
IF project has agent.rules: true OR agent.skills: true:

Scan project .agents/rules.md → for each rule with matching trigger:
[ ] [rule-name]: [key requirement from rule]

Scan project .agents/skills.md → for each skill with matching trigger:
[ ] [skill-name]: [key requirement from skill]

ELSE:
(No project-specific governance — standard checklist only)
```

## Suggested Next Steps

- **Option A (Activate & Execute):** Run `/plan [project-name] dev` (or `/plan dev`) to begin automatic execution of the phases.
- **Option B (Sandbox Run):** Run `/vibecode loop` to execute tasks in a sandboxed/interactive loop.
- **Option C (Stress-test Plan):** Run `/qa [project-name] plan` (or `/qa plan`) to trigger a Red Team Q&A review before execution.
````
