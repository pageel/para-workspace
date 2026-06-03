# Docs Folder Structure Best Practices

A structured, logical folder layout for technical documentation makes it easier for developers, AI Agents, and stakeholders to search, maintain, and automate the synchronization (Traceability) of project knowledge.

Below is the standard, recommended `docs/` folder layout and best practices for projects inside the PARA Workspace.

---

## 1. Directory Layout Overview

Recommended `docs/` folder structure template for medium to large projects:

```text
docs/
├── README.md                   # Portal page (Documentation Portal)
├── changelog.md                # Version history & release notes
├── architecture/               # System Architecture & Design docs
│   ├── overview.md             # System Overview & block diagrams
│   ├── spec.md                 # Business Specs & Decision Tables
│   └── database.md             # Entity Relationship Diagram (ERD) & schema design
├── development/                # Guidelines for developers (Developer Guide)
│   ├── setup.md                # Environment setup & local running guide
│   ├── standards.md            # Coding standards & style guidelines
│   └── testing.md              # Test execution & TDD guidelines
├── reference/                  # Detailed technical reference documentation
│   ├── api-endpoints.md        # API Endpoint spec & payload examples
│   ├── cli.md                  # CLI options & command-line guides
│   └── third-party/            # Third-party integrations (e.g. sepay, stripe)
├── user-manual/                # End-user guide manuals (User Manual)
│   ├── index.md                # Software features & UI portal guide
│   └── features/               # Detailed guides for each application module
└── ops/                        # Operations & Deployment documentation
    ├── deployment.md           # CI/CD pipelines & production deployment instructions
    └── monitoring.md           # Logging configurations, alerts & system monitoring
```

---

## 2. Details of Roles and Files

### 🏠 Documentation Portal (`docs/README.md`)
*   **Goal**: The entry point for anyone reading the documentation.
*   **Content**: Quick introduction to the project, fast links to key documents (Architecture, Setup, APIs), contact info, and current documentation health status.

### 📐 The `docs/architecture/` Folder (Architecture & Specs)
*   **overview.md**: Describes Client-Server models, Tech Stack choices, and core flow diagrams.
*   **spec.md**: The **Operational Authority** for business rules. Contains detail specs, Acceptance Criteria (AC), and Decision Tables for logic drift audits (Logic Drift / Drift Audit).
*   **database.md**: Documents the DB schemas, primary tables, and relationship diagrams.

### 💻 The `docs/development/` Folder (Developer Guides)
*   **setup.md**: Step-by-step instructions from cloning the repository to successfully running the dev server (including dependency installs, local env setup, `.env.local` template variables).
*   **standards.md**: Coding conventions, architectural patterns (e.g. Clean Architecture, Hexagonal), git commits standards, and PR workflows.
*   **testing.md**: Outlines how to run tests, write new test cases, and coverage requirements.

### 📖 The `docs/reference/` Folder (Technical Reference)
*   **api-endpoints.md**: Specs for all API routes, Request/Response JSON payloads, and error codes.
*   **cli.md**: Detailed descriptions of parameters for running CLI binaries or package scripts.
*   **third-party/**: Detailed setup for integrations like payment gateways, CRM connections, or serverless setups.

### 👥 The `docs/user-manual/` Folder (End-User Manuals)
*   **index.md**: User guide portal, analyzing key user journeys on the interface.
*   **features/**: Detailed user guides with screenshots guiding practical end-user tasks (e.g. creating invoices, managing customers).

---

## 3. Standards inside PARA Workspace

To ensure the Code-Graph analysis pipelines work optimally, docs inside the `docs/` folder should follow these invariants:

### 1. Single Source of Truth (SSOT)
*   Each code component or business rule should be documented in detail in **exactly one** place under `docs/`.
*   Avoid duplicating API definitions or business logic explanations across multiple files.

### 2. Using Anchor Comments (`docAnchors`)
Every documentation node explaining code components must use corresponding anchor comments.
*   **Syntax**: `<!-- @graph-node: <file_path_or_identifier> -->` immediately following the Markdown heading tag.
*   **Example**:
    ```markdown
    ### User Login Handler
    <!-- @graph-node: src/controllers/auth.ts:loginHandler -->
    This function authenticates credentials sent by user requests...
    ```

### 3. Clear Language Separation (vi/en)
If the project documents are multilingual:
*   The source code should only contain standardized English comment anchors.
*   Multilingual documents can be structured using subdirectories (e.g. `docs/vi/` and `docs/en/`) or rendered dynamically via translation templates.

---

## 💡 Suggested Prompts & Commands

Here are some useful prompts you can type in the chat with the AI Agent to manage your project's documentation structure:

*   **Review current documentation structure**:
    ```text
    /docs review the current docs directory structure of the project to see if any adjustments are needed
    ```
*   **Scaffold new documentation following the template**:
    ```text
    /docs [project-name] new --graph
    ```
    *(Replace `[project-name]` with your project's folder name, e.g., `pageel-crm`)*
*   **Audit missing anchors or broken links**:
    ```text
    /docs [project-name] review --graph
    ```

