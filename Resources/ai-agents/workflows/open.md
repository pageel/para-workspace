---
description: Bắt đầu phiên làm việc - xem lịch sử và đề xuất công việc tiếp theo
---

# /open [project-name]

> **Workspace Version:** 1.3.6 (Cross-Project Sync)

Bắt đầu phiên làm việc mới với context từ session trước.

## Steps

### 1. Xác định project paths

```
Base: Projects/[project-name]/
├── repo/           # Source code (git root)
├── sessions/       # Session logs & BACKLOG
├── docs/           # Project documentation
└── project.md      # Project contract (YAML)
```

### 2. Đọc project contract

// turbo

Read `Projects/[project-name]/project.md` to understand goal, deadline, status, and DoD.

### 3. Tìm và đọc session gần nhất

// turbo

```bash
ls -t Projects/[project-name]/sessions/*.md | head -3
```

Read the latest session log for context on previous work.

### 4. Đọc BACKLOG (nếu có)

// turbo

```bash
head -30 Projects/[project-name]/sessions/BACKLOG.md
```

### 5. 🔔 Check Sync Queue (Cross-Project Notifications)

// turbo

Read `Areas/Workspace/SYNC.md` and **filter rows** where the `Downstream` column matches `[project-name]` and Status is `🔴 Pending`.

If there are pending sync items, display them prominently:

```
⚠️ UPSTREAM CHANGES DETECTED:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
| Source: [upstream-project] v[version]
| Action: [what needs to be done]
| Date:   [when it was logged]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

After the user processes the sync, update the row in `SYNC.md`:

- Move the row from `## Pending` to `## Completed`
- Remove the `Status` column (Completed table doesn't have it)

### 6. Kiểm tra Git status

// turbo

```bash
cd Projects/[project-name]/repo && git status --short && git log -n 1 --oneline
```

### 7. Hiển thị báo cáo

```
🚀 Bắt đầu: [Project Name] | 📅 [YYYY-MM-DD]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 PHIÊN GẦN NHẤT: [Date] - [Focus]

✅ Đã hoàn thành:
- [Items from session log]

⏳ TODO tồn đọng:
- [ ] [Pending items]

🔔 SYNC QUEUE: [N pending] / [0 if none]

📥 BACKLOG SUMMARY:
- High: [N] | Medium: [N] | Low: [N]
- Top items: [list 2-3 items]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 ĐỀ XUẤT HÔM NAY:
1. [Priority 1 - include sync items if pending]
2. [Priority 2]

❓ Bạn muốn làm gì?
```

## Related

- `/end` - Kết thúc session
- `/backlog` - Xem backlog chi tiết
- `/push` - Quick commit and push
