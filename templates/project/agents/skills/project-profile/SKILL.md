---
name: Project Profile
description: Project-specific conventions, naming patterns, and quality standards
version: "1.0.0"
---

# Project Profile: [project-name]

> **Project Type:** [oss-library | internal-app | website | cli-tool | template-repo]
> **Trigger:** Creating plans, naming files, writing docs, running maintenance checklists, or reviewing plan quality

This skill defines the **DNA** of this project — conventions that influence workspace-level workflows without modifying them.

## §1. Project Identity

| Field | Value |
|:------|:------|
| Type | `[type]` |
| Primary Language | [languages] |
| Doc Tone | `[formal-technical | conversational | tutorial-friendly]` |
| Doc Language | [en | vi | mixed] — per `preferences.language` |
| Build System | [command or "None"] |

## §2. Naming Conventions

### Plan Files

Pattern: `[describe your plan naming pattern]`

### Branches

Pattern: `[feat/topic | fix/topic | direct-to-main]`

### Commits

Pattern: `[describe your commit message format]`

## §3. Maintenance Patterns

> Add project-specific checklists here that don't belong in global rules.
> Reference existing rules instead of duplicating content.

## §4. Quality Standards

### Build & Test

```bash
# Build
[build command or "N/A"]

# Test
[test command or "N/A"]
```

### Verification after changes

```bash
# Add project-specific verification commands
```

## §5. Documentation Flow

> Describe the documentation flow for this project.
> Example: internal docs (VI) → public docs (EN) → website

## §6. Plan Review Checklist

> **Trigger:** AFTER any `/plan create` or `/plan update` — agent MUST run this checklist before presenting plan to user.
> **Purpose:** Catch logic errors, security gaps, missing scope, and token bloat BEFORE execution.
> **Defense:** If running `/plan create`, re-read this §6 AFTER Step 9 (Write Plan File) to counter token decay.

### A. Logic & Dependency Check

- [ ] **Phase ordering:** Are phases in correct dependency order?
- [ ] **Circular references:** No phase depends on a later phase's output
- [ ] **Missing cleanup:** If creating files, is there a verify/cleanup phase?

### B. Security & Safety Check

- [ ] **Secrets check:** No `.env`, credentials, or tokens in plan scope
- [ ] [Add project-specific security checks]

### C. Completeness Scan

- [ ] **Impact count verified:** Does stated number match actual scan?
- [ ] [Add project-specific completeness checks]

### D. Token Efficiency Check

- [ ] **Plan size:** < 200 lines for release plan, < 300 for complex multi-feature
- [ ] **No duplicate info:** Architecture overview doesn't repeat task details
- [ ] **References over repetition:** Large sections link to separate files
