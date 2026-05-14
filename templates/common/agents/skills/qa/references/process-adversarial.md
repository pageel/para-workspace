# QA Process: Adversarial Red Team

> **Slug:** `adversarial`
> **Philosophy:** Devil's Advocate — Assume the artifact is flawed until proven otherwise.
> **Best for:** Architecture decisions, OSS releases, Plans deploying to production.
> **Inspired by:** Military Red Team / Netflix Chaos Engineering / Adversarial ML Testing.

## Process Flow

```
┌──────────────────────────────────────────────┐
│ 1. Kickoff: Full Red Team Roster (ALL 7      │
│    personas activated simultaneously)         │
│    + Focus Areas                             │
├──────────────────────────────────────────────┤
│ 2. Tech Lead Governance Audit                │
│    → Validate project rules & skills         │
│    → Generate & check Governance Checklist   │
├──────────────────────────────────────────────┤
│ 3. Round 1: Independent Attack Vectors       │
│    → Each Persona generates questions        │
│      INDEPENDENTLY                           │
│    → No cross-persona visibility             │
│    → Grouped output by Persona               │
│                                              │
│    ⛔ CHECKPOINT: User review attack vectors │
├──────────────────────────────────────────────┤
│ 4. Round 2: Cross-Persona Debate             │
│    → Agent role-plays each Persona to        │
│      CHALLENGE answers from other personas   │
│    → Create "Debate Cards":                  │
│      Architect says X → Security objects Y   │
│    → Identify unresolved conflicts           │
│                                              │
│    ⛔ CHECKPOINT: User review debates        │
├──────────────────────────────────────────────┤
│ 5. Round 3: Escalation to Tech Lead (PM)     │
│    → Agent assumes 💼 Tech Lead role         │
│    → Synthesize debates → Final ruling       │
│    → Present unresolved conflicts to User    │
│    → User = Final Decision Maker             │
├──────────────────────────────────────────────┤
│ 6. Fix Loop + Comprehensive Re-audit         │
│    → Fix ALL accepted issues                 │
│    → Re-run Round 1 on fixed artifact        │
│    → Verify no regression                    │
├──────────────────────────────────────────────┤
│ 7. Certification Verdict                     │
│    → Sign-off: "Artifact reviewed by N       │
│      personas across M dimensions"           │
│    → Attach debate log as evidence           │
└──────────────────────────────────────────────┘
```

## Characteristics

| Property | Value |
|:--|:--|
| **Scope per round** | Entire artifact (from multiple viewpoints) |
| **Number of rounds** | 3 (Attack → Debate → Ruling) |
| **Token cost** | 🔴 High (7 personas × full artifact × 3 rounds) |
| **Depth** | 🔴 Very High (adversarial + cross-validation) |
| **Best token efficiency** | When cost of failure > cost of review |

## Debate Card Template

```markdown
### 🗣️ Debate: [Topic]

**🏗️ Architect says:**
> [Observation or claim about the architecture]

**🛡️ Security objects:**
> [Counter-argument from security perspective]

**⏱️ Delivery Manager weighs in:**
> [Feasibility concern or timeline impact]

**💼 Tech Lead ruling:**
> [Final recommendation based on project context]
> **Resolution:** [Accept Architect / Accept Security / Compromise]
```

## When to Suggest

- Architecture-level brainstorm decisions (irreversible choices)
- Plans deploying to production environment
- OSS release plans (public-facing, affecting community)
- Security-critical features (auth, payment, data privacy)
- When user requests "stress test hard" or "most thorough review possible"
- When plan budget allows (sufficient tokens for 3 heavy rounds)

## Roles

| Step | Who | Action |
|:--|:--|:--|
| Kickoff | Agent | Activate ALL 7 personas |
| Governance Audit | Agent (💼 Tech Lead) | Check project rules & skills compliance |
| Round 1 | Agent (each Persona) | Independent attack questions |
| Round 2 | Agent (cross-Persona) | Debate + counter-arguments |
| Round 3 | Agent (💼 Tech Lead) | Final ruling + escalate to User |
| Fix | Agent + User | Fix → comprehensive re-audit |
| Certification | Agent → User | Sign-off with evidence trail |

## Key Differentiator

Compared to all other processes:
- **Adversarial mindset:** Assume flawed until proven otherwise (guilty until proven innocent)
- **Cross-validation:** Persona A challenges Persona B — no self-validation
- **Debate log:** Creates an audit trail artifact for future traceability
- **Certification-grade:** Suitable for regulated environments or high-stakes releases
- **Most expensive but most thorough:** Use when cost of failure exceeds cost of review

## Anti-patterns

- ❌ Do not use for small fixes or documentation-only plans (extreme overkill)
- ❌ Do not use when token budget is limited (requires >= 3 heavy rounds)
- ❌ Do not use for early-stage brainstorms (nothing concrete enough to attack)
