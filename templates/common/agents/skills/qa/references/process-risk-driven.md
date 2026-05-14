# QA Process: Risk-Driven Review

> **Slug:** `risk-driven`
> **Philosophy:** Pareto Gate — Focus 80% effort on the 20% highest risks.
> **Best for:** Plans with clear Risks tables, Security-critical projects, Production deployments.
> **Inspired by:** Risk-Based Testing (ISO 31000) / FMEA (Failure Mode & Effects Analysis).

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
│       before moving to triage                │
├──────────────────────────────────────────────┤
│ 3. Risk Triage                               │
│    → Read Risks & Mitigations table          │
│    → Read HARNESS GUARD comments             │
│    → Classify: 🔴 Critical / 🟡 Medium /     │
│      🟢 Low risk phases                      │
│    → Build Risk Priority Matrix              │
├──────────────────────────────────────────────┤
│ 4. Deep Drill: 🔴 Critical Risks FIRST      │
│    → Generate questions focused on [SEC],    │
│      [LOGIC], [DEP] for phases flagged       │
│      as 🔴 Critical                          │
│    → Answer + Fix loop                       │
│                                              │
│    ⛔ CHECKPOINT: ALL Critical risks         │
│       resolved before proceeding             │
├──────────────────────────────────────────────┤
│ 5. Medium Scan: 🟡 Medium Risks             │
│    → Questions on [COMP], [FEAS], [GOV]      │
│    → Answer + Fix if needed                  │
├──────────────────────────────────────────────┤
│ 6. Low Sweep: 🟢 Low Risk (optional)        │
│    → Quick scan for [CONS] consistency       │
│    → User may skip if desired                │
├──────────────────────────────────────────────┤
│ 7. Risk Matrix Update + Final Verdict        │
│    → Update Risk Priority Matrix             │
│    → All 🔴 resolved? → ✅ Ready             │
└──────────────────────────────────────────────┘
```

## Characteristics

| Property | Value |
|:--|:--|
| **Scope per round** | Phases grouped by Risk Level |
| **Number of rounds** | 3 (Critical → Medium → Low) |
| **Token cost** | 🟢 Low (skip Low risk if not needed) |
| **Depth** | 🔴 Very High for Critical, 🟢 Low for rest |
| **Best token efficiency** | Plans with explicit risk tables |

## Risk Priority Matrix Template

```markdown
| Risk ID | Phase | Risk Description | Severity | Likelihood | Risk Score | Status |
|:--|:--|:--|:--|:--|:--|:--|
| R1 | Phase 2 | SQL Injection via FTS5 | 🔴 High | 🟡 Medium | 🔴 Critical | ⏳ Pending |
| R2 | Phase 4 | Version sync miss | 🟡 Medium | 🟢 Low | 🟡 Medium | ⏳ Pending |
| R3 | Phase 1 | Test env config | 🟢 Low | 🟢 Low | 🟢 Low | ⏳ Pending |
```

**Scoring Logic:**
- `Severity × Likelihood` → Risk Score
- 🔴 High × 🟡 Medium = 🔴 Critical
- 🟡 Medium × 🟢 Low = 🟡 Medium
- 🟢 Low × 🟢 Low = 🟢 Low

## When to Suggest

- Plan has a well-defined Risks & Mitigations table (≥ 3 risks)
- Security-critical projects (handling sensitive data, SQL, auth)
- Production deployment plans
- Plans with HARNESS GUARD annotations
- When token budget is limited but safety must be ensured

## Roles

| Step | Who | Action |
|:--|:--|:--|
| Kickoff | Agent | Propose Strategy + Risk Triage |
| Governance Audit | Agent (💼 Tech Lead) | Check project rules & skills compliance |
| Risk Triage | Agent | Classify risks → Priority Matrix |
| Critical Drill | Agent (🛡️ Security + 🏗️ Architect) | Deep questions for 🔴 Critical |
| Medium Scan | Agent (⏱️ Delivery + 🔍 QA Lead) | Standard questions for 🟡 Medium |
| Low Sweep | Agent (optional) | Quick consistency check |
| Verdict | Agent → User | Present Risk Matrix + recommendation |

## Key Differentiator

Compared to `full-plan` and `phase-loop`:
- **Token efficient:** Skip low-risk phases entirely if user agrees
- **Targeted protection:** 80% effort on the 20% highest risks
- **Risk-aware:** Produces a Risk Priority Matrix — reusable artifact
- **Production-grade:** Suitable for release pipelines and deployment governance

## Anti-patterns

- ❌ Do not use when plan has no Risks table (nothing to triage)
- ❌ Do not use for brainstorms/specs (no concrete risks yet)
- ❌ Do not use when all risks are 🟢 Low (overkill)
