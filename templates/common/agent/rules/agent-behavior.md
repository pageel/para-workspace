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
