# Agent Behavior & Communication

> Agent governance rule for behavior and communication standards.

## Scope

- [x] Global (applies to entire workspace)

## Rules

### 1. Language Configuration

- **MUST** respect the `preferences.language` setting in `.para-workspace.yml` for documentation and chat responses.
- **MUST** keep technical artifacts (code variables, commit messages) in English for standard compatibility.
- **SHOULD** adapt communication language to the user's configured preference.

### 2. Communication Style

- **MUST** be concise — focus on the solution, avoid fluff.
- **SHOULD** use checklists when completing multi-step tasks (✅ Done, ⏳ Pending).
- **MUST** state errors clearly and propose a fix immediately when they occur.

### 3. Workflow Standards

- **MUST** perform a verification step (`npm run build` or test) after every code change, unless the user explicitly requests `--quick`.
- **MUST NOT** `git commit` or `git push` without user confirmation, unless explicitly running a trusted workflow (`/push`, `/release`).
- **MUST** check the build result before reporting "Done".
- **SHOULD** prioritize using defined workflows in `.agent/workflows/` over ad-hoc commands.
- **SHOULD** ask the user instead of assuming when uncertain.

### 4. Context Recovery

When context appears incomplete (cannot recall loaded rules, received truncation/checkpoint notice, or conversation has been very long):

1. **MUST** re-read `.agent/rules.md` (workspace rules index) before performing any side-effect.
2. **MUST** re-read project `.agent/rules.md` (if exists) before project-specific actions.
3. **SHOULD** inform user: "Context recovery — re-loaded rules index."

Side-effects requiring rules re-read:

- Git operations (commit, push, merge, branch, tag, PR)
- File deletion, move, or rename outside project scope
- Install/deploy commands
- Creating/modifying system config files

#### File-Level Guards

When editing these files **directly** (outside of a workflow), agent **MUST** re-read the corresponding rule first:

| File pattern              | MUST re-read before editing     |
| :------------------------ | :------------------------------ |
| `artifacts/tasks/done.md` | `hybrid-3-file-integrity.md` C2 |
| `artifacts/tasks/*.md`    | `hybrid-3-file-integrity.md`    |
| `.agent/rules/*.md`       | `governance.md`                 |
| `kernel/`, `.para/`       | `governance.md`                 |

> **Why:** Workflows enforce rules via Step 0 Pre-flight, but direct file edits bypass that guard. This table ensures rule compliance even without a workflow.
>
> **Extensible:** Project-specific rules MAY define additional file guards in their own rule files (e.g., `maintenance.md` may guard `CHANGELOG.md` and `VERSION`).
