# TDD Compliance Audit Template

> Loaded by `/logs --deep` when the session plan uses TDD methodology.
> Agent MUST cross-reference `artifacts/tests/tdd-evidence.log` (primary), conversation log
> (secondary), and git history to verify the Red-Green-Refactor cycle.

## Audit Section: TDD Compliance

Append this section **after** the base `✅ Tasks & Progress` section in the `/logs --deep` report:

```markdown
### 🧪 TDD Compliance Audit

> ⚠️ **ANTI-HALLUCINATION:** Agent MUST verify each step from conversation log
> (step_index sequence) and git history (`git show --stat`). DO NOT assume
> compliance — prove it with evidence.

**Plan methodology:** [Plan filename + TDD markers detected]
**Evidence sources:** `artifacts/tests/tdd-evidence.log` (primary), Conversation log (fallback), Git log

#### Per-Task Compliance

| Task | 🔴 RED First? | Verify FAIL? | 🟢 GREEN After? | Verify PASS? | TDD Gate Passed? | Verdict |
|:--|:--|:--|:--|:--|:--|:--|
| [Task ID] | ✅/⚠️/❌ | ✅/⚠️/❌ | ✅/⚠️/❌ | ✅/⚠️/❌ | ✅/⚠️ | ✅ Compliant / ⚠️ Partial / ❌ Violated |

**Verdict Legend:**
- ✅ = Evidence confirms correct order from conversation log
- ⚠️ = Cannot verify (context truncated or commit bundled)
- ❌ = Evidence shows production code written before failing test

#### Phase Boundary Compliance

| Transition | Checkpoint Exists? | User Confirmed? | Verdict |
|:--|:--|:--|:--|
| Phase N → Phase N+1 | ✅/❌ | ✅/❌ | ✅ OK / ❌ Violated |

#### TDD Score

| Metric | Value |
|:--|:--|
| Tasks verified compliant | [N] / [Total] |
| Tasks partial / unverifiable | [N] / [Total] |
| Tasks violated | [N] / [Total] |
| Phase boundaries respected | [N] / [Total] |
| **Overall TDD Score** | [N]% |

> **Scoring:** Compliant = 1.0, Partial = 0.5, Violated = 0.0, Unverifiable = 0.5 (benefit of doubt).
> Formula: (sum of scores / total tasks) × 100
```

## Audit Process

Agent MUST follow this process to fill the template:

1. **Check for evidence log** — read `artifacts/tests/tdd-evidence.log` in the project repo root.
   - If exists → use as primary evidence source (timestamps prove order).
   - If missing → fall back to conversation log (`overview.txt`).
2. **Identify all TDD tasks** from the plan (look for `🔴 RED` / `🟢 GREEN` markers).
3. **For each task**, verify from evidence log:
   - A `status: FAIL` entry exists for the test file
   - A `status: PASS` entry exists for the same test file **after** the FAIL entry (higher timestamp)
   - The TDD Gate step (Step 5) was ticked `[x]` in the plan
4. **Fallback (no evidence log):** Scan conversation log (`overview.txt`) for step_index ordering.
5. **Check phase boundaries**: Look for user messages like "tiếp tục phase N" — if Agent continued without such a message, it's a boundary violation.

## Anti-Patterns to Flag

| Anti-Pattern | How to Detect |
|:--|:--|
| **GREEN before RED** | Evidence log shows PASS without prior FAIL for the same test file |
| **Skipped evidence logger** | Agent ran `npm test` directly instead of via `tdd-test.sh` — no entry in evidence log |
| **Missing TDD Gate** | Plan step 5 (🤖 TDD Gate) not ticked but commit was made |
| **Context truncation** | No evidence log AND step_index gap > 30 in conversation log |
| **Self-congratulatory tone** | Subjective positive assessment in telemetry report (violates Zero-fluff) |
