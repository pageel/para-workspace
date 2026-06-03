# Optimizing Blast Radius and Handling God Nodes

In software architecture, a high **Blast Radius** and the presence of **God Nodes** (overly connected core entities) are two major challenges affecting system maintainability and stability.

This guide provides practical strategies to control and optimize these metrics.

---

## 1. Identifying and Assessing God Nodes

A code component (function, class, or file) is classified as a **God Node** when its direct graph connection count satisfies `Degree >= 20`.
- **The Risk:** Modifying a God Node introduces a high probability of regression failures across all dependent upstream modules.
- **Classification:**
  - *Legitimate God Nodes:* Common infrastructural modules like `DB Client`, `Logger`, or `Auth Helper`.
  - *Anti-pattern God Nodes:* Large files containing bloated, mixed business logic (e.g., a single helper doing customer matching, invoice reconciliation, excel generation, and emailing).

---

## 2. Strategies to Reduce Blast Radius

To minimize the impact radius of any code entity, apply the following design patterns:

### 🧩 Apply the Single Responsibility Principle (SRP)
- Refactor large, multi-tasking functions/files into smaller, specialized helper functions.
- This disperses incoming connections (Indegree) and reduces overall dependency density.

### 🛡️ Dependency Inversion via Interfaces
- Avoid tight coupling by making upstream callers depend on Interfaces or Abstract Classes instead of direct concrete implementations.
- The Blast Radius chain is cut at the Interface boundary, allowing you to refactor concrete code without breaking callers.

### 🧪 Strengthen Unit Test Coverage
- Any node with a `Blast Radius > 5` must have robust unit tests covering edge cases.
- This guarantees that refactoring does not alter the expected behavioral contracts.

---

## 💡 Suggested Prompts & Commands

Here are some useful prompts and commands to optimize architecture and minimize risk:

*   **Find God Nodes in the project**:
    Use the `graph_god_nodes` MCP tool, or ask in chat:
    ```text
    List all God Nodes with Degree >= 20 in this project to evaluate risk
    ```
*   **Analyze Blast Radius of a specific function or file**:
    Use the `graph_impact_analysis` MCP tool, or ask in chat:
    ```text
    Calculate the Blast Radius if I modify the 'autoMatchCustomer' function in 'src/lib/reconciliation.ts'
    ```
*   **Get refactoring suggestions to reduce Blast Radius**:
    ```text
    Suggest refactoring ideas for src/lib/reconciliation.ts to reduce its Outdegree and Blast Radius
    ```

