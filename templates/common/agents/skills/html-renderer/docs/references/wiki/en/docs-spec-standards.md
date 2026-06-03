# Specification (Spec) & Documentation (Docs) Standards in PARA Workspace

In the PARA Workspace, maintaining the consistency and accuracy of technical documentation and business specifications is a mission-critical task. To prevent **Documentation Drift** and **Logic Drift**, the workspace establishes strict standards supported by automated Workflows, Skills, and Rules.

Below are the detailed standards for writing Specifications (Specs) and Documentation (Docs) along with their corresponding technical proof.

---

## 1. 📐 Specification Standards (Spec-Driven Development Standards)

The purpose of a Specification (Spec) is to resolve all misunderstandings and clearly define the feature scope **before writing any line of source code**.

*   **Companion workflow:** `/spec` (located at `.agents/workflows/spec.md`)
*   **Governance skill:** `spec-driven-development` (located at `.agents/skills/spec/SKILL.md`)

### 🔴 Rule 1: Assumptions Are Dangerous
Assumptions are the single largest source of misaligned development.
*   **Standard:** The AI Agent is strictly required to list all technical and business assumptions (extracted from the `project.md` configuration file at the project root or user requests) before drafting the core Spec content.
*   **Execution:** Explicit human confirmation (`+ask` or plan approval) is mandatory for these assumptions. The Agent must not make implicit decisions.

### 🔴 Rule 2: Gated Workflow (No Shortcuts)
Each stage of software development must pass through independent, human-verified gates:
```text
DRAFT SPEC ──→ APPROVED SPEC ──→ PLAN ──→ TASK (task.md) ──→ IMPLEMENT
     │                │             │          │
     ▼                ▼             ▼          ▼
Human Gate 1     Human Gate 2  Human Gate 3 Human Gate 4
```

### 🔴 Rule 3: Reframe Vague Success Criteria into Testable Conditions
Vague user requirements must be translated into specific, measurable Success Criteria.
*   *Bad:* "The system should search fast."
*   *Standard:* "The search API response time must be under 200ms for a database of 10,000 records; the UI must display a loading state during the query."

### 🔴 Rule 4: Boundaries System
Every Spec document must define three tiers of operational boundaries:
1.  **Always Do:** Non-negotiable rules. E.g., Run tests before committing, validate API inputs.
2.  **Ask First:** Actions requiring explicit approval. E.g., Modifying database schema, adding new dependencies/libraries.
3.  **Never Do:** Absolute prohibitions. E.g., Committing secrets, deleting failing tests to bypass CI/CD.

### 🔴 Rule 5: Spec Re-read Checkpoint (Implementation Guard)
This is the key mechanism to protect the AI Agent against Context Decay during long-term coding.
*   **Standard:** Before starting any implementation task, the Agent must read the Spec's Success Criteria and Boundaries system (by directly opening the Spec file under the `artifacts/specs/` directory). This ensures the Agent stays aligned with the approved design and does not drift into coding out-of-scope features.

---

## 2. 📂 Documentation Standards (Docs Templates & Freshness Standards)

Outdated documentation is worse than no documentation because it misleads developers and AI Agents.

*   **Companion workflow:** `/docs` (located at `.agents/workflows/docs.md`)
*   **Governance skill:** `Docs Templates` (located at `.agents/skills/docs/SKILL.md`)

### 🔴 Rule 1: Docs Freshness Rule
When the source code modifications change a public interface, the corresponding documentation must be updated in the **same session**.
*   **Trigger Conditions:**
    *   API endpoint added or modified (e.g. in `docs/reference/api-endpoints.md`).
    *   Database Schema modified (Prisma/Drizzle schema).
    *   Config format or env variables changed (`wrangler.jsonc`, `env.example.txt`).
    *   Public function signatures modified.

### 🔴 Rule 2: Source Verification Protocol (Anti-Hallucination Guard)
To ensure the Agent does not document non-existent features, every generated document must include a verification tag:
```markdown
<!-- ⚠️ SOURCE-VERIFIED — Cross-referenced with [src/lib/auth.ts, wrangler.jsonc] on YYYY-MM-DD -->
```
*   **State Rules:**
    *   If a config is declared but not yet used in code, it must be marked: `[Planned — Not yet implemented in source]`.
    *   If a feature is removed from the code, it must be updated or deleted from the docs immediately.

### 🔴 Rule 3: Graph-Anchoring Protocol
Every architecture or feature document must link directly to the codebase via graph anchors:
```markdown
<!-- @graph-node: [nodeId_or_file_path] -->
```
Then, run the `graph_link_docs` utility to register this relationship in the graph database. This is used to calculate the **Docs Health Score** and detect **Stale Docs** dynamically.

---

## 💡 Recommended Commands & Suggested Prompts

Here are useful commands and prompts to help you enforce Spec & Docs standards:

### 📐 Specification (Spec) Prompts
*   **Create a new Draft Spec following the Gated Workflow:**
    ```text
    /spec [project-name] new-feature "Integrate SePay payment gateway for auto reconciliation"
    ```
*   **Instruct the Agent to list assumptions before writing a spec:**
    ```text
    Before writing the Spec for feature X, review project.md and list all technical and business assumptions under an Always/Ask/Never boundary table for my approval.
    ```
*   **Trigger the Spec Re-read Checkpoint before coding:**
    ```text
    Perform the Spec Re-read Checkpoint: Read the Success Criteria and Boundaries from spec-X.md before writing code for function Y.
    ```

### 📂 Documentation (Docs) Prompts
*   **Initialize a standard architecture document:**
    ```text
    /docs [project-name] new-doc architecture
    ```
*   **Perform a Freshness and Stale Nodes audit:**
    ```text
    /docs [project-name] review --graph
    ```
*   **Instruct the Agent to run Source Verification to prevent hallucination:**
    ```text
    Perform the Source Verification Protocol for docs/reference/api.md. Scan all code under src/ to ensure all described endpoints and parameters are active. Add the <!-- ⚠️ SOURCE-VERIFIED --> header when done.
    ```
