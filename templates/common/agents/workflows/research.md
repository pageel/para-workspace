---
description: Create research case studies documenting agent processes, development timelines, and architecture analysis
---

# /research [project-name] [type] [--brainstorm-sync]

> **Workspace Kernel Version:** 1.7.3 (Brainstorm Integration)

Create structured research documents that capture real-world processes, agent behavior, architecture decisions, and development timelines. Research docs are **internal-only** — never published via `/docs publish`.

## Research Types

| Type          | Slug      | Description                                                   |
| :------------ | :-------- | :------------------------------------------------------------ |
| Agent Process | `process` | Agent thoughts, actions, and decision making (default)        |
| Dev Chronicle | `chronicle` | Development history of a feature/system across multiple sessions |
| Architecture  | `analysis` | Deep dive into system architecture, patterns, and trade-offs  |
| Comparison    | `compare` | Comparison of approaches, tools, or design options            |

> **Default:** If user does not specify type → use `process`.

---

## Principles

> 🛡️ **Constraint:** Read `preferences.language` from `.para-workspace.yml`. All research MUST use this language. Default: `vi`.

1. **Evidence-based.** Every claim must be backed by evidence (tool calls, git commits, file paths).
2. **Chronological.** Organized in chronological order.
3. **Transparent.** Document failures (tool errors, wrong assumptions), not just successes.
4. **Reproducible.** The reader must understand enough to reproduce the process.
5. **Internal-only.** Research is stored in `docs/researches/` — NEVER publish to `repo/docs/`.

## Location

```text
Projects/[project-name]/docs/researches/
├── README.md                                     ← Auto-categorized index
└── [category]/research-[YYYY-MM-DD]-[topic].md   ← Research file (user-defined category)
```
> **Note:** The `[category]/` directory is user-defined based on storage purpose (e.g., `process/`, `architecture/`, `history/`, `compare/`, etc.). The slugs in Research Types act as default categories if not specified.

---

## Steps (all types)

### 0. Pre-flight

// turbo

1. Re-read `.agent/rules.md` (workspace rules index)
2. Re-read `.agent/skills.md` (workspace skills index)
3. Check `project.md` for `agent.rules` / `agent.skills` — if true, re-read project indices too

### 1. Identify Research Scope

Determine:

- **Project**: From user input or active document context
- **Type**: From user input, or infer from request keywords:

| Request keywords                                              | Inferred type |
| :------------------------------------------------------------ | :------------ |
| "suy nghĩ", "agent", "tool calls", "quyết định", "process", "thoughts", "decisions" | `process`     |
| "quá trình", "lịch sử", "timeline", "phát triển", "history"    | `chronicle`   |
| "kiến trúc", "architecture", "patterns", "deep dive"          | `analysis`    |
| "so sánh", "compare", "options", "trade-offs"                 | `compare`     |

- **Topic**: Specific topic (e.g., "knowledge-system-merge", "v1.7.2-workflow-simplification")
- **Scope**: Current session only, or cross-session?

### 2. Gather Evidence

// turbo

Gather evidence based on type:

**For ALL types:**

```bash
# Read project contract
cat Projects/[project-name]/project.md

# Check existing researches
ls -t Projects/[project-name]/docs/researches/ 2>/dev/null | head -5

# Read docs index
cat Projects/[project-name]/docs/README.md 2>/dev/null
```

**Type-specific evidence gathering:**

| Type        | Evidence sources                                         |
| :---------- | :------------------------------------------------------- |
| `process`   | Conversation memory (tool calls, thinking, decisions)    |
| `chronicle` | Git log, brainstorm artifacts, session logs, milestones  |
| `analysis`  | Source code, architecture docs, KI artifacts, schemas    |
| `compare`   | Multiple source files, benchmarks, brainstorm artifacts  |

**`chronicle` evidence:**

```bash
# Git history for the topic period
cd Projects/[project-name]/repo && git log --oneline --since="[start-date]" --pretty=format:"%h %ai %s" -30

# Brainstorm artifacts
ls -t Projects/[project-name]/artifacts/para-decisions/brainstorm-*[topic]* 2>/dev/null
```

**`process` evidence:**
- Primary source: **Conversation memory** — agent recalls all tool calls, thinking, decisions from current session
- Secondary: Try session logs at `~/.gemini/antigravity/brain/[conversation-id]/.system_generated/logs/overview.txt`
- Fallback: Git log + brainstorm artifacts for corroboration

**`analysis` evidence:**

```bash
# Source code structure
find Projects/[project-name]/repo -maxdepth 3 -type f \
  ! -path '*/node_modules/*' ! -path '*/.git/*' ! -path '*/dist/*' | head -50

# Architecture docs
ls Projects/[project-name]/docs/architecture/ 2>/dev/null
```

### 3. Present Research Plan

```
🔬 Research Plan: [topic]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📂 Project: [project-name]
🏷️ Type: [process / chronicle / analysis / compare]
📅 Scope: [current session / cross-session / date range]

📋 Sections planned:
  1. [Section name] — [brief description]
  2. [Section name] — [brief description]
  ...

📦 Evidence collected:
  - [N] tool calls from conversation memory
  - [N] git commits
  - [N] brainstorm artifacts
  - [N] source files read

❓ Proceed? (y/n, or adjust scope)
```

Wait for user confirmation.

### 4. Generate & Integrate Research Document

// turbo

Use the appropriate template from **Research Templates** section below.

Write to `Projects/[project-name]/docs/researches/research-[YYYY-MM-DD]-[topic].md`.

> 🔄 **Brainstorm Integration Protocol (v1.7.3):**
> *   If the `--brainstorm-sync` flag is enabled or during Research document creation/update, the Agent **MUST** scan all files in the project's `artifacts/para-decisions/` and `artifacts/brainstorms/` directories to find brainstorms that contain this research file path within their `contributes_to` array field.
> *   Sort these brainstorms in ascending chronological order.
> *   Instead of just listing raw links in the Mapping section, the Agent **MUST integrate the detailed analysis** of each brainstorm into the Research document, structured into two core sections:
>     1. **Chronological Discussion Log:** List each brainstorm sequentially. For each brainstorm, Agent **MUST** explicitly document:
>        - The options considered (Options Evaluated).
>        - The chosen option (Chosen Option).
>        - A detailed breakdown of the chosen option and its rationale.
>        - A direct clickable file link to the original brainstorm file in the project.
>     2. **Unified Technical Analysis:** Consolidate and merge all detailed technical analyses, ASCII/Mermaid diagrams, JSON schemas, trade-offs, and general evaluations from all brainstorms into a unified, coherent, and highly-detailed section in the main body of the Research document. Do not omit any technical detail or hide them in collapsible elements in this section.
> *   This creates a seamless knowledge flow, making the Research document the most comprehensive and detailed study of that topic.

### 5. Update Doc Index

// turbo

Add entry to `Projects/[project-name]/docs/researches/README.md` under the appropriate **[Category]** section:
*(If the Category does not exist, the Agent automatically creates a new H2 header in the README.md file)*

```markdown
| [topic-title][res-NN]  | [1-line description] | YYYY-MM-DD |

[res-NN]: ./[category]/research-[YYYY-MM-DD]-[topic].md
```

### 6. Suggested Follow-ups

```
🔬 RESEARCH COMPLETE: [topic]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Saved: docs/researches/research-[date]-[topic].md

💡 NEXT STEPS:
  A. 📚 Extract to /knowledge — Persist patterns as KI
  B. 📐 Inform /plan — Use findings for implementation plan
  C. 📝 Create /docs — Turn analysis into architecture doc
  D. 🎓 Extract to /learn — Reusable lesson for Areas/Learning

❓ Which option? (A/B/C/D/skip)
```

---

## Research Templates

### 📡 Type: `process` — Agent Process Case Study

> Record agent thoughts, actions, and decisions. **Each user request is a case study.**

```markdown
# [Topic] — Agent Process Case Study

> **Version**: 1.0 | **Last reviewed**: YYYY-MM-DD
> **Subject**: [1-line description]
> **Session**: YYYY-MM-DD, conversation `[conversation-id]`

---

## 1. Session Context

| Attribute | Value |
|:--|:--|
| Conversation ID | `[id]` |
| Project | [project-name] |
| KIs injected | [list slugs] |
| Active document | [file path] |
| Open documents | [N] files |

---

## 2. Request Log

### Request [N]: "[Exact user request]"

**Timestamp:** ~HH:MM

**Context received from platform:**
- Active document: `[path]` (cursor line [N])
- Open documents: [list relevant ones]
- KI injected: [list]
- Workflow injected: [if @mention]

#### Step 1: [Step name] — **[Purpose]**

> ⚠️ **ANTI-HALLUCINATION RULE:**
> This process log section MUST reflect **100% TRUTHFULLY** the internal thoughts and action decisions of the Agent during tool executions (including errors, leaps, and recoveries). ABSOLUTELY DO NOT embellish or add non-existent steps to paint a perfect picture.

```text
Internal Monologue:
  - [What context data was actually gathered from the previous tool?]
  - [How were choices weighed in the IF/ELSE reasoning trees?]
  - [Were there any misunderstandings or gaps in perception?]

Action Decision:
  - [Conclusion on which tool/command to call and a brief explanation why]
```

#### Step 2: Data Gathering — **[N] tool calls**

```text
BATCH [N] (parallel / sequential):
  ├── [tool_name]([params])    ← [purpose]
  └── [tool_name]([params])    ← [purpose]

Why [parallel/sequential]? [dependency rationale]
```

#### Step [N]: [Step name]

[Repeat pattern...]

#### Summary of Request [N]

```text
Tool calls:   [N] ([breakdown by tool type])
Batches:      [N] ([N] parallel + [N] sequential)
Execution:    ~[N] minutes
Key Decisions: [N] ([list key decisions])
Token Est:
  Input:      ~[N] tokens ([N] files × avg [N] lines)
  Output:     ~[N] tokens ([N] lines generated)
Code changed: [N] files, +[N] / -[N] lines
```

---

## 3. Aggregate Statistics

### Tool Calls

| Tool | Count | Primary Purpose |
|:--|:--|:--|
| `view_file` | [N] | [purpose] |
| `run_command` | [N] | [purpose] |
| `write_to_file` | [N] | [purpose] |
| `replace_file_content` | [N] | [purpose] |
| **Total** | **[N]** | |

### Impact Metrics

**Estimated Tokens (full session):**

| Type | Estimate | Notes |
|:-----|:---------|:------|
| Input (read files) | ~[N] tokens | [N] files × avg [M] lines, ~4 tokens/line |
| Input (user requests) | ~[N] tokens | [N] requests |
| Input (platform inject) | ~[N] tokens | KI summaries + metadata |
| Output (text responses) | ~[N] tokens | [N] responses |
| Output (code generated) | ~[N] tokens | [N] files written/edited |
| **Subtotal** | **~[N] tokens** | |

> **Estimation Rule:** 1 code line ≈ 4 tokens (average). 1 prose line ≈ 8 tokens. JSON/YAML ≈ 6 tokens/line. Parallel batching does not add tokens but reduces latency.

**Code Impact (modified files):**

| File | Action | +Lines | -Lines | Net |
|:-----|:-------|:-------|:-------|:----|
| `[path/to/file]` | created/edited | +[N] | -[N] | +[N] |
| `[path/to/file]` | created/edited | +[N] | -[N] | +[N] |
| **Total** | | **+[N]** | **-[N]** | **+[N]** |

### Key Decisions

| # | Decision | Decision Data | Outcome |
|:--|:---------|:--------------|:--------|
| 1 | [decision] | [evidence] | [outcome] |

---

## 4. Indicators & Patterns (Objective)

> ⚠️ **OBJECTIVE RULE:** Only record repeating behaviors (patterns) or facts from the log. DO NOT extrapolate into subjective conclusions or lessons learned.

### 4.1. [Pattern / Indicator Name]

[Describe pattern + evidence/examples from session, without subjective feedback]

### 4.2. [Pattern / Indicator Name]

[Describe pattern + evidence/examples from session]

---

_Internal Document — YYYY-MM-DD_
_Source: conversation memory, [other sources]_
```

---

### 📜 Type: `chronicle` — Development Chronicle

> Development history of a feature/system across multiple sessions.

```markdown
# [Feature/System Name] — Development Chronicle

> **Version**: 1.0 | **Last reviewed**: YYYY-MM-DD
> **Subject**: [1-line description]
> **Period**: YYYY-MM-DD → YYYY-MM-DD
> **Conversations**: [list conversation IDs]

---

## 1. Context

### Problem to Solve

[2-3 paragraphs describing WHY]

### Proposed Solution

[High-level description of WHAT]

---

## 2. Timeline

### Phase [N]: [Name] (YYYY-MM-DD — Conv [short-id])

**Objective**: [1 line]

| Step | Action | Result |
|:-----|:-------|:-------|
| 1 | [action] | [result] |
| 2 | [action] | [result] |

**Key Decisions:**
- [decision + rationale]

**Git evidence:**

```text
[hash] [date] [commit message]
[hash] [date] [commit message]
```

### Phase [N+1]: [Name] (YYYY-MM-DD — Conv [short-id])

[Repeat pattern...]

---

## 3. Artifacts Created

| Artifact | Type | Path |
|:---------|:-----|:-----|
| [name] | brainstorm | [path] |
| [name] | plan | [path] |
| [name] | code | [path] |

---

## 4. Identify Events/Indicators (Objective)

> ⚠️ **OBJECTIVE RULE:** Only aggregate events, indicators, or facts collected from logs/commits. DO NOT extrapolate into lessons.

### 4.1. [Event / Indicator Name]

[Describe fact/event + evidence]

---

## 5. Final State

| Component | Status | Files |
|:----------|:-------|:------|
| [component] | ✅/🔴/🟡 | [files] |

### Backlog

| # | Item | Priority | Target |
|:--|:-----|:---------|:-------|
| 1 | [item] | [emoji] | [version] |

---

## 6. Evolution Diagram

```text
v[X]          v[Y]          v[Z]
────          ────          ────
[summary] →   [summary] →   [summary]
```

---

_Internal Document — YYYY-MM-DD_
_Source: [list sources]_
```

---

### 🔍 Type: `analysis` — Architecture Analysis

> Deep dive into system architecture, patterns, and trade-offs.

```markdown
# [System Name] — Architecture Analysis

> **Version**: 1.0 | **Last reviewed**: YYYY-MM-DD
> **Subject**: [1-line description]
> **Scope**: [component / subsystem / full system]

---

## 1. System Overview

[2-3 paragraphs describing the system at a high level]

### System Diagram

```text
[ASCII component diagram]
```

---

## 2. Core Components

### [Component 1]

| Attribute | Value |
|:--|:--|
| Location | `[path]` |
| Purpose | [what it does] |
| Dependencies | [list] |
| Consumers | [who uses it] |

**How it works:**

[Details on implementation, data flow, edge cases]

### [Component 2]

[Repeat pattern...]

---

## 3. Identified Design Patterns

| # | Pattern | Location | Rationale |
|:--|:--------|:---------|:----------|
| 1 | [pattern] | [where] | [why] |

---

## 4. Trade-offs & Constraints

| Decision | Gains | Losses | Alternatives Considered |
|:---------|:------|:-------|:------------------------|
| [decision] | [gain] | [loss] | [alternatives] |

---

## 5. Risks & Mitigations

| Risk | Level | Mitigation |
|:-----|:------|:-----------|
| [risk] | 🔴/🟡/🟢 | [mitigation] |

---

## 6. Improvement Proposals

| # | Proposal | Priority | Effort | Impact |
|:--|:---------|:---------|:-------|:-------|
| 1 | [proposal] | [emoji] | [estimate] | [impact] |

---

_Internal Document — YYYY-MM-DD_
_Source: [source code, docs, KI artifacts]_
```

---

### ⚖️ Type: `compare` — Comparison Study

> Compare approaches, tools, options.

```markdown
# [Topic] — Comparison Study

> **Version**: 1.0 | **Last reviewed**: YYYY-MM-DD
> **Subject**: [1-line description]
> **Decision owner**: [user / team]

---

## 1. Context

### Problem to Solve

[WHY we need to decide]

### Evaluation Criteria

| # | Criteria | Weight | Description |
|:--|:---------|:-------|:------------|
| 1 | [criteria] | 🔴 Must | [description] |
| 2 | [criteria] | 🟡 Should | [description] |
| 3 | [criteria] | 🟢 Nice | [description] |

---

## 2. Options

### Option [A]: [Name]

**Concept:** [2-3 sentences]

**Pros:**
- [pro 1]
- [pro 2]

**Cons:**
- [con 1]
- [con 2]

**Evidence:** [code samples, benchmarks, references]

### Option [B]: [Name]

[Repeat pattern...]

---

## 3. Summary Comparison

| Criteria | Option A | Option B | Option C |
|:---------|:---------|:---------|:---------|
| [criteria 1] | ✅/❌/⚠️ | ✅/❌/⚠️ | ✅/❌/⚠️ |
| [criteria 2] | ✅/❌/⚠️ | ✅/❌/⚠️ | ✅/❌/⚠️ |

---

## 4. Decision

**Selected: Option [X]**

**Rationale:**
1. [reason 1]
2. [reason 2]

**Mitigations for cons:**
- [mitigation]

---

## 5. Next Steps

- [ ] [action item]

---

_Internal Document — YYYY-MM-DD_
_Source: [brainstorm artifacts, code analysis, external research]_
```

---

## Output Checklist

- [ ] Research type identified and confirmed with user
- [ ] Evidence gathered from appropriate sources
- [ ] Research plan presented and approved
- [ ] Document follows the correct template for type
- [ ] All claims backed by evidence (tool calls, git commits, file paths)
- [ ] Failures and wrong assumptions included (transparency)
- [ ] `docs/researches/README.md` updated with new entry under the correct type
- [ ] Follow-up action suggested

## Related

- `/brainstorm` — Explore problems before formal research
- `/docs` — Create technical documentation (architecture, CLI, etc.)
- `/learn` — Extract reusable lessons from research findings
- `/knowledge` — Persist key findings as cross-session KI
- `/retro` — Project retrospective (may trigger research)
- `/end` — End session (research may be suggested for significant sessions)
