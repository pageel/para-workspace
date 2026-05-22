# QA Process: Phase-by-Phase Loop

> **Slug:** `phase-loop`
> **Philosophy:** Iterative Gate — Review each Phase independently, ensuring cumulative quality.
> **Best for:** Large Detail Plans (≥5 Phases), TDD Plans, High-Risk projects.
> **Inspired by:** Agile Sprint Review / Iterative Quality Assurance.

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
│ 3. Phase Loop START (Phase 0 → Phase N)      │
│    ┌────────────────────────────────────┐     │
│    │ 3a. Context Recovery & Rule Check  │     │
│    │     → Re-read project `.agents/rules.md` │
│    │     → Load triggered rules (e.g.,  │     │
│    │        maintenance) for this phase │     │
│    │ 3b. Graph Context (if --graph)     │     │
│    │     → Query nodes & impact for     │     │
│    │        this specific Phase ONLY    │     │
│    │ 3c. Scan Phase N                   │     │
│    │     → Generate questions for       │     │
│    │        Phase N ONLY                │     │
│    │ 3d. Answer Phase N questions       │     │
│    │ 3e. Fix Phase N issues             │     │
│    │ 3f. Phase N Verdict                │     │
│    │     ✅ Pass → Next Phase           │     │
│    │     🔴 Block → Fix before next     │     │
│    │                                    │     │
│    │ ⛔ CHECKPOINT: User approve        │     │
│    │    before moving to next Phase     │     │
│    └────────────────────────────────────┘     │
│    ↓ (repeat per Phase)                       │
├──────────────────────────────────────────────┤
│ 4. Cross-Phase Consistency Check             │
│    → Verify consistency across all Phases    │
├──────────────────────────────────────────────┤
│ 5. Final Verdict → Recommend Activate/Block  │
└──────────────────────────────────────────────┘
```

## Characteristics

| Property | Value |
|:--|:--|
| **Scope per round** | 1 Phase at a time |
| **Number of rounds** | N rounds (= N Phases) |
| **Token cost** | 🟢 Low per round (total may be 🟡 Medium) |
| **Depth** | 🔴 High (deep focus on each Phase) |
| **Best token efficiency** | Plans ≥ 5 phases or TDD plans |

## When to Suggest

- Plan with ≥ 5 phases
- TDD plans (each Phase has multiple TDD cycles to verify)
- Plans with complex cross-phase dependencies
- User wants incremental QA to avoid being overwhelmed
- High-risk projects (security, finance, production deployments)

## Roles

| Step | Who | Action |
|:--|:--|:--|
| Kickoff | Agent | Propose Strategy + Phase order |
| Governance Audit | Agent (💼 Tech Lead) | Check project rules & skills compliance |
| Phase Recovery | Agent | Re-read rules/skills index and load relevant files before generating questions |
| Phase Graph | Agent | If --graph: Context bundle & impact for this Phase |
| Phase Scan | Agent | Generate questions for current Phase |
| Phase Answer | Agent | Self-answer + phase verdict |
| Phase Gate | User | Approve phase → next |
| Cross-Phase | Agent | Consistency check across all phases |
| Final Verdict | Agent → User | Present accumulated recommendation |

## Key Differentiator

Compared to `full-plan`, this process enables:
- **Early detection:** Catch Phase 1 errors before spending time reviewing Phase 4
- **Focused attention:** Agent concentrates context on 1 Phase, producing sharper questions
- **Incremental fix:** Fix immediately within the Phase, no scrolling through long fix lists
- **Context budget friendly:** Each round is lightweight, suitable for model token limits

## Anti-patterns

- ❌ Do not use for artifacts with < 3 phases (overhead of too many rounds)
- ❌ Do not use for specs/brainstorms (no Phase structure to iterate over)
