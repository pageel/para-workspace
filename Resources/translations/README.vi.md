# PARA Workspace Specification

## 1. Mục tiêu của tài liệu

Tài liệu này định nghĩa **chuẩn workspace cá nhân** dựa trên phương pháp **PARA (Projects – Areas – Resources – Archive)**, được thiết kế riêng cho **Antigravity Workspace** – nơi kết hợp:

- Code (Git repositories)
- Documentation
- Agent / Beads / Automation
- Tư duy dài hạn của người làm sản phẩm & hệ thống

Mục tiêu chính:

- Giảm cognitive load
- Chuẩn hoá vòng đời công việc
- Giúp agent hiểu đúng ngữ cảnh
- Giữ workspace sống bền vững theo thời gian

---

## 🚀 Bắt đầu nhanh (Quick Start)

Khởi tạo và quản lý workspace bằng các công cụ CLI:

```bash
# Tạo dự án mới
./para scaffold my-new-project

# Lên kế hoạch tính năng
./para plan my-new-project "Cài đặt OAuth"

# Kiểm chứng task
./para verify my-new-project "OAuth Login"

# Kiểm tra sức khoẻ workspace
./para status

# Nâng cấp một dự án cũ sang chuẩn PARA v1.3
./para migrate old-project-folder
```

### 🤖 Lệnh Slash của Agent

Sau khi cài đặt, bạn có thể yêu cầu AI Agent quản lý workspace bằng:

- `/para`: Lệnh tổng lực để chuẩn hóa, kiểm tra trạng thái hoặc migrate dự án.

---

## 2. Triết lý cốt lõi

### 2.1 Workspace là hệ thống tư duy, không chỉ là nơi chứa file

Workspace không đơn thuần là filesystem. Nó là:

- Bản đồ công việc đang diễn ra
- Bộ nhớ dài hạn của quyết định
- Nơi agent và con người cùng cộng tác

PARA được chọn vì nó **phản ánh cách não người phân loại công việc theo thời gian**, không theo loại file hay công nghệ.

---

### 2.2 PARA không phải taxonomy, mà là lifecycle

| Thành phần | Câu hỏi mà não đặt ra     |
| ---------- | ------------------------- |
| Projects   | Tôi đang làm gì?          |
| Areas      | Tôi phải duy trì điều gì? |
| Resources  | Tôi có thể tham khảo gì?  |
| Archive    | Cái gì đã xong?           |

Mỗi item trong workspace **luôn thuộc đúng 1 nhóm tại 1 thời điểm**.

---

## 3. Cấu trúc workspace chuẩn

```txt
workspace-root/
├─ Projects/
├─ Areas/
├─ Resources/
├─ Archive/
└─ .agent/
```

### Quy ước chung

- Luôn dùng **tên đầy đủ**, không viết tắt
- PascalCase cho thư mục top-level
- Không đặt Git repo trực tiếp ở root

---

## 4. Projects

### 4.1 Định nghĩa

**Project** là bất kỳ công việc nào:

- Có mục tiêu rõ ràng
- Có trạng thái (đang làm / gần xong)
- Có điều kiện kết thúc

Ví dụ:

- Phát triển sản phẩm
- Migrate hệ thống
- Thử nghiệm kỹ thuật có output

---

### 4.2 Cấu trúc Project chuẩn

```txt
Projects/
└─ project-name/
   ├─ repo/         # Source code
   ├─ sessions/     # Nhật ký phiên làm việc (Daily logs)
   ├─ artifacts/    # NEW: Artifact của Agent (Plans, Walkthroughs, Tasks)
   ├─ docs/         # Tài liệu dự án
   ├─ .agent/       # Cấu hình Agent riêng cho dự án
   └─ project.md    # Trạng thái dự án
```

### 4.3 project.md (bắt buộc)

```md
# Project: <name>

## Goal

## Status

## Key Decisions

## Dependencies

## Done Condition
```

Project tồn tại để **được hoàn thành**, không phải để duy trì mãi.

---

## 5. Areas

### 5.1 Định nghĩa

**Area** là các lĩnh vực trách nhiệm lâu dài:

- Không có điểm kết thúc
- Project có thể đến và đi
- Rule & decision được tích luỹ

Ví dụ:

- Infrastructure
- Architecture
- Product strategy
- Community management

---

### 5.2 Cấu trúc Areas

```txt
Areas/
├─ Infrastructure/
├─ Architecture/
├─ Product/
└─ Community/
```

### 5.3 Nguyên tắc

- Không chứa code đang active
- Chỉ chứa tài liệu, rule, policy
- Là nơi Project "đẩy tri thức lên"

---

## 6. Resources

### 6.1 Định nghĩa

**Resources** là kho kiến thức tham khảo:

- Research
- So sánh
- Ghi chú học tập
- Ý tưởng chưa kích hoạt

Resources **không điều khiển hành vi**, chỉ hỗ trợ hiểu biết.

---

### 6.2 Cấu trúc Resources

```txt
Resources/
├─ Databases/
├─ Frameworks/
├─ Agents/
└─ Notes/
```

### 6.3 Nguyên tắc

- Không chứa quyết định cuối cùng
- Có thể trùng lặp, chưa hoàn chỉnh
- Agent chỉ đọc khi được yêu cầu

---

## 7. Archive

### 7.1 Định nghĩa

**Archive** là nơi đóng băng:

- Project đã xong
- Thử nghiệm thất bại
- Ý tưởng không theo đuổi

---

### 7.2 Cấu trúc Archive

```txt
Archive/
├─ 2024/
├─ Deprecated/
└─ Experiments/
```

### 7.3 Nguyên tắc

- Không chỉnh sửa thường xuyên
- Agent mặc định ignore
- Không xoá trừ khi chắc chắn

---

## 8. Tích hợp Agent (Kiến trúc)

Chúng tôi tuân theo triết lý **Thin Root / Rich Project** (Gốc mỏng / Dự án giàu) cho các AI Agent:

### 🌟 Root `.agent/` (Thin)

Đóng vai trò là "Hiến pháp" của workspace. Chỉ chứa các quy tắc toàn cục:

- `workspace.yaml`: Định nghĩa cấu trúc PARA & Thứ tự quét (Scan Order).
- `conventions.md`: Các quy ước về đặt tên & Phong cách lập trình.

### 🧩 Project `.agent/` (Rich)

"Trạm năng lượng" của công việc hàng ngày. Mỗi dự án có thư mục `.agent` riêng chứa:

- `role.md`: Persona (vai trò) cụ thể cho dự án đó.
- `context.yaml`: Các quy tắc đặc thù của domain.
- `workflow.md`: Các bước tự động hóa.

**Quy tắc Vàng của Agent**: Một Agent thường chỉ hoạt động trong phạm vi mà nó được định nghĩa.

- Root Agent -> Điều hướng (Routing) & Quét (Scanning).
- Project Agent -> Lập trình (Coding) & Thực thi (Execution).

---

## 9. Vòng đời chuẩn của một Project

1. Khởi tạo trong Projects/
2. Tích luỹ decision trong Beads
3. Chuyển hoá decision → Areas
4. Hoàn thành
5. Di chuyển sang Archive/

Project chết đi, tri thức thì không.

---

## 10. Anti-patterns cần tránh

- Dùng PARA để phân loại file
- Để Project sống mãi trong Projects/
- Trộn Areas và Resources
- Để agent scan toàn workspace

---

## 11. Naming & Casing Convention (Bắt buộc)

### 11.1 Nguyên tắc chung

Workspace được xem là **public API cho não người và agent**, vì vậy naming phải:

- Self-documenting
- Không cần giải thích thêm
- Đọc hiểu được sau 6–12 tháng

---

### 11.2 Quy ước thư mục

| Cấp              | Quy ước    | Ví dụ                          |
| ---------------- | ---------- | ------------------------------ |
| Top-level (PARA) | PascalCase | Projects/, Areas/              |
| Domain           | PascalCase | Infrastructure/, Architecture/ |
| Project          | kebab-case | pageel-workhub/                |
| Experiment       | kebab-case | libsql-turso-migrate/          |

---

### 11.3 Quy ước file

| Loại          | Quy ước                | Ví dụ            |
| ------------- | ---------------------- | ---------------- |
| Policy / Rule | kebab-case.md          | backup-policy.md |
| Architecture  | kebab-case.md          | git-based-cms.md |
| Notes         | snake_case.md          | quick_notes.md   |
| Entry         | README.md / project.md | project.md       |

---

### 11.4 Tên cấm dùng

- misc
- temp
- new
- test123
- final_v2

Những tên này **làm agent mất khả năng suy luận ngữ nghĩa**.

---

## 12. PARA Workspace RFC (Versioned)

### RFC-0001: PARA Workspace Standard

**Status**: Accepted  
**Version**: 1.0.0  
**Applies to**: Antigravity Workspace

---

### 12.1 Problem

Workspace phát triển theo thời gian thường gặp các vấn đề:

- File và repo trộn lẫn
- Project cũ không được đóng
- Agent đọc quá nhiều context
- Người dùng quay lại sau thời gian dài bị lạc

---

### 12.2 Decision

Áp dụng PARA làm **cấu trúc workspace cấp cao nhất**, với các quyết định:

- Sử dụng tên đầy đủ: Projects / Areas / Resources / Archive
- Mỗi item chỉ thuộc 1 nhóm PARA tại 1 thời điểm
- Project phải có điều kiện kết thúc rõ ràng
- Tri thức dài hạn phải được đẩy lên Areas

---

### 12.3 Consequences

#### Positive

- Giảm cognitive load
- Agent routing chính xác
- Workspace scale tốt theo năm

#### Trade-offs

- Cần kỷ luật archive
- Cần viết project.md

---

### 12.4 Migration Strategy

1. Tạo thư mục PARA
2. Di chuyển project đang active vào Projects/
3. Gom policy / rule vào Areas/
4. Gom research vào Resources/
5. Đóng băng phần còn lại vào Archive/

---

### 12.5 Graduation Rule (Quan trọng)

Một Project **BẮT BUỘC** rời Projects/ khi:

- Goal đạt hoặc bị huỷ
- Không còn commit trong 30–60 ngày
- Decision đã được tổng hợp vào Areas/

---

## 13. Kết luận cuối cùng

PARA Workspace là **hạ tầng tư duy**, không phải mẹo sắp xếp.

Nếu bạn duy trì kỷ luật:

- Workspace sẽ không mục nát
- Agent ngày càng thông minh hơn
- Bạn không phải dọn dẹp lại từ đầu

Đây là hệ thống được thiết kế để **đồng hành lâu dài**, không phải cho một giai đoạn ngắn.

---

## 14. Artifact-Driven Workflow (Quy trình làm việc dựa trên Artifact)

Để đảm bảo chất lượng cộng tác với AI agent, chúng ta sử dụng **Lớp Artifact (Artifact Layer)**. Lớp này đóng vai trò cầu nối giữa "ý định" và "thực thi".

| Loại Artifact           | Mục đích                                                    | Vị trí                    | Lệnh CLI                      |
| :---------------------- | :---------------------------------------------------------- | :------------------------ | :---------------------------- |
| **Task List**           | Danh sách TODO đang hoạt động với Definition of Done (DoD). | `artifacts/tasks.md`      | `(Quản lý thủ công)`          |
| **Implementation Plan** | Kế hoạch từng bước cho các tính năng phức tạp.              | `artifacts/plans/`        | `./para plan <proj> <desc>`   |
| **Walkthrough**         | Các bước kiểm chứng để đảm bảo tính đúng đắn.               | `artifacts/walkthroughs/` | `./para verify <proj> <desc>` |

### Quy trình (The Cycle)

1. **Plan (Lập kế hoạch)**: Agent tạo một `Implementation Plan` (`./para plan`).
2. **Execute (Thực thi)**: Agent thực hiện thay đổi trong `repo/`.
3. **Verify (Kiểm chứng)**: Agent tạo một `Walkthrough` (`./para verify`) để kiểm tra thay đổi.
4. **Log (Ghi nhật ký)**: Agent ghi lại kết quả vào `sessions/`.
5. **Status (Trạng thái)**: Kiểm tra tiến độ tổng thể bằng `./para status`.

---

## 15. Hợp đồng dự án (Project Contracts - Spec v1.3)

Để đảm bảo Workspace có thể "thực thi bởi Agent", mọi dự án phải tuân thủ một hợp đồng dữ liệu nghiêm ngặt.

### Schema của `project.md` (YAML Frontmatter)

Mỗi thư mục gốc của dự án phải có file `project.md` với:

```yaml
---
goal: "Mục tiêu cụ thể bằng chuỗi ký tự"
deadline: "YYYY-MM-DD"
status: "active" | "paused" | "done" | "archived"
dod: [ "Checklist 1", "Checklist 2" ]
last_reviewed: "YYYY-MM-DD"
---
```

### `artifacts/tasks.md`

Các tác vụ phải được định dạng dưới dạng danh mục có thể liên kết:

```markdown
- [ ] Tên tính năng
  - DoD: Chuỗi ký tự định nghĩa khi nào là Hoàn thành
  - Plan: link/to/plan.md
  - Walkthrough: link/to/walkthrough.md
```

---

---

## 17. Các thành phần cốt lõi (Core Components)

Hệ sinh thái PARA Workspace bao gồm 3 trụ cột chính:

### 🛠️ PARA CLI (Tầng thực thi)

Bộ công cụ bash chuẩn hóa để quản lý cấu trúc vật lý của workspace:

- `scaffold`: Tạo dự án mới với đầy đủ thư mục chuẩn.
- `plan`: Tạo kế hoạch thực thi cho agent.
- `verify`: Tạo walkthrough để kiểm chứng chất lượng.
- `status`: Báo cáo cấp cao về sức khỏe dự án và hạn chót.
- `migrate`: Nâng cấp các thư mục cũ lên chuẩn PARA v1.3.

### 🧠 PARA Kit Skill (Tầng trí tuệ)

Nằm tại `.agent/skills/para-kit/`, đây là "bộ não" hướng dẫn AI agent:

- **Lựa chọn chiến lược**: AI tự chọn giữa script CLI nhanh hoặc workflow cộng tác tùy theo nhiệm vụ.
- **Kiểm toán dự án**: Tự động đánh dấu các task quá hạn hoặc dự án bị đình trệ.
- **Trích xuất tài nguyên**: Gợi ý các mẫu (patterns) để đưa vào `Resources/` khi dự án kết thúc.

### 📑 Thư viện Workflow (Tầng tự động hóa)

Danh mục các workflow có sẵn trong `Resources/ai-agents/workflows/` với tiền tố `p-`:

- `/para`: Quản lý master (mặc định đã cài đặt).
- `/p-kickoff`: Khởi động dự án bài bản.
- `/p-plan`: Tự động hóa việc tạo roadmap.
- `/p-verify`: Vòng lặp kiểm chứng tự động.
- `/p-release`: Kiểm tra dọn dẹp và phát hành.
- `/p-retro`: Rút bài học kinh nghiệm trước khi lưu trữ.
