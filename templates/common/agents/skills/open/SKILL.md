---
name: open
description: >
  Companion skill for the /open workflow. Automates workspace diagnostic steps when starting
  a new session on a project. Collects active session status, project contracts, active task metrics, 
  compact memory presence, roadmap phases, pending brainstorms, and git status.
version: "1.0.0"
---

# Open Skill

> **Purpose:** Automate project opening checks and gather developer context.
> **Trigger:** Active during the `/open` workflow execution, or when starting/resuming a project session.

## Workflow

This skill is executed during the initialization of a project session to check for configuration, Git status, and task files.

### Step 1: Execute Project Diagnostics
Run the script `scripts/run_open.sh` with the target project name as the first argument.

```bash
bash .agents/skills/open/scripts/run_open.sh [project-name]
```

### Step 2: Parse and Report
Parse the output of the script to construct the session opening report. Identify any non-zero exit codes. Note that exit codes of 1 from `grep` operations are normal if no matching patterns exist.

## Input / Output

### Input
- **Format:** String (project name)
- **Example:**
```text
pageel-crm
```

### Output
- **Format:** Shell output stdout/stderr containing diagnostic details.
- **Example:**
```text
=== DIAGNOSTICS FOR PROJECT: pageel-crm ===
Active session: Inactive
Latest sessions: Projects/pageel-crm/sessions/2026-06-03.md ...
Pending brainstorms: None
Compact memory: Present
Sprint-current lines: 12
Active backlog tasks: 0
Git status: Modified files ...
==========================================
```

## Edge Cases
- **Project directory not found:** Script exits with code 1 and logs error.
- **Missing `project.md`:** Script warns and skips contract parsing.
- **No git repository (`repo/`):** Script skips git checks.

## Scripts

> Read and run `scripts/run_open.sh` when performing project diagnostics.

## 🧪 Test Mode (Sandbox Override)

> **Trigger:** User includes "Test Mode" or explicitly asks to evaluate/test this skill.

When in Test Mode, follow these overrides:
1. **No Live Edits:** Do NOT modify files outside the sandbox directory.
2. **Containment:** Route ALL outputs into `[PROJECT_ROOT]/sandbox/evals/open-[YYYY-MM-DD]/`.
3. **Execute Task:** Run diagnostics for the mock project or target project and output the test report.
4. **Generate Report:** After completing the task, create `test-report.md` in the sandbox folder:

   ```markdown
   # Test Report: open
   > Date: YYYY-MM-DD | Prompt: "[user's prompt]"
   
   ## Actions Taken
   - Run open diagnostics on the sandbox project.
   
   ## Skill Rules Invoked
   - Step 1: Run diagnostics script.
   
   ## Files Created
   - sandbox/evals/open-[date]/test-report.md
   
   ## Self-Assessment
   - Diagnosed successfully. Verified exit codes and output formatting.
   ```
