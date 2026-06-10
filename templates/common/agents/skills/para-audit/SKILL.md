# Sidecar Skill: Workspace Audit Extensions & Legacy Cleanups

> **Skill ID:** para-audit
> **Version:** 1.0.0
> **Target Workflow:** /para-audit

This skill supports the `/para-audit` (specifically the `update` action) and `/update` workflows by providing dynamic, version-specific rules to identify legacy, renamed, or deprecated files in the workspace, and suggesting cleanups.

## Key Capabilities

1. **Legacy Files Registry:** Maintains a catalog of files that are deprecated, renamed, or moved in recent versions (in `files/legacy-files.json`).
2. **Automated Clean Check:** Exposes scripts (`scripts/check-legacy.sh`) to safely detect these files in the workspace and output actionable remediation instructions.
3. **Flexible Action Types:**
   - `rm`: Standard removal.
   - `mv`: Migration to archive or new paths.
   - `warn`: General deprecation warnings.

## Usage in Workflows

To run the legacy cleanup checks in a workflow, load this skill:

```yaml
# In workflow metadata/setup:
skills:
  - para-audit
```

Then execute the check script:

```bash
bash .agents/skills/para-audit/scripts/check-legacy.sh
```
