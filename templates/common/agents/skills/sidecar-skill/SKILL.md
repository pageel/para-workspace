---
name: Sidecar Skill Governance
description: Architectural rules and standards for creating Sidecar Skills to support Workflows.
source: catalog
---

# Sidecar Skill Governance

> **Version:** 1.0.0 | **Type:** Governance Skill

This skill defines the structural standards and OSS compliance rules for creating **Sidecar Skills**. 
A Sidecar Skill is a data companion to a Workflow of the same name. It offloads static data (templates, checklists) and complex scripts from the workflow file, keeping the workflow "Zero-fluff" and strictly focused on process logic.

---

## 1. Core Principles

1. **Workflow = Process Logic:** The `.agents/workflows/<name>.md` file must only contain sequential steps and router calls. It should not contain heavy text blocks or large bash scripts.
2. **Skill = Data Companion:** The `.agents/skills/<name>/SKILL.md` file serves as the index and router for data, templates, and scripts.
3. **Lazy Loading (Just-In-Time):** Data is only read by the workflow when a specific step requires it (e.g., using `cat`).
4. **Graceful Degradation:** A workflow should still function (or fail gracefully with a warning) if its sidecar skill or specific templates are missing.

## 2. OSS English-First Governance (CRITICAL)

All Sidecar Skills must comply with the **English-First** rule for Open Source Repositories:

- **All internal files** within `.agents/skills/` (including `SKILL.md`, templates in `references/`, and scripts in `scripts/`) **MUST be written in English**.
- This rule ensures the workspace structure can be shared, reviewed, and extended by global open-source contributors, regardless of the end-user's localized preferred language for code generation.

## 3. Directory Structure

A compliant Sidecar Skill must follow this exact structure:

```text
.agents/skills/[workflow-name]/
├── SKILL.md              ← Router & Governance Index (Required)
├── scripts/              ← Bash scripts to offload CLI logic (Optional)
│   └── example.sh
└── references/           ← Static data, markdown templates, checklists (Optional)
    └── example-template.md
```

## 4. Extraction Thresholds (When to use a Sidecar)

When designing or updating a workflow, extract content to a Sidecar Skill if:
1. **Templates > 20 lines:** Any markdown template, prompt skeleton, or formatted output block should be placed in `references/`.
2. **Scripts > 10 lines:** Any complex bash logic (loops, `jq` parsing, heavy `sed`/`awk` replacements) must be extracted to an `.sh` file in `scripts/`.
3. **Checklists:** QA or code review checklists should be maintained in the skill, not embedded in the workflow.

## 5. Implementation Guide

### Defining the Router Table (`SKILL.md`)
The `SKILL.md` must contain a "Router" table so the Agent knows what files are available:

```markdown
## Resource Router

| Resource | Relative Path | Description |
| :-- | :-- | :-- |
| Main Template | `references/main-template.md` | Used in step 3 to format the output |
| Build Script | `scripts/build.sh` | Executed to compile assets |
```

### Invoking from Workflow
Inside the workflow file, use `// turbo` bash blocks to invoke scripts or load templates:

```bash
# Example: Loading a template safely
cat .agents/skills/[workflow-name]/references/template.md 2>/dev/null || echo "⚠️ Template not found"

# Example: Executing a script
bash .agents/skills/[workflow-name]/scripts/build.sh
```

## 6. Resource Router

This skill provides ready-to-use boilerplate templates to quickly scaffold new sidecar skills:

| Resource | Relative Path | Description |
| :-- | :-- | :-- |
| Workflow Sidecar Template | `references/workflow-sidecar-template.md` | Boilerplate for creating a sidecar skill attached to a global workflow. |
| Project Sidecar Template | `references/project-sidecar-template.md` | Boilerplate for creating a domain-specific context skill for a project. |

