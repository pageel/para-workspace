---
description: Systematic Q&A loop to stress-test plans, specs, and artifacts before execution. Generates probing questions across logic, security, feasibility, and consistency dimensions to catch issues early — saving expensive thinking model tokens.
source: catalog
---

# /qa <action> [target] [--graph] [--sys]

> **Workspace Version:** 1.9.4 (Spec-Audit Enhanced)

Systematic Q&A review and quality audit loop (Red Team) for PARA artifacts (plans, specs, brainstorms, roadmaps). Catches logic errors, security gaps, architectural drift, and CSA audit violations **before** starting code execution.

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

## Actions

| Action | Description | When to use |
|:--|:--|:--|
| `plan` | Phase-by-phase Q&A loop on a Detail Plan | Before `/plan` activation (Draft → Active) |
| `spec` | Section-by-section Q&A on a Spec and alignment check with Sysdesign | Before spec approval |
| `audit` | Compliance-focused Q&A (guards, governance, VCS, CSA) | Post-review harness verification or pre-commit |
| `generic` | Generic Q&A on other markdown artifacts (brainstorms, roadmaps) | Macro artifact evaluation |

## Options

| Option | Description |
|:--|:--|
| `--graph` | Run Graph Pipeline (Build → Query → Bundles) to anchor Q&A in real codebase architecture |
| `--sys` | Cross-validate Spec against the system design (Sysdesign) to detect structural drift (used in `spec` action only) |

---

## Why This Workflow Exists

> **Problem:** Expensive thinking models (Claude Opus, Gemini Pro) often miss logic errors, incorrect sequencing, missing guards, or security gaps in plans — because they generate and self-validate in the same pass.
> **Solution:** A dedicated Q&A loop that acts as a **Red Team** — systematically questioning each section of an artifact from multiple angles. This is cheaper than discovering issues mid-execution.

## Red Team Personas (System Prompt)

> **Agent Context:** When running this workflow, you MUST adopt the combined persona of a top-tier software engineering leadership team. Do not ask superficial or generic questions. Embody the following roles during the Q&A loop:

- 🏗️ **Principal Architect (`[LOGIC]`, `[DEP]`):** You hunt for systemic failures. You ask: _"What happens when this API fails? Is there a circular dependency here? Does this architecture scale, or are we hardcoding a bottleneck?"_
- 🛡️ **Security Auditor (`[SEC]`):** You assume the system is under attack. You ask: _"Are we logging credentials? Is this bash command safe to auto-run? Can a user perform path traversal here? Where is the validation?"_
- 🤖 **AI Security & Boundary Expert (`[SEC]`, `[LOGIC]`):** You anticipate prompt injection, context poisoning, and agent hallucinations. You ask: _"Can a malicious payload in a markdown file trick the LLM into executing harmful commands? Is the agent given too much autonomy without human-in-the-loop validation? Could the graph extraction leak sensitive data to the LLM context?"_
- 🌍 **Open Source Maintainer (`[OSS]`, `[CONS]`):** You enforce English-First governance, licensing, and clean room design. You ask: _"Are there any hardcoded local absolute paths? Does this architecture violate our OSS copyright constraints? Are these documentation blocks compliant with our English-First global contributor standards?"_
- ⏱️ **Delivery Manager (`[FEAS]`, `[COMP]`):** You hate missed deadlines and scope creep. You ask: _"Is this 2-day estimate realistic for integrating a new database? Are we missing critical setup steps in the Walkthrough? Have we verified the third-party dependency even exists?"_
- 🔍 **QA/Test Lead (`[CONS]`):** You are obsessed with edge cases and contradictions. You ask: _"Why does Phase 1 say 'TypeScript' but Phase 3 mentions 'Python script'? How exactly do we verify this step before moving to the next? What is the edge case if the input is null?"_
- 💼 **Project Tech Lead (`[GOV]`, `[COMP]`):** You are the PM who **deeply knows this specific project**. Before asking questions, you MUST read `project.md`, ALL project rules (`.agents/rules/`), ALL project skills (`.agents/skills/`), and the project's release/maintenance process. You ask governance-level questions that generic reviewers miss: _"The project has M6 tarball rule — does this plan include a release phase? The project is OSS — are all commits scoped to `repo/` per M1? The maintenance rule requires version sync across 8 files — is the Governance Checklist complete? Does the Walkthrough cover the project's specific build+test+release cycle?"_
- 📐 **CSA Expert (`[CSA]`):** You enforce Spec-to-Code double-binding and micro-anchoring rules. Before asking questions, you MUST check if the project has CSA configuration. You ask: _"Does the plan map every spec anchor to a physical entity? Are the proposed anchor locations in code correctly positioned above public entities, and not clustered? Do all new anchor IDs follow the kebab-case csa-prefix convention? Are checkpoints for local phase-level CSA checks and a final 100% global CSA audit properly established?"_
- 💻 **Runtime Environment Auditor (`[ENV]`):** You hunt for implicit dependencies on execution context (CWD, environment variables, globally shared mutable state, or platform runtime differences). You ask: _"Does this implementation assume the process runs under a specific working directory? How does it resolve file paths under different runtime environments (CLI vs background daemon)? Are there any implicit assumptions about environment variables, permissions, or global process states?"_

## Modes

| Mode       | Description                                 | When to use                                |
| :--------- | :------------------------------------------ | :----------------------------------------- |
| `plan`     | Phase-by-phase Q&A loop on a Detail Plan    | Before `/plan` activation (Draft → Active) |
| `spec`     | Section-by-section Q&A on a Spec            | Before spec approval                       |
| `artifact` | Generic Q&A on any markdown artifact        | Brainstorms, roadmaps, research docs       |
| `audit`    | Compliance-focused Q&A (guards, governance) | Post-review harness verification           |

## Q&A Dimensions

Each question is tagged with a dimension. Agent generates questions from ALL dimensions per section:

| Dimension        | Tag       | What it catches                                                       |
| :--------------- | :-------- | :-------------------------------------------------------------------- |
| **Logic**        | `[LOGIC]` | Incorrect sequencing, circular dependencies, impossible preconditions |
| **Security**     | `[SEC]`   | Exposed secrets, unsafe auto-run, missing VCS guards                  |
| **Feasibility**  | `[FEAS]`  | Unrealistic time estimates, missing tools/deps, untested assumptions  |
| **Completeness** | `[COMP]`  | Missing steps, files, guards, edge cases                              |
| **Consistency**  | `[CONS]`  | Mismatched numbers, names, refs across sections                       |
| **Dependencies** | `[DEP]`   | Missing imports, unresolved cross-phase deps, version conflicts       |
| **Governance**   | `[GOV]`   | Missing project rules compliance, release process gaps, checklist drift |
| **Environment**  | `[ENV]`   | Implicit process state dependencies (CWD drift, global mutations, environment differences) |

---

## Steps

### Phase 1: Question Generation & Approval

### Step 0. Pre-flight

// turbo

1. Identify the target artifact from user input or active document.
2. Determine the mode (`plan`, `spec`, `artifact`, `audit`) — auto-detect from file location if not specified:
   - `artifacts/plans/*.md` → `plan` mode
   - `artifacts/specs/*.md` → `spec` mode
   - Default → `artifact` mode
3. Read the target file fully.
4. **Context Gathering (MANDATORY):** To ask deep, expert-level questions, you MUST NOT review the artifact in a vacuum. Before proceeding, you MUST:
   - Read `Projects/[project]/project.md` to understand the overarching contract and dependencies.
   - Read any explicitly linked Knowledge Items (KIs) or Rules.
5. **Project Governance & CSA Loading (MANDATORY for `[GOV]` and `[CSA]` personas):** The Project Tech Lead and CSA Expert personas require full project context. Agent MUST:
   - Read project `.agents/rules.md` index → load ALL project rules (e.g., `maintenance.md`, `review.md`).
   - Read project `.agents/skills.md` index → load ALL project skills.
   - Check `Projects/[project]/project.md` for `csa:` configuration (thresholds, gates) or existence of a `csa-compliance.md` rule.
   - If CSA is enabled for the project:
     - Load `csa-compliance.md` rule and `csa.md` QA domain template.
     - Mandate that **CSA Expert** is activated for the Red Team Roster.
   - Identify: project type (OSS/internal), release process, build tool, git scope rules.
6. **Memory-Assisted QA (CONDITIONAL):** IF project has `.beads/graph/` directory, use `memory_search` to find past QA findings, known issues, and recurring patterns. Specifically, search for friction beads and past decisions related to the physical files specified in the target plan's inventory. This prevents Red Team from re-raising resolved issues, and allows them to ask historical questions based on past project quirks.
7. **Domain-Specific Red Team Templates:** Load the expert persona templates from `.agents/skills/qa/domains/` (if any).

### Step 0.25. Graph Context Pipeline (if --graph)

If the `--graph` flag is provided, execute an INTERACTIVE Graph Preparation Phase BEFORE creating the QA Strategy:

1. **Build Graph:** Run the graph build command (using `run_command` in a separate turn) to ensure graph data is up-to-date. 
   - *Note on Working Directory:* If the project has a `repo/` directory (e.g., `Projects/[project]/repo/`), the `Cwd` MUST be set to that `repo/` directory, not the project root.
2. **Identify & Analyze Nodes:** Use MCP tools (`graph_god_nodes`, `graph_query`, `graph_context_bundle`, `graph_impact_analysis`) to deeply analyze the core files and God nodes related to the artifact.
3. **Enrich:** For any unenriched God nodes found, use `graph_enrich` to document their semantic meaning.
4. **Pattern Verify (Step G, para-graph §4.2):** If the artifact contains file count estimates for inline code patterns, run `grep_search` to cross-validate. Challenge: "Does the plan claim N files? Verify with grep."
5. **Interactive Report:** Pause the workflow and present a Chat Report to the user containing the impact analysis and blast radius of the components covered in the artifact.
6. **Wait for User:** Ask if the user wants to analyze any other aspects/nodes before generating the QA Strategy. **STOP HERE.** Proceed to Step 0.5 only after user confirms.

### Step 0.5. Process Selection & Pre-QA Strategy (The QA Kickoff)

> **IMPORTANT:** Do NOT generate questions yet.

#### Step 0.5a. Process Selection

> 🧩 **Sidecar Skill:** Load `SKILL.md` §5 (Process Selection Router) for the comparison matrix and auto-suggest heuristics.

1. **Analyze artifact characteristics:** Count phases, risks, lines, and mode.
2. **Auto-suggest a process** using the heuristics from `SKILL.md` §5.3.
3. **Present the selection prompt:** You MUST present the menu EXACTLY as a literal code block, line-by-line, as defined in `SKILL.md` §5.4. Do not summarize or flatten the options into a single paragraph.

⛔ **CHECKPOINT:** Agent MUST STOP the workflow here and wait for the user's explicit process selection. Do NOT proceed to generate questions or create the QA Strategy until the user selects a process (1-4).

4. **After user selects:** Load the corresponding `references/process-*.md` template from the QA skill. This template defines the flow that governs all subsequent steps.

#### Step 0.5b. QA Strategy Creation

1. **Create the QA Report file immediately:** 
   - Generate a collision-safe filename: `Projects/[project]/artifacts/qa/qa-[date]-[mode]-[target]-[seq].md`.
   - Initialize the file with the Report Header (see `SKILL.md` §1) and a new `## 0. QA Strategy` section.
   - Add `> **Process:** [slug]` to the Report Header to record the selected process.
2. **Propose the Strategy:** In the `## 0. QA Strategy` section of the file, the Agent MUST write:
   - **Focus Areas — Coverage Tracker:** Based on the artifact's nature (e.g., SQLite migration, API design), list the 3-7 most critical areas that need stress-testing. Format as a TABLE with columns `#`, `Focus Area`, `Round 1`, `Round 2`, `Status` (initially all `⏳ Pending`). This table will be updated after each round to show which questions covered which area.
   - **Red Team Roster:** Select the 3-4 most relevant Personas from `SKILL.md` §2 (e.g., Principal Architect, Security Auditor) that will lead this specific review. Justify why they are chosen.
     - *CSA Expert Rule:* If the target project has CSA configuration (i.e. `csa:` exists in `project.md` or `csa-compliance.md` rule is active), the Agent **MUST** automatically include the **CSA Expert** in the roster.
     - *OSS Expert Rule:* If the target project is an open-source project (i.e., `tags` in `project.md` contains `oss`), the Agent **MUST** automatically include the **Open Source Maintainer** in the roster.
   - **Process Log:** Create an empty table with columns `Round`, `Trigger`, `Scope`, `Questions`, `Critical`, `Fixed`. Agent MUST append a row after each round of Q&A completes.
3. **Wait for Approval:** Present this strategy to the user. **STOP HERE.** Do not proceed to structure scan and question generation until the user approves the strategy or adjusts the focus areas.

### Step 0.75. Tech Lead & CSA Governance Pre-flight

Before diving into general Red Team questions, the Agent MUST step into the roles of the **Project Tech Lead** and **CSA Expert** to enforce project-specific compliance and specification double-binding:

1. **Load Context:** Read the project's `.agents/rules.md` and `.agents/skills.md` indexes. Identify and read all project-specific rules (e.g., `maintenance.md`, `csa-compliance.md`) and skills.
2. **Project-Specific QA Rules Integration:** Check if the project rules index contains a rule file mapping to `qa.md` (e.g., `Projects/[project]/.agents/rules/qa.md`). If present, read it and extract all pre-defined checklist questions.
3. **Generate Governance & CSA Checklist:** Create a dedicated set of crucial checklist questions by combining:
   - The pre-defined project questions extracted from `Projects/[project]/.agents/rules/qa.md` (if any, including `[CSA-1]` to `[CSA-4]` spec/anchor questions).
   - Custom compliance questions generated strictly from the loaded rules (`maintenance.md`, `csa-compliance.md`, etc.) and project skills.
   - If CSA is enabled, include specific checks for spec anchor mapping, micro-anchoring placement (G1-G3), anchor kebab-case format, and phase-level commit/release gates.
4. **Document:** Append this combined checklist to the QA Report file under a new `## 0.5 Tech Lead & CSA Governance Checklist` section.
5. **Halt for Review:** The Agent MUST stop and present this checklist to the user. **STOP HERE.** Wait for the user to confirm this checklist before moving to structure scan and general question generation.

### Step 1. Structure Scan

// turbo

Parse the artifact structure:

- **Plan mode:** Extract Phase headings, Task Lists, Walkthrough, Risks table, Git Operation Summary.
- **Spec mode:** Extract sections (Scope, Constraints, Acceptance Criteria, Edge Cases).
- **Artifact mode:** Extract all `##` headings as sections.
- **Audit mode:** Extract all guards (MANDATORY, HARNESS, CHECKPOINT), File Guards, Governance Checklist.

Output a **Structure Map**:

```
📋 STRUCTURE MAP: [filename]
---
Sections: N
Tasks: N (across M phases)
Guards: N (MANDATORY: x, HARNESS: y, CHECKPOINT: z)
Risks: N
Git Operations: N commits + N pushes
---
```

### Step 2. Generate Probing Questions

For each section/phase in the artifact:

0. **All-Phases Coverage Enforcer (MANDATORY):** If the process is phase-loop or risk-driven, the Agent **MUST NOT** skip or orphan any phase defined in the Structure Map. The QA questions and audit rounds **MUST** cover 100% of the phases/sections. If the Agent splits the QA process into consecutive rounds/vessels, the Agent **MUST** explicitly track which phases are pending, and **MUST** proceed to the next round until all phases from the Structure Map are audited.
1. **Context Recovery & Rule Check (MANDATORY):** Before generating questions for the current phase or section, Agent MUST actively re-read the project rules index (`.agents/rules.md`) and load any relevant rule files (e.g., `maintenance.md`) to verify if any specific checklists, caveats, or constraints apply to the current Phase's specific actions.
2. **Phase-Specific Graph Context (if --graph AND phase-loop process):** Agent MUST execute the Graph Context Pipeline (Step 0.25) scoped specifically to the nodes modified or affected by this Phase. This ensures focused impact analysis.
3. **Generate probing questions** based on the approved Focus Areas, Red Team Roster, the actively recovered Rules context, and the **specific project domain context** (especially for `spec` mode):
   - **Spec-to-Sysdesign Cross Analysis (MANDATORY for `spec` mode):** The Agent MUST NOT generate generic questions. Instead, it MUST analyze the target Spec alongside the active system design (`sysdesign-*.md`) and codebase structure to identify domain-specific risks (e.g., payload mismatch, concurrency bottlenecks, security loopholes like session management drift, database foreign key constraints conflict).
   - **Dynamic Contextualization:** Draft questions that reference physical entities (API endpoints, database tables, specific modules) rather than abstract concepts. Use the persona templates in the QA Skill only as a baseline of *how* to question, but generate the *what* entirely based on the target artifact's technical details.
   - **No Arbitrary Limits:** Generate **as many questions as necessary** to fully stress-test the section.
   - Each question MUST be tagged with a dimension (`[LOGIC]`, `[SEC]`, etc.).
3. **Do NOT answer them yet.**
4. **Format the output** as a Question List and **Append** them to the `## 2. Red Team Findings` section of the QA Report file created in Step 0.5.

```
---
📌 Phase N: [Phase Name]
---
- Q1 [LOGIC]: [Question about sequencing or preconditions]
- Q2 [SEC]: [Question about security or unsafe operations]
- Q3 [COMP]: [Question about missing steps or files]
...
```

### Step 3. Interactive Iteration Loop

1. Present the generated Question List to the user in the chat.
2. **Agent Suggestion:** Proactively suggest 1-2 areas where deeper questions could be asked.
3. **Ask user:** "Do you approve this question list? You can add your own questions, ask me to re-roll, or type `deep [aspect]` to add deep source-code level questions (e.g. `deep logic`, `deep sec`)."
4. **Deep Review (Dual-Pass) Options:** Display the following options for High-Token Models:
   ```text
   🚀 Deep Review Options: To run a deep source-level review, type:
   - `deep`       : Comprehensive review (Line-by-line).
   - `deep logic` : Focus on algorithm logic and Edge cases.
   - `deep sec`   : Hunt for hidden security vulnerabilities.
   - `deep perf`  : Analyze performance, bottlenecks, memory leaks.
   - `deep int`   : Verify cross-file Data Payload and API Contracts.
   - `deep clean` : Review Code Smells and propose Refactoring.
   *(Note: The Agent will ingest the full repository source code upon activation).*
   ```
5. **Loop:** If the user adds questions or requests a `deep` aspect:
   - Generate the new questions.
   - Append them to the QA file.
   - Present again.
6. **Wait for final approval.** **STOP HERE.** Do not proceed to Phase 2 until approved.

---

### Phase 2: Execution & Answering

### Step 4. Change Role & Deep Dive

Once the user approves the questions OR triggers a `deep` review, the agent MUST change role to executor:
1. **If `deep` review triggered:** The user must be on a High-Token Model. Agent MUST ingest the full repository source code relevant to the target, combine it with Phase 1 results, and generate answers focusing strictly on the requested aspect (`logic`, `sec`, `perf`, `int`, `clean`, or all).
2. Re-verify any complex code relationships, upstream specs, or missing artifacts that you deferred in Phase 1. Use `mcp_para-graph` tools to trace deep dependencies or impacts if a question requires codebase analysis.
3. Ensure you have actively loaded the relevant `skills` and `rules` files into memory before answering.

### Step 5. Answer & Verdict (Per Question Loop)

1. **Self-answer each approved question** by analyzing the artifact against the deep context loaded in Step 4.
2. **Assign a verdict** to each answer:
   - `✅ OK` — No issue found.
   - `⚠️ Issue` — Minor gap, can be fixed easily.
   - `🔴 Critical` — Blocks execution, must fix before activation.
3. Format as Q&A Cards:

```
---
📌 Phase N: [Phase Name]
---
Q1 [LOGIC]: [Question]
→ A1: [Deep Answer based on loaded context]
→ Verdict: ✅ OK | ⚠️ Issue | 🔴 Critical
```

### Step 6. Cross-Section Consistency Check

After all sections are reviewed, perform cross-cutting checks:

| Check                    | What to verify                                                       |
| :----------------------- | :------------------------------------------------------------------- |
| **Task numbering**       | Are task numbers sequential and non-duplicated?                      |
| **Git refs**             | Do Git Operation Summary refs match actual task numbers?             |
| **Walkthrough coverage** | Does every key deliverable appear in Walkthrough?                    |
| **Risk→Guard mapping**   | Does every Risk row have a corresponding HARNESS GUARD in its Phase? |
| **Dependency chain**     | Does Phase N actually depend on Phase N-1 output?                    |
| **File scope**           | Are all modified files listed in `git add` commands?                 |
| **Version consistency**  | Is version number the same across all mentions?                      |

### Step 7. Issue Summary, Recommendations & Next Steps

Compile all `⚠️ Issue` and `🔴 Critical` findings into a summary table:

```
---
📊 Q&A SUMMARY: [filename]
---

Total Questions: NN
✅ OK:       XX (YY%)
⚠️ Issues:   XX
🔴 Critical: XX

| # | Dim | Phase | Issue | Fix |
|---|---|---|---|---|
| 1 | [LOGIC] | Phase 4 | Build before test missing | Task X.Y |
| 2 | [SEC] | Phase 2 | No guard on git push | Removed |
| ... | | | | |

VERDICT: ✅ Ready for activation | ⚠️ Fix N issues first | 🔴 BLOCKED
---
```

**After writing the summary, Agent MUST:**

1. **Update Coverage Tracker:** Go back to `## 0. QA Strategy` and update the Focus Areas table — mark each area's Status as `✅ Covered` or `⏳ Pending` based on which questions touched it. Map each Q# to the corresponding Focus Area rows.
2. **Update Process Log:** Append a new row to the Process Log table with the round number, trigger command, scope, question range, critical count, and fix count.
3. **Generate Next Steps Menu:** At the bottom of the Strategy section, write a `### 🚀 Next Steps` subsection using the decision table from `SKILL.md` §1 (QA Report Template → Next Steps section).
4. **Update Header Verdict:** Change the Report Header's `Verdict` field from `[Pending]` to the final verdict (e.g., `✅ PASSED (12/12 Questions Resolved — 2 Rounds)`).
5. **Present the Next Steps** to the user in the chat and wait for their decision.


### Step 8. Fix Loop & Post-Fix Re-Audit

If issues were found:

1. **Present each issue** with a proposed fix.
   - **For 🔴 Critical risks:** Agent SHOULD proactively suggest using the `@[/brainstorm]` workflow methodology to generate 3-5 distinct options (Ideation) per issue BEFORE proposing a final fix. This ensures high-risk problems are solved with architectural rigor rather than quick patches.
2. **Ask user:** "Fix this now? (y/n/skip) or run Brainstorm for solutions?"
3. If user approves → apply the fix immediately.
4. **Post-Fix Full Re-Audit:** After all fixes are applied, the artifact has changed. Agent MUST re-load the updated artifact context and perform a comprehensive re-evaluation (re-running Step 6 Cross-Section Check AND verifying that the fixes did not introduce new Security/Logic/Governance violations).
5. If new issues are found during re-audit, return to 8.1.
6. **Halt for Tracking Confirmation:** Before updating the Plan's tracking tables, the Agent MUST STOP and present a proposal: "All issues fixed. Shall I automatically update the *Review & Audit Tracking* table and tick the *Project Governance Checklist* in the Plan to conclude this QA loop? (y/n)"

### Step 9. Audit Tracking Update (User Approved)

**Only perform Tracking Update if the user approved it in Step 8.6.**

Update the target artifact's **Review & Audit Tracking** table (if present) by mapping the Q&A results to the standard criteria rows:

1. Analyze the passed (✅ OK) questions and map them to the table rows:
   - `[LOGIC]`, `[CONS]`, `[DEP]` → **Logic review**
   - `[SEC]` → **Security review**
   - `[COMP]`, `[FEAS]` → **Checklist review**
   - `[GOV]`, `[OSS]` → **Project governance compliance**
2. For each mapped row that had at least one question verified:
   - Increment its `Count`.
   - Set `Last reviewed` to today's date.
3. Add or update the summary row `Q&A review ([mode])` to include the total statistics (e.g., `Total: X | ✅ Y | ⚠️ Z | 🔴 W`) and increment its `Count`.
4. **Check off Governance Checklist:** If the Tech Lead Governance pre-flight passed, tick the checkboxes `[x]` for the triggered rules in the Plan's `Project Governance Checklist` section.

### Step 10. Save Report (Optional)

If the Q&A generated ≥ 10 questions or found ≥ 3 issues:

1. **Ask user:** "Save Q&A report as artifact? (y/n)"
2. If yes → save with **collision-safe naming**:

   **Filename pattern:** `qa-[date]-[mode]-[target]-[seq].md`

   **Sequence resolution:**
   ```bash
   # Count existing reports for same date+mode+target
   ls Projects/[project]/artifacts/qa/qa-[date]-[mode]-[target]-*.md 2>/dev/null | wc -l
   # seq = count + 1, zero-padded to 2 digits (01, 02, ...)
   ```

   **Examples:**
   - First run:  `qa-2026-05-06-plan-v0.11.0-hook-injection-01.md`
   - Second run: `qa-2026-05-06-plan-v0.11.0-hook-injection-02.md`

   **Target slug rules:**
   - Derive from artifact filename (strip date prefix and `.md` extension)
   - Keep kebab-case, max 60 chars
   - If target is the active plan → use plan filename as slug

3. Format: full Q&A cards + summary table + fixes applied.
4. **Link to Artifact:** Ngay sau khi lưu file QA, Agent BẮT BUỘC phải chèn một dòng `> **QA Report:** [qa-report-name.md](path/to/qa-report.md)` vào ngay bên dưới header/frontmatter của file mục tiêu (target artifact) để tạo bằng chứng Audit (Audit Trail).

### Step 11. Graph Memory Push (CONDITIONAL)

> **Gate:** Only trigger if project has `.beads/graph/` directory.

1. Check graph availability:
   ```bash
   test -d "Projects/[project-name]/.beads/graph" && echo "✅ Graph Memory available" || echo "⏭️ No graph — skip memory push"
   ```

2. **IF graph exists:**
   Push the QA summary via MCP `memory_push`:
   - **kind:** `qa-review`
   - **content:** Verdict + critical count + key findings summary
   - **sessionId:** `YYYY-MM-DD-qa-[mode]-[target]`
   - **metadata:** `{ "mode": "[plan/spec/artifact/audit]", "total_questions": N, "critical": N, "verdict": "[PASSED/BLOCKED]" }`

3. **Curate memory:** After pushing, call `memory_curate(projectName)` to consolidate.

4. **IF no graph** → Skip silently.

### Step 12. Self-Improvement & Process Graduation (CONDITIONAL)

> **Purpose:** Analyze resolved QA issues (`⚠️ Issue` or `❌ Fail` verdicts) to propose systemic process improvements (rules, workflows, templates).

1. Review all QA questions in this review round that had a verdict of `⚠️ Issue` or `❌ Fail` (prior to resolution).
2. If any of these issues represent systemic gaps (such as outdated templates, missing rules, or lack of automated tooling):
   a. **Propose Rule/Workflow Graduation:** Suggest creating/updating a rule in `.agents/rules/agent-behavior.md` or a template in `.agents/workflows/`.
   b. **Prompt for Consent:** Proactively present the proposal to the user in the chat and wait for confirmation before applying.

### Step 13. Handover & Execution Guard

**CRITICAL RULES:**
1. **NO AUTO-EXECUTION:** After completing the QA review, the Agent **MUST NOT** perform any coding task or file modification.
2. **HANDOVER REQUIREMENT:** The Agent **MUST** stop execution and recommend the next action based on the QA mode:
   - **IF mode = plan:** If all phases/tasks in the target plan have been fully reviewed, the Agent **MUST** explicitly recommend running the slash command `/plan [project-name] dev` to begin development. Otherwise (e.g., in phase-loop or risk-driven mode with pending phases), the Agent **MUST** propose the next Q&A review round for the remaining phases and **MUST NOT** suggest development execution. The Agent **MUST NOT** suggest manual file modifications before the `/plan dev` workflow is initiated (Mandatory per Rule 3d).
   - **IF mode = spec:** The Agent **MUST** return to the parent `/spec` workflow context, present the finalized specification (with all QA fixes integrated), and request the user's final approval (Gate 1). The Agent **MUST NOT** suggest creating a new spec or starting a plan before the user explicitly approves the current specification.
   - **RECOMMENDATION CONTEXT RULE:** Across all modes, when presenting next steps, the Agent **MUST** explicitly recommend exactly one option as the primary choice and write a clear, context-specific rationale explaining *why* the user should choose it based on the current state of the codebase, backlog, and spec compliance.

## Spec Action — Additional Checks (Spec Audit)

When running `/qa spec`, the Agent MUST perform these automated quality control steps:

### 1. Spec Quality Checklist Audit

> 🧩 **Spec Skill:** Load the Spec Governance Skill (located under `skills/spec/`) to retrieve all check items from the Spec Quality Checklist.

The Agent matches the Specification against the verification check items retrieved from the Spec Governance Skill and aggregates the quality score (e.g., `[passed]/[total] Pass`).

### 2. Sysdesign Alignment & Spec Overlap Check
If the `--sys` option is enabled or a system design file exists under `artifacts/sysdesigns/`:
*   **API Schema Check:** Compare the new/modified API endpoints in the Spec against the communication design in Sysdesign to detect payload, query params, or HTTP method drift.
*   **Database Schema Check:** Compare SQL DDL statements, field types, foreign keys, and check constraints in the Spec Migration against the ERD of the Sysdesign. Detect logic errors (e.g., conflicting foreign key constraints or missing columns).
*   **Structure Check:** Ensure the proposed file structure in the Spec conforms to the software architecture layout defined in the Sysdesign.
*   **Spec Overlap Check:** Scan the existing specs in `artifacts/specs/` to verify that the target Spec documents boundaries clearly when overlapping with existing Specs, preventing duplicate requirements or conflicting definitions.

### 3. CSA Anchors Audit
*   **G1 (One-to-One):** Ensure each `<span id="csa-...">` anchor serves exactly one unique test verification or business requirement.
*   **G2 (Reverse Validation):** Verify if changing the corresponding code file would invalidate the anchor description.
*   **G3 (No Blanket):** Prohibit placing blanket anchors at the macro header level (H1/H2) without detail breakdown.
*   **Format Check:** Ensure all anchor IDs start with `csa-` and use kebab-case format.

---

## Question Templates (Per Dimension)

> **📦 Sidecar Skill:** Question templates and persona question banks are maintained in the QA Sidecar Skill.
> Agent MUST read `SKILL.md` §2 (Persona Question Banks) and §3 (Dimension Seed Patterns) at Step 2 for inspiration.
> This avoids duplicating ~80 lines of reference data in the workflow.
>
> **Load command:** Read `.agents/skills/qa/SKILL.md` → sections §2 and §3.

---

## Audit Mode — Additional Checks

When `mode = audit`, also verify:

| Check                                     | Source Rule                             |
| :---------------------------------------- | :-------------------------------------- |
| Every Phase has MANDATORY guard           | guard-catalog.md R1                     |
| HARNESS GUARD maps from Risk table        | guard-catalog.md R2-R3                  |
| VCS inline guard before every git task    | guard-catalog.md R6                     |
| git commit ≠ git push (separate tasks)    | guard-catalog.md R7                     |
| Status transition guard in Walkthrough    | guard-catalog.md R8                     |
| Walkthrough cleanup for generated files   | guard-catalog.md R9                     |
| Graph-First Policy (if project has graph) | guard-catalog.md R10                    |
| Dual-Format (HTML + blockquote)           | guard-catalog.md Dual-Format Convention |

---

## Examples

### Quick plan review before activation

```
User: /qa plan
Agent: (reads active plan → runs Q&A loop → presents summary)
```

### Audit a specific file

```
User: /qa audit artifacts/plans/v0.9.0-deep-calls.md
Agent: (reads file → runs audit checks → presents compliance report)
```

### Review a brainstorm decision

```
User: /qa artifact artifacts/para-decisions/brainstorm-2026-05-06-graphify.md
Agent: (reads brainstorm → questions each option → checks decision rationale)
```

---

## Related

- `/plan` — Creates plans that this workflow reviews
- `/spec` — Creates specs that this workflow reviews
- `/verify` — Verifies task completion (post-execution); `/qa` verifies plan quality (pre-execution)
- `/brainstorm` — Creates decisions that this workflow can stress-test
