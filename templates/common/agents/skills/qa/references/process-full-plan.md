# QA Process: Full-Plan Review

> **Slug:** `full-plan`
> **Philosophy:** Waterfall Gate — Review the entire artifact before allowing execution.
> **Best for:** Small-to-medium Detail Plans (≤4 Phases), Specs, Brainstorms.
> **Inspired by:** Traditional Gate Review / Waterfall Quality Gate.

## Process Flow

```
┌──────────────────────────────────────────────┐
│ 1. Kickoff: Select Personas + Focus Areas    │
│    (Step 0.5 — Pre-QA Strategy)              │
├──────────────────────────────────────────────┤
│ 2. Tech Lead Governance Audit                │
│    → Validate project rules & skills         │
│    → Generate & check Governance Checklist   │
│                                              │
│    ⛔ CHECKPOINT: Halt for user review       │
│       before moving to scan                  │
├──────────────────────────────────────────────┤
│ 3. Full-Artifact Scan                        │
│    → Read entire artifact in one pass        │
│    → Generate questions for ALL sections     │
├──────────────────────────────────────────────┤
│ 4. User Iteration Loop                       │
│    → User adds/removes questions             │
│    → Deep review if needed                   │
├──────────────────────────────────────────────┤
│ 5. Answer ALL questions                      │
│    → Verdict per question                    │
│    → Cross-Section Consistency Check         │
├──────────────────────────────────────────────┤
│ 6. Fix Loop                                  │
│    → Fix all issues → Re-audit               │
├──────────────────────────────────────────────┤
│ 7. Final Verdict → Recommend Activate/Block  │
└──────────────────────────────────────────────┘
```

## Characteristics

| Property | Value |
|:--|:--|
| **Scope per round** | Entire artifact |
| **Number of rounds** | 1-2 (generate → fix → re-verify) |
| **Token cost** | 🟡 Medium (read all once, answer once) |
| **Depth** | 🟡 Medium (breadth over depth) |
| **Best token efficiency** | Artifacts ≤ 500 lines |

## When to Suggest

- Plan with ≤ 4 phases
- Spec documents
- Brainstorm decision documents
- Short artifacts needing quick QA

## Roles

| Step | Who | Action |
|:--|:--|:--|
| Kickoff | Agent | Propose Strategy + Persona roster |
| Governance Audit | Agent (💼 Tech Lead) | Check project rules & skills compliance |
| Scan | Agent | Generate ALL questions |
| Iterate | User | Approve / add / deep review |
| Answer | Agent | Self-answer + verdict |
| Fix | Agent + User | Fix issues → re-audit |
| Verdict | Agent → User | Present final recommendation |

## Anti-patterns

- ❌ Do not use for plans > 6 phases (too many questions, loss of focus)
- ❌ Do not use for code review (use `deep` mode instead)
