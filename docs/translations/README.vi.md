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

## 2. Triết lý cốt lõi

### 2.1 Workspace là hệ thống tư duy, không chỉ là nơi chứa file

Workspace không đơn thuần là filesystem. Nó là:
- Bản đồ công việc đang diễn ra
- Bộ nhớ dài hạn của quyết định
- Nơi agent và con người cùng cộng tác

PARA được chọn vì nó **phản ánh cách não người phân loại công việc theo thời gian**, không theo loại file hay công nghệ.

---

### 2.2 PARA không phải taxonomy, mà là lifecycle

| Thành phần | Câu hỏi mà não đặt ra |
|----------|---------------------|
| Projects | Tôi đang làm gì? |
| Areas | Tôi phải duy trì điều gì? |
| Resources | Tôi có thể tham khảo gì? |
| Archive | Cái gì đã xong? |

Mỗi item trong workspace **luôn thuộc đúng 1 nhóm tại 1 thời điểm**.

---

## 3. Cấu trúc workspace chuẩn

```txt
workspace-root/
├─ Projects/
├─ Areas/
├─ Resources/
└─ Archive/
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
   ├─ repo/
   ├─ .beads/
   ├─ .agent/
   ├─ project.md
   └─ README.md
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

## 8. Agent & Beads trong PARA Workspace

### 8.1 Nguyên tắc phân vai

| Thành phần | Phạm vi |
|----------|--------|
| Beads | Project-specific memory |
| Agent rules | Project hoặc global |
| Long-term knowledge | Areas |

---

### 8.2 Agent scan order đề xuất

```yaml
scan_order:
  - Projects/**
  - Areas/**
  - Resources/**
  - Archive/**

rules:
  Archive/**: ignore
  Resources/**: read_on_demand
  Areas/**: reference
  Projects/**: primary
```

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

| Cấp | Quy ước | Ví dụ |
|---|---|---|
| Top-level (PARA) | PascalCase | Projects/, Areas/ |
| Domain | PascalCase | Infrastructure/, Architecture/ |
| Project | kebab-case | pageel-workhub/ |
| Experiment | kebab-case | libsql-turso-migrate/ |

---

### 11.3 Quy ước file

| Loại | Quy ước | Ví dụ |
|---|---|---|
| Policy / Rule | kebab-case.md | backup-policy.md |
| Architecture | kebab-case.md | git-based-cms.md |
| Notes | snake_case.md | quick_notes.md |
| Entry | README.md / project.md | project.md |

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

