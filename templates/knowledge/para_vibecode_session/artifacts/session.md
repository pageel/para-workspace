# Vibecode Session Memory

> **Status:** Inactive
> **Active Plan:** None

## Vibecode Rules
- Agent MUST only focus on code implementation tasks defined in the active plan.
- Do NOT modify project management artifacts (e.g., backlog.md, done.md) during vibecode.
- Agent MUST check that the task checklist in the active plan/phase is marked as completed ([x]) BEFORE proposing or executing a git commit or push.
- Defer all synchronization tasks to `/end`.
