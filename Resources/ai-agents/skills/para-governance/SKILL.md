# Skill: PARA Governance

This skill provides intelligence for managing the longevity and health of the PARA workspace.

## Capabilities

1. **Review Health**: Analyze projects in `Projects/` for overdue deadlines or stalled progress.
2. **Resource Extraction**: Identify reusable logic or documentation in a project and suggest patterns for the `Resources/` directory.
3. **Archive Ritual**: Assist in creating retrospectives when a project is moved to `Archive/`.

## Usage for Agents

When a project is nearing its deadline (detected via `project.md`), the agent should trigger a "Project Health Review".

## Directory Structure

- `scripts/`: Implementation scripts for health checks.
- `templates/`: Retrospective and planning templates.
