# Agent Behavior & Communication

## 1. Language Configuration

- **Preference**: Respect the `language` setting in `.para-workspace.yml` (e.g., `vi` or `en`) for documentation and chat responses.
- **Code & Commits**: Technical artifacts (code variables, commit messages) MUST remain in **English** for standard compatibility.
- **Communication**: Adapt to the User's configured language.

## 2. Communication Style

- **Concise**: Focus on the solution. Avoid fluff.
- **Checklists**: When completing a multi-step task, summarize progress with a checklist (✅ Done, ⏳ Pending).
- **Error Handling**: If an error occurs, state it clearly and propose a fix immediately.

## 3. Workflow Standards

- **Build & Test**: Every code change (feat/fix) MUST include a verification step (`npm run build` or test), UNLESS the user explicitly requests `--quick`.
- **Git Approval**: DO NOT `git commit` or `git push` without user confirmation, unless explicitly running a trusted workflow like `/push`.
- **Verify**: Always check the build result before reporting "Done".
- **Workflow First**: Prioritize using defined workflows in `.agent/workflows/` over ad-hoc commands.
- **Ask First**: When in doubt, ask the USER instead of assuming.
