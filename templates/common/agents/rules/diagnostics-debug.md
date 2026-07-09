<!-- ⚠️ GOVERNED — /para-rule only. Overwritten by para update -->

# Diagnostics & Debug Pipeline

> Agent governance rule for diagnostic design in specifications and structured bug diagnosis.
> Priority: 🟡 High

## Scope

- [x] Global (applies to all projects)

## Triggers

- Writing or reviewing any Spec (`/spec create`, `/spec update`)
- Encountering a bug report or debugging session
- Running `/fix` workflow
- Writing Plan that involves runtime code

## Rules

### DR1. Spec Diagnostics Design is MANDATORY

- **MUST** include `## 9. Diagnostics Design` section in every Spec created via `/spec create`.
- Section content **MUST** be adapted to the Spec's primary domain:

| Domain | Focus | Key Observables |
|:--|:--|:--|
| Security / Auth | Error codes, token validation, cookie lifecycle | Auth checkpoint logs, token comparison, session transitions |
| API / Integration | Request/Response tracking, timeout & retry | HTTP status, latency, payload diff, upstream health |
| UI / UX | User action trace, component state snapshot | Event sequence, state before/after, rendering errors |
| Data / Schema | Validation failures, migration drift | Schema version, field validation errors, integrity checks |
| Performance | Timing breakdown, resource bottleneck | LCP/TTFB, memory profile, query execution time |
| Infrastructure / Deploy | Environment parity, config drift | Env var validation, runtime version, adapter differences |

- Agent **SHOULD** combine multiple domains if the Spec crosses boundaries.
- Agent **MUST NOT** skip Diagnostics Design even for "simple" Specs — every runtime feature can produce unexpected errors.

### DR2. Bug Diagnostic Pipeline (6-Step Protocol)

When encountering a bug (user report, test failure, verification failure), Agent **MUST** follow this structured protocol instead of jumping directly to grep-and-guess:

#### Step 1: CSA Reverse Lookup (Spec Traceability)

1. Identify the buggy component/endpoint.
2. Use `graph_query` to find the component's node in the code graph.
3. Find CSA anchor (`// @para-doc [#csa-xxx]`) → read the original Spec.
4. Read `## Diagnostics Design` section (if exists) → know where to look for logs.
5. If no CSA anchor exists → fall back to `grep_search` for related Spec files.

#### Step 2: Graph Context Analysis (Blast Radius)

1. `graph_context_bundle(buggy_node)` → callers, callees, dependencies.
2. `graph_impact_analysis(buggy_node)` → blast radius assessment.
3. `memory_search("keywords from bug")` → check if similar issue was encountered before.
4. `insight_search(category: "gotcha")` → find recorded gotchas/lessons.

> **Shortcut:** If Step 2.3 or 2.4 returns a matching insight, prioritize that fix path.

#### Step 3: Spec vs Reality Diff (Root Cause Isolation)

1. Compare the Spec's Acceptance Criteria (AC) against the actual runtime behavior.
2. Identify the GAP — which specific AC is violated.
3. Check `Environment Parity Risks` table (from Diagnostics Design) for known env differences.
4. Formulate root cause hypothesis.

#### Step 4: Fix Implementation

1. **Fix:** Write code that satisfies the Spec AC — not just "makes it work".

#### Step 5: Verify Fix

1. Run test suite (project-specific command).
2. `graph_audit_csa` (if available) → ensure CSA links are intact after fix.
3. `project_snapshot` + `project_diff` → verify only expected files changed.

#### Step 6: Learn & Evolve (Knowledge Loop)

1. `insight_push(category: "gotcha/lesson")` → record the fix in Graph Memory.
2. Update the Spec's `## Diagnostics Design` section if a new Environment Parity Risk was discovered.
3. Propose adding a regression test case if one doesn't exist.

### DR3. Plan Debug Infrastructure (Conditional)

When creating a Plan (`/plan create`) for **runtime code changes** (not docs-only, not template-only):

- Agent **SHOULD** include Debug Infrastructure tasks in Phase 0 or Phase 1:
  - Structured logger setup (if not already present in the project).
  - Observable checkpoint implementation (based on Spec's `## Diagnostics Design`).
  - Environment parity mock scripts (for known env differences).
- Agent **MAY** skip Debug Infrastructure if:
  - The project already has a structured logging system.
  - The plan is for minor tweaks with no new error paths.

### DR4. Learn-Back Loop (Post-Fix MANDATORY)

After completing a bug fix (whether via `/fix` workflow or ad-hoc):

- **MUST** push an insight to Graph Memory (`insight_push`) documenting the root cause and fix.
- **SHOULD** propose updating the relevant Spec's Diagnostics Design section if a new risk was discovered.
- **SHOULD** propose adding a regression test case.
- **MUST NOT** close a bug fix without documenting the lesson learned (zero-knowledge-loss principle).

### DR5. Diagnostics Audit in Hardened Plans

When creating a **Hardened Plan** (`detail-plan-hardened.md`):

- The Post-Draft Audit Gate **MUST** include a `Diagnostics Coverage` dimension:
  ```
  | Diagnostics Coverage — Observable checkpoints exist for every runtime path | ⬜ | |
  ```
- The TDD Classification Table **SHOULD** include a third type `🔍 Debug` for diagnostic tasks.
- The Walkthrough **MUST** verify: `Diagnostics Design from Spec is fully implemented`.

## Anti-Patterns

| ❌ Anti-Pattern | ✅ Correct Approach |
|:--|:--|
| Jump straight to `grep` when a bug is reported | Follow 4-Step Bug Diagnostic Pipeline (DR2) |
| Fix code to "make it work" without checking Spec | Fix MUST satisfy Spec AC, not just eliminate the error |
| Close bug fix without documenting root cause | MUST `insight_push` the lesson/gotcha |
| Skip Diagnostics Design for "simple" Spec | Every runtime Spec gets Diagnostics Design |
| Use `console.log` for debugging | Use structured JSON logging with error codes |

## Related

> Paths are relative to the project root unless prefixed with `.agents/` (workspace-level).

- **Decision:** `Projects/<project>/artifacts/para-decisions/brainstorm-2026-07-09-debug-diagnostics-pipeline.md`
- **Spec Template:** `.agents/skills/spec/references/templates/feature-spec.md` — §9 Diagnostics Design
- **Workflow:** `.agents/workflows/fix.md` — Bug Diagnostic Pipeline execution
- **Skill:** `.agents/skills/plan/SKILL.md` — Debug Infrastructure in Plan templates
