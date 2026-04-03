# Governance — Kernel Invariants

> **Version**: 1.5.4

The most critical rule — defines the **invariants** that agents MUST NOT violate under any circumstances. Protects workspace structure, prevents destructive operations, and controls access to system files.

## Scope

- **Type**: Global (all projects)
- **Priority**: 🔴 Critical
- **Trigger**: Touching `kernel/`, `.para/`, `Resources/ai-agents/`

## Rules

### 1. Scope Containment (I1 & I8)

Only operate within the active project (`Projects/<active>/`) or `Areas/`. Do NOT create files at the workspace root except approved configuration files.

### 2. Resource Immutability (I9)

ABSOLUTELY DO NOT modify system files in `Resources/ai-agents/`. This is a read-only snapshot of the Kernel Spec.

### 3. No Destructive Actions (I6)

Do not bulk-delete directories or core files. Only move data to `Archive/` when cleanup is necessary.

### 4. Single Source of Truth (I2)

All tasks must be read/written from `backlog.md` via the `/backlog` workflow. Do not create scattered task lists.

## Safety Guardrails

**Safe to auto-run:** `ls`, `cat`, `grep`, `find`, `mkdir`, intra-project `mv`/`cp`.

**Prohibited without approval:** `rm -rf`, `git commit`/`push` in system repos or root directory.

## Progressive Disclosure

Do NOT read the full Kernel documentation during daily tasks. Only access `Resources/ai-agents/kernel/` when running `/para-audit`, designing large-scale architecture via `/plan`, or scaffolding with unclear context.

## Related

- [Kernel Architecture](../architecture/kernel.md)
- [Rule Layers](../architecture/rule-layers.md)
- **Source**: `templates/common/agents/rules/governance.md`
