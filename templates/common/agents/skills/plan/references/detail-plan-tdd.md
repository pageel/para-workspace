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

- [ ] 0.0 🤖 Graph Knowledge Preparation (if para-graph enabled)
- [ ] 0.1 🤖 [Task description]
- [ ] 0.2 🤖 [Task description]
- [ ] ⛔ CHECKPOINT: Agent MUST verify ALL tasks in Phase 0 are checked [x] BEFORE proceeding to Phase 1. Ask User to proceed.

---

### Phase 1. [Core Feature] ⚙️ `Difficulty: [🟡 Medium | 🔴 High]`

<!-- ⚠️ MANDATORY: Agent MUST reload .agents/rules.md + .agents/skills.md BEFORE modifying files or executing git commands -->

> ⛔ **MANDATORY:** Re-read `.agents/rules.md` + `.agents/skills.md` BEFORE modifying files.

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

- [ ] 1. 🔴 **RED: Write Failing Test**
  ```typescript
  // Example code block testing specific behavior
  test('should return correct format', () => {
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
- [ ] 6. 👤 **Commit**
  ```bash
  git add exact/path/to/feature.test.ts exact/path/to/feature.ts
  git commit -m "tdd(feature): [Behavior] — red-green verified"
  ```

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
- [ ] 6. 👤 **Commit** (`tdd(scope): [Behavior]`)
- [ ] ⛔ CHECKPOINT: Agent MUST verify ALL tasks in Phase 1 are checked [x] BEFORE proceeding to the next Phase. Ask User to proceed.

---

### Phase 2. [Refactoring & Cleanup] ⚙️ `Difficulty: 🟢 Low`

<!-- ⚠️ MANDATORY: Agent MUST reload .agents/rules.md + .agents/skills.md BEFORE modifying files or executing git commands -->

> ⛔ **MANDATORY:** Re-read `.agents/rules.md` + `.agents/skills.md` BEFORE modifying files.

<!-- ⚠️ HARNESS GUARD (Phase 2 Risk): [Derived from Risks & Mitigations table. Leave empty if no risk mapped to this Phase.] -->

> Only execute when ALL test suites are passing (Green).
> Goal: DRY, algorithmic optimization, NO new behaviors.

#### Task 2.1: Refactor [Component]

- [ ] 1. 🟣 **REFACTOR:** Clean up and restructure code.
- [ ] 2. 🟢 **Verify PASS:** Re-run entire test suite (`bash .agents/skills/tdd/scripts/tdd-test.sh npm run test`) to ensure no regressions.
- [ ] 3. 👤 **Commit Checkpoint**
  ```bash
  git commit -a -m "refactor: cleanup [Component] implementation"
  ```
- [ ] ⛔ CHECKPOINT: Agent MUST verify ALL tasks in Phase 2 are checked [x] BEFORE proceeding to the next Phase. Ask User to proceed.

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
- [ ] [Project-specific checks: build pass, docs updated, governance rules...]
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

| Squash allowed?  | Condition                              |
| :--------------- | :------------------------------------- |
| ⛔ No            | Each TDD cycle gets its own commit (1 commit = test + production, prefix `tdd(scope):`) |
| ⛔ Never         | Push — ALWAYS separate from commits    |

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

1. **Activate Plan:** Set `active_plan` in `project.md` and set Status to `🔨 Active`.
2. **Execute Plan:** Run `/plan [project-name] dev` or `/vibecode loop` to begin execution.

````
