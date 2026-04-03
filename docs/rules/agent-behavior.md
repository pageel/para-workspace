# Agent Behavior & Communication

> **Version**: 1.5.4

Defines how the agent communicates, handles language settings, and self-recovers context after truncation. The foundational rule for agent "working style" — from response format to memory recovery.

## Scope

- **Type**: Global (all projects)
- **Priority**: 🟡 Important
- **Trigger**: Agent communication, formatting, context recovery after truncation

## Rules

### 1. Language Configuration

- MUST respect `preferences.language` in `.para-workspace.yml` for docs and chat.
- MUST keep technical artifacts (code variables, commit messages) in English.
- SHOULD adapt communication language to user's configured preference.

### 2. Communication Style

- MUST be concise — focus on solutions, avoid fluff.
- SHOULD use checklists for multi-step tasks (✅ Done, ⏳ Pending).
- MUST state errors clearly and propose a fix immediately.

### 3. Workflow Standards

- MUST run verification (`npm run build` or test) after code changes unless `--quick`.
- MUST NOT `git commit`/`push` without confirmation (except trusted workflows).
- MUST check build result before reporting "Done".
- SHOULD prefer defined workflows over ad-hoc commands.

### 4. Context Recovery (v1.5.4)

When context appears incomplete (cannot recall rules, truncation notice, or very long conversation):

1. MUST re-read `.agents/rules.md` (workspace index) before any side-effect.
2. MUST re-read project `.agents/rules.md` (if exists) before project-specific actions.
3. SHOULD inform user: "Context recovery — re-loaded rules index."

**Side-effects requiring rules re-read:** Git operations, file deletion/move/rename outside project, install/deploy commands, system config changes.

#### File-Level Guards

When editing these files directly (outside a workflow), agent MUST re-read the corresponding rule first:

| File pattern | MUST re-read |
|:-------------|:-------------|
| `artifacts/tasks/done.md` | `hybrid-3-file-integrity.md` C2 |
| `artifacts/tasks/*.md` | `hybrid-3-file-integrity.md` |
| `.agents/rules/*.md` | `governance.md` |
| `kernel/`, `.para/` | `governance.md` |

Workflows enforce rules via Step 0 Pre-flight, but direct edits bypass that guard. Project rules MAY define additional file guards.

## Related

- [Context Recovery Architecture](../architecture/context-recovery.md) — 4-layer Defense-in-Depth
- [Rule Layers](../architecture/rule-layers.md) — Two-Tier trigger mechanism
- **Source**: `templates/common/agents/rules/agent-behavior.md`
