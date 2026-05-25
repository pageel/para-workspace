# Loop Report Template

> JIT-loaded by `/vibecode loop` at Step 5 (Final Report).

## Template

```markdown
## 🔄 VIBECODE LOOP REPORT

**Target:** [Task/Phase description]
**Iterations:** [N/MAX]
**Status:** ✅ Complete | ⚠️ Partial (stopped at iter N) | ❌ Failed
**Project type:** [detected]

### Iteration Log

| # | Strategy | Action | Errors | Fixed | Patterns |
|:--|:--|:--|:--|:--|:--|
| 1 | 🟢 Direct | [What Agent did] | 0→N | — | [Pattern groups found] |
| 2 | 🟢 Direct | [Batch-fix or individual] | N→M | K | [Remaining patterns] |
| 3 | 🟡 RCA | [Root cause hypothesis + fix] | M→L | J | [Resolved patterns] |
| ... | ... | ... | ... | ... | ... |

### Exit Criteria

- [x/] [Criterion 1]
- [x/] [Criterion 2]
- [x/] [Criterion 3]

### Files Modified (across all iterations)

| # | File | Total changes | Lines |
|:--|:--|:--|:--|
| 1 | `path/to/file` | +N / -M | Z |

### Error Patterns (Agent Learning)

> This section is critical for Agent self-improvement and cross-session knowledge.
> Document specific patterns so future loop runs AND Knowledge Extraction (Step 5b)
> can leverage this data.

| # | Error pattern | Root cause | Fix pattern | Frequency | Strategy used |
|:--|:--|:--|:--|:--|:--|
| 1 | [Error message pattern] | [Why it happened] | [How it was fixed] | [N times] | 🟢/🟡/🔴 |

### Root Cause Hypotheses (if iteration ≥ 3)

> Logged when Strategy Escalation triggered Root Cause Analysis.

| Iteration | Hypothesis | Validated? | Action taken |
|:--|:--|:--|:--|
| 3 | "[hypothesis statement]" | ✅/❌ | [What was changed based on hypothesis] |

### Convergence Signals

> Agent tracks these signals after EACH iteration to detect stagnation or regression.

| Iter | Errors | Δ | New types? | Regression? | Signal |
|:--|:--|:--|:--|:--|:--|
| 1 | N | — | — | — | — |
| 2 | M | ↓/↑/→ | Y/N | Y/N | ✅/⚠️/🔴 |
| 3 | L | ↓/↑/→ | Y/N | Y/N | ✅/⚠️/🔴 |

### Lessons Learned

> Agent MUST write at least 1 lesson per loop run.

1. **[Lesson title]:** [Specific, actionable insight that prevents this issue in future]
2. **[Lesson title]:** [Another insight]

### Confidence Assessment

| Metric | Value |
|:--|:--|
| Exit criteria passed | N/M |
| Iterations used | N/MAX |
| Regressions encountered | Y/N |
| **Confidence** | 🟢 High / 🟡 Medium / 🔴 Low |

**Confidence rubric:**
- 🟢 High — All criteria passed, no regressions, < 50% max iterations used
- 🟡 Medium — All criteria passed but used > 50% iterations OR had 1 regression
- 🔴 Low — Partial completion, multiple regressions, or max iterations reached
```
