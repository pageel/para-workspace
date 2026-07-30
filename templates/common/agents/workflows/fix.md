---
description: Structured bug diagnosis using Spec, CSA, and Graph Intelligence
source: catalog
---

# /fix [project-name] [bug-description] [--graph] [--session]

> **Workspace Version:** 1.9.5 (Debug Diagnostics Pipeline + Session Escalation)

Structured bug diagnosis workflow that leverages the project's Spec, CSA traceability, and Graph Memory to systematically find root causes — replacing ad-hoc grep-and-guess debugging.

## Options

| Option | Description |
|:--|:--|
| `--graph` | Use para-graph MCP tools for context analysis, impact assessment, and memory search (recommended) |
| `--deep` | Activate Deep Reasoning Protocol (`deep-reasoning` skill) for 4-phase CoT root-cause analysis |
| `--session` | Open a `/vibecode session` upfront to track all diagnosis + fix work with full commit history and quality gates |

## When to Use

| Trigger | Example |
|:--|:--|
| User reports a bug | `/fix pageel-cms logout-returns-403` |
| `/verify` fails | Verification step detects unexpected behavior |
| `/open` finds pending bug | Session log mentions unresolved issue |
| `/scan-sec` detects vulnerability | Security scanner flags a problem |
| `/test-plan` fails | Regression test catches a broken flow |

## Steps

> **Constraint:** Read `.para-workspace.yml` at the workspace root to resolve the user's preferred language.
> Resolution priority:
> 1. If `language` is a map:
>    - chat language = `language.chat` (fallback: `language.default` -> "en")
>    - thinking language = `language.thinking` (fallback: `language.default` -> "en")
>    - artifacts language = `language.artifacts` (fallback: `language.default` -> "en")
> 2. If `language` is a string: chat & thinking & artifacts language = `language`
> 3. If `language` is undefined, look for `preferences.language` (legacy)
> 4. Default ultimate fallback: "en"
> All output (chat response) MUST be translated to the chat language, all internal reasoning (<thought>) MUST be written in the thinking language, and all generated files in artifacts/ (plans, tasks, qa) MUST follow the artifacts language.

### Step 0. Pre-flight & Rule Loading

// turbo

1. Read `rules/diagnostics-debug.md` — load DR2 (Bug Diagnostic Pipeline protocol).
2. Detect active project from `[project-name]` or infer from conversation context.
3. Read `project.md` to understand project scope, tech stack, and CSA configuration.
4. Check if `--graph` flag is set or project has `.beads/graph/metadata.json`.

```bash
# Quick project context
cat Projects/[project-name]/project.md | head -30
ls Projects/[project-name]/.beads/graph/ 2>/dev/null && echo "Graph: Available" || echo "Graph: Not available"
ls Projects/[project-name]/artifacts/specs/ 2>/dev/null | head -10
```

### Step 1. Bug Triage — CSA Reverse Lookup (Spec Traceability)

> **Goal:** Identify WHAT the code was supposed to do, by tracing from the buggy component back to its Spec.

1. **Identify the buggy component/endpoint** from the user's bug description.

2. **CSA Reverse Lookup (if graph available):**
   ```
   graph_query(name: "[component_name]", projectName: "[project]")
   ```
   → Find the component's node → check for CSA anchor (`// @para-doc [#csa-xxx]`).
   → If anchor found → read the original Spec file and section.

3. **Fallback (no graph):**
   ```bash
   grep -rn "@para-doc" Projects/[project-name]/repo/src/ | grep -i "[component_keyword]"
   # Or search specs directly:
   grep -rn "[component_keyword]" Projects/[project-name]/artifacts/specs/
   ```

4. **Read Diagnostics Design (if Spec has §9):**
   - Check `## Error Taxonomy` — does the reported error match a known error code?
   - Check `## Observable Checkpoints` — where should we look for logs?
   - Check `## Environment Parity Risks` — is this a known environment difference?

5. **Present Bug Triage Report:**
   ```
   🔍 Bug Triage:
   - Component: [name]
   - CSA Anchor: [#csa-xxx] → Spec [spec-name.md] §[section]
   - Spec AC violated: [AC-XXX: description]
   - Diagnostics Design available: [Yes/No]
   - Known Environment Risk: [Yes: description / No]
   ```

### Step 2. Graph Context Analysis (Blast Radius)

> **Goal:** Understand the component's dependency tree and check historical knowledge.

**If `--graph` is available:**

1. **Context Bundle:**
   ```
   graph_context_bundle(nodeId: "[buggy_node_id]", projectName: "[project]")
   ```
   → Get callers (who calls this?), callees (what does this call?), and dependencies.

2. **Impact Analysis:**
   ```
   graph_impact_analysis(nodeId: "[buggy_node_id]", projectName: "[project]")
   ```
   → Blast radius: how many other components could be affected?

3. **Memory Search (historical bugs):**
   ```
   memory_search(query: "[bug keywords]", projectName: "[project]")
   ```
   → Has a similar issue been encountered and resolved before?

4. **Insight Search (gotchas):**
   ```
   insight_search(category: "gotcha", projectName: "[project]")
   ```
   → Are there recorded gotchas relevant to this component?

**If no graph:** Fall back to manual analysis using `grep_search` and `view_file`.

> ⚡ **Shortcut:** If memory_search or insight_search returns a matching past resolution,
> present it immediately and ask user: "A similar issue was resolved before. Apply the same fix? (y/n)"

### Step 3. Spec vs Reality Diff (Root Cause Isolation)

> **Goal:** Pinpoint the exact gap between what the Spec promises and what actually happens.

1. **Extract Acceptance Criteria from Spec:**
   List all relevant ACs from the Spec section identified in Step 1.

2. **Compare with actual behavior:**

   | AC | Spec Says | Reality Does | Match? |
   |:--|:--|:--|:--|
   | [AC-001] | [Expected behavior] | [Actual behavior] | ✅ / ❌ |

3. **Root Cause Hypothesis:**
   Based on the gap(s) found, formulate a root cause hypothesis.

4. **Check Environment Parity:**
   If the Spec has Environment Parity Risks table → cross-reference.
   If not → check common pitfalls:
   - Cookie handling differences (local vs CDN/Edge)
   - Body stream behavior (Node.js vs Serverless)
   - URL encoding differences
   - DNS/CORS configuration
   - Timezone/locale differences

5. **Present Root Cause Report:**
   ```
   🎯 Root Cause Analysis:
   - Violated AC: [AC-XXX]
   - Gap: [Spec says X, but reality does Y]
   - Root Cause: [Hypothesis]
   - Environment Factor: [Yes: detail / No]
   - Confidence: [High / Medium / Low]
   ```

> ⛔ CHECKPOINT: Present Root Cause Report to User. Wait for confirmation before proceeding to fix.

### Step 3b. Session Escalation Gate (Traceability)

> **Goal:** Determine if this fix warrants a `/vibecode session` for full history tracking.

**Auto-escalate to session if ANY of these conditions are true:**

| # | Condition | Reason |
|:--|:--|:--|
| E1 | `--session` flag is set | User explicitly requests session tracking |
| E2 | Root cause touches **sensitive code** (auth, crypto, payment, session, CORS) | Security-critical changes need audit trail |
| E3 | Fix requires **≥ 3 files** modified | Multi-file changes benefit from checkpoint commits |
| E4 | Root cause is **environment-specific** (edge, CDN, serverless quirks) | Hard-to-reproduce bugs need detailed documentation |
| E5 | **Previous fix attempt failed** (this is a retry `/fix`) | Iteration history prevents repeating failed approaches |

**If escalation triggers:**

```
📋 SESSION ESCALATION GATE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Trigger: [E1/E2/E3/E4/E5 — reason]

Recommendation: Open a /vibecode session to track this fix with:
  ✅ Full commit history (checkpoint commits per milestone)
  ✅ Quality gates (TDD, --hardened if auth/crypto)
  ✅ Session plan archived for future reference
  ✅ Graph memory push for knowledge retention

Open session? (y/n/skip)
  y → Agent creates DSP: session(fix-[bug-slug])
  n → Continue with standard /fix (no session tracking)
  skip → Continue but log to sprint-current.md for manual tracking
```

**If user confirms (y):**
1. Agent runs `/vibecode session fix-[bug-slug]` (or `--hardened` if E2).
2. The DSP captures: root cause analysis (from Step 3) as Pre-Phase Report, fix implementation as Phase 1 tasks, verification + commit as checkpoint.
3. `/fix` continues from Step 4 but now operates **within the vibecode session** — all changes are tracked, committed, and archived.

**If user declines (n/skip):**
- Standard `/fix` continues without session. Bug is logged to `sprint-current.md` if "skip".

### Step 4. Fix Implementation

> **Goal:** Write code that satisfies the Spec AC — not just "makes it work".

1. **Fix Criteria:**
   - The fix MUST directly address the violated AC from Step 3.
   - The fix MUST handle the identified environment parity issue (if any).
   - The fix SHOULD add or update Observable Checkpoints (structured logging) at the failure point.

2. **Implementation:**
   - Apply the code fix.
   - Add structured log at the fixed location (if not already present).
   - Update existing Observable Checkpoints if they were insufficient to diagnose this bug.

3. **Pre-fix snapshot (if para-graph available):**
   ```
   project_snapshot(projectName: "[project]")
   ```

### Step 5. Verify Fix

1. **Run test suite:**
   ```bash
   # Project-specific test command from project.md or package.json
   npm run test  # or equivalent
   ```

2. **CSA Compliance Check (if graph available):**
   ```
   graph_audit_csa(projectName: "[project]")
   ```
   → Ensure CSA links are still intact after the fix.

3. **Post-fix snapshot & diff (if para-graph available):**
   ```
   project_snapshot(projectName: "[project]")
   project_diff(projectName: "[project]")
   ```
   → Verify only expected files were changed.

4. **Manual verification:**
   If the bug was environment-specific, suggest deployment to staging for verification.

### Step 6. Learn & Evolve (Knowledge Loop)

> **MANDATORY — Agent MUST NOT skip this step (DR4).**

1. **Push Insight to Graph Memory:**
   ```
   insight_push(
     projectName: "[project]",
     category: "gotcha",  // or "lesson"
     content: "[Root cause summary + fix approach]",
     metadata: { component: "[name]", error_code: "[code]", env_factor: "[yes/no]" }
   )
   ```

2. **Update Spec Diagnostics Design (if new risk discovered):**
   - If a new Environment Parity Risk was found → propose adding it to the Spec's §9.
   - If the Error Taxonomy was incomplete → propose adding the new error code.
   - Agent MUST ask user before modifying the Spec: "I discovered a new [risk/error]. Should I update the Spec's Diagnostics Design?"

3. **Propose Regression Test:**
   - If no test covers this specific failure mode → propose creating one.
   - Use `/test-plan` or create inline test suggestion.

4. **Session Log Entry:**
   - Record the bug fix in the active session log (if `/end` will be run later).

### Step 7. Next Steps

Present completion report and recommend next action:

```
✅ Bug Fix Complete: [bug-description]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
- Root Cause: [summary]
- Fix: [what was changed]
- Insight Pushed: [insight_id]
- Tests: [pass/fail]
- Spec Updated: [yes/no]
- Session: [vibecode session active / none]

Recommended next:
  A. /push — Commit and push the fix
  B. /qa — Stress-test the fix before committing
  C. /backlog add — Log a follow-up task for deeper investigation
  D. /end — Close session (if this was the main task)
  E. /vibecode session — Open session for continued work (if not already in session)
```

## Workflow Connections

### Upstream (triggers /fix)

```
/verify (FAIL) ──────→ /fix
/open (pending bug) ──→ /fix
/scan-sec (vuln) ─────→ /fix
/test-plan (fail) ────→ /fix
User report ──────────→ /fix
```

### Downstream (/fix triggers)

```
/fix ──→ /push (commit fix)
/fix ──→ /vibecode session (escalate to tracked session)
/fix ──→ /qa (stress-test)
/fix ──→ /backlog add (deeper issue)
/fix ──→ /spec update (new risk discovered)
/fix ──→ /brainstorm (complex, needs discussion)
/fix ──→ /end (close session)
```
