---
name: deep-reasoning
description: >
  Structured Chain-of-Thought (CoT) & Deep Reasoning Protocol for complex problem analysis,
  architectural decisions, security evaluations, and deep troubleshooting. Activate when `--deep` or `--cot`
  flag is present in workflows, or when deep architectural reasoning is required.
version: "1.0.0"
---

# Deep Reasoning Protocol (CoT Engine)

> **Purpose:** Provide a structured, repeatable 4-phase Chain-of-Thought (CoT) reasoning protocol for high-complexity tasks, cross-cutting architectural choices, security audits, and root-cause debugging.
> **Trigger:** 
> - Explicitly activated via `--deep` or `--cot` flags in workflows (e.g., `/brainstorm`, `/sysdesign`, `/fix`, `/spec`, `/plan`).
> - Automatically loaded when analyzing multi-system architecture, breaking changes, complex migrations, or security vulnerabilities.

---

## Reasoning Workflow (4-Phase Cycle)

When this skill is active, the Agent MUST execute the following 4 phases inside its internal reasoning process (`<thought>`) before outputting final proposals or writing artifacts.

```
┌─────────────────────────┐     ┌─────────────────────────┐
│  1. DECOMPOSE & BOUNDS  │ ──► │   2. DIVERGE & SCORE    │
└─────────────────────────┘     └─────────────────────────┘
                                             │
                                             ▼
┌─────────────────────────┐     ┌─────────────────────────┐
│  4. CONVERGE & SYNTHESIZE │ ◄── │   3. RED-TEAM & STRESS  │
└─────────────────────────┘     └─────────────────────────┘
```

---

### Phase 1: Problem Decomposition & Invariants

1. **Root Problem Formulation:**
   - What is the core problem behind the user request? (Separate symptoms from underlying causes).
   - What domain boundaries and systems are touched?
2. **Invariants & Safety Guards Check:**
   - List workspace invariants (Kernel rules, governance, project rules) that MUST NOT be broken.
   - Verify data safety, security parameters, and non-negotiable constraints.
3. **Implicit Assumptions Audit:**
   - Identify unstated assumptions in the request or environment.
   - Mark assumptions that require empirical verification via tools (`view_file`, `grep_search`, `graph_query`).

---

### Phase 2: Divergent Exploration & Multi-Perspective Scoring

1. **Generate 3+ Distinct Approaches:**
   - **Approach A (Conservative):** Minimal change, lowest blast radius, leverages existing patterns.
   - **Approach B (Balanced/Optimal):** Balanced structural improvement, maintainable long-term.
   - **Approach C (Aggressive/Redesign):** Comprehensive refactor, decouples dependencies, maximum scalability.

2. **Multi-Dimensional Scoring Matrix:**
   Score each approach on a scale of 1-5 across core engineering dimensions:

   | Dimension | Weight | Approach A (Conservative) | Approach B (Balanced) | Approach C (Aggressive) |
   |:---|:---:|:---:|:---:|:---:|
   | **Blast Radius & Safety** (Lower risk = higher score) | 30% | [1-5] | [1-5] | [1-5] |
   | **Architectural Quality & Maintainability** | 25% | [1-5] | [1-5] | [1-5] |
   | **Security & Failure Resilience** | 20% | [1-5] | [1-5] | [1-5] |
   | **Reversibility / Door Type** (Two-Way = 5, One-Way = 2) | 15% | [1-5] | [1-5] | [1-5] |
   | **Token & Runtime Efficiency** | 10% | [1-5] | [1-5] | [1-5] |
   | **Weighted Total** | 100% | **[Score]** | **[Score]** | **[Score]** |

3. **Token Overhead Guard & Reasoning Scope Limits:**
   - **Limit:** Keep internal reasoning inside `<thought>` under **300 lines** (approx. 1,500 tokens).
   - **Exit Criteria:** Stop divergent exploration as soon as one approach scores ≥ 0.8 higher weighted score than others.

---

### Phase 3: Red-Teaming & Stress Testing

1. **Failure Mode Analysis:**
   - How will this solution break under 10x scale, high concurrency, or network failures?
   - What happens if an external dependency times out or returns unexpected state?
2. **Edge Cases & Race Conditions:**
   - Null/Empty states, malformed input, missing config, authorization boundary bypasses.
3. **Trade-Off Matrix Construction:**
   - Explicitly articulate what is being sacrificed for what (e.g., "Trading short-term dev speed for long-term schema safety").

---

### Phase 4: Convergence & Decision Synthesis

1. **Selection Rationale:**
   - Select the single optimal approach based on Phase 2 scoring and Phase 3 stress testing.
   - Justify why discarded alternatives were rejected.
2. **Execution Steps & Verification Plan:**
   - Break down the winning approach into atomic, verifiable implementation tasks.
   - Define exact verification criteria (unit tests, static checks, manual inspection).
3. **Structured CoT Artifact Section:**
   Format key insights to present to the user or append to the target document (`brainstorm`, `sysdesign`, `research`).

---

## Output Format (Artifact / Chat Summary)

When outputting decisions derived from this protocol, include a concise **Deep Reasoning Summary** block:

```markdown
### 🧠 Deep Reasoning Summary (CoT)

- **Root Problem:** [Concise statement of core challenge]
- **Options Evaluated & Scoring:**
  | Approach | Blast Radius (30%) | Maintainability (25%) | Security (20%) | Door Type (15%) | Efficiency (10%) | Weighted Total | Status |
  |:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
  | **A. Conservative** | 4.5 | 3.0 | 4.0 | 5.0 (Two-Way) | 4.0 | **3.95** | Rejected |
  | **B. Balanced** | 4.0 | 4.5 | 4.5 | 5.0 (Two-Way) | 3.5 | **4.25** | **SELECTED** |
  | **C. Aggressive** | 2.0 | 5.0 | 3.5 | 2.0 (One-Way) | 2.5 | **3.10** | Rejected |

- **Critical Trade-Offs:** [Key sacrifices made for safety/scalability]
- **Failure Modes & Guards:** [Key risks identified and mitigated]
- **Decision Type:** [One-Way Door / Two-Way Door]
```

---

## 🧪 Test Mode (Sandbox Override)

> **Trigger:** User includes "Test Mode" or explicitly asks to evaluate/test this skill.

When in Test Mode, STRICTLY follow these overrides:

1. **No Live Edits:** Do NOT modify files outside the sandbox directory.
2. **Containment:** Route ALL outputs into `[PROJECT_ROOT]/sandbox/evals/deep-reasoning-[YYYY-MM-DD]/`.
3. **Execute Task:** Carry out the user's prompt as if this skill were active in production.
4. **Generate Report:** After completing the task, create `test-report.md` in the sandbox folder.
