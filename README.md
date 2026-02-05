# PARA Workspace Standard

> **The Code-First Personal Knowledge Management System for Agentic Workflows**

<div align="center">

![PARA Workspace](./favicon.svg)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub issues](https://img.shields.io/github/issues/pageel/para-workspace)](https://github.com/pageel/para-workspace/issues)
[![GitHub stars](https://img.shields.io/github/stars/pageel/para-workspace)](https://github.com/pageel/para-workspace/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/pageel/para-workspace)](https://github.com/pageel/para-workspace/network)

[🇺🇸 English](README.md) • [🇻🇳 Tiếng Việt](./Resources/translations/README.vi.md)

</div>

```text
 ┌─────────────────────────────────────────────────────────────┐
 │   P A R A   W O R K S P A C E    S T A N D A R D            │
 └─────────────────────────────────────────────────────────────┘
          │
          ├───► ⚡ PROJECTS  (Active Work)
          │       └── [Goal] + [Deadline]
          │
          ├───► 🛡️ AREAS     (Responsibilities)
          │       └── [Standard] + [Maintenance]
          │
          ├───► 📚 RESOURCES (Interests)
          │       └── [Topic] + [Utility]
          │
          └───► ❄️ ARCHIVE   (Inactive)
                  └── [Completed] + [Cold Storage]
```

**PARA Workspace** is a standardized, code-centric Personal Knowledge Management (PKM) system designed for the age of AI. It bridges the gap between human cognition and artificial intelligence by providing a structured file system layout that is both intuitive for humans and contextually rich for AI agents.

## 🚀 Quick Start

Initialize your workspace with the included CLI tools:

```bash
# Create a new project
./para scaffold my-new-project

# Plan a feature
./para plan my-new-project "Implement OAuth"

# Verify a task
./para verify my-new-project "OAuth Login"

# Check workspace health
./para status
```

---

## 1. Objective

This document defines the **Personal Workspace Standard** based on the **PARA Method (Projects – Areas – Resources – Archive)**. It is specifically designed for **Antigravity Workspaces**, enabling seamless collaboration between Humans and AI Agents.

**Key Goals:**

- **reduce cognitive load** for humans.
- **Normalize lifecycle** of digital assets.
- **Provide context** for AI agents.
- **Ensure sustainability** over years.

---

## 2. Core Philosophy

### A Thinking System, Not Just a Filesystem

The workspace is a map of your active life and long-term memory. We choose PARA because it reflects **how our brains prioritize information by timeline**, not by file type.

### PARA is a Lifecycle

Every item belongs to exactly one category based on its current relevance:

| Category      | Question to Ask                    |
| ------------- | ---------------------------------- |
| **Projects**  | What am I working on right now?    |
| **Areas**     | What must I maintain indefinitely? |
| **Resources** | What can I use for reference?      |
| **Archive**   | What is finished?                  |

---

## 3. Directory Structure

```txt
workspace-root/
├── Projects/    # Active work with goals & deadlines
├── Areas/       # Ongoing responsibilities (infra, docs, product)
├── Resources/   # Reference materials (topics of interest)
├── Archive/     # Completed or inactive items
└── .agent/      # Root-level configuration & workflows
```

### Conventions

- **PascalCase** for top-level directories.
- **kebab-case** for project names and files.
- **No Git Repo at Root**: The root tracks the structure; projects contain their own repos.

---

## 4. Projects

**Definition**: A Project has a specific **Goal**, a **Deadline**, and a clear **Done Condition**.

**Structure**:

```txt
Projects/
└── my-awesome-app/
   ├── repo/        # Git repository (Source code)
   ├── sessions/    # Work logs (Daily session notes)
   ├── docs/        # Project-specific documentation
   ├── artifacts/   # AI-Agent artifacts (Plans, Walkthroughs, Tasks)
   ├── .agent/      # Project-specific rules & workflows
   └── project.md   # Project status & metadata
```

---

## 5. Areas

**Definition**: Ongoing responsibilities that must be maintained indefinitely.

**Standard Areas**:

- `Areas/infra`: Infrastructure (CLI tools, server configs, CI/CD).
- `docs`: Workspace standards, policies, and RFCs.
- `Areas/architecture`: Design patterns and system architecture rules.
- `Areas/agent`: AI agent workflows and global rules.

---

## 6. Resources

**Definition**: Reference materials used for learning, comparison, or exploration.

**Examples**:

- `Resources/databases`: Research on database engines (Postgres vs LibSQL).
- `Resources/web-development`: Frontend frameworks, CSS tips.
- `Resources/ai-agents`: Research on LLMs and agentic patterns.

---

## 7. Archive

**Definition**: Stopped active work.
**Rule**: Projects are moved here when completed or cancelled.

---

## 8. Agent Integration (Architecture)

We follow the **Thin Root / Rich Project** philosophy for AI Agents:

### 🌟 Root `.agent/` (Thin)

Acts as the "Constitution" of the workspace. Only contains global rules:

- `workspace.yaml`: Definition of PARA structure & Scan Order.
- `conventions.md`: Naming & Code style conventions.

### 🧩 Project `.agent/` (Rich)

The "Powerhouse" of daily work. Each project has its own `.agent` folder containing:

- `role.md`: Specific persona for that project.
- `context.yaml`: Domain-specific rules.
- `workflow.md`: Automation steps.

**Agent Golden Rule**: An Agent generally only acts within the scope where it is defined.

- Root Agent -> Routing & Scanning.
- Project Agent -> Coding & Execution.

---

## 🛠️ Workflow Management

This template includes a **Workflow Catalog** located in `Resources/ai-agents/workflows/`. These are powerful, pre-configured workflows that you can "install" into your workspace.

### Discovery

List all available workflows in the catalog:

```bash
./para work list
```

### Installation

Activate a workflow by installing it to your `.agent/workflows/` folder:

```bash
./para work install push
./para work install end
```

Once installed, you can trigger these workflows using your agent (e.g., `/push`).

---

---

## 9. Artifact-Driven Workflow

To ensure high-quality collaboration with AI agents, we utilize an **Artifact Layer**. This layer acts as the bridge between "intent" and "execution".

| Artifact Type           | Purpose                                     | Location                  | CLI Command                   |
| :---------------------- | :------------------------------------------ | :------------------------ | :---------------------------- |
| **Task List**           | Active TODOs with Definition of Done (DoD). | `artifacts/tasks.md`      | `(Managed manually)`          |
| **Implementation Plan** | Step-by-step roadmap for complex features.  | `artifacts/plans/`        | `./para plan <proj> <desc>`   |
| **Walkthrough**         | Verification steps to ensure correctness.   | `artifacts/walkthroughs/` | `./para verify <proj> <desc>` |

### The Cycle

1. **Plan**: Agent creates an `Implementation Plan` (`./para plan`).
2. **Execute**: Agent implements changes in `repo/`.
3. **Verify**: Agent creates a `Walkthrough` (`./para verify`) to test the changes.
4. **Log**: Agent records the results in `sessions/`.
5. **Status**: Check overall progress with `./para status`.

---

_Version: 1.2.0_
