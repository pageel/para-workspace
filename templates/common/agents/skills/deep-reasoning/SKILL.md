---
name: deep-reasoning
description: >
  Structured Chain-of-Thought (CoT) & Deep Reasoning Protocol for complex problem analysis,
  architectural decisions, security evaluations, and deep troubleshooting. Activate when `--deep` or `--cot`
  flag is present in workflows, or when deep architectural reasoning is required.
  Supports MCP Graph integration for codebase-grounded reasoning.
  v2.2.0: Adaptive Budget, Tier Detection, Phase Reentry, Audit Logging, Process Transparency Harness Guard.
version: "2.2.0"
---

# Deep Reasoning Protocol (CoT Engine)

> **Purpose:** Provide a structured, repeatable 4-phase Chain-of-Thought (CoT) reasoning protocol for high-complexity tasks, cross-cutting architectural choices, security audits, and root-cause debugging.
> **Trigger:** 
> - Explicitly activated via `--deep` or `--cot` flags in workflows (e.g., `/brainstorm`, `/sysdesign`, `/fix`, `/spec`, `/plan`).
> - Automatically loaded when analyzing multi-system architecture, breaking changes, complex migrations, or security vulnerabilities.

---

## Process Transparency Harness Guard (v2.2.0)

> **Origin:** Q9 — Discovered when Flash 3.6 Medium executed Tier Detection correctly but skipped artifact creation.
> **Severity:** 🔴 Mandatory — applies to ALL models executing this skill.

### Guard 1: Artifact Creation Enforcement

When this skill is activated inside a workflow that creates artifacts (e.g., `/brainstorm`, `/sysdesign`, `/fix`):

- Agent **MUST** create or append to the workflow's artifact file BEFORE entering Phase 1.
- Agent **MUST NOT** run the 4-phase cycle in `<thought>` only — the process MUST be visible in the artifact.
- If the calling workflow has no artifact mechanism, Agent MUST output phases directly in the chat response.

### Guard 2: Phase Skip Detection

Agent **MUST** execute ALL phases (Step 0, Phase 1, Phase 2, Phase 3, Phase 4). If any phase is skipped:

```markdown
> ⚠️ PHASE SKIPPED: [Phase Name] — Reason: [why]
```

This warning **MUST** appear in the output (artifact or chat). Agent **MUST NOT** silently skip phases.

**Valid skip reasons (exhaustive list):**
- `user-requested` — User explicitly asked to skip
- `empty-graph-downgrade` — Graph exists but returned empty results (Phase 2-3 MCP skip)
- `time-budget-exceeded` — Context window approaching limit

Any other reason is a **protocol violation**.

### Guard 3: Phase Logging in Artifacts

When writing to an artifact file, each phase **MUST** have its own section header:

```markdown
## Step 0: Tier Detection Log
[Tier result table]

## Phase 1: Problem Decomposition & Invariants
[Root problem, sub-problems, invariants]

## Phase 2: Divergent Exploration & Scoring
[3 approaches, 5D Scoring Matrix]

## Phase 3: Red-Team & Stress Testing
[Stress tests, trade-off matrix]

## Phase 4: Convergence & Decision
[Selected approach, rationale, next steps]
```

> **Rationale:** Users MUST be able to trace the full reasoning process by reading the artifact file alone, without needing access to the Agent's internal `<thought>` chain.

## Step 0: Complexity Tier Detection (Pre-Cycle)

> **Timing:** BEFORE the 4-phase reasoning cycle. Agent MUST determine the complexity tier to allocate the correct MCP budget.
> **Gate:** Run Step 0 FIRST, then enter Phase 1 with the allocated budget.

### Hybrid 3-Layer Detection Algorithm

**Layer 1: Prompt Keyword Signals (40% weight, zero-cost)**

| Signal | Tier Hint | Regex Examples |
|:---|:---:|:---|
| Single entity focus | Tier 1 | `"tối ưu function X"`, `"fix bug trong module Y"` |
| Cross-module mention | Tier 2 | `/tích hợp\|integration\|refactor.*module\|cross.*module/i` |
| Architecture/trade-off | Tier 3 | `/redesign\|migration\|architect\|cross-cutting/i` |
| Compare N≥3 options | Tier 3 | `/so sánh.*(3\|4\|5\|nhiều).*option/i` |

**Layer 2: Graph Stats (40% weight, 1 scout MCP call, only when `--graph`)**

Scout call: `graph_god_nodes(topN=3)` → extract `totalNodes`, `topGodEdges`

| Metric | Tier 1 | Tier 2 | Tier 3 | Bonus |
|:---|:---:|:---:|:---:|:---:|
| Total nodes | ≤ 50 (+1) | 51-200 (+2) | > 200 (+3) | — |
| Top god node edges | — | — | — | > 40 (+1) |

No graph available? → Prompt score × 1.5, cap at Tier 2.

**Layer 3: Agent Override (20% weight)**

- Agent MAY upgrade/downgrade 1 level, MUST justify in CoT Summary
- CANNOT downgrade if prompt contains tier3 keywords

**Score Mapping:**

| Score | Tier | MCP Budget | Phase Budget Breakdown |
|:---:|:---:|:---:|:---|
| 1-3 | **Tier 1** | 9 calls | P1: 2, P2: 3, P3: 2, P4: 2 |
| 4-5 | **Tier 2** | 14 calls | P1: 3, P2: 5, P3: 3, P4: 3 |
| 6+ | **Tier 3** | 21 + 3 reentry | P1: 4, P2: 8, P3: 5, P4: 4 (+3 reentry) |

**Mid-Session Escalation:** If Phase 2 `impact_analysis` > 20 affected nodes AND Tier == 1 → upgrade Tier 1→2. Max 1 escalation per session.

> **Scout Call Budget Note:** The Layer 2 scout call (`graph_god_nodes`) counts as 1 call from the Phase 1 budget. If no graph exists, the scout call is skipped and the budget is unchanged.

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
         │                                   ▲
         │    ┌───────────────────────┐       │
         └───►│  PHASE REENTRY (3→2) │───────┘
              │  IF reentry triggered │
              └───────────────────────┘
```

### Graph-Enhanced CoT (MCP Integration)

> **Gate:** Before starting the 4-phase cycle, Agent MUST check if the active project has a code-knowledge graph:
> ```bash
> test -d "Projects/[project-name]/.beads/graph" || test -d "Projects/[project-name]/repo/.beads/graph"
> ```
>
> - **IF graph exists** → Agent MUST use MCP tools to ground each reasoning phase in real codebase data (see per-phase MCP table below). This prevents hallucinated architectural assumptions.
> - **IF no graph** → Agent runs the protocol as pure reasoning. No MCP calls.

### Adaptive MCP Budget Allocation (Per Tier)

> **Budget Rule:** Agent MUST track MCP call count per phase. When phase budget is exhausted, move to next phase. Audit `memory_push` calls (kind: `cot-audit`) are **system overhead** and do NOT count against the tier budget.

**Tier 1 — Simple (9 calls total)**

| Phase | Budget | Priority Tools |
|:---|:---:|:---|
| Phase 1 (Decompose) | 2 | `graph_query`, `memory_search` |
| Phase 2 (Diverge) | 3 | `graph_impact_analysis`, `graph_god_nodes` |
| Phase 3 (Red-Team) | 2 | `graph_edges`, `insight_search` |
| Phase 4 (Converge) | 2 | `memory_push` (cot-decision), optional |

**Tier 2 — Moderate (14 calls total)**

| Phase | Budget | Priority Tools |
|:---|:---:|:---|
| Phase 1 (Decompose) | 3 | `graph_query`, `memory_search`, `graph_context_bundle` |
| Phase 2 (Diverge) | 5 | `graph_impact_analysis` ×2, `graph_god_nodes`, `graph_context_bundle` ×2 |
| Phase 3 (Red-Team) | 3 | `graph_edges` ×2, `insight_search` |
| Phase 4 (Converge) | 3 | `memory_push` (cot-decision), `graph_enrich`, optional |

**Tier 3 — Complex (21 + 3 reentry calls)**

| Phase | Budget | Priority Tools |
|:---|:---:|:---|
| Phase 1 (Decompose) | 4 | `graph_query` ×2, `memory_search`, `graph_context_bundle` |
| Phase 2 (Diverge) | 8 | `graph_impact_analysis` ×3, `graph_god_nodes`, `graph_context_bundle` ×2, `graph_edges` ×2 |
| Phase 3 (Red-Team) | 5 | `graph_edges` ×2, `insight_search` ×2, `graph_impact_analysis` |
| Phase 4 (Converge) | 4 | `memory_push` (cot-decision), `graph_enrich` ×2, `insight_push` |
| Reentry (Phase 3→2) | 3 | `graph_impact_analysis`, `graph_context_bundle`, `insight_search` |

> **Early Exit:** Stop divergent exploration as soon as one approach scores ≥ 0.8 higher weighted score than others. Remaining budget is NOT carried forward.

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
   - Mark assumptions that require empirical verification via tools (`view_file`, `grep_search`).
   - **IF graph available:** Use `graph_query` to locate architectural nodes related to the problem domain. Use `memory_search` to surface past decisions and friction on similar topics — avoid repeating solved problems.

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
3. **Memory Persistence (IF graph available):**
   Push the CoT decision into the knowledge graph via MCP `memory_push`:
   - **kind:** `cot-decision`
   - **content:** Root Problem + Selected Approach (A/B/C) + 5D Weighted Score + Critical Trade-Offs
   - **sessionId:** Current session identifier
   - **metadata:** `{ "cotDepth": 4, "scoringDimensions": 5, "selectedApproach": "[A/B/C]", "weightedScore": [N.NN], "doorType": "[one-way/two-way]", "mcp_evidence": [true/false] }`
   > This enables future sessions to retrieve architectural reasoning via `memory_search(query, category: "cot-decision")`.
4. **Structured CoT Artifact Section:**
   Format key insights to present to the user or append to the target document (`brainstorm`, `sysdesign`, `research`).

---

## Phase Reentry Protocol

> **Scope:** Tier 3 only. Max 1 reentry per session. Direction: Phase 3 → Phase 2 only.
> **Purpose:** When Phase 3 stress testing reveals significant downstream risk that was not fully explored in Phase 2, Agent may re-enter Phase 2 with additional MCP budget to deepen analysis.

### Trigger Conditions

| Condition | Threshold | Rationale |
|:---|:---|:---|
| **Trigger formula** | `downstream_count / total_nodes ≥ 10%` | Scales with graph size |
| **Minimum floor** | ≥ 5 downstream nodes | Prevents trigger on tiny graphs |
| **Maximum ceiling** | DO NOT trigger if ≥ 70% downstream already surveyed | Prevents wasteful reentry |
| **Reentry limit** | Max **1 time** per session | Prevents infinite loops |

### Reentry Budget

When reentry is triggered, Agent receives 3 additional MCP calls:
- 1× `graph_impact_analysis` (deeper blast radius on newly discovered path)
- 1× `graph_context_bundle` (pull callers/callees for feasibility)
- 1× `insight_search` (surface outstanding risks/gotchas)

### Reentry Flow

```
Phase 3 detects downstream_count/total_nodes ≥ 10%
  AND downstream_count ≥ 5
  AND surveyed < 70%
  AND reentry_count == 0
    → Log reentry trigger reason
    → Re-enter Phase 2 with 3 additional calls
    → Continue to Phase 3 → Phase 4
```

---

## MCP Results Ledger & Auto-Summary

> **Purpose:** Prevent MCP result fragmentation across phases. Agent maintains a running Ledger of `_summary` fields from each MCP tool response.
> **Mechanism:** After each MCP call, copy the `_summary` field (if present) into the Ledger. During Phase Reentry or final Convergence, read the Ledger instead of re-calling MCP tools.

### Short Code Registry

| Tool | Short Code | Mnemonic |
|:---|:---:|:---|
| `graph_query` | **GQ** | Graph Query |
| `graph_impact_analysis` | **GIA** | Graph Impact Analysis |
| `graph_god_nodes` | **GGN** | Graph God Nodes |
| `graph_context_bundle` | **GCB** | Graph Context Bundle |
| `graph_edges` | **GE** | Graph Edges |
| `memory_search` | **MS** | Memory Search |
| `insight_search` | **IS** | Insight Search |

### Ledger Format

After each MCP call, record one line in the format:

```
{SHORT_CODE} | {_summary content from MCP response}
```

Example Ledger after a Tier 2 session (14 calls):

```
GQ | 12 function matching 'auth': auth-guard, jwt-handler, rbac-check, session-mgr, token-verify, ...+7
GGN | Top 3: auth-guard(45), db-connector(38), router(32). Total: 150 nodes
GIA | both: 18 affected. Critical: auth-guard→jwt-handler→session-mgr. Depth: 4
GCB | auth-guard: 5↓ callers, 12↑ callees, 3 imports. Tests: yes (2 files)
MS | 3 events (cot-decision). Latest: 2026-08-03. Top: 'Adaptive Budget(4.20)'
...
```

> **Token Budget:** Each `_summary` is 30-60 tokens. Max Ledger size: Tier 3 = 24 entries × 60 tokens = ~1,440 tokens (1.1% of 128K context). Negligible overhead.
> **No `_summary`?** If the MCP response does not contain a `_summary` field, Agent MUST compose a 1-line summary using the short code template format above.

---

## Tier Audit Logging (Dual-Write Protocol)

> **Purpose:** Provide an auditable trail of complexity tier decisions for process improvement and retroactive analysis.
> **Mechanism:** Dual-write — one write for humans (CoT Summary table), one write for machines (`memory_push` with `kind: "cot-audit"`).
> **Budget:** Audit `memory_push` calls are **system overhead** — they do NOT count against the tier MCP budget.

### Logging Events

| Event | Type | Timing | Required? |
|:---|:---|:---|:---:|
| Tier Detection | `tier-detection` | End of Step 0 | ✅ Always |
| Phase Reentry | `phase-reentry` | When triggered | 🟡 Conditional |
| Mid-Session Escalation | `mid-escalation` | When triggered | 🟡 Conditional |
| Session Complete | `session-complete` | End of Phase 4 | ✅ Always |

### Write 1 — CoT Summary Table (Human-Readable)

Agent MUST append this table to the end of the CoT output (after Phase 4):

```markdown
### 🔍 Adaptive Reasoning Audit
| Metric | Value |
|:---|:---|
| **Complexity Tier** | Tier {1/2/3} |
| **Detection Method** | {rule-based / agent-override} |
| **Override** | {none / up:reason / down:reason} |
| **MCP Budget** | {used}/{allocated} calls |
| **Phase Reentry** | {yes:reason / no} |
| **Escalation** | {none / T1→T2:reason} |
| **Ledger Entries** | {count} summaries |
| **Decision Confidence** | {1-5}/5 |
```

### Write 2 — memory_push Schema (Machine-Searchable)

Agent MUST push audit events via `memory_push` with the following schema:

```json
{
  "kind": "cot-audit",
  "content": "[human-readable 1-line summary]",
  "sessionId": "[current session identifier]",
  "projectName": "[active project name]",
  "metadata": {
    "cotEventType": "[tier-detection|phase-reentry|mid-escalation|session-complete]",
    "complexityTier": "[1|2|3]",
    "tierScore": "[1-7+]",
    "tierMethod": "[rule-based|agent-override]",
    "mcpBudget": "[9|14|24]",
    "mcpCallsUsed": "[N]",
    "phaseReentry": "[true|false]",
    "escalation": "[none|T1→T2]",
    "decisionConfidence": "[1-5]",
    "ledgerEntries": "[N]",
    "ledgerHighlights": ["[top 3 _summary entries by impact]"]
  }
}
```

> **Ledger Highlights:** The `session-complete` event MUST include the top 3 most impactful `_summary` entries from the Ledger. Agent selects entries that had the greatest influence on the final decision.
> **Retroactive Query:** Use `memory_search(query: "cot-audit")` to find all past audit events. Filter by `cotEventType` for specific event types.

---

## Output Format (Artifact / Chat Summary)

When outputting decisions derived from this protocol:

1. **In artifact files** (brainstorm, decision, research): Use the Phase Logging structure from Guard 3 above. Include the `🧠 Deep Reasoning Summary (CoT)` block AND the `🔍 Adaptive Reasoning Audit` table at the end.

2. **In chat responses** (when no artifact is created): Include the concise summary block below:

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
