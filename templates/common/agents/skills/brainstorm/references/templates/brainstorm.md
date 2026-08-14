---
Topic: "[Topic Title]"
Date: "YYYY-MM-DD"
Status: "Open"
contributes_to: []
---

# Brainstorm: [Topic]

> **Project:** [project-name]

## Context

[1-2 sentences describing the exploration goal or research question]

## Running Log

### YYYY-MM-DD
- [Finding, idea, or insight from this session]
- [Source reference if applicable]

## Synthesis

[Evolving summary — Agent updates this section as new findings accumulate]

<!-- ⚠️ AGENT INSTRUCTION: Include the following section ONLY IF Deep Reasoning (CoT) was active during this brainstorm session (--deep flag or auto-triggered). Omit entirely if CoT was not active. -->

## 🧠 Deep Reasoning Summary (CoT)

- **Root Problem:** [Concise statement of core challenge]
- **Options Evaluated & Scoring:**

  | Approach | Blast Radius (30%) | Maintainability (25%) | Security (20%) | Door Type (15%) | Efficiency (10%) | Weighted Total | Status |
  |:---|:---:|:---:|:---:|:---:|:---:|:---:|:---|
  | **A. Conservative** | [1-5] | [1-5] | [1-5] | [1-5] | [1-5] | **[Score]** | [Selected/Rejected] |
  | **B. Balanced** | [1-5] | [1-5] | [1-5] | [1-5] | [1-5] | **[Score]** | [Selected/Rejected] |
  | **C. Aggressive** | [1-5] | [1-5] | [1-5] | [1-5] | [1-5] | **[Score]** | [Selected/Rejected] |

- **Critical Trade-Offs:** [Key sacrifices made for safety/scalability]
- **Failure Modes & Guards:** [Key risks identified and mitigated]
- **Decision Type:** [One-Way Door / Two-Way Door]
- **MCP Evidence:** [Graph nodes queried, blast radius data, past decisions surfaced — or "N/A (no graph)"]

## Open Questions

1. [Question that needs further research]
2. [Question 2]

## Next Steps

<!-- ⚠️ AGENT INSTRUCTION:
When user is ready to act, present these options (from /brainstorm Step 5):
  A. 📐 /plan [project] create  — Formalize into implementation plan
  B. 📥 /backlog add            — Create tasks directly
  C. 📝 /spec [project] create  — Write specification before coding
  D. 🔴 /qa [project] [topic]   — Stress-test with Red Team review
  E. 🌱 Keep incubating         — Continue appending to this brainstorm
  F. ✅ Promote to Decision      — Create frozen decision in para-decisions/

Agent MUST wait for user selection before proceeding.
-->

1. [Next action item]

<!-- ⚠️ AGENT INSTRUCTION:
- This is a LIVING DOCUMENT. Agent MAY append new "### YYYY-MM-DD" entries to the Running Log across sessions.
- Agent SHOULD update the Synthesis section when significant new findings are added.
- When the user is ready to finalize a decision, create a SEPARATE file in para-decisions/ using the Decision template, and cross-reference this brainstorm.
-->
