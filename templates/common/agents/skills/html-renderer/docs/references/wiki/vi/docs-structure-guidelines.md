# Cấu trúc thư mục Tài liệu (Docs) Best Practice

Một cấu trúc thư mục tài liệu kỹ thuật khoa học giúp nhà phát triển, AI Agent và các bên liên quan dễ dàng tra cứu, bảo trì và tự động hóa đồng bộ (Traceability) thông tin của dự án. 

Dưới đây là cấu trúc thư mục `docs/` chuẩn mực (Best Practice) được khuyến nghị áp dụng cho các dự án trong PARA Workspace.

---

## 1. Sơ đồ cấu trúc tổng quan

Mẫu cấu trúc thư mục `docs/` chuẩn cho một dự án trung bình đến lớn:

```text
docs/
├── README.md                   # Trang chủ tài liệu (Documentation Portal)
├── changelog.md                # Nhật ký thay đổi và lịch sử phiên bản
├── architecture/               # Kiến trúc hệ thống & Thiết kế
│   ├── overview.md             # Tổng quan kiến trúc & Sơ đồ khối (System Overview)
│   ├── spec.md                 # Đặc tả nghiệp vụ & Bảng quyết định (Spec & Decision Table)
│   └── database.md             # Sơ đồ quan hệ thực thể (ERD) & Schema thiết kế
├── development/                # Hướng dẫn dành cho nhà phát triển (Developer Guide)
│   ├── setup.md                # Hướng dẫn cài đặt môi trường & Chạy cục bộ
│   ├── standards.md            # Quy chuẩn viết code & Phong cách (Coding standards)
│   └── testing.md              # Quy trình kiểm thử & TDD guidelines
├── reference/                  # Tài liệu tham khảo kỹ thuật chi tiết
│   ├── api-endpoints.md        # Đặc tả các cổng API & payload mẫu
│   ├── cli.md                  # Hướng dẫn các tham số dòng lệnh CLI
│   └── third-party/            # Tài liệu tích hợp bên thứ ba (Ví dụ: sepay, stripe)
├── user-manual/                # Hướng dẫn sử dụng cho người dùng cuối (User Manual)
│   ├── index.md                # Tổng quan các tính năng phần mềm & giao diện
│   └── features/               # Các bài viết hướng dẫn chi tiết từng chức năng
└── ops/                        # Tài liệu vận hành & Triển khai
    ├── deployment.md           # Hướng dẫn CI/CD & Deploy production
    └── monitoring.md           # Hướng dẫn cấu hình logs, alert & giám sát hệ thống
```

---

## 2. Chi tiết vai trò từng thư mục & tệp tin

### 🏠 Trang chủ tài liệu (`docs/README.md`)
*   **Mục tiêu**: Điểm bắt đầu cho bất kỳ ai muốn đọc tài liệu.
*   **Nội dung**: Giới thiệu ngắn về dự án, liên kết nhanh đến các tài liệu quan trọng nhất (Kiến trúc, Cài đặt, API), thông tin liên hệ và trạng thái sức khỏe tài liệu hiện tại.

### 📐 Thư mục `docs/architecture/` (Kiến trúc & Đặc tả)
*   **overview.md**: Mô tả tổng quan về mô hình Client-Server, Tech Stack được sử dụng, và các luồng xử lý chính.
*   **spec.md**: Đây là **Operational Authority** về mặt nghiệp vụ. Chứa các Specs chi tiết của dự án, các Acceptance Criteria (AC), và các Bảng Quyết Định (Decision Tables) phục vụ cho quy trình đối chiếu sai lệch logic (Logic Drift / Drift Audit).
*   **database.md**: Mô tả thiết kế cơ sở dữ liệu, các bảng chính và mối quan hệ giữa chúng.

### 💻 Thư mục `docs/development/` (Hướng dẫn phát triển)
*   **setup.md**: Mô tả từng bước thiết lập từ lúc clone repo về cho đến khi chạy thành công dev server (Bao gồm các lệnh cài đặt dependencies, môi trường dev, cấu hình `.env.local` mẫu).
*   **standards.md**: Định nghĩa quy chuẩn đặt tên, quy tắc kiến trúc (như Clean Architecture, Hexagonal), quy chuẩn Git commits, PRs.
*   **testing.md**: Hướng dẫn cách chạy test suites, cách viết test cases và các ràng buộc về độ phủ kiểm thử (coverage).

### 📖 Thư mục `docs/reference/` (Tài liệu tra cứu tham khảo)
*   **api-endpoints.md**: Tài liệu hóa các endpoints cụ thể, cấu trúc Request/Response JSON, mã lỗi HTTP trả về.
*   **cli.md**: Mô tả đầy đủ các tham số cấu hình khi chạy CLI tool của dự án (nếu có).
*   **third-party/**: Lưu trữ các hướng dẫn tích hợp dịch vụ thanh toán, CRM, hoặc các nhà cung cấp hạ tầng trung gian khác.

### 👥 Thư mục `docs/user-manual/` (Hướng dẫn cho người dùng cuối)
*   **index.md**: Cổng thông tin hướng dẫn sử dụng, phân tích hành trình người dùng trên giao diện.
*   **features/**: Chứa các bài viết chi tiết, ảnh chụp màn hình (screenshots) hướng dẫn thực hiện từng tác vụ thực tế của người dùng (ví dụ: tạo hóa đơn, quản lý khách hàng).

---

## 3. Các quy chuẩn thiết lập tài liệu trong PARA Workspace

Để hệ thống định vị đồ thị (Code-Graph) hoạt động hiệu quả, bộ tài liệu trong thư mục `docs/` cần tuân thủ các quy chuẩn sau:

### 1. Nguyên tắc Đơn nguồn Sự thật (Single Source of Truth)
*   Mỗi cấu phần mã nguồn chỉ nên được giải nghĩa chi tiết tại **một** nơi duy nhất trong thư mục `docs/`.
*   Tránh tạo ra nhiều tệp tin trùng lặp nội dung giải nghĩa cho cùng một API hay một luồng logic nghiệp vụ.

### 2. Sử dụng đúng Neo liên kết (`docAnchors`)
Mỗi tệp tin tài liệu mô tả về mã nguồn phải sử dụng chú thích neo tương ứng.
*   **Cú pháp neo**: `<!-- @graph-node: <file_path_or_identifier> -->` đặt ngay dưới thẻ tiêu đề Markdown.
*   **Ví dụ**:
    ```markdown
    ### Xử lý Đăng nhập Người dùng
    <!-- @graph-node: src/controllers/auth.ts:loginHandler -->
    Hàm này thực hiện xác thực thông tin đăng nhập từ request...
    ```

### 3. Tách biệt Ngôn ngữ rõ ràng (Song ngữ vi/en)
Nếu dự án yêu cầu hỗ trợ đa ngôn ngữ cho tài liệu:
*   Mã nguồn (code base) chỉ chứa một bộ neo hoặc chú thích chuẩn tiếng Anh (English-First).
*   Các tệp tin tài liệu hỗ trợ đa ngôn ngữ có thể được tổ chức theo thư mục con (ví dụ: `docs/vi/` và `docs/en/`), hoặc hỗ trợ cấu hình đa ngôn ngữ động của máy chủ render.

---

## 💡 Đề xuất câu lệnh & Prompt gợi ý

Dưới đây là một số câu lệnh hữu ích bạn có thể gõ vào chat với AI Agent để quản lý cấu trúc tài liệu của dự án này:

*   **Đánh giá cấu trúc tài liệu hiện tại**:
    ```text
    /docs review cấu trúc thư mục docs hiện tại của dự án để xem có cần điều chỉnh gì không
    ```
*   **Khởi tạo tài liệu mới theo chuẩn**:
    ```text
    /docs [project-name] new --graph
    ```
    *(Thay `[project-name]` bằng tên dự án của bạn, ví dụ: `pageel-crm`)*
*   **Kiểm tra các liên kết hỏng hoặc thiếu neo**:
    ```text
    /docs [project-name] review --graph
    ```

