# Review Report Template

> JIT-loaded by `/vibecode review` at Step 7 (Review Report Output).

## Template

```markdown
## 📋 VIBECODE REVIEW REPORT

**Plan:** [Plan title from H1 heading]
**File:** [Absolute path to plan]
**Reviewed:** [ISO timestamp]
**Reviewer mode:** `/vibecode review`

### Summary Scorecard

| Category | Score | Issues |
|:--|:--|:--|
| Structure (8 checks) | ✅ N/8 | [count issues] |
| Logic (5 checks) | ✅ N/5 | [count issues] |
| Security (6 checks) | ✅ N/6 | [count issues] |
| Token Budget | 🟢/🟡/🔴 | [turns needed] |
| Governance (6 checks) | ✅ N/6 | [count issues] |
| **Overall** | **[verdict]** | **[total issues]** |

**Verdict scale:**
- 🟢 **Clear to execute** — no issues found
- 🟡 **Proceed with caution** — minor issues, fix recommended
- 🔴 **Block** — critical issues, must fix before execution

### Issues Found

| # | Category | ID | Severity | Detail | Fix suggestion |
|:--|:--|:--|:--|:--|:--|
| 1 | [cat] | [L1/S1/G1] | 🔴/🟡/🟢 | [specific description] | [actionable fix] |

### Token Budget Breakdown

| Phase | Tasks | Files (C/M) | Est. lines | Turns |
|:--|:--|:--|:--|:--|
| Phase 0 | N | C:X M:Y | ~Z | 1 |
| Phase 1 | N | C:X M:Y | ~Z | 1 |
| **Total** | **N** | **C:X M:Y** | **~Z** | **N** |

**Assumptions:**
- Platform overhead per turn: ~10K tokens
- Productive file I/O per turn: ~500 lines
- Rule JIT-loading cost: ~2K tokens per load

### Governance Compliance Matrix

| # | Rule | Status | Note |
|:--|:--|:--|:--|
| G1 | catalog.yml entry | ✅/❌ | [detail] |
| G2 | VERSIONS.yml entry | ✅/❌ | [detail] |
| G3 | Docs reference | ✅/❌ | [detail] |
| G4 | Dogfooding policy | ✅/❌ | [detail] |
| G5 | English-first | ✅/❌ | [detail] |
| G6 | Pre-flight blocks | ✅/❌ | [detail] |

### Recommendations

> Agent MUST provide at least 1 actionable recommendation, even if all checks pass.

1. [Recommendation with specific action]
2. [Recommendation with specific action]

### Next Steps

Choose:
  1. ✅ Issues found → Fix in plan → re-review (`/vibecode review [ref]`)
  2. 🧪 Test first → `/vibecode test [Phase 0]`
  3. 🔄 Loop execution → `/vibecode loop [Phase 0]`
  4. ⚡ Auto execution → `/vibecode auto [ref]`
  5. ❌ Reject plan → needs redesign
```

## Agent Learning Notes

> This section helps the Agent understand HOW to use the review report effectively.

### Pattern: Review → Execute Pipeline

When user chains `review` → `test` → `auto`:

1. **Review** produces Issues table
2. Agent fixes issues in the plan file BEFORE proceeding
3. **Test** validates Phase 0 in sandbox
4. If test passes → **Auto** executes full plan

### Pattern: Review → Loop

When review finds a specific problematic phase:

1. **Review** identifies Phase N as risky (🟡/🔴)
2. Agent suggests: "Phase N identified as high-risk. Recommend `/vibecode loop Phase N`"
3. **Loop** executes Phase N iteratively until zero errors
4. After loop completes, resume with `/vibecode auto [ref] --resume PhaseN+1`

### Anti-Pattern: Skip Review

❌ Never go directly from plan creation to `auto` mode without review.
✅ Always: `/vibecode review` → fix issues → then `test` or `auto`.
