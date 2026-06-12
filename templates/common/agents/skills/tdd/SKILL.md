---
name: TDD Guidelines
description: Strict Test-Driven Development workflow rules, anti-patterns, and the Red-Green-Refactor cycle.
source: user
---

# Skill: Test-Driven Development (TDD)

> **Context:** This skill governs execution-time behavior for AI Agents when writing code. It prevents hallucinations, bloated code, and missing test coverage by enforcing strict TDD principles.
>
> **Load this reference when:** The user requests TDD, the active plan specifies strict TDD/testing, you are writing tests, or you are refactoring existing code.

## 1. The Iron Law

> ⛔ **NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST.**

This rule is absolute. If you are instructed to implement a feature, you MUST write the test first, observe it fail, and only then write the production code. If you find yourself writing production code without a corresponding failing test, **STOP. Delete the code. Write the test.**

## 2. The TDD Cycle (Bite-Sized Tasks)

Do not attempt to write 500 lines of code at once. Break the work into 5-minute bite-sized cycles:

### 🔴 RED: Write a Failing Test

Write a test for the _exact_ behavior you are about to implement.

- **Run the test.**
- **Observe the failure.** This is the most crucial step. If it passes immediately, your test is flawed or the feature already exists.

> ⛔ **FALSE RED GUARD:** A valid RED state means the test fails because the logic is missing (e.g., Assertion Error: Expected A but got B, or TypeError: function is not defined). If the test fails due to a Syntax Error or Missing Import in the test file itself, you MUST fix the test structure before proceeding. It is NOT a valid RED if the test code is simply broken.
>
> ⛔ **NO WATCH MODE:** When executing tests in the terminal, Agent MUST use one-shot execution commands (e.g., `CI=true npm test` or `npm run test:run`) and MUST NOT use watch mode (`--watch`). Watch mode will block the terminal process and break the workflow.

### 🟢 GREEN: Write Minimal Code

1. Write ONLY the production code necessary to make the failing test pass.
2. Do not anticipate future needs (YAGNI - You Aren't Gonna Need It).
3. Do not format or clean up code excessively at this stage. Just make it pass.
4. Run the test command and verify it is completely green.

### 🟣 REFACTOR: Clean and Optimize

1. You may only refactor when all tests are green.
2. Clean up duplications (DRY), rename variables for clarity, and extract helper functions.
3. **Warning:** Do NOT add new behavior or logic during the Refactor phase.

## 3. Testing Anti-Patterns

### Anti-Pattern A: Testing Mock Behavior

- **The Error:** Asserting that a mock was called or that a mocked component exists in the DOM, rather than testing the system's actual outcome.
- **The Fix:** Test real behavior. Mocks are a tool for isolation, not the subject under test. If you are just proving your mock works, the test is useless.

### Anti-Pattern B: Test-Only Methods in Production

- **The Error:** Adding methods to a production class (e.g., `destroy()`, `resetState()`) just to make the test teardown easier.
- **The Fix:** Keep production classes pristine. Use test utilities or external state managers to handle test lifecycle. Production classes should not know they are being tested.

### Anti-Pattern C: Incomplete Mocks

- **The Error:** Mocking only the 2 fields you need for the current test, while the real API returns 20 fields.
- **The Fix:** If you must mock, mock the _entire_ schema as it exists in reality. Partial mocks lead to silent failures when downstream code unexpectedly relies on the missing fields.

### Anti-Pattern D: Integration Tests as an Afterthought

- **The Error:** Saying "I am done coding, now I will write tests."
- **The Fix:** Testing is not an optional follow-up. It is the implementation vehicle. Use the Red-Green-Refactor cycle.

## 4. Execution Checkpoints

When acting as an implementing Agent, you MUST:

- Add a commit checkpoint at every successful `GREEN` phase.
- Use Conventional Commits (`test:`, `feat:`, `refactor:`).
- Verify the test command output in the terminal before proceeding.

## 5. Integration with TDD Plans

If you are executing tasks from a TDD Plan (e.g., generated via `detail-plan-tdd.md`), you MUST strictly tick the `[ ]` checkboxes in the Plan file as you progress through the `RED`, `GREEN`, and `REFACTOR` cycles. Do not mark a task as completely Done until all its TDD cycle checkboxes are ticked and the corresponding code is committed. This guarantees the Walkthrough Completion Gate can be audited.

## 6. TDD Evidence Log

When executing a TDD Plan, Agent MUST use the evidence logger script instead of running test commands directly. This creates an on-disk audit trail that survives conversation truncation.

### Usage (Cwd-Agnostic Path Resolution)

The script path `.agents/skills/tdd/scripts/tdd-test.sh` is relative to the **workspace root** (directory containing `.para-workspace.yml`). Since Agent typically runs commands from `Projects/<name>/repo/`, the relative path varies depending on depth.

**Agent MUST resolve the script path before invocation:**

1. Determine workspace root by locating `.para-workspace.yml` (usually 3 levels up from `repo/`).
2. Construct the full path: `<workspace-root>/.agents/skills/tdd/scripts/tdd-test.sh`

**Examples by Cwd:**

```bash
# Cwd = workspace root (/)
bash .agents/skills/tdd/scripts/tdd-test.sh npm test --run test/foo.test.ts

# Cwd = Projects/<name>/repo/ (most common during plan execution)
bash ../../../.agents/skills/tdd/scripts/tdd-test.sh npm test --run test/foo.test.ts

# Cwd = Projects/<name>/ (project root)
bash ../../.agents/skills/tdd/scripts/tdd-test.sh npm test --run test/foo.test.ts
```

**Cross-platform notes:**

- **Linux/macOS:** Works natively (bash + POSIX tools pre-installed).
- **Windows:** Requires bash environment (WSL or Git Bash). Forward-slash paths work in both.

> ⛔ **SCRIPT NOT FOUND GUARD:** If `tdd-test.sh` returns exit code 127 (command not found),
> Agent MUST:
>
> 1. Re-read this skill to verify the correct path
> 2. Try resolving from workspace root (find `.agents/` directory)
> 3. **STOP and report** if still not found — DO NOT fall back to raw test commands
>
> Running tests without the evidence logger is a **TDD compliance violation**
> (Anti-Pattern: "Skipped evidence logger").

The script:

1. Runs the test command and captures output + exit code.
2. Appends an evidence entry (timestamp, status FAIL/PASS, command, output snippet) to `artifacts/tests/tdd-evidence.log`.
3. Passes through the original output and exit code to the Agent.

### TDD Gate (Step 5 in TDD Cycle)

Before committing, Agent MUST read `artifacts/tests/tdd-evidence.log` and verify:

- A `status: FAIL` entry exists for the test file **before** the `status: PASS` entry.
- If no FAIL is found before PASS → **STOP, do not commit**. Re-run the RED step.

### Lifecycle

| Event                        | Action                                                                                                                                                  |
| :--------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Plan starts                  | Script creates `artifacts/tests/tdd-evidence.log` on first run                                                                                          |
| During plan                  | Evidence entries accumulate (append-only)                                                                                                               |
| Session ends (`/end`)        | Agent runs Quarantine hook to move `artifacts/tests/*` to `tmp/` and appends `.bak`. This prevents sandbox trash buildup while preserving audit trails. |
| Plan done (Status → ✅ Done) | Agent renames to `artifacts/tests/tdd-evidence-<version>.log` (e.g., `tdd-evidence-v0.13.2.log`)                                                        |
| Next plan starts             | Fresh `artifacts/tests/tdd-evidence.log` created automatically                                                                                          |
| `.gitignore`                 | `artifacts/tests/` should be ignored                                                                                                                    |

## Resource Router

| Resource                    | Relative Path                 | Description                                                                                                |
| :-------------------------- | :---------------------------- | :--------------------------------------------------------------------------------------------------------- |
| TDD Evidence Logger         | `scripts/tdd-test.sh`         | Bash wrapper that logs test FAIL/PASS to `artifacts/tests/tdd-evidence.log` for TDD Gate verification      |
| Transcript Telemetry Parser | `scripts/parse-transcript.py` | Python script to parse Antigravity session transcript locally for tool counts, commands, and mutated files |

### Transcript Parser Usage

When executing TDD Drift Verification & Cleanup or auditing session telemetry, run this script to parse conversation transcripts locally without context bloat:

```bash
python3 .agents/skills/tdd/scripts/parse-transcript.py [path_to_transcript_or_directory]
```

## 7. Isolated TDD Protocol (Workspace & Repo Protection)

To protect the active workspace from configuration pollution (junk files) and avoid committing ad-hoc test scripts to the open-source templates repository, Agent MUST follow the Isolated TDD Protocol:

### A. Workspace Isolation (Mock/Sandbox output)

- When writing tests for CLI synchronization, installations, or file mutations, Agent **MUST NOT** run installer commands directly targeting the active workspace (e.g., `para install` or raw `install.sh`).
- Route all test outputs, created directories, and mock files to a sandboxed directory (e.g., `artifacts/tests/tmp/sandbox/`).

### B. Temporary Test Scripts Management

- All test scripts written during a TDD cycle to verify template sync, CLI commands, or shell scripts **MUST NOT** be committed to the `repo/` repository.
- Store these temporary test scripts in the project's internal `artifacts/tests/tmp/` folder.
- **Naming Convention:** `test-tmp-[YYYY-MM-DD]-[topic].sh`.
  - If multiple test scripts are created for the same topic or session, append an incremental index suffix: `test-tmp-[YYYY-MM-DD]-[topic]-[index].sh` (e.g., `test-tmp-2026-05-29-sync-01.sh`).
- These files MUST be ignored via `.gitignore` to prevent polluting the OSS template repository.

### C. Repo State Snapshot (Junk File Prevention)

- **At the start of the Plan (Phase 0):** Agent MUST execute a repo state snapshot command (e.g., `git status --ignored --porcelain` or a file structure log) and save it to `artifacts/tests/tdd-repo-before-[date].log`. This serves as the Ground Truth Before.
  - If multiple snapshots are taken (e.g., across multiple sub-sessions or coding iterations), append an incremental index suffix: `tdd-repo-before-[date]-[index].log` (e.g., `tdd-repo-before-2026-05-29-01.log`).
- **At the end of the Plan (Walkthrough / Completion Gate):** Agent MUST compare the final repo state against the snapshot log. Any unexpected modified or untracked files (junk/zombie files generated during testing) MUST be cleaned up completely before proposing the plan's transition to Done.

#### Example Plan Task Templates:

To implement this protocol, a TDD-hardened plan MUST include the following tasks:

1. **Phase 0 (Start Snapshot):**

   ```markdown
   - [ ] 0.X 🤖 **TDD Repo Before Snapshot** (run `git status --ignored --porcelain` & `git log -n 1 --oneline` and save to `artifacts/tests/tdd-repo-before-[date].log`)
   ```

2. **At the end of intermediate phases (Phase 1, Phase 2, Phase 3...):**

   ```markdown
   - [ ] X.Y 🤖 **Compare Git Drift** (compare current repo state with `artifacts/tests/tdd-repo-before-[date].log` to identify newly generated untracked/ignored files in this phase)
   ```

3. **Pre-commit Gate (before Git Commit task):**

   ```markdown
   - [ ] X.N 🤖 **Compare Git Drift (Pre-commit)** (compare final changes against snapshot before commit to prevent committing junk)
   ```

4. **Walkthrough (Final Post-Release Audit):**
   ```markdown
   - [ ] **TDD Drift Verification & Cleanup:** Compare current repo state with `artifacts/tests/tdd-repo-before-[date].log` and completely clean up any junk files generated during local TDD/testing before completion.
   ```
