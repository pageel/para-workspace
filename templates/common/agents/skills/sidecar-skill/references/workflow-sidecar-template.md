---
name: [Workflow Name] Sidecar
description: Sidecar data and scripts for the /[workflow-name] workflow.
source: custom
---

# [Workflow Name] Sidecar Skill

> **Type:** Workflow Sidecar Skill
> **Companion Workflow:** `/[workflow-name]`

This skill provides sidecar data (templates, checklists, scripts) for the `/[workflow-name]` workflow. By extracting heavy static content and complex scripts into this skill, the main workflow file remains clean and strictly focused on process logic (Zero-fluff).

## 1. Resource Router

| Resource | Relative Path | Description |
| :-- | :-- | :-- |
| Main Template | `references/main-template.md` | Used to format the final output of step X. |
| Helper Script | `scripts/helper.sh` | Bash script used in step Y to perform complex processing. |

## 2. Usage Instructions

Agent must use the following commands within the `/[workflow-name]` workflow to utilize these resources:

```bash
# To load a template:
cat .agents/skills/[workflow-name]/references/main-template.md 2>/dev/null || echo "⚠️ Template not found"

# To execute a script:
bash .agents/skills/[workflow-name]/scripts/helper.sh
```

## 3. Maintenance Notes

- When adding new templates, ensure they follow the **OSS English-First Governance** (all internal content must be in English).
- Register any new files in the Resource Router above.
