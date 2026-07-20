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
│ 4. Cross-Phase Consistency Check (MANDATORY) │
│    → Verify consistency across all Phases    │
│    → Verify God Nodes touched by 2+ Phases   │
│    → Verify shared helpers referenced correct│
│    → Update Focus Areas & Process Log tables │
│    → Verify Governance Checklist (§0.5) ✅/❌ │
│    → Update Verdict in Report Header         │
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
| **Phase merge** | Adjacent phases MAY be merged (see Phase Merge Rule below) |

### Phase Merge Rule

Agent MAY merge 2 adjacent phases into a single QA round when:
- Phase 0 (Setup/Scaffold) contains only configuration tasks with no business logic
- Two adjacent phases operate on the same domain (e.g., both are CRUD endpoints)

**Constraints:**
- Agent MUST explicitly document the merge decision in the Process Log: `"Merged Phase X + Phase Y — Reason: [justification]"`
- Agent MUST NOT merge phases that touch different security boundaries (e.g., auth + data access)
- Merged rounds MUST still cover all Focus Areas from both phases

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

## Step 4: Cross-Phase Consistency Check (MANDATORY)

After completing all Phase rounds, Agent MUST perform a mandatory Cross-Phase Consistency Check before issuing the Final Verdict. This step catches cumulative errors that only emerge when combining multiple phases.

### 4a. Structural Consistency

| Check | What to verify |
|:--|:--|
| **God Node conflicts** | If a file (e.g., `index.ts`) is modified in 2+ phases, verify no merge conflicts between local commits |
| **Shared helper references** | If Phase N creates a helper (e.g., `auth.ts`), verify all subsequent phases reference it correctly |
| **Config accumulation** | If `wrangler.toml` or `package.json` is modified across phases, verify final state is consistent |
| **Import/export chain** | Verify that cross-phase imports resolve correctly (no circular dependencies introduced) |

### 4b. Report Housekeeping (MANDATORY)

Agent MUST update ALL tracking sections in the QA Report:

1. **Focus Areas (§0.2):** Update every row's Status from `⏳ Pending` → `✅ Covered` (with round reference)
2. **Process Log (§0.3):** Append one row per completed round with actual question/fix counts
3. **Governance Checklist (§0.5):** Revisit every GOV/CSA item and update from `⏳ Pending` → `✅ Pass` or `❌ Fail`
4. **Verdict Header:** Update the Report Header `Verdict` field from `[Pending]` → final verdict (e.g., `✅ PASS (16 Questions — 6 Issues Fixed — 3 Rounds)`)

> [!WARNING]
> Leaving Focus Areas, Process Log, or Governance Checklist in `⏳ Pending` state at the end of the QA process is a **process violation**. These tables exist for auditability and MUST reflect the actual final state.

## Anti-patterns

- ❌ Do not use for artifacts with < 3 phases (overhead of too many rounds)
- ❌ Do not use for specs/brainstorms (no Phase structure to iterate over)
- ❌ Do not skip Step 4 (Cross-Phase Consistency) — cumulative errors are the #1 missed category
- ❌ Do not leave Governance Checklist or Focus Areas in Pending state after final round
- ❌ Do not merge phases silently — always document merge rationale in Process Log
