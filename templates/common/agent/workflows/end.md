---
description: Log session and close working day with PARA classification
source: catalog
---

# /end [project-name | all | workspace] [done]

> **Workspace Version:** 1.4.3 (Governed Libraries)
> **Constraint:** Read `.para-workspace.yml` at the workspace root to get the user's preferred language from `preferences.language` (e.g., `vi` for Vietnamese). **All output and the final report MUST be translated to this language.**

Summarize accomplishments and log them to the correct context (Project vs. Workspace).

| Option | Description                                                                                                    |
| :----- | :------------------------------------------------------------------------------------------------------------- |
| `all`  | Đóng phiên làm việc cho tất cả các dự án đã thay đổi trong git status.                                         |
| `done` | (Optional) Nếu kế hoạch dự án (`active_plan`) đã hoàn thành 100%, tự động gỡ bỏ trường này trong `project.md`. |

## Classification Rules

1. **Project Work**: Active development, bug fixes, or documentation for a specific project.
   - **Log Destination**: `Projects/[project-name]/sessions/YYYY-MM-DD.md`
2. **Workspace & Learning**: Refactoring workspace structure, creating learning artifacts, global standards, or infrastructure updates.
   - **Log Destination**: `Areas/Workspace/sessions/YYYY-MM-DD.md`

## Steps

### 1. Classify & Identify Changes

// turbo

Review your task and determine if it belongs to a specific Project or a Global Area. List modified files.

### 2. Log Session

Create or append to the correct destination based on the rules above. Use "Session X" headers if multiple topics were covered.

Include:

- **What was done** (completed items, bullet list)
- **Pending TODOs** (carry-forward items for next session)
- **Downstream Impact** (if changes affect other projects)

### 3. Cross-Project Sync Queue

Check if the project has `downstream` dependencies in `project.md` (or metadata).
If yes, **append one row** to `Areas/Workspace/SYNC.md` under the `## Pending` table:

```markdown
| YYYY-MM-DD | [project-name] | [new-version] | [downstream-project] | [brief action needed] | 🔴 Pending |
```

### 4. Check Plan Phase Progress (if active)

// turbo

> ⚠️ **Token optimization:** Only check if `project.md` has `active_plan` field (already read in Step 1). Skip entirely if missing.

If `active_plan` exists in `project.md`:

1. Extract current phase:
   ```bash
   grep -n "^### Phase" Projects/[project-name]/artifacts/[active_plan]
   ```
2. Cross-reference with backlog — count ✅ Done items for the current phase.
3. Report phase status in the session log:

```markdown
### Plan Progress

- **Current Phase**: [Phase N: Name]
- **Progress**: [N/M] tasks done
- **Status**: [🔨 In Progress | 🎉 Phase Complete!]
```

4. Nếu tất cả các mục trong phase cuối cùng đã hoàn thành HOẶC người dùng ra lệnh kèm từ khóa `done`:
   - Nếu kịch bản là 100% hoàn thành:
     - Thông báo: `🎉 Project Plan Complete! Cleaning up active_plan reference.`
     - **Hành động**: Gỡ bỏ trường `active_plan` khỏi `project.md` để tối ưu hóa context cho phiên sau.
   - Nếu chỉ hoàn thành một phase trung gian:
     - Thông báo: `🎉 Phase [N] Complete! Phase [N+1] ready to start.`
5. Nếu phạm vi hoặc kiến trúc thay đổi trong phiên này, gợi ý chạy `/plan update`.

### 5. Update Master Index

// turbo

Append a summary line to the global index at `Areas/Workspace/SESSION_LOG.md`:

```markdown
| YYYY-MM-DD | [project-name] | [brief summary of session] |
```

## Related

- `/open` — Start session with context loading
- `/plan` — View or update implementation plan
- `/backlog` — View and manage project tasks
- `/push` — Quick commit and push
- `/retro` — Project retrospective before archiving
