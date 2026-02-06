---
description: Quản lý và thực thi các quy tắc (rules) trong workspace.
---

# /rule [action]

> **Workspace Version:** 1.3.2 (Intelligence & Customization)

Hệ thống quản lý quy tắc tập trung giúp đảm bảo tính nhất quán giữa con người và AI Agent.

## 📋 Catalog Operations

Sử dụng thư viện quy tắc có sẵn trong `Resources/ai-agents/rules/`.

// turbo

- **Liệt kê quy tắc**: `./para rule list`
- **Cài đặt quy tắc**: `./para rule install <tên-quy-tắc>`
  - Ví dụ: `./para rule install versioning`

## 🛠️ Project Execution

- **Định tuyến ngữ cảnh (RFC-0003)**:
  - Tự động ưu tiên Quy tắc Dự án (`Project Rules`) trước Quy tắc Chung (`Global Rules`).
  - Sử dụng `.agent/rules/context-rules.md` để kiểm tra agent có đang nạp quá nhiều file không cần thiết không.

- **Kiểm tra tính tuân thủ**:
  1. Đọc file quy tắc mục tiêu.
  2. Phân tích task hiện tại hoặc file đang viết.
  3. Báo cáo các điểm vi phạm (VD: sai format đặt tên, thiếu metadata).

## 🎓 Graduation (Beads to Rules)

- Trong quá trình `/p-retro`, nếu một "Bead" (điểm kiến thức) lặp lại nhiều lần, hãy đề xuất chuyển nó thành một Rule chính thức trong `.agent/rules/`.
