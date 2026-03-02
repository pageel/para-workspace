---
description: Kernel Governance Invariants and Scope Restrictions
source: catalog
---

# Agent Governance

> **Context:** PARA Workspace Kernel v1.4.5
> **Spec Path:** `Resources/ai-agents/kernel/`

You are operating within a strict PARA methodology workspace. This file contains the critical invariants. Adhere to them absolutely.

## 🔴 Critical Invariants (Must Follow)

- **[I1 & I8] Scope Containment**: Only operate within the active project (`Projects/<active>/`) or `Areas/`. DO NOT create files at the workspace root except for approved configuration files.
- **[I9] Resource Immutability**: ABSOLUTELY DO NOT modify system files in `Resources/ai-agents/`. This is a read-only snapshot of the Kernel Spec.
- **[I6] No Destructive Actions**: Do not bulk-delete directories or core files. Only move data to `Archive/` when cleanup is necessary.
- **[I2] Single Source of Truth**: All tasks must be read/written from `backlog.md` via the appropriate workflow (e.g., `/backlog`). Do not create scattered task lists.

## 🛡️ Safety Guardrails (Terminal Allowlist)

- **Safe to Auto-run Commands**: OS read commands (`ls`, `cat`, `grep`, `find`), directory creation (`mkdir`), intra-project file moving (`mv`, `cp`).
- Do not run `rm -rf` freely.
- **[I10] Repository Protection**: ABSOLUTELY DO NOT automatically `git commit` or `git push` in system repos or the root directory unless explicitly authorized by the user via a specific workflow (like `/push`).

## 🟡 Progressive Disclosure (When to read the full Kernel)

**DO NOT read the entire Kernel documentation during daily tasks to save tokens.**
ONLY read `Resources/ai-agents/kernel/` when instructed to:

1. Run the `/para-audit` workflow.
2. Run the `/plan` workflow to design large-scale architecture/standards.
3. Scaffold a new Project or Area with unclear context.

_(To view the full details of the 11 technical invariants I1 to I11, only access the Spec file at: `Resources/ai-agents/kernel/invariants.md` when an audit is actually commanded)._

## 🟢 Context Loading Order (For reference)

1. System Rules (This file)
2. Project Contract (`Projects/<active>/project.md`)
3. Task Context (`Projects/<active>/artifacts/`)
