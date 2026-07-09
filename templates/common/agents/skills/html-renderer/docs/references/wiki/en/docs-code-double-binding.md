---
title: "Double-Binding Traceability between Docs and Code"
order: 1
author: "Antigravity (AI Agent)"
version: "1.0.0"
status: "✅ Approved"
updated: "2026-06-03"
---
# Double-Binding Traceability between Docs and Code

In large software projects, technical documentation easily drifts away from the actual source code (Documentation Drift). To solve this issue permanently, the PARA Workspace enforces a **Double-Binding Traceability** mechanism between documentation (`docs/`) and source code (`src/`) utilizing the Code-Graph tool (`para-graph`).

Below are the details of how this two-way coupling works and how to leverage it.

---

## 1. 📂 Flow 1: Docs ➔ Code (Documenting Source Code)

**Meaning:** Identifying which part of the Markdown documentation explains which codebase entity or file.

### 🔗 Execution Mechanism (docAnchors)
This link is established manually by inserting a special HTML comment anchor immediately underneath the header in your Markdown file:

```markdown
### [Heading explaining code functionality]
<!-- @graph-node: [code_file_path_or_identifier] -->
```

*   **File level**: `src/lib/auth.ts`
*   **Function level**: `src/lib/auth.ts:verifySessionCookie`
*   **Concrete Example**:
    ```markdown
    ### Session Cookie Verification
    <!-- @graph-node: src/lib/auth.ts:verifySessionCookie -->
    This function decrypts and verifies the validity of the Signed Session Cookie sent by the client...
    ```

### 📊 Key Benefits
*   **Documentation Coverage Metrics**: The Code-Graph engine knows exactly what percentage of critical source files have been documented.
*   **Weighted Health Score**: Contributes to the Overall Health score based on successfully anchored entities (see Section 3 for calculation details).

---

## 2. 💻 Flow 2: Code ➔ Docs (Mapping Back from Source Code)

**Meaning:** From a specific source code file, identifying which technical documents explain it, or whether it has been completely missed.

Along with document-side anchors, Double-Binding mandates backward links from the codebase using the `@para-doc` comment syntax.

### 🔗 Short-form Reference — Recommended & Mandated since v0.17.4
To prevent broken links when renaming or moving document files, developers only need to specify the unique CSA ID prefixed with `#` (resolved dynamically via the SQLite database):
```typescript
// @para-doc [#csa-verify-session]
export function verifySessionCookie(cookie: string) {
    // cookie verification logic...
}
```

### ⚠️ Long-form Reference — Deprecated
Avoid using long-form comments containing physical file paths:
```typescript
// @para-doc [doc-auth.md#csa-verify-session]
```
*Why*: This introduces coupling and leads to broken links (dangling edges) whenever documentation files are reorganized or renamed.

When parsing the graph, the system audits both directions in parallel:
1. Markdown `<!-- @graph-node -->` tags pointing to code.
2. Code `// @para-doc` comments pointing back to Markdown documents.
The **Completed** state (100% health status) on the Quality Dashboard is only awarded when both directions are validated and matched.

### 🔍 Automated Graph Enrichment
When you build the project graph database (`para-graph build`), the static analyzer parses the entire codebase to build a call graph. It then maps it back against the anchors located inside the `docs/` folder:

*   **Detecting Unlinked Code**: The system automatically lists important files or God Nodes that are not yet referenced by any Markdown file.
*   **Detecting Stale Nodes**: If a function is renamed, parameters change, or a source file is deleted while the documentation anchor still points to the old signature, the system marks the node as **Stale** and displays warnings on the Quality Dashboard.
*   **AI Context Bundling**: AI Agents can fetch all source declarations matching a specific document header to automatically write updates without hallucinating (Anti-Hallucination).

---

## 3. 📊 Docs Health Score Calculation

The Overall Health Status Score displayed on the Dashboard reflects the completeness, coverage, and synchronization of technical documentation relative to the source code.

### 🧮 Formula
$$\text{Overall Health Score} = \text{Weighted Graph Coverage} \times \left(\frac{\text{Doc Sync Rate}}{100}\right)$$

Where:
1. **Weighted Graph Coverage**:
   * Measures the documentation rate of code entities categorized by priority (default weights: Critical = `5.0`, Medium = `2.0`, Low = `0.5`).
   * A code entity awards 100% of its weight if it passes Double-Binding (has both a Markdown `@graph-node` anchor and a `@para-doc` code comment). If it has only one direction, it contributes 50%.
2. **Doc Sync Rate (Freshness)**:
   * The percentage of healthy documents (those without drift audit mismatches and not marked as stale) out of all documents.

### ⚙️ Calibration Options
In the **Calibration Settings** panel, you can customize these calculations dynamically:
* **Entity Weights**: Adjust the weight sliders to change the relative importance of Critical, Medium, and Low-priority entities.
* **Verify Code Comment Anchors**: If unchecked, back-anchors (`@para-doc` comments) are skipped, and nodes with only doc anchors receive 100% weight.
* **Exclude Low-priority entities**: Completely removes Low-priority variables and constants from the coverage formula (improving the score if minor variables lack documentation).
* **Disable stale/drift penalty**: Stops documentation drift and stale files from penalizing the Overall Health Score (forces Doc Sync Rate to 100% in the calculation).

### 🛡️ CSA Audit Sub-metrics
The dashboard also shows the two gatekeeping tiers that govern Git workflows:
* **Tier 1 Specs Coverage (Hard Gate)**: Coverage of hard specification anchors in `artifacts/specs/`. The CLI audit requires 100% to allow commits.
* **Tier 2 Docs Coverage (Soft Gate)**: Coverage of soft documentation guides in `docs/`. The CLI audit requires 50% to pass.

---

## 🔁 Two-Way Integration Flow

```mermaid
graph TD
    subgraph Docs ["Documentation Layer (docs/)"]
        DocA["README.md"]
        DocB["spec.md"]
    end

    subgraph Code ["Source Code Layer (src/)"]
        CodeA["auth.ts"]
        CodeB["reconciliation.ts"]
    end

    DocB -- "1. Manual Anchor @graph-node in Markdown" --> CodeB
    CodeB -- "2. Comment @para-doc in Code" --> DocB
    CodeA -- "3. Auto Graph Scan & Parse" --> DocA
    CodeB -- "Logic/Signature modified" --> Stale["Stale Node / Logic Drift Warning"]
```


---

## 💡 Suggested Prompts & Commands

Here are some useful prompts and commands structured by mapping directions to help you sync your documentation and codebase:

### 📂 Direction 1: Docs ➔ Code (Markdown pointing to Code)
*   **Review current document mapping coverage and quality**:
    ```text
    /docs [project-name] review --graph
    ```
*   **Scaffold new document templates with appropriate graph-node anchors**:
    ```text
    /docs [project-name] new --graph
    ```

### 💻 Direction 2: Code ➔ Docs (Source code pointing back to Docs)
*   **Sync and update documentation automatically after codebase changes (clear stale nodes)**:
    ```text
    /docs [project-name] update --graph
    ```
*   **Identify critical source files (God Nodes) lacking backward links (Unlinked Code)**:
    ```text
    List God Nodes or critical source files in [project-name] that do not have @para-doc comment anchors pointing to documentation
    ```
*   **Audit code comments to find mismatched `@para-doc` references**:
    ```text
    Audit @para-doc comment anchors inside the source code of [project-name]
    ```

