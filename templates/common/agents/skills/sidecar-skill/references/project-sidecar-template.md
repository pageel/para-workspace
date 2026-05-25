---
name: [Project Name] Context Skill
description: Project-specific domain constraints, templates, and scripts for [Project Name].
source: custom
---

# [Project Name] Context Skill

> **Type:** Project-Level Skill
> **Location:** `Projects/[project-name]/.agents/skills/SKILL.md`

This skill provides domain-specific context, conventions, and reusable data tailored specifically for **[Project Name]**. Agents must load this skill when working on the project to ensure architectural consistency.

## 1. Domain Constraints & Conventions

- **Language:** (e.g., Use TypeScript strict mode, prefer functional components).
- **Architecture:** (e.g., Domain-Driven Design, Feature-sliced design).
- **Naming Conventions:** (e.g., Interface names must not be prefixed with 'I').

## 2. Resource Router

| Resource | Relative Path | Description |
| :-- | :-- | :-- |
| Feature Spec | `references/feature-spec-template.md` | Standard spec template for new features in this project. |
| Deploy Script | `scripts/deploy.sh` | Custom deployment logic for this project's environment. |

## 3. Usage Instructions

Agent should proactively read this skill file when entering the project.
To load project-specific templates:

```bash
cat Projects/[project-name]/.agents/skills/references/feature-spec-template.md 2>/dev/null
```
