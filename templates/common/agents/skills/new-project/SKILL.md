---
name: new-project
description: >
  Sidecar skill for the /new-project workflow. Use this skill whenever a new project is initialized,
  when establishing architecture specs, database schemas, roadmap phases, or local project rules.
  Even if the user does not explicitly mention "standards" or "design patterns", consult this skill
  to ensure the project is set up following Spec-First and TDD-First principles from day one.
version: "1.0.0"
---

# Skill: New Project Scaffolding & Design Standards

> **Version:** 1.0.0 | **Kernel min:** 1.7.15 | **Type:** Sidecar Skill
> **Companion workflow:** `/new-project` (`workflows/new-project.md`)

This skill defines the architectural guidelines, recommended design patterns, and setup procedures for project-specific Sidecar Skills during new project initialization within the workspace.

---

## §1. Core Setup Principles

To ensure a new project starts in the right direction, Agent and User MUST adhere to three core principles:

1. **Specification-First (Spec-First):**
   * Do NOT start writing application code before a structured specification file (`artifacts/specs/spec-*.md`) is approved.
   * Translate ambiguous requirements into concrete, quantifiable Success Criteria to ensure objective verification.
2. **Roadmap & Versioning:**
   * Create a project roadmap (`roadmap.md`) to map major milestones to execution phases.
   * Clearly define target release versions corresponding to each checkpoint (e.g., `v0.1.0-alpha`, `v1.0.0-stable`).
3. **Test-Driven Development (TDD-First):**
   * Configure an automated testing framework (e.g., Vitest or Jest) running on in-memory databases or mocked data during project scaffolding.
   * Persist test evidence and outputs in a structured `tdd-evidence.log` file.

---

## §2. Recommended Design Patterns

Agent SHOULD recommend and guide the User to implement the following design patterns depending on the application context:

### 1. Repository Pattern (Data Access Separation)
* **When to use:** Multi-environment applications (Local SQLite file, Production Cloudflare D1/Postgres, and in-memory databases for testing).
* **Rule:** Define interfaces for data operations. Application routes or UI pages MUST communicate with database engines solely through repositories, never directly invoking raw SQL or ORM clients.
* **Example:**
  ```typescript
  // src/lib/db/repositories/customer.interface.ts
  export interface ICustomerRepository {
    getById(id: string): Promise<Customer | null>;
    create(data: NewCustomer): Promise<Customer>;
  }
  ```

### 2. Service Layer Pattern (Business Logic Isolation)
* **When to use:** Applications containing complex calculation, reconciliation, or external integration logic.
* **Rule:** Separate business workflows from UI frameworks (e.g., Astro pages or nextjs routes). Group them into pure TypeScript Service functions/classes (`src/services/` or `src/features/`) to facilitate unit testing.

### 3. Strategy Pattern (Interchangeable integrations)
* **When to use:** Integrating multiple third-party services that serve the same purpose but have different payload structures (e.g., automated payment reconciliations via SePay, PayOS, or manual CSV import).
* **Rule:** Define a generic strategy interface and write individual adapters for each gateway to support seamless runtime swapping.

### 4. Event-Driven Pattern (Asynchronous execution)
* **When to use:** Serverless environments (e.g., Cloudflare Workers) with tight API gateway execution timeouts.
* **Rule:** Webhook handler receives payload $\rightarrow$ dispatches event and returns immediate 200 OK $\rightarrow$ background event listeners handle DB updates, emails, or backups asynchronously.

---

## §3. Project-specific Sidecar Skill Setup

To govern project-specific DNA and constraints, use the workspace's `/para-skill` engine to initialize a local companion skill.

### Setup Flow:

1. **Invocation:**
   Once the project is scaffolded, run:
   ```bash
   /para-skill add [project-name] --template project
   ```
2. **Behavior:**
   This command loads the `project-profile.md` template to:
   * Auto-scan the local `project.md`, `.agents/rules/`, and `.agents/skills/`.
   * Scaffold the project profile skill at `Projects/[project-name]/.agents/skills/[project-name]/SKILL.md`.
3. **Trigger Registration:**
   Add the trigger mapping to the project's local index `Projects/[project-name]/.agents/skills.md`:
   ```markdown
   | Rule/Skill | Trigger | File | Pri |
   | :--- | :--- | :--- | :--- |
   | [project-name] | Any task within the [project-name] project | skills/[project-name]/SKILL.md | 🔴 |
   ```

---

## §4. Local Project Rules (Project-specific Rules)

Initialize baseline local rules under `Projects/[project-name]/.agents/rules/` to enforce behaviors:

* **`vcs.md` (Source Control Rules):** Enforce branch naming patterns (`feat/*`, `fix/*`), commit formatting, and strictly prohibit committing secrets (`.env`, `credentials.json`).
* **`maintenance.md` (Project Maintenance):** Outline local build/test verification steps and enforce the Docs Freshness rule (updating documentation in sync with codebase mutations).

---

## 🧪 Test Mode (Sandbox Override)

> **Trigger:** User includes "Test Mode" or explicitly asks to evaluate/test this skill.

When in Test Mode, STRICTLY follow these overrides:

1. **No Live Edits:** Do NOT modify files outside the sandbox directory.
2. **Containment:** Route ALL outputs into `[PROJECT_ROOT]/sandbox/evals/[skill-name]-[YYYY-MM-DD]/`.
3. **Execute Task:** Carry out the user's prompt as if this skill were active in production.
4. **Generate Report:** After completing the task, create `test-report.md` in the sandbox folder:

   ```markdown
   # Test Report: new-project
   > Date: YYYY-MM-DD | Prompt: "[user's prompt]"
   
   ## Actions Taken
   - [List each action performed]
   
   ## Skill Rules Invoked
   - [Which sections of the skill were applied, e.g., "§2 Recommended Design Patterns"]
   
   ## Files Created
   - [List files created in sandbox/]
   
   ## Self-Assessment
   - [Did the skill provide useful guidance? What was ambiguous?]
   ```

