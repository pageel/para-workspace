# Hướng dẫn viết tài liệu kỹ thuật chuẩn PARA Workspace

Hệ thống quản lý tri thức của PARA Workspace sử dụng cơ chế liên kết động giữa tài liệu kỹ thuật và mã nguồn thực tế (Traceability). 

Tài liệu này hướng dẫn cách soạn thảo tài liệu kỹ thuật chuẩn để hệ thống tự động nhận diện và tính điểm sức khỏe tài liệu (Docs Health Score).

---

## 1. Cơ chế liên kết tài liệu (docAnchors)

Hệ thống liên kết mã nguồn với tài liệu thông qua cú pháp chú thích neo đặc biệt (graph-node anchors):
- **Cú pháp trong tài liệu (.md):**
  `<!-- @graph-node: <node_id> -->`
- **Ví dụ cụ thể:**
  Nếu bạn muốn viết tài liệu thuyết minh cho hàm `autoMatchCustomer` định nghĩa trong file `src/lib/reconciliation.ts`:
  ```markdown
  ### Hàm đối soát tự động Khách hàng
  <!-- @graph-node: src/lib/reconciliation.ts:autoMatchCustomer -->
  Hàm này tự động so khớp thông tin chuyển khoản với cơ sở dữ liệu khách hàng...
  ```

---

## 2. Quy trình soạn thảo và cập nhật tài liệu

### 📝 Bước 1: Soạn thảo file Markdown
Viết tài liệu kỹ thuật chuẩn trong thư mục `docs/` của dự án (ví dụ: `docs/architecture/spec.md`). Giải thích rõ luồng xử lý và nghiệp vụ.
*   **Workflow hỗ trợ:** Bạn có thể khởi chạy workflow `/docs [project-name] new --graph` (ví dụ: `/docs para-workspace new --graph`) để hệ thống tự động phân tích codebase và sinh khung mẫu các tài liệu cơ bản còn thiếu.

### 🔗 Bước 2: Neo mã nguồn (Anchoring)
Đặt mã neo `<!-- @graph-node: ... -->` ngay bên dưới tiêu đề mô tả thành phần mã nguồn đó trong tài liệu markdown.
*   **Workflow hỗ trợ:** Hãy chạy `/docs [project-name] review --graph` để kiểm tra các neo liên kết bị thiếu sót hoặc lỗi thời. Nếu mã nguồn thay đổi cấu trúc, hãy chạy `/docs [project-name] update --graph` để tự động cập nhật lại thông tin mô tả chi tiết của node tương ứng.

### 🔄 Bước 3: Biên dịch và Cập nhật Đồ thị
Chạy quy trình phân tích đồ thị và cập nhật tài liệu:
1. Chạy cập nhật và biên dịch tài liệu bằng lệnh `/docs` (xem chi tiết tại phần 3).
2. Biên dịch tài liệu sang HTML tĩnh để xem trước bằng cách chạy workflow `/docs` với các cờ `--render --graph`:
   `/docs [project-name] --render --graph` (ví dụ: `/docs para-workspace --render --graph`)
   Lệnh này tự động cập nhật đồ thị, biên dịch toàn bộ tệp markdown sang HTML dạng Notion-style và khởi chạy máy chủ xem trước (live-reload preview).
3. Mở **Docs Quality Dashboard** để kiểm tra điểm sức khỏe tài liệu đã tăng lên và xem các node liên kết chuyển sang màu xanh (Completed).

---

## 3. Các lệnh Workflow `/docs` và tùy chọn `--graph`

Hệ thống cung cấp lệnh `/docs` chuyên dụng để tự động hóa việc khởi tạo, kiểm tra, và cập nhật tài liệu kỹ thuật dựa trên cấu trúc dự án thực tế.

### 🛠️ Các hành động chính (Actions)
*   **/docs [project-name] new --graph**: Phân tích toàn bộ codebase hiện tại, chạy đồ thị và khởi tạo tự động các tài liệu kỹ thuật cơ bản còn thiếu (ví dụ: `architecture.md`, `cli.md`) trong thư mục `docs/`.
*   **/docs [project-name] review --graph**: Chạy phân tích đồ thị code trước, sau đó kiểm tra độ phủ và độ tươi mới của bộ tài liệu hiện tại, đưa ra cảnh báo lỗi thời hoặc thiếu neo `@graph-node`.
*   **/docs [project-name] update --graph**: Chạy đồ thị mới nhất và tự động cập nhật nội dung tài liệu kỹ thuật để đồng bộ với sự thay đổi của mã nguồn.

### 🎯 Vai trò của tùy chọn `--graph`
Cờ `--graph` là tham số cực kỳ quan trọng khi chạy kèm với các hành động của `/docs`.
*   **Cú pháp:** `/docs [project-name] [action] --graph` (ví dụ: `/docs para-workspace review --graph`).
*   **Cơ chế hoạt động:** Khi có cờ `--graph`, hệ thống sẽ kích hoạt **Graph Pipeline** (chạy build cơ sở dữ liệu đồ thị code, phân tích mối quan hệ Upstream/Downstream và sinh các gói ngữ cảnh `Context Bundles`) **trước khi** tiến hành viết hoặc cập nhật tài liệu.
*   **Lợi ích:**
    *   Giúp AI Agent nắm được sơ đồ liên kết chính xác nhất của dự án ở thời điểm hiện tại.
    *   Tránh việc AI tự ý đoán hoặc sinh nội dung sai lệch so với mã nguồn thực tế (Anti-Hallucination).
    *   Tự động neo các `@graph-node` chuẩn xác vào tài liệu dựa trên phân tích Blast Radius và các God Nodes nóng nhất.

---

## 💡 Đề xuất câu lệnh & Prompt gợi ý

Dưới đây là một số câu lệnh hữu ích bạn có thể gõ vào chat với AI Agent để quản lý và đồng bộ tài liệu:

*   **Tự động cập nhật tài liệu đồng bộ với thay đổi mã nguồn**:
    ```text
    /docs [project-name] update --graph
    ```
*   **Kiểm tra độ phủ tài liệu và neo graph-node còn thiếu**:
    ```text
    /docs [project-name] review --graph
    ```
*   **Biên dịch tài liệu thành trang HTML tĩnh Notion-style**:
    ```text
    /docs [project-name] --render --graph
    ```

