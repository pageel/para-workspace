---
name: self-improvement
description: >
  Enables the AI Agent to continuously improve developer velocity and code quality
  by recording terminal failures, recurring TDD errors, and architectural drift into
  the para-graph memory, and retrieving past resolutions to avoid repeating mistakes.
version: "1.0.0"
---

# Self-Improvement via para-graph

> **Purpose:** Automate the recording, lookup, and resolution of developer struggles (friction beads) and code quality insights using graph memory.
> **Trigger:** Activates when a terminal command fails (exit code != 0), a Vitest test runs fail twice, linter halts, or during the `/end` workflow.

## Workflow

### Step 1: JIT Retrieval on Failure
Whenever a terminal command or test execution fails:
1. Extract the core error message or error code (e.g. `INVALID_REDIRECT_URI` or `Miniflare transaction failed`).
2. Call `memory_search` or `insight_search` MCP tool on the `para-graph` server with the error string as the query.
3. If a past resolution is found:
   - Apply the solution immediately.
   - Inform the user: *"Retrieving past fix from graph memory..."*
4. If no past resolution is found, proceed to debug and resolve manually.

### Step 2: Friction Beads Logging
Once a new error/friction is successfully resolved:
1. Log the error and the successful resolution using `memory_push` MCP tool:
   - **projectName:** [active-project-name]
   - **kind:** `friction-bead`
   - **content:** Comprehensive detail of the error message and the fix.
   - **metadata:** `{ "category": "linter|test-failure|config-drift", "error_pattern": "[regex/keywords]", "resolution": "[fix applied]" }`
2. Call `memory_curate` MCP tool to consolidate the new memory event.

### Step 3: Post-Session Reflection
During the `/end` workflow (before closing the session):
1. Call the `session_telemetry_query` MCP tool on the `para-graph` server:
   - **projectName:** [active-project-name]
   - **limit:** 5
2. Parse the returned session telemetry logs and friction details.
3. Group the friction events by type/message and summarize the session struggles.

### Step 4: Rule & Insight Graduation
If the same friction bead or error pattern occurs $\ge 2$ times across sessions:
1. Propose a rule graduation to the user in the chat:
   - *"I noticed we solved [Error X] twice. I suggest adding this rule to agent-behavior.md to prevent it from happening again. Approve?"*
2. If approved, append the rule to `.agents/rules/agent-behavior.md` (or the project rules file).
3. Push the finalized lesson learned via `insight_push` MCP tool (kind: `pattern-lesson`).

---

## Input / Output

### Input Example (Friction bead push)
```json
{
  "kind": "friction-bead",
  "sessionId": "2026-07-02-session-auth",
  "content": "Miniflare failed to resolve local D1 mock because seed data was missing in worker directory",
  "metadata": {
    "category": "test-failure",
    "error_pattern": "D1_DATABASE.prepare is not a function",
    "resolution": "Run wrangler d1 migrations apply --local before running vitest"
  }
}
```

### Output Example (Reflection Summary)
```markdown
### 🔄 AI Self-Improvement & Friction Report
- **Telemetry Errors detected:** 3 (Vitest runner exited with code 1)
- **Resolved via Memory:** 1 (Matched pattern: 'wrangler d1 migrations')
- **New Friction Bead recorded:** 1 ('Miniflare transaction timeout')
- **Proposals for User:** 
  - Add rule to `agent-behavior.md` to run local migrations in Phase 0.
```

---

## Edge Cases

- **MCP Server Offline:** If `para-graph` tools are missing or return errors, fall back to writing temporary log files in `artifacts/scratch/friction-beads.log`. Do not block the execution.
- **Empty Query Results:** If `memory_search` returns no matches, proceed directly to standard debugging without warning.

---

## 🧪 Test Mode (Sandbox Override)

> **Trigger:** User includes "Test Mode" or explicitly asks to evaluate/test this skill.

When in Test Mode, STRICTLY follow these overrides:
1. **No Live Edits:** Do NOT modify rules files or workflows outside the sandbox directory.
2. **Containment:** Route ALL outputs and friction-bead logs into `[PROJECT_ROOT]/sandbox/evals/self-improvement-[YYYY-MM-DD]/`.
3. **Execute Task:** Simulate telemetry parsing and report creation using dummy data.
4. **Generate Report:** After completing the task, create `test-report.md` in the sandbox folder.
