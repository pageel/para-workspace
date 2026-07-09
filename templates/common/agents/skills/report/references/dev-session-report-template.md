# Dev Session Report

> **Plan Name:** `[plan-name]` | **Version:** `[version]` | **Report Date:** YYYY-MM-DD
> **Project:** `[project-name]` | **Status:** ✅ Completed

---

## 1. Detailed Session Statistics (Session Dimensions)

### 📊 Token & Performance
* **Total Token Consumption (estimated):** [N] tokens.
* **Average Execution Latency:** [N]ms.
* **Maximum Test Suite Duration:** [N]ms (at [test-file]).
* **Performance Assessment:** [Good / High latency detected at build/test command]

### 🛡️ CSA Compliance
* **Spec Coverage Score:** [N]% (Threshold: >= 90%).
* **Linked Spec Anchors:** [N] anchors.
* **Bound Anchor IDs:** `csa-[anchor-1]`, `csa-[anchor-2]`.
* **Dangling Edges Status:** [No dangling edges detected / [N] dangling edges found].

### 📂 Snapshot & Drift
* **Baseline Snapshot ID:** [Snapshot ID or timestamp].
* **Final Snapshot ID:** [Snapshot ID or timestamp].
* **Physical File Changes vs File Inventory:**
  * Added: [list of files] (Matched / Diverged from plan)
  * Modified: [list of files] (Matched / Diverged from plan)
* **Protected Files Integrity:** [Secure, no modifications / Drift detected at [file_path]].

### 🧪 TDD Execution
* **TDD Cycles Run:** [N] cycles.
* **RED States Recorded (tdd-evidence.log):** [N] FAIL entries.
* **GREEN States Recorded (tdd-evidence.log):** [N] PASS entries.
* **Evidence Accuracy:** [100% Sequence match / Out-of-order execution detected].

### 🧠 Session KI Usage
* **Last Session Compaction:** [Timestamp].
* **JIT Context Recovery Hits (session.md):** [N] times.
* **Token Efficiency Assessment:** [Saved approximately N% tokens compared to loading raw rules].

### 🛠️ Tool & Terminal Usage
* **Native API Tool Calls:** [N] times (`view_file`, `replace_file_content`, `write_to_file`).
* **Bash Command Executions:** [N] times (`run_command` CLI).
* **MCP Tool Calls:** [N] times (`graph_*`, `memory_*`, `project_*`).
* **Heuristic Routing Compliance (MCP -> Native -> Bash):** [100% Compliant / Violation detected at step [X]].

---

## 2. Log Process

> Chronological sequence of actual actions, tool calls, and test executions run by the Agent:

* **[Start Time]** — Initiated session, loaded [session.md](~/.gemini/antigravity-ide/knowledge/para_vibecode_session/artifacts/session.md).
* **[Time]** — Executed `project_snapshot` to establish baseline.
* **[Time]** — Started TDD cycle (RED state).
* **[Time]** — Completed implementation logic (GREEN state) and added `@para-doc` tags.
* **[Time]** — Executed `graph_audit_csa` to verify spec alignment.
* **[Time]** — Ran final snapshot comparison, diff verification, and git commit/push.

---

## 3. Summary & Objective Assessment

* **Summary:** [Brief overview of accomplishments and codebase quality].
* **Objective Assessment:**
  * *Strengths:* [Correct spec implementation, robust CSA coverage, tests passing smoothly].
  * *Risks / Areas for Improvement:* [Remaining linter warnings, or build latency optimization needed].

---

## 4. Deep-Dive Focus: [Selected Dimension]

> Deep-dive analysis focusing on the dimension selected by the user (or determined dynamically):

* **Dimension Details:** [Specific metrics, files affected, or logs analysis].
* **Technical Analysis & Reasoning:** [Deep technical explanation of design decisions, algorithm complexity, or coverage improvements].
* **Observed Behaviors & Mitigations:** [Any errors caught, dynamic adjustments made, or future actions required].

---

## 💾 Storage Proposal

> **MANDATORY:** Agent proposes that the User saves this report to preserve development history:
* **Storage Directory:** `Projects/[project-name]/artifacts/reports/dev/`
* **Suggested Filename:** `report-[plan-name]-[date].md` (e.g., `report-v0.17.3-2026-06-23.md`).

---

## 🎯 Next Steps

* [ ] Update project roadmap at `plans/roadmap-*.md` to `✅ Done`.
* [ ] Run `/retro` to compile lessons learned before closing the feature branch.
* [ ] Propose brainstorm or roadmap phase alignment for the next phase: `[Next Phase Name]`.


