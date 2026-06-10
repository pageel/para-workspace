---
description: Orchestrate resource import, graph generation, and pattern learning
source: custom
---

# /resource [action] [target]

> **Workspace Version:** 1.8.5
> **Goal:** Automate the end-to-end process of importing a reference resource, building its intelligence graph, and generating a study guide (README) for pattern learning.
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

## Usage

```bash
/resource add <url>          # Clone repo -> Build Graph -> Generate README
/resource init <namespace>   # Build Graph -> Generate README (for already cloned repo)
/resource update <namespace> # Sync repo -> Rebuild Graph -> Update README
/resource study <namespace> [--deep] [--target <project>] [--extract-prompts] [--dx-teardown] [--anti-patterns] [--compare <other_namespace>] [--extract-tools] [--extract-skills] [--extract-workflows] [--extract-rules] [--extract-plugins] [--extract-hooks]
/resource audit              # Scan resources and generate Audit Dashboard
/resource objective add ".." # Define a cross-resource study objective
/resource objective list     # List active study objectives
/resource objective clear    # Clear all active objectives
```

---

## Steps

### 0. Pre-flight

// turbo

Load resource study templates from sidecar skill:

```bash
cat .agents/skills/resource/references/study-template.md 2>/dev/null || echo "⚠️ No study template found"
cat .agents/skills/resource/references/pattern-mapping-template.md 2>/dev/null || echo "⚠️ No pattern mapping template found"
cat .agents/skills/resource/references/extracted-prompts-template.md 2>/dev/null || echo "⚠️ No extracted prompts template found"
cat .agents/skills/resource/references/dx-teardown-template.md 2>/dev/null || echo "⚠️ No dx teardown template found"
cat .agents/skills/resource/references/anti-patterns-template.md 2>/dev/null || echo "⚠️ No anti-patterns template found"
cat .agents/skills/resource/references/comparative-study-template.md 2>/dev/null || echo "⚠️ No comparative study template found"
cat .agents/skills/resource/references/extracted-tools-template.md 2>/dev/null || echo "⚠️ No extracted tools template found"
cat .agents/skills/resource/references/extracted-skills-template.md 2>/dev/null || echo "⚠️ No extracted skills template found"
cat .agents/skills/resource/references/extracted-workflows-template.md 2>/dev/null || echo "⚠️ No extracted workflows template found"
cat .agents/skills/resource/references/extracted-rules-template.md 2>/dev/null || echo "⚠️ No extracted rules template found"
cat .agents/skills/resource/references/extracted-plugins-template.md 2>/dev/null || echo "⚠️ No extracted plugins template found"
cat .agents/skills/resource/references/extracted-hooks-template.md 2>/dev/null || echo "⚠️ No extracted hooks template found"
cat .agents/skills/resource/references/audit-dashboard-template.md 2>/dev/null || echo "⚠️ No audit dashboard template found"
```

### 1. Action: add

When the user runs `/resource add <url>`:

This action orchestrates three sequential steps:

1. **Clone the Resource:**
   - Agent delegates to the `/remote clone <url>` workflow.
   - Wait for the operation to complete and identify the resulting `namespace`.

2. **Build Code-Knowledge Graph:**
   - Agent delegates to the `/para-graph build @resources/[namespace]` workflow.
   - Wait for the graph extraction to complete successfully.

3. **Generate Quick Summary:**
   - Agent MUST read the `README.md` (or key documentation) of the cloned resource.
   - Write a concise 1-2 sentence high-level AI summary of what the resource does.
   - Save this summary to `Areas/Learning/Resources/[namespace]/summary.txt`.
   - This ensures the Audit Dashboard can display a clean, accurate description.

4. **Generate Study Document (README):**
   - Agent automatically transitions to the `study` action below for the newly cloned namespace.

5. **Suggest Follow-up Actions:**
   - After completing the base study, Agent **MUST** output a list of suggested `/resource study` commands (with flags like `--deep`, `--extract-prompts`, `--dx-teardown`, etc.) to prompt the user for further deep-dive analysis.

### 2. Action: study

When the user runs `/resource study <namespace> [--deep]`:

This action focuses on understanding the resource's codebase and extracting valuable patterns.

**[Phase 1] Pre-Study (Graph Verification & Context Setup):**

1. **Graph Availability Check:**
   - Agent MUST check if `Resources/references/[namespace]/.beads/graph/metadata.json` exists.
   - If missing, Agent MUST STOP and PROMPT the user with explicit choices:
     "⚠️ Graph data not found for `[namespace]`. How would you like to proceed?

     - **[A]** Build Graph: Run `/resource init <namespace>` (Recommended).
     - **[B]** Skip Graph: Proceed with native tools only.
     - **[C]** Cancel."
2. **Context & Objectives Loading:**
   - Read `metadata.json` for graph overview.
   - Read `Areas/Learning/Resources/OBJECTIVES.md` (if exists) to load active Study Objectives.
   - If `para-graph` MCP server is connected, run `mcp_para-graph_graph_query` to get a high-level map.

**[Phase 2] Study Execution (The Loop):**

3. **Deep Study Mode (`--deep` flag):**
   - If the user provides the `--deep` flag, the Agent MUST enter an autonomous "Loop Paradigm".
   - **Step 3.1:** Use `mcp_para-graph_graph_god_nodes` to identify "God Nodes" (highest connected classes) or critical entry points.
   - **Step 3.2:** For each critical node, run `mcp_para-graph_graph_impact_analysis` or `graph_context_bundle` to analyze its upstream/downstream flow.
   - **Step 3.3:** Use native tools (`view_file`, `grep_search`) to dive into the actual source code of these key components to extract "The Why" (design rationale, algorithmic decisions).
   - **Step 3.4:** Loop and iterate through these steps autonomously until a profound understanding of the resource's core engine is achieved.

4. **Targeted Assimilation Mode (`--target` flag):**
   - If the user provides the `--target <project>` flag, the Agent MUST perform Cross-Pollination mapping.
   - **Step 4.1:** Load metadata from both `Resources/references/[namespace]/.beads/graph/metadata.json` AND `Projects/[project]/.beads/graph/metadata.json`.
   - **Step 4.2:** Analyze how the resource's patterns can specifically solve problems in the target project. Map Source Nodes to Target Nodes.
   - **Step 4.3:** Use the `pattern-mapping-template.md` loaded from the Sidecar Skill to generate the documentation.
   - **Step 4.4:** Save the generated mapping document as `Areas/Learning/Resources/[namespace]/applied_patterns/[project]_mapping.md`.
   - **Step 4.5:** Skip the standard "Documentation Generation" steps below.

5. **Extraction Mode (`--extract-prompts`, `--dx-teardown`, `--anti-patterns`, `--compare`, `--extract-tools`, `--extract-skills`, `--extract-workflows`, `--extract-rules`, `--extract-plugins`, `--extract-hooks`):**
   - If the user provides any of the extraction flags, the Agent MUST perform the requested analysis using the resource's code and graph.
   - **Step 5.1:** Load the corresponding template from the Sidecar Skill (e.g., `extracted-prompts-template.md` for `--extract-prompts`).
   - **Step 5.2:** Analyze the codebase strictly focusing on the requested extraction category.
   - **Step 5.3:** Generate the document following the template and translating the output to the workspace language.
   - **Step 5.4:** Save the generated document in the appropriate category folder under `Areas/Learning/Resources/[namespace]/` (e.g., `extracted_prompts/`, `dx_teardowns/`, `extracted_skills/`, `extracted_workflows/`, `extracted_rules/`, `extracted_plugins/`, `extracted_hooks/`, etc.).
   - **Step 5.5:** Skip the standard "Documentation Generation" steps below.

**[Phase 3] Post-Study (Enrichment & Documentation):**

6. **Graph Enrichment (Optional but Recommended):**
   - Agent SHOULD identify the most valuable nodes (e.g., core classes, unique algorithms) discovered during the study.
   - Agent MAY use `mcp_para-graph_graph_enrich` to write summaries and domain concepts back into the resource's graph nodes, tagging them as "Reference Patterns" for future target projects.

7. **Documentation Generation (Standard/Deep Mode):**
   - Based on the graph intelligence and source code, Agent creates a comprehensive study document detailing:
     - Core Architecture & Project Structure
     - Notable Design Patterns
     - Key Files and Entry Points
     - Lessons & Reference Value
   - The document MUST follow the template loaded from the Sidecar Skill.

8. **Save (Best Practice):**

   > ⚠️ **Namespace = full path.** `[namespace]` is the full source-based path (e.g., `github.com/<org>/<repo>`), NOT a short name. The save path mirrors this hierarchy.

   - **Save path:** `Areas/Learning/Resources/[namespace].md`
     - Example: `Areas/Learning/Resources/github.com/acme/my-lib.md`
   - **MUST NOT** save inside `Resources/references/[namespace]/` to avoid polluting the Git working tree of the cloned repository.
   - **MUST NOT** flatten namespace to a short name (e.g., ~~`my-lib.md`~~ at the `Resources/` root).

   **Merge-first rule (prevent data loss):**
   - Before writing, Agent **MUST** check if the study file already exists at the target path.
   - **If file exists:** Agent MUST read the existing content first, then **merge** new insights into the existing document:
     - Update metadata header (date, graph metrics).
     - Preserve all existing analysis sections — do NOT overwrite them.
     - Append an `## Update Log` section (or add a new row if it already exists) documenting what changed.
   - **If file does not exist:** Create new file following the study template.

9. **Extraction Statistics & Follow-up Suggestions:**
   - Agent MUST check the directory `Areas/Learning/Resources/[namespace]/` for any existing extraction folders (e.g., `extracted_prompts/`, `dx_teardowns/`, `anti_patterns/`, `applied_patterns/`, `extracted_skills/`, `extracted_workflows/`, `extracted_rules/`, `extracted_plugins/`, `extracted_hooks/`).
   - If generating the standard study document, Agent MUST append an "Extraction Status" section summarizing what has been extracted so far for this resource.
   - At the end of the study, Agent MUST present a **numbered menu** of extraction options.
   - **Standard options** (always shown): `--extract-prompts`, `--extract-tools`, `--anti-patterns`, `--dx-teardown`, `--extract-skills`, `--extract-workflows`, `--extract-rules`, `--extract-plugins`, `--extract-hooks`.
   - **Domain-aware custom options**: Agent MUST analyze the resource's tech stack, architecture patterns, and domain concepts discovered during the study to suggest **additional custom extractions** beyond the standard set. Examples:
     - If resource uses LLM prompts/chains → suggest "Prompt Engineering Patterns"
     - If resource has a unique retrieval/search architecture → suggest "Retrieval Architecture Deep-dive"
     - If resource implements self-evolution/adaptive logic → suggest "Self-Evolution Patterns"
     - If resource has multimodal processing → suggest "Multimodal Pipeline Study"
     - If resource has security/auth patterns → suggest "Security Patterns"
   - Custom extractions are saved to `Areas/Learning/Resources/[namespace]/custom_extractions/<slug>.md`.
   - **Menu format** (line-break separated for readability):

     ```
     📋 What would you like to extract from this resource?

     [1] --extract-prompts (AI prompts & system instructions)
     [2] --extract-tools (Utilities & helper scripts)
     [3] --anti-patterns (Architectural debt & mistakes)
     [4] --dx-teardown (Developer experience analysis)
     [5] --extract-skills (Agentic skills & capabilities)
     [6] --extract-workflows (Sequential agent workflows)
     [7] --extract-rules (Behavior rules & governance)
     [8] --extract-plugins (Antigravity plugin configurations)
     [9] --extract-hooks (Antigravity lifecycle hooks)
     [10] <custom: domain-specific suggestion> ← Agent-generated
     [11] <custom: domain-specific suggestion> ← Agent-generated
     [A] Run all (1-9)
     [S] Skip

     Pick one or more (e.g.: 1,3,5):
     ```

   - Agent MUST mark already-completed extractions with ✅ and skip them from the menu unless user explicitly re-requests.

### 3. Action: init & update

When the user runs `/resource init <namespace>`:
1. **Build Graph:** Agent delegates to `/para-graph build @resources/[namespace]`.
2. **Generate Study:** Agent transitions to the `study` action.

When the user runs `/resource update <namespace>`:
1. **Sync Code:** Agent delegates to `/remote sync [namespace]`.
2. **Rebuild Graph:** Agent delegates to `/para-graph build @resources/[namespace]`.
3. **Update Study:** Agent transitions to the `study` action with **merge-first rule** (Step 6 above).
4. **Suggest Follow-up Actions:** Agent **MUST** proactively suggest other deep-dive `/resource study` modes to the user (e.g., `--anti-patterns`, `--extract-tools`).

> ⚠️ `update` action MUST NOT create a new study file if one already exists. It MUST merge.

### 4. Action: audit

// turbo

When the user runs `/resource audit`:

This action generates a central Dashboard tracking learning progress. It uses the template from the Sidecar Skill to output `Areas/Learning/Resources/README.md`.

```bash
bash .agents/skills/resource/scripts/audit.sh
```

### 5. Action: objective

When the user runs `/resource objective <command>`:

This action manages global Study Objectives stored in `Areas/Learning/Resources/OBJECTIVES.md`.

- `add "<description>"`: Agent MUST append the new objective as a checklist item to the file (create the file with a simple header if it doesn't exist).
- `list`: Agent MUST read and output the current active objectives.
- `clear`: Agent MUST delete or clear the contents of the file, confirming to the user that all objectives are cleared.

When active objectives exist, any subsequent `/resource study` operation MUST actively look for patterns, code, and architectures that fulfill these objectives.

## Namespace Resolution

When the user provides a **short name** (e.g., `/resource update my-lib`), Agent MUST resolve the full namespace:

1. Search `Resources/references/` recursively for a directory matching the short name.
2. Use the full relative path from `Resources/references/` as the namespace.
3. Example: `my-lib` → found at `Resources/references/github.com/acme/my-lib` → namespace = `github.com/acme/my-lib`.

If multiple matches are found, Agent MUST ask the user to disambiguate.

## Related

- `/remote` — Handles the low-level git clone operations
- `/para-graph` — Handles Code-Knowledge Graph extraction
