---
description: Generate and maintain project documentation following best practices
source: catalog
---

# /docs [project-name] [action]

> **Workspace Version:** 1.4.10

Generate, review, or update technical documentation for a PARA project. Docs are always created in `Projects/[project-name]/docs/` (internal). Use `publish` to promote selected docs to `repo/docs/` when ready.

## Actions

| Action    | Description                                                    |
| :-------- | :------------------------------------------------------------- |
| `new`     | Analyze project and create appropriate documentation (default) |
| `review`  | Audit existing docs for completeness and freshness             |
| `update`  | Update specific doc files to reflect current state             |
| `publish` | Copy selected docs from `docs/` to `repo/docs/` for shipping   |

---

## Principles

> 🛡️ **Constraint:** Read `preferences.language` from `.para-workspace.yml` to get the user's preferred language. All generated documentation MUST be written in this language. Default: `en`.

1. **Internal first.** Always create docs in `Projects/[name]/docs/`. Publish to repo only when ready.
2. **Only document what exists.** Never create docs for planned or hypothetical features.
3. **Source code is truth.** Read the actual codebase before writing — do not invent.
4. **Progressive depth.** Each doc has a clear summary at top → details below.
5. **Versioned and dated.** Every doc carries a version header and "last reviewed" date.
6. **Minimal overhead.** Only create docs the project actually needs based on its type and size.

## Doc Locations

Every PARA project has **2 doc locations** serving different purposes:

```
Projects/[project-name]/
├── docs/               ← DEFAULT: All docs created here (internal)
│   ├── architecture.md
│   ├── cli.md
│   └── update-mechanism.md
│
└── repo/docs/          ← PUBLISH ONLY: Promoted from docs/
    ├── architecture.md   # Reviewed, ready to ship
    └── cli.md
```

| Criteria        | `docs/` (default)           | `repo/docs/` (after publish)   |
| :-------------- | :-------------------------- | :----------------------------- |
| **Created**     | Always — `/docs new`        | Only via `/docs publish`       |
| **Audience**    | Internal team, AI agent     | Developer, contributor, user   |
| **Git tracked** | ❌ No (PARA workspace only) | ✅ Yes (shipped with repo)     |
| **Style**       | Detailed, user's language   | Concise, 40-100 lines, English |

> **Flow:** `/docs new` → create in `docs/` → user review → `/docs publish` → copy to `repo/docs/`

## Doc Index

Every project’s `docs/` directory MUST have a `README.md` index file. This is the **single source of truth** for doc inventory — agent reads this one file (~10 lines) instead of scanning the directory.

**Template:**

```markdown
# [Project Name] — Documentation

> [One-line project description]

| Document                          | Description                         | Updated    |
| :-------------------------------- | :---------------------------------- | :--------- |
| [Architecture](./architecture.md) | System overview & component diagram | YYYY-MM-DD |
| [CLI](./cli.md)                   | Commands, options, examples         | YYYY-MM-DD |

---

_Updated: YYYY-MM-DD_
```

**Rules:**

- `/docs new` auto-creates this file if it does not exist (Step 7).
- When adding or removing docs, always update this table.
- No prose, no extra sections — just title, description, and the table.

---

## 📝 Action: new

Analyze the project and create documentation appropriate to its type and complexity.

### Steps

#### 1. Read Project Contract

// turbo

Read `Projects/[project-name]/project.md` to extract:

- **Goal** and **Description**
- **Tech Stack** (language, framework, tooling)
- **Status** (active, dormant, completed)
- **Definition of Done**

#### 2. Analyze Source Code

// turbo

Scan the project's source code to understand structure:

```bash
# Get directory tree (depth 3, ignore common noise)
find Projects/[project-name]/repo -maxdepth 3 -type f \
  ! -path '*/node_modules/*' ! -path '*/.git/*' ! -path '*/dist/*' \
  ! -path '*/.astro/*' ! -path '*/.next/*' | head -80
```

Extract:

- **File structure** and key directories
- **Entry points** (main, index, CLI, etc.)
- **Config files** (package.json, astro.config, tsconfig, etc.)
- **Internal libraries** (lib/, utils/, helpers/)

#### 3. Classify Project Type

Determine what documentation this project needs (all created in `docs/`):

| Project Type    | Indicators                        | Recommended Docs                                 |
| :-------------- | :-------------------------------- | :----------------------------------------------- |
| **CLI Tool**    | `cli/`, shell scripts, `bin/`     | architecture, cli, development, update-mechanism |
| **Web App**     | Astro/Next/Vite, `src/pages/`     | architecture, development, deployment            |
| **Library/SDK** | `lib/`, `src/index.ts`, exports   | architecture, api-reference, getting-started     |
| **Website**     | Static pages, CMS integration     | architecture, deployment, content-structure      |
| **Template**    | `templates/`, scaffolding scripts | architecture, cli, workflows, kernel             |

> **Rule:** Do NOT create all possible docs. Only create what the project type requires.

#### 4. Read Doc Index (if exists)

// turbo

> ⚠️ **Token optimization:** Read `Projects/[project-name]/docs/README.md` only. Do NOT `ls` or read individual doc files.

- **Index exists** → extract the table to know what docs are already covered. Skip those.
- **Index does not exist** → fresh project, all docs are new. Step 7 will auto-create the index.

#### 5. Present Doc Plan

Before writing, present a plan to the user:

```
📖 Documentation Plan: [Project Name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📂 Project Type: [CLI Tool / Web App / Library / Website]
📁 Location: Projects/[project-name]/docs/ (internal)

📝 Docs to create:
  1. 🆕 architecture.md — System overview & component diagram
  2. 🆕 cli.md — Command reference and usage
  3. ⏭️ roadmap.md — Already exists, skipping

� Tip: Use `/docs publish` later to promote to repo/docs/

❓ Create these docs? (y/n, or specify numbers)
```

Wait for user confirmation before proceeding.

#### 6. Generate Documentation

// turbo

Create each approved document using the appropriate template from Section "Doc Templates" below.

**For each doc file:**

1. Read the relevant source files (max 5 files per doc to limit tokens)
2. Write documentation based on **actual code**, not assumptions
3. Include the standard header with version and date
4. Save to `Projects/[project-name]/docs/[doc-name].md`

#### 7. Create or Update Doc Index

// turbo

Create or update `Projects/[project-name]/docs/README.md` using the template from the **Doc Index** section above. Add a row for each doc created in Step 6.

#### 8. Log in Session

// turbo

Append to current session log:

```markdown
### Documentation Generated

- **Project**: [project-name]
- **Docs created**: [list of files]
- **Location**: `Projects/[project-name]/docs/`
```

---

## 📋 Action: review

Audit existing documentation for completeness, accuracy, and freshness.

### Steps

// turbo

1. Read `Projects/[project-name]/docs/README.md` (Doc Index) to get the inventory.
2. For each doc, check:
   - **Freshness**: Is "last reviewed" date > 30 days old?
   - **Accuracy**: Does the doc reference files/functions that still exist?
   - **Completeness**: Are there gaps (e.g., does Architecture doc miss new modules)?
3. Present audit report:

```
📖 Docs Audit: [Project Name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

| Document         | Status | Issue                           |
| :--------------- | :----- | :------------------------------ |
| architecture.md  | ✅ OK  | —                               |
| cli-reference.md | ⚠️ Stale | Last reviewed 45 days ago      |
| deployment.md    | 🔴 Missing | No deployment docs found     |

💡 Recommendations:
  1. Update cli-reference.md (new commands added since last review)
  2. Create deployment.md (project has deploy scripts)

❓ Fix these issues now?
```

---

## ✏️ Action: update

Update specific documentation to reflect current project state.

### Steps

1. User specifies which doc to update (or "all").
2. Re-read the relevant source code.
3. Diff current doc against actual code to find discrepancies.
4. Update the doc and bump "last reviewed" date.
5. Log in session.

---

## 📤 Action: publish

Copy selected docs from `docs/` (internal) to `repo/docs/` (ship with code).

### Steps

#### 1. Read Doc Index

// turbo

Read `Projects/[project-name]/docs/README.md` to list available docs.

#### 2. User selects which docs to publish

Present the list and let the user choose:

```
📤 Publish to repo/docs/:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Available in docs/:
  1. architecture.md (120 lines)
  2. cli.md (85 lines)
  3. update-mechanism.md (350 lines)

❓ Which docs to publish? (numbers, or "all")
```

#### 3. Adapt for repo audience

Before copying, adapt the doc to match the repo's standards:

1. **Detect repo language**: Check existing `repo/docs/` or `repo/README.md` to determine the repo's language.
2. **Translate if needed**: If internal doc language ≠ repo language, translate to match.
3. **Condense**: Shorten to 40-100 lines if internal doc is a deep-dive.
4. **Fix references**: Replace workspace-specific paths with relative repo paths.

> **Ask the user**: _"Should this doc be condensed for the repo, or published in full?"_

#### 4. Copy to repo/docs/

// turbo

```bash
mkdir -p Projects/[project-name]/repo/docs/
cp Projects/[project-name]/docs/[selected].md Projects/[project-name]/repo/docs/
```

#### 5. Log in session

// turbo

Append to current session log:

```markdown
### Docs Published to Repo

- **Files**: [list]
- **From**: `docs/` → `repo/docs/`
```

---

## Doc Templates

### Architecture Document

```markdown
# [Project Name] — Architecture

> **Version**: [X.Y.Z] | **Last reviewed**: YYYY-MM-DD

## Overview

[2-3 sentence description of the system]

## System Diagram

[ASCII component diagram — NOT Mermaid, to ensure portability]

## Directory Structure

[Key directories and their purpose — max 20 entries]

## Key Components

### [Component 1]

- **Location**: `path/to/component/`
- **Purpose**: [what it does]
- **Key files**: [2-3 important files]

## Data Flow

[How data moves through the system]

## Dependencies

| Dependency | Version | Purpose |
| :--------- | :------ | :------ |

---

_Last updated: YYYY-MM-DD_
```

### CLI Reference

```markdown
# [Project Name] — CLI Reference

> **Version**: [X.Y.Z] | **Last reviewed**: YYYY-MM-DD

## Quick Start

[Minimal usage example]

## Commands

### `command-name`

[Description]

**Usage:**
[code block]

**Options:**

| Flag | Description | Default |
| :--- | :---------- | :------ |

**Examples:**
[code blocks with real examples]

---

_Last updated: YYYY-MM-DD_
```

### Deployment Guide

```markdown
# [Project Name] — Deployment

> **Version**: [X.Y.Z] | **Last reviewed**: YYYY-MM-DD

## Prerequisites

[Required tools, accounts, environment]

## Build

[Build commands with explanation]

## Deploy

[Deployment process, step by step]

## Environment Variables

| Variable | Required | Description | Default |
| :------- | :------- | :---------- | :------ |

## Troubleshooting

[Common issues and fixes]

---

_Last updated: YYYY-MM-DD_
```

### Changelog

> **Note:** Only create if the project doesn't already maintain a changelog at repo root or in `docs/changelog/`.

```markdown
# [Project Name] — Changelog

All notable changes to this project, ordered by version (newest first).

## [X.Y.Z] — YYYY-MM-DD

### Added

- [New feature]

### Changed

- [Modified behavior]

### Fixed

- [Bug fix]
```

---

> **Flow:** `/docs new` creates in `docs/` → review & iterate → `/docs publish` copies to `repo/docs/`.
> **Rule:** If writing a doc yields a reusable lesson → extract it with `/learn`.
> **Learning docs** go to `Areas/Learning/` (via `/learn`), not in project docs.

## Output Checklist

- [ ] Project contract and source code analyzed
- [ ] Project type classified
- [ ] Existing docs inventoried (no duplicates)
- [ ] Doc plan presented and approved by user
- [ ] Docs written from actual code (not assumptions)
- [ ] All docs have version header and "last reviewed" date
- [ ] `docs/README.md` index created or updated
- [ ] Session log updated

## Related

- `/learn` — Extract reusable lessons from project experience
- `/plan` — Create implementation plan (may reference architecture docs)
- `/end` — End session (may trigger doc updates for significant changes)
- `/release` — Pre-release quality gate (checks doc completeness)
- `/verify` — Verify task completion (may use docs as checklist)
