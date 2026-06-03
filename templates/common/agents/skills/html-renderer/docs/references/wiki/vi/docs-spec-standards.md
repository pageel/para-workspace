# Tiêu chuẩn viết Đặc tả (Spec) & Tài liệu (Docs) trong PARA Workspace

Trong PARA Workspace, việc duy trì tính nhất quán và độ chính xác của tài liệu kỹ thuật cũng như đặc tả nghiệp vụ là nhiệm vụ sống còn. Để ngăn chặn hiện tượng trôi lệch tài liệu (**Documentation Drift**) và trôi lệch nghiệp vụ (**Logic Drift**), workspace thiết lập bộ tiêu chuẩn nghiêm ngặt được hỗ trợ bởi các Workflow, Skill và Rule tự động.

Dưới đây là chi tiết các tiêu chuẩn viết Đặc tả (Spec) và Tài liệu (Docs) cùng các minh chứng kỹ thuật tương ứng.

---

## 1. 📐 Tiêu chuẩn viết Đặc tả (Spec-Driven Development Standards)

Mục tiêu của Đặc tả (Spec) là làm sáng tỏ tất cả các hiểu lầm và xác định rõ ràng phạm vi tính năng **trước khi viết bất kỳ dòng mã nguồn nào**.

*   **Workflow điều phối:** `/spec` (nằm tại `.agents/workflows/spec.md`)
*   **Skill quản lý tiêu chuẩn:** `spec-driven-development` (nằm tại `.agents/skills/spec/SKILL.md`)

### 🔴 Quy tắc 1: Giả định là nguy hiểm (Assumptions Are Dangerous)
Giả định là nguồn gốc lớn nhất của việc phát triển sai hướng.
*   **Tiêu chuẩn:** AI Agent bắt buộc phải liệt kê toàn bộ các giả định kỹ thuật và nghiệp vụ (lấy từ tệp cấu hình `project.md` ở gốc dự án hoặc yêu cầu của người dùng) trước khi soạn thảo nội dung Spec chính.
*   **Thực thi:** Phải có một bước xác nhận tường minh từ phía người dùng (`+ask` hoặc phê duyệt kế hoạch) về các giả định này. Không được tự ý đưa ra quyết định ngầm định.

### 🔴 Quy tắc 2: Quy trình Gated Workflow (Không đi tắt)
Mỗi giai đoạn phát triển phần mềm phải đi qua các cổng phê duyệt (Gates) độc lập và có sự xác nhận của con người:
```text
DỰ THẢO (Draft Spec) ──→ DUYỆT (Approved Spec) ──→ KẾ HOẠCH (Plan) ──→ TASK (task.md) ──→ TRIỂN KHAI (Implement)
       │                         │                    │                 │
       ▼                         ▼                    ▼                 ▼
   Human Gate 1              Human Gate 2         Human Gate 3      Human Gate 4
```

### 🔴 Quy tắc 3: Chuyển Success Criteria thành điều kiện kiểm thử được
Các yêu cầu mơ hồ từ người dùng phải được viết lại dưới dạng Success Criteria cụ thể và có thể đo lường (Testable Success Criteria).
*   *Ví dụ tồi:* "Hệ thống hoạt động nhanh và mượt mà."
*   *Tiêu chuẩn chuẩn:* "Thời gian phản hồi API tìm kiếm phải nhỏ hơn 200ms với cơ sở dữ liệu 10,000 bản ghi; UI phải hiển thị trạng thái loading trong quá trình truy vấn."

### 🔴 Quy tắc 4: Hệ thống Giới hạn (Boundaries System)
Mỗi tài liệu Spec bắt buộc phải định nghĩa rõ ràng 3 tầng giới hạn hoạt động:
1.  **Always Do (Luôn luôn thực hiện):** Ví dụ: Chạy test trước khi commit, validate input đầu vào của API.
2.  **Ask First (Hỏi trước khi làm):** Ví dụ: Thay đổi database schema, thêm dependencies thư viện mới.
3.  **Never Do (Tuyệt đối không làm):** Ví dụ: Commit API keys/secrets lên Git, xóa các test cases đang thất bại để bypass CI/CD.

### 🔴 Quy tắc 5: Chốt chặn Đọc lại Đặc tả (Spec Re-read Checkpoint)
Đây là cơ chế quan trọng nhất để chống lại sự suy giảm ngữ cảnh (Context Decay) của AI Agent trong quá trình code dài hạn.
*   **Tiêu chuẩn:** Trước khi bắt đầu thực hiện bất kỳ task lập trình nào, Agent bắt buộc phải đọc lại phần Success Criteria và hệ thống Boundaries của Spec liên quan (bằng cách mở trực tiếp tệp Spec trong thư mục `artifacts/specs/`). Điều này đảm bảo Agent luôn tuân thủ đúng thiết kế ban đầu và không tự ý code thêm các tính năng ngoài tầm kiểm soát.

---

## 2. 📂 Tiêu chuẩn viết Tài liệu (Docs Templates & Freshness Standards)

Tài liệu lỗi thời còn nguy hiểm hơn việc không có tài liệu vì nó dẫn dắt sai lập trình viên và AI Agent.

*   **Workflow điều phối:** `/docs` (nằm tại `.agents/workflows/docs.md`)
*   **Skill quản lý tiêu chuẩn:** `Docs Templates` (nằm tại `.agents/skills/docs/SKILL.md`)

### 🔴 Quy tắc 1: Cập nhật tài liệu tức thì (Docs Freshness Rule)
Khi mã nguồn có thay đổi ảnh hưởng đến các giao diện công khai (Public Interfaces), tài liệu tương ứng bắt buộc phải được cập nhật trong **cùng một phiên làm việc** (same session).
*   **Các trường hợp kích hoạt:**
    *   Thêm mới hoặc thay đổi cổng API (ví dụ trong `docs/reference/api-endpoints.md`).
    *   Thay đổi Database Schema (Prisma/Drizzle schema).
    *   Thay đổi định dạng tệp cấu hình (`wrangler.jsonc`, `env.example.txt`).
    *   Thay đổi signature của hàm public quan trọng.

### 🔴 Quy tắc 2: Chống ảo tưởng nguồn (Source Verification Protocol)
Để đảm bảo AI Agent không tự suy diễn hoặc viết tài liệu cho các tính năng chưa tồn tại, mọi file tài liệu sinh ra phải được dán nhãn kiểm chứng nguồn:
```markdown
<!-- ⚠️ SOURCE-VERIFIED — Cross-referenced with [src/lib/auth.ts, wrangler.jsonc] on YYYY-MM-DD -->
```
*   **Quy chuẩn trạng thái:**
    *   Nếu một cấu hình được khai báo nhưng mã nguồn chưa triển khai, bắt buộc phải ghi rõ: `[Planned — Not yet implemented in source]`.
    *   Nếu tính năng đã bị xóa khỏi code, tài liệu tương ứng phải được xóa hoặc cập nhật ngay lập tức.

### 🔴 Quy tắc 3: Neo liên kết đồ thị (Graph-Anchoring Protocol)
Mỗi tệp tài liệu kiến trúc hoặc tính năng phải được liên kết trực tiếp với các nút trong Đồ thị mã nguồn thông qua cú pháp neo:
```markdown
<!-- @graph-node: [nodeId_hoặc_file_path] -->
```
Sau đó, chạy công cụ liên kết `graph_link_docs` để ghi nhận mối quan hệ hai chiều vào cơ sở dữ liệu graph, từ đó tự động tính toán điểm **Docs Health Score** và phát hiện các tài liệu bị lỗi thời (**Stale Docs**).

---

## 💡 Đề xuất câu lệnh & Prompt gợi ý

Dưới đây là các câu lệnh và prompt gợi ý giúp bạn duy trì và thực thi đúng các tiêu chuẩn Spec & Docs trong dự án:

### 📐 Câu lệnh & Prompt liên quan đến Đặc tả (Spec)
*   **Khởi tạo một đặc tả tính năng mới (Draft Spec) tuân thủ Gated Workflow:**
    ```text
    /spec [project-name] new-feature "Tích hợp cổng thanh toán SePay tự động đối soát giao dịch"
    ```
*   **Yêu cầu Agent liệt kê và xác minh các giả định trước khi viết spec:**
    ```text
    Trước khi viết Đặc tả cho tính năng X, hãy phân tích project.md và liệt kê toàn bộ các giả định (Assumptions) nghiệp vụ và kỹ thuật dưới dạng bảng Always/Ask/Never để tôi duyệt.
    ```
*   **Kích hoạt chốt chặn đọc lại Spec trước khi code:**
    ```text
    Hãy thực hiện Spec Re-read Checkpoint: Đọc lại Success Criteria và Boundaries trong file spec-X.md trước khi bắt đầu viết code cho hàm Y.
    ```

### 📂 Câu lệnh & Prompt liên quan đến Tài liệu (Docs)
*   **Tạo mới một file tài liệu kiến trúc mẫu chuẩn:**
    ```text
    /docs [project-name] new-doc architecture
    ```
*   **Kiểm tra độ tươi mới và rà soát lỗi thời của tài liệu (Freshness & Stale Audit):**
    ```text
    /docs [project-name] review --graph
    ```
*   **Yêu cầu Agent đối soát nguồn (Source Verification) để tránh ảo tưởng:**
    ```text
    Hãy thực hiện Source Verification Protocol cho file docs/reference/api.md. Quét toàn bộ mã nguồn trong src/ để đảm bảo mọi Endpoint và tham số được mô tả đều đang hoạt động thực tế. Thêm header <!-- ⚠️ SOURCE-VERIFIED --> khi hoàn tất.
    ```
