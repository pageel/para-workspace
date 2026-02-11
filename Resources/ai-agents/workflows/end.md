---
description: Log session and close working day with PARA classification
---

# /end [project-name | all | workspace]

> **Workspace Version:** 1.3.5 (PARA Standardized)

Summarize accomplishments and log them to the correct context (Project vs. Workspace).

## Classification Rules

1. **Project Work**: Active development, bug fixes, or documentation for a specific project.
   - **Log Destination**: `Projects/[project]/sessions/YYYY-MM-DD.md`
2. **Workspace & Learning**: Refactoring workspace structure, creating learning artifacts, global standards, or infrastructure updates.
   - **Log Destination**: `Areas/Workspace/workspace/YYYY-MM-DD.md`

## Steps

### 1. Classify & Identify Changes

Review your task and determine if it belongs to a specific Project or a Global Area. List modified files.

### 2. Log Session

Create or append to the correct destination based on the rules above. Use "Session X" headers if multiple topics were covered.

### 3. Update Master Index

Update the global index at `Areas/Workspace/SESSION_LOG.md`.
