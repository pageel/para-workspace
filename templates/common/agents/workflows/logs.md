---
description: Analyze session telemetry, context budget, and agent footprint
source: catalog
---

# /logs [mode] [scope]

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

Diagnostic workflow to track performance, context budget, and Agent I/O. Useful for debugging context decay, agent hallucination, or token bloatedness.

## Arguments

**1. Mode (How to analyze)**
- `(empty)`: **Fast Glance** mode (Default). Quick summary table using Agent's short-term memory impression.
- `--deep` or `deep`: **Structured Audit** mode. Agent performs a meticulous, item-by-item scan of the full conversation context window, producing an exhaustive breakdown with exact lists.

**2. Scope (What to analyze)**
- `--all` (Default): Covers the entire chat session from the start.
- `--last`: Covers ONLY the most recent user request and Agent response cycle.
- `--workflow [name]`: Filters metrics for a specific workflow execution within the session (e.g., `/logs --deep --workflow plan`).

## Steps

### 1. Resolve Mode & Scope

Determine the execution path based on user arguments:
- If `mode` is `--deep` or `deep` → proceed to **Step 3 (Structured Audit)**.
- Otherwise → proceed to **Step 2 (Fast Glance)**.
- Apply `scope` boundaries (`--last`, `--all`, or `--workflow`) strictly to the chosen mode.

### 2. Fast Glance Mode (Impression-based)

The Agent uses its short-term memory impression to quickly estimate the session footprint. Output a concise summary table:

```markdown
📊 **SESSION TELEMETRY (Fast Glance) — Scope: [All / Last / Workflow: name]**

| Category | Count | Notes |
| :--- | :--- | :--- |
| 📚 Knowledge Items | [N] | (KI names) |
| 🛡️ Rules & Skills | [N] | (Names loaded) |
| 📄 Files Read | [N] | (Brief summary) |
| 🛠️ Tools Invoked | [N] | (Tool types — for `run_command`: list key commands) |
| 📝 Artifacts Mutated | [N] | Total files modified or created |
| 💰 Token Budget | ~[N]k | (Incl. KI injection ~[N]k + rules ~[N]k) |
| 🚧 Agent Friction | [N] | (Errors, retries, corrections) |
| ✅ Tasks Progress | [N] | (Done or added) |

> 💡 *Metrics are estimated from memory. Use `--deep` for an exhaustive item-by-item audit.*
> ⚠️ *Token Budget includes platform-injected KI context (`~200-800 tokens/KI`) which is invisible in conversation but consumes context window.*
```

*(Stop workflow execution after printing the table.)*

### 3. Structured Audit Mode (Exhaustive)

The Agent performs a **deliberate, systematic scan** of the entire conversation context window within the defined `scope`. Unlike Fast Glance (which relies on impression), this mode requires the Agent to explicitly enumerate every single item.

> ⚠️ **Context Truncation Warning:** Conversation transcripts can be extremely long. Agent **MUST use the `view_file` tool to read** the conversation log file. DO NOT use bash `cat` to read logs, as it will flood the terminal output and cause immediate context truncation.

**Process:**
1. Scan the conversation context from start to end (or within `scope` boundary).
2. For each category below, list **every individual item** — do not estimate, do not round.
3. **Memory cross-reference (CONDITIONAL):** IF project has `.beads/graph/` directory, use `memory_search` with query "session" to retrieve past session telemetry patterns. Compare current session metrics against historical averages to flag anomalies (e.g., unusually high token usage, excessive tool calls, repeated friction patterns).
4. Format as the detailed report below.

```markdown
📊 **SESSION TELEMETRY (Structured Audit) — Scope: [All / Last / Workflow: name]**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### 📚 Knowledge Items ([N] total)
| # | KI Name | Usage |
|:--|:--|:--|
| 1 | [slug] | [How it was used] |

### 🛡️ Rules & Skills ([N] total)
| # | Type | Name | Trigger |
|:--|:--|:--|:--|
| 1 | Rule | [name] | [Why loaded] |
| 2 | Skill | [name] | [Why loaded] |

### 📄 Files Read ([N] total)
| # | File Path | Purpose |
|:--|:--|:--|
| 1 | `[path]` | [Why read] |

### 🛠️ Tools Invoked ([N] total)

**Non-command tools:**
| # | Tool | Count | Context |
|:--|:--|:--|:--|
| 1 | [view_file / grep_search / write_to_file / etc.] | [N]x | [What for] |

**Commands executed** (each `run_command` = 1 row):
| # | Command | Cwd | Purpose |
|:--|:--|:--|:--|
| 1 | `[exact command line]` | `[working directory]` | [What it did] |
| 2 | `[exact command line]` | `[working directory]` | [What it did] |

> ⚠️ Agent MUST list **every** `run_command` individually with exact `CommandLine`. Grouping like `run_command 9x` is PROHIBITED — it destroys traceability.

### 📝 Artifacts Mutated ([N] total)
| # | Action | File Path |
|:--|:--|:--|
| 1 | Created | `[path]` |
| 2 | Modified | `[path]` |

### 🚧 Agent Friction ([N] total)
| # | Type | Description |
|:--|:--|:--|
| 1 | [Error/Retry/Correction] | [What happened] |

### ✅ Tasks & Progress ([N] total)
| # | Action | Item |
|:--|:--|:--|
| 1 | [Done/Added/Reverted] | [Description] |

### 💰 Token Budget Estimate
| Source | Est. Tokens | Notes |
|:--|:--|:--|
| 📚 KI Injection (platform) | ~[N] | [N] KIs × ~200-800 tokens each (invisible in chat, injected at session start) |
| 🛡️ User Rules (system prompt) | ~[N] | Rules loaded via user_rules block |
| 💬 Conversation turns | ~[N] | User requests + Agent responses |
| 📄 File reads (view_file) | ~[N] | [N] files, avg ~[N] lines each |
| 🛠️ Tool I/O overhead | ~[N] | Tool call/response metadata |
| **Total estimated** | **~[N]k** | |

> ⚠️ KI tokens are **platform-injected** at session start and invisible in the conversation transcript. They consume context window budget but are never shown in chat. Always count them to avoid underestimating total usage.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Conditional Extensions (Sidecar Skill):**

After printing the base report, Agent MUST check for plan-specific audit needs:

```text
IF session has active_plan AND plan uses TDD methodology
  (markers: "Methodology: Strict TDD", 🔴 RED / 🟢 GREEN in task list):
  → Load `.agents/skills/logs/references/tdd-compliance.md`
  → Append TDD Compliance Audit section to the report
  → Cross-reference conversation log + git history for evidence
ELSE:
  → Skip (no extension needed)
```

> 💡 See `.agents/skills/logs/SKILL.md` for available extensions and detection logic.

*(Stop workflow execution after printing the report + any extensions.)*

## Design Notes

- **No artifacts generated.** All output is printed directly to chat. Zero file pollution.
- **No filesystem dependency.** Both modes rely on the Agent's conversation context window, not on external system logs. This ensures portability across AI platforms.
- **Fast Glance vs Deep tradeoff:** Fast Glance is ~50 tokens output, Deep is ~200-400 tokens but provides full traceability for governance audits.

## Related

- `/end` — Conclude session and output persistent review.
- `/plan` — Generate architectural implementation plans.
- `/para-audit` — Macro structural audit (complementary to session-level `/logs`).
