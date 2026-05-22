# New Project Scaffolding & Design Standards Skill — Reference

> **Version**: 1.0.0

## Overview

**New Project** is a sidecar skill for the `/new-project` workflow. It defines the architectural guidelines, recommended design patterns, and setup procedures for project-specific Sidecar Skills during new project initialization within the workspace.

## Triggers

Trigger                    | Example
:--------------------------|:----------------------------------------
Initializing a new project | `/new-project`, "setup new project"
Establishing specs         | Creating spec-*.md
Designing database schema  | Scaffolding schema or repositories

## Core Setup Principles

1. **Specification-First (Spec-First):** Do NOT start writing application code before a structured specification file (`artifacts/specs/spec-*.md`) is approved.
2. **Roadmap & Versioning:** Create a project roadmap (`roadmap.md`) to map major milestones to execution phases.
3. **Test-Driven Development (TDD-First):** Configure an automated testing framework (e.g. Vitest) running on in-memory databases or mock data from day one.

## Recommended Design Patterns

- **Repository Pattern**: Defines interfaces for data operations. App layers communicate with database engines solely through repositories.
- **Service Layer Pattern**: Isolates complex business workflows from UI frameworks (e.g. Astro pages) into pure TypeScript service functions.
- **Strategy Pattern**: Swap third-party integrations (e.g. payment reconciliation strategies) seamlessly at runtime.
- **Event-Driven Pattern**: Async webhook processing using serverless queues.

## Project-Specific Sidecar Skill

Add a local companion skill to govern project-specific DNA:
```bash
/para-skill add [project-name] --template project
```

## Sync

Location | Role | Updated by
:---|:---|:---
`repo/templates/common/agents/skills/new-project/` | Source of Truth | Developer (git push)
`Resources/ai-agents/skills/new-project/` | Read-only (I9) | `para install` / `update`
`.agents/skills/new-project/` | Active copy | `para install` / `update`

---

_See also: [PARA Kit Skill](./para-kit.md) · [Full SKILL.md](../../templates/common/agents/skills/new-project/SKILL.md)_
