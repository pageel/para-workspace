---
plan_id: detail-plan-csa-audit
title: "CSA Spec-to-Code Alignment & Quality Audit Plan"
status: 📝 Draft
type: csa-audit
target_version: "0.0.0"
---

# CSA Spec-to-Code Alignment & Quality Audit Plan: [project-name]

> **Description:** Blueprint template for reviewing, aligning, and improving the quality of the CSA (Convergent Specification Architecture) system between legacy specifications (`artifacts/specs/`) and the active codebase (`repo/src/`).
> **Goal:** 
> 1. Detect and repair structural/quantitative reference breakages (`dangling references`, `missing anchors`).
> 2. Assess semantic consistency to ensure specifications accurately reflect the active codebase logic.
> 3. Optimize code context to improve AI agent ingestion quality in subsequent sessions.

---

> ⛔ **STATUS GATE:** Agent MUST NOT execute Phase tasks while Status is "📝 Draft".
> Lifecycle: 📝 Draft → 🔨 Active → ✅ Done. Transition from Draft to Active requires explicit user approval.

---

## 📂 Target Specifications

*Identify the target specifications included in the audit scope for this session:*

| Spec ID | Spec Filename | Original Version | Current Status | Review Reason |
| :--- | :--- | :--- | :--- | :--- |
| `S1` | [spec-filename.md](file:///absolute/path/to/spec) | `v0.x.x` | ⚠️ Uncurated | Suspected semantic drift |
| `S2` | [spec-filename-2.md](file:///absolute/path/to/spec2) | `v0.y.y` | ⚠️ Incomplete | Contains dangling anchors |

---

## 🛠️ Context Files & Indices Loaded

*Before executing this plan, Agent MUST reload all specified context files to prevent workflow drift:*

| Scope | File / Index | Purpose | Path |
| :--- | :--- | :--- | :--- |
| Session Memory | `session.md` | Compacted session rules, skills, and contract | [session.md](~/.gemini/antigravity-ide/knowledge/para_vibecode_session/artifacts/session.md) |
| Workspace Rules | `.agents/rules.md` | Workspace-level rules index | [.agents/rules.md](file:///absolute/path/to/workspace/.agents/rules.md) |
| Project Contract | `project.md` | Project contract and thresholds | [project.md](file:///absolute/path/to/project/project.md) |
| Project Rules | `.agents/rules/csa-compliance.md` | Project-specific CSA rules | [csa-compliance.md](file:///absolute/path/to/project/.agents/rules/csa-compliance.md) |

---

## Phase 1: Ingestion & Structural Alignment (Quantitative) ⚙️ `Difficulty: 🟢 Low`

> 💡 **Model Hint:** This phase is primarily structural audits — consider using a lighter model to save cost.

### Checklist:
- [ ] **1.1. Run Automatic Audit:** Execute the CSA audit command using the CLI or MCP tool:
  ```bash
  npx para-graph audit csa --project Projects/[project-name]
  ```
  *(Or call the `graph_audit_csa` MCP tool if the graph server is active).*
- [ ] **1.2. Capture Quantitative Metrics:** Record current metrics from the audit output:
  - Spec Coverage: `....... %` (Threshold: `....... %`)
  - Dangling References (`danglingEdges` / `danglingInherits`): `.......`
  - Prefix Mismatches (`prefixMismatches`): `.......`
- [ ] **1.3. Scan Documentation Architecture:** Perform a quick scan of the existing documentation files (`docs/`) to understand their structure, naming conventions, and compile a high-level summary. Append this structural summary into `session.md` along with other starting contexts to ensure downstream steps inherit a complete system blueprint.
- [ ] **1.4. Initialize Drift Backlog:** Map dangling or missing IDs discovered in the audit output into the Phase 5 drift resolution table.
- [ ] **1.5. Ingest Global CSA Skill:** Run `view_file` to read the global CSA skill file `.agents/skills/csa/SKILL.md` to ensure deep alignment with G1 (One-to-One), G2 (Reverse Validation), and G3 (No Blanket) micro-anchoring principles before evaluating IDs in Phase 2.

---

## Phase 2: Spec ID Design & Placement Quality Audit (Reporting) ⚙️ `Difficulty: 🟡 Medium`

> 💡 **Model Hint:** Evaluating the quality of design anchors in spec files and generating a structured report. Switch to a thinking model.

### Checklist:
- [ ] **2.1. Spec ID Quality Checklist:** For each target specification in the audit scope, review the declared anchors against the following quality dimensions:
  - **Density:** Check if anchor density is sufficient relative to spec complexity (avoid zero anchors or a single anchor covering too much text).
  - **Placement:** Verify anchors are placed at logical subheadings, criteria blocks, or specific data schemas rather than general paragraphs.
  - **Naming Schema:** Ensure IDs match project namespaces (e.g., `csa-[project]-[domain]-[element]`).
- [ ] **2.2. Generate Quality Assessment Report:** Document findings and save a quality report file at `artifacts/reports/csa-audit/[YYYY-MM-DD]-v[version]-id-quality.md`. The report must detail:
  - Quality score/grade (A/B/C/F) for each audited spec file.
  - Identification of legacy specs requiring anchor additions ("CSA-ification").
  - Specific recommendations for renaming, splitting, or consolidating anchors.
- [ ] **2.3. Register Spec Refactoring Tasks:** Register any required spec modifications or anchor injections in the Phase 5 drift resolution table.
- [ ] ⛔ **CHECKPOINT (Interactive Pause):** Stop and present the Spec ID Quality Report (`[YYYY-MM-DD]-v[version]-id-quality.md`) to the user for approval before transitioning to Phase 3.

---

## Phase 3: Semantic Verification & Code Walkthrough (Qualitative) ⚙️ `Difficulty: 🔴 High`

> 💡 **Model Hint:** Analyzing code logic against architectural specifications requires deep reasoning. Switch to a thinking model.

### Checklist:
- [ ] **3.1. Spec-to-Code Deep Alignment:** For each target specification in the scope:
  - Open the Spec file using `view_file` to review its anchor definitions and requirements.
  - Locate the corresponding code entities in `repo/src/` using `graph_query` or `grep_search`.
  - Read code logic and verify alignment with the description, pre-conditions, post-conditions, and Acceptance Criteria in the Spec.
- [ ] **3.2. Identify Semantic Drift:** Document inconsistencies where:
  - Code logic has changed (e.g., param updates, algorithm shifts) but the Spec remains outdated.
  - Spec details edge cases or requirements that are not covered in the active codebase or unit tests.
  - `@para-doc` markers are misplaced or formatted incorrectly.
- [ ] **3.3. Diagnostics Design Coverage Audit:** For Specs with §9 Diagnostics Design:
  - Verify that Observable Checkpoints defined in Spec are implemented in code (structured logging exists at documented boundaries).
  - Verify Error Taxonomy codes from Spec are used consistently in error responses.
  - Flag any Environment Parity Risks not covered by test mocks.

---

## Phase 4: Brainstorming & Refactoring Task Generation (Qualitative & Planning) ⚙️ `Difficulty: 🟡 Medium`

> 💡 **Model Hint:** Synthesizing quality audit findings and semantic drifts to design fixes. Switch to a thinking model.

### Checklist:
- [ ] **4.1. Analyze Assessment Reports & Drift Logs:** Brainstorm solutions for all issues discovered during Phase 2 (Spec ID quality report) and Phase 3 (Semantic verification).
- [ ] **4.2. Generate Actionable Refactoring Tasks:** Create granular refactoring tasks and register them into the Phase 5 modification checklist, explicitly separated into two categories:
  - **Spec-to-Code Alignment Tasks:** Tasks relating to code logic, JSDoc `@para-doc` comment injections, parameter mismatch fixes, and unit tests.
  - **Spec-to-Docs Alignment Tasks:** Tasks relating to documentation files, transitive `data-csa-inherits` links, architectural blueprints, and user guides.
- [ ] ⛔ **CHECKPOINT (Interactive Pause):** Stop and present the detailed refactoring task list (Spec-Code and Spec-Docs) in Phase 5 to the user for approval before executing changes.

---

## Phase 5: Alignment Correction & Drift Resolution (Execution) ⚙️ `Difficulty: 🟡 Medium`

> 💡 **Model Hint:** Writing code fixes, adding doc links, or updating spec descriptions. Standard coding model recommended.

### Drift Resolution Strategy:
- **Case A (Outdated Spec):** Update spec documentation content (using `replace_file_content` or `multi_replace_file_content`) to match code reality.
- **Case B (Missing Code Logic/Docs):** Inject JSDoc comments or adapt code logic to comply with spec constraints.
- **Case C (Obsolete Anchors):** Prune deprecated anchors or re-map them to correct IDs.

### Modification Checklist:

#### Section A: Spec-to-Code Alignment (Spec ↔ Code)
*Focuses on resolving inconsistencies between implementation files (`repo/`) and target specs.*

| Spec ID | Target Code/Spec File | Change Type | Detailed Code/Spec Modifications | Status |
| :--- | :--- | :--- | :--- | :--- |
| `S1` | `repo/src/xxx.ts` | JSDoc Link | Inject `// @para-doc [csa-id]` in class definition | `[ ]` |

#### Section B: Spec-to-Docs Alignment (Spec ↔ Docs)
*Focuses on resolving inconsistencies between documentation files (`docs/`, `plans/`) and target specs.*

| Spec ID | Target Doc/Plan File | Change Type | Detailed Transitive/Anchor Modifications | Status |
| :--- | :--- | :--- | :--- | :--- |
| `S2` | `docs/guides/xxx.md` | Doc Update | Update `data-csa-inherits` to resolve duplicate warnings | `[ ]` |

---

## Phase 6: Final Validation & Memory Preservation ⚙️ `Difficulty: 🟢 Low`

> 💡 **Model Hint:** Final compliance verification and telemetry sync. Lighter model recommended.

### Checklist:
- [ ] **6.1. Run Build Verification:** Execute `npm run build` to ensure no syntax/type errors were introduced during code/doc updates.
- [ ] **6.2. Run Test Suite:** Execute `npm run test` to verify unit test correctness.
- [ ] **6.3. Run Final CSA Audit:** Execute the CSA audit tool:
  - Requirements: **Spec Coverage = 100%**, **Dangling Edges = 0**.
- [ ] **6.4. Build Graph & Sync Memory:**
  - Build the updated codebase graph: `para-graph build .` to persist the new links.
  - Update `session.md` to compact session memory for downstream work.
- [ ] **6.5. Update Spec Registry (README.md):** Document the final audit metrics (Audit Date, Version, Spec/Doc Coverage, Dangling Errors, Auditor) in the "CSA Audit Registry" table in `artifacts/specs/README.md` to preserve the historical audit trail.
