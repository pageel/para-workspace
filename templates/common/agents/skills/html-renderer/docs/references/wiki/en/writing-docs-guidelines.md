# Writing Technical Documentation in PARA Workspace

The PARA Workspace knowledge management system utilizes dynamic bi-directional links between technical documentation and actual source code (Traceability).

This guide outlines how to author standard technical documentation so the system can automatically identify links and calculate the overall Docs Health Score.

---

## 1. Documentation Anchors (docAnchors)

The system bridges source code entities to documentation files via special HTML comment tags (graph-node anchors):
- **Syntax in markdown (.md):**
  `<!-- @graph-node: <node_id> -->`
- **Concrete Example:**
  If you are writing technical explanations for the function `autoMatchCustomer` defined in `src/lib/reconciliation.ts`:
  ```markdown
  ### Automatic Customer Matching Function
  <!-- @graph-node: src/lib/reconciliation.ts:autoMatchCustomer -->
  This function automatically matches incoming wire transfer records with the customer database...
  ```

---

## 2. Technical Authoring Workflow

### 📝 Step 1: Draft Markdown Files
Write technical specs inside the project's `docs/` directory (e.g., `docs/architecture/spec.md`). Explain the business logic and core workflows clearly.
*   **Workflow Support:** You can trigger the `/docs [project-name] new --graph` workflow (e.g., `/docs para-workspace new --graph`) to automatically analyze the codebase and generate baseline documentation templates for missing components.

### 🔗 Step 2: Plant Graph Anchors
Embed the anchor tag `<!-- @graph-node: ... -->` directly underneath the header block describing that specific code component in your markdown file.
*   **Workflow Support:** Run `/docs [project-name] review --graph` to scan for any missing or outdated anchors. If the codebase structure changes, run `/docs [project-name] update --graph` to automatically sync the documentation contents.

### 🔄 Step 3: Compile and Verify
Execute the graph analysis and compile HTML docs:
1. Update and compile documentation using the `/docs` command (see Section 3 for options).
2. Compile markdown to interactive static HTML by running the `/docs` workflow with the `--render --graph` flags:
   `/docs [project-name] --render --graph` (e.g., `/docs para-workspace --render --graph`)
   This command automatically updates the code-graph, converts all markdown files into Notion-styled HTML pages, and boots up the local live-reload preview server.
3. Launch the **Docs Quality Dashboard** to verify that the Docs Health Score has improved and the corresponding code nodes now show a green "Completed" status.

---

## 3. The `/docs` Workflow and the `--graph` Option

The system provides a dedicated `/docs` command to automate the creation, auditing, and updating of technical documentation based on the actual codebase structure.

### 🛠️ Core Actions
*   **/docs [project-name] new --graph**: Analyzes the current codebase, builds the code graph, and automatically scaffolds missing essential docs (e.g. `architecture.md`, `cli.md`) under the `docs/` folder.
*   **/docs [project-name] review --graph**: Builds the latest code graph first, then audits the coverage and freshness of existing documentation, warning if a doc is stale or missing its `@graph-node` anchors.
*   **/docs [project-name] update --graph**: Re-analyzes codebase relationships and automatically updates existing documentation files to reflect the latest source code state.

### 🎯 The Power of the `--graph` Option
The `--graph` flag is a crucial modifier parameter when executing `/docs` actions.
*   **Syntax:** `/docs [project-name] [action] --graph` (e.g., `/docs para-workspace review --graph`).
*   **Mechanism:** When `--graph` is specified, the system triggers the **Graph Pipeline** (builds the code dependency database, maps upstream/downstream connections, and builds code `Context Bundles`) **before** running the documentation analysis or updates.
*   **Key Benefits:**
    *   Ensures the AI Agent operates on the most up-to-date and accurate structural map of the codebase.
    *   Prevents hallucination by referencing actual source declarations rather than guessing.
    *   Automatically plants accurate `@graph-node` tags matching the latest business hot spots (God Nodes) and Blast Radius.

---

## 💡 Suggested Prompts & Commands

Here are some useful prompts and commands to manage and synchronize your documentation:

*   **Sync documentation with codebase changes**:
    ```text
    /docs [project-name] update --graph
    ```
*   **Audit documentation coverage and missing graph anchors**:
    ```text
    /docs [project-name] review --graph
    ```
*   **Compile markdown files to interactive Notion-styled HTML pages**:
    ```text
    /docs [project-name] --render --graph
    ```

