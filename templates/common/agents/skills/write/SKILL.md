---
name: Write Templates
description: >
  Sidecar data for /write workflow — best-practice templates and quality checklists
  for deep-dive content types (ebook, paper, guide). Loaded just-in-time by the workflow.
source: catalog
---

# Skill: Write Templates

> **Trigger:** `/write` workflow requests template or checklist data.
> **Pattern:** Sidecar Skill — this skill contains NO executable logic, only data resources.

## Resource Router

| Resource           | Relative Path                        | Loaded when                      |
| :----------------- | :----------------------------------- | :------------------------------- |
| Ebook Template     | `references/templates/ebook.md`      | `/write new` with type `ebook`   |
| Paper Template     | `references/templates/paper.md`      | `/write new` with type `paper`      |
| Tutorial Template  | `references/templates/tutorial.md`   | `/write new` with type `tutorial`   |
| Blog Template      | `references/templates/blog.md`       | `/write new` with type `blog`       |
| Social Template    | `references/templates/social.md`     | `/write new` with type `social`  |
| Email Template     | `references/templates/email.md`      | `/write new` with type `email`   |
| Options Reference  | `references/options.md`              | User provides `--style`, `--depth`, `--tools`, or `--platform` |
| Writing Rules      | `references/writing-rules.md`        | Always loaded during Step 5 (Write Content)                    |
| Quality Checklist  | `references/quality-checklist.md`    | `/write review`                  |

## Conventions

- Templates define **structure only** (headings, placeholders). Agent fills content from source material.
- Quality checklist is the single gate for `/write review` action.
- All templates follow the writing rules defined in `references/writing-rules.md`.
