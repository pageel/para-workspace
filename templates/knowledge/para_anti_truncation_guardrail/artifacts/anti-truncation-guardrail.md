# Anti-Truncation Behavioral Guardrail

## Root Cause
When executing batched `// turbo` bash scripts in workflows (such as `/open` or `/plan`), the Agent's terminal output is hard-capped (e.g., ~220 lines). If the aggregated output of multiple `cat` or `grep` commands exceeds this limit, the system truncates the bottom portion.

## Agent Vulnerability
When the output is truncated, the Agent is deprived of the trailing context (often critical files like `sprint-current.md` or `backlog.md`). Without intervention, the Agent tends to **confabulate (hallucinate)** the missing tasks based on structural patterns, presenting fake data to the user.

## Mandatory Behavioral Rules

1. **Detection:** You MUST actively check the bottom of any bash execution output. If you see `<truncated ...>` or if the expected data is visibly cut off, YOU ARE IN A TRUNCATED STATE.
2. **No Confabulation:** You MUST NOT guess, synthesize, or invent the missing data. 
3. **Active Fallback:** You MUST immediately use native API tools (`view_file`, `grep_search`) to manually read the missing files that were cut off by the bash truncation.
4. **Admit Ignorance:** If you cannot successfully fetch the missing data, you MUST tell the user: *"Bash output was truncated and I could not read [File Name]."* Do NOT pretend you read it.

> **Architectural Fix:** Workflows should progressively migrate from Unstructured Bash reading to Structured JSON Memory (e.g., `task-state-snapshot` via MCP) to bypass output length limits entirely.
