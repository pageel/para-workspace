# Understanding Stale Nodes in Code-Graph

During the operation of the Documentation Management and Code-Graph systems within the PARA Workspace, developers will frequently encounter the concept of **Stale Nodes**. Understanding the nature, causes, and mitigation of stale states is crucial to maintaining 100% synchronization between architecture documents and the actual codebase.

---

## 1. 🔍 What is a Stale Node?

A **Stale Node** is a codebase entity (function, class, file, or API endpoint) that exists in the graph database, but whose **source code logic or signature has changed locally since its semantic description (Semantic Summary) was last enriched by AI**.

When a node becomes stale, its `semantic.staleSince` attribute in the graph database is assigned a timestamp recording the moment the modification was detected.

> [!NOTE]
> The stale state is **only a warning regarding documentation desynchronization (outdated AI summary)**. It has absolutely no impact on the application's runtime logic.

---

## 2. ⚡ What Causes a Node to Become Stale?

The Code-Graph tracks modifications using two primary mechanisms:
1.  **Signature Change:** The entity name, input parameters, return type, or line range (startLine/endLine) of the code entity has changed.
2.  **File Content Change (MD5 Hash Change):** The source file containing the entity was modified locally (e.g., adding a `@para-doc` comment, editing internal business logic).

When a developer runs the graph rebuild command (`para-graph build`), the static analysis tool scans the codebase, recalculates MD5 hashes for all files, and compares entity signatures against the database:
*   The graph preserves the existing semantic summary to prevent losing valuable historical AI-generated data.
*   The graph automatically flags the node with a `staleSince = [scan timestamp]` to alert the developer that the description may no longer accurately reflect the new code logic.

---

## 3. ⚠️ Impact of Stale Nodes on Docs Quality

If too many stale nodes accumulate in the system:
*   **Attention Decay (AI Hallucination):** When an AI Agent reads context from the graph to write or update documentation, outdated summaries can lead to incorrect assumptions and documentation discrepancies.
*   **Docs Health Score:** The overall Docs Health Score on the Quality Dashboard will decline, reflecting a drift between codebase truth and written words.

---

## 4. 🛠️ 3-Step Workflow to Resolve Stale Nodes

To bring the stale node count back to $0$ and fully align your documentation:

### Step 1: Commit Local Changes (Git Commit)
Before cleaning up the graph, ensure all local code modifications are verified by tests and committed to Git. This fixes the MD5 hashes of the files.

### Step 2: Relink Documentation (Link Docs)
Run the link command to map document anchors back to the updated code positions:
```bash
./para para-graph link [project-name]
# Or run directly via Node
node Projects/para-graph/repo/dist/cli.js link [project-name]
```
This scans all `<!-- @graph-node -->` comments in the Markdown documents, matches them with code, and clears outdated stale references.

### Step 3: Semantic Re-Enrichment (graph_enrich)
For high-impact God Nodes that are stale, trigger semantic re-enrichment so that the AI analyzes the new code and writes an updated summary:
*   In the Quality Dashboard, select the stale nodes and click **Copy AI Prompt** or use **Chat with Agent** to request an update.
*   The Agent calls the MCP tool `graph_enrich` to write the new summary, resetting `staleSince` to `null`.

---

## 📊 Quick Comparison

| Feature | Stale Node | Broken Link |
| :--- | :--- | :--- |
| **Nature** | Code logic changed, but summary is outdated. | Doc anchor references a function/file that no longer exists. |
| **Severity** | 🟡 Medium (Outdated docs). | 🔴 High (Incorrect/broken references). |
| **Resolution** | Run `link` and `graph_enrich` to update semantic data. | Fix comment anchors or remove invalid links in Markdown. |

---

## 💡 Suggested Prompts & Commands

Here are some useful prompts and commands to resolve stale nodes and synchronize your documentation:

*   **Automatically update docs to sync with source code changes**:
    ```text
    /docs [project-name] update --graph
    ```
*   **Relink shifted document anchors**:
    ```text
    /para para-graph link [project-name]
    ```
*   **Trigger semantic enrichment for stale nodes**:
    Use the `graph_enrich` MCP tool, or ask in chat:
    ```text
    Update and enrich semantic descriptions for all stale nodes in the graph of [project-name]
    ```

