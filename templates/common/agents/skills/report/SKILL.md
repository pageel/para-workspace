---
name: Report Engine
description: Shared reporting engine for generating session, verification, and compliance reports across workspace workflows.
version: 1.0.0
---

# Skill: Report Engine

> Workspace Skill for the Report Engine. Provides standard templates and rules for generating session summary reports, verification logs, and compliance audits.
>
> **Pattern:** Workflow = Logic ➔ Sidecar Skill = Data & Template Router.
> Any workflow invoking the `--report` option loads this skill to generate standardized outputs.

## When to Load

- Triggered when the user runs any workflow with the `--report` flag (e.g., `/plan end --report`, `/verify --report`).
- Loaded by Agent to format and populate objective summaries at session completion or verification phases.

## References

| File | When | Purpose |
|:--|:--|:--|
| `references/dev-session-report-template.md` | Called during plan closure (`/plan end --report`) | Standard structure for comprehensive dev session reports |

## Data Collection & Analysis Instructions

When generating a report, the Agent **MUST** collect and analyze statistics across the following 6 dimensions, compile a General Overview, and execute a Deep-Dive Focus analysis.

### General Overview
- **Accomplishments:** Provide a concise summary of all features implemented, bugs fixed, and goals achieved.
- **Code Quality Evaluation:** Rate the overall cleanliness, type safety, and architectural integrity of the changes.
- **Strengths & Risks:** Highlight the most robust aspects of the implementation and note any remaining risks, code debt, or warnings.

### Core 6 Dimensions

#### 1. Token & Performance
- **Token Estimation:** Estimate the token consumption of the session based on context length or session transcript logs.
- **Latency & Performance:** List execution times for major test suites, build scripts, or AST building. Note performance degradation if any command exceeded normal limits.

#### 2. CSA Compliance
- **CSA Audit:** Run the MCP tool `graph_audit_csa` (or CLI `npx para-graph audit csa`).
- **Traceability:** Document final spec coverage %, active double-binding comments (`// @para-doc`), and identify if any spec anchors are dangling.

#### 3. Snapshot & Drift
- **Drift Detection:** Run the MCP tool `project_snapshot` followed by `project_diff` to get the list of physically added, modified, or deleted files.
- **Comparison:** Cross-check the modified file list against the plan's *File Inventory*.
- **Watchlist Check:** Verify the integrity of files registered under `project_protected_files` to confirm no drift occurred on core structures.

#### 4. TDD Execution
- **Evidence Count:** Read `artifacts/tests/tdd-evidence.log` (if TDD was active).
- **Audit:** Count the exact number of RED (failing test) and GREEN (minimal code passing) states. Confirm that no PASS occurred before a FAIL for each respective feature.

#### 5. Session KI Usage
- **Compaction Status:** Check if `project_session_compact` was run and confirm that [session.md](~/.gemini/antigravity-ide/knowledge/para_vibecode_session/artifacts/session.md) is updated.
- **Recovery Analytics:** Document how many times JIT Context Recovery reloaded indices from `session.md` versus falling back to raw rule parsing.

#### 6. Tool & Terminal Usage
- **Native vs Bash vs MCP:** Count the tool invocations from the session log:
  - **Native API:** `view_file`, `grep_search`, `replace_file_content`, `write_to_file`.
  - **Bash commands:** `run_command` pipeline executions.
  - **MCP tools:** `para-graph` tools.
- Highlight if the specificity priority rule (`MCP -> Native -> Bash`) was obeyed.

### Deep-Dive Focus Analysis

The report **MUST** include a dedicated section focusing deeply on one of the 6 dimensions chosen by the user (the "Focus Area").


#### Focus Area Resolution:
- If `--report-focus` flag is passed, use the matching dimension as the Focus Area.
- If `--report-focus` is not passed, prompt the user: *"Which dimension would you like to deep-dive into? (csa, tdd, performance, drift, tools, session)"*. If the user doesn't specify, default to the area with the most active changes or complexity.

#### Deep-Dive Guidelines per Focus Area:
- **CSA Compliance:** List every spec anchor bound, quote the corresponding spec requirement text, analyze why the implementation meets or exceeds it, and trace the semantic path in the graph.
- **TDD:** Step-by-step breakdown of every RED-to-GREEN transition, detail how the minimal code was written, the refactoring steps performed, and any test coverage challenges.
- **Performance:** Analyze code hotspots, algorithmic complexity of new functions, trace latency bottlenecks in test runs, and propose future optimization steps.
- **Snapshot & Drift:** Detailed breakdown of physical file modifications, explain why any deviating files were modified, and analyze structural changes in the codebase layout.
- **Tools:** Analyze tool call patterns, evaluate tool efficiency, and identify any anti-patterns (e.g. over-reliance on bash commands instead of native tools).
- **Session KI:** Trace context size progression across the session, list specific JIT context recovery events, and evaluate the clarity of compressed guidelines in `session.md`.

