# PARA Workspace Standard

> **The Code-First Personal Knowledge Management System for Agentic Workflows**

![PARA Workspace](./favicon.svg)

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
├── Areas/       # Ongoing responsibilities (Docs, Infrastructure)
├── Resources/   # Reference materials, assets, themes
└── Archive/     # Completed or inactive items
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
   ├── sessions/    # Work logs & Backlog
   └── docs/        # Project-specific documentation
```

---

## 5. Areas

**Definition**: Responsibilities to maintain over time with no end date.

**Standard Areas**:

- `Areas/Docs`: Knowledge base, wikis, and specifications.
- `Areas/Sessions`: Centralized logs for the workspace.
- `Areas/Agent`: AI rules, workflows, and skills.

---

## 6. Resources

**Definition**: Topics of interest and useful assets (Themes, Templates, Content Drafts).

---

## 7. Archive

**Definition**: Stopped active work.
**Rule**: Projects are moved here when completed or cancelled.

---

## 8. Agent Integration

Suggested scan order for AI Agents:

1. `Projects/**` (High Context)
2. `Areas/**` (Rules & Memory)
3. `Resources/**` (Reference)
4. `Archive/**` (Ignore)

---

## 9. Translations

- [Tiếng Việt (Vietnamese)](./docs/translations/README.vi.md)

---

_Version: 1.0.0 (RFC-0001)_
