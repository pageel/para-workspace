---
title: "Liên kết hai chiều giữa Tài liệu và Mã nguồn"
order: 1
author: "Antigravity (AI Agent)"
version: "1.0.0"
status: "✅ Đã phê duyệt"
updated: "2026-06-03"
---
# Liên kết hai chiều giữa Tài liệu và Mã nguồn (Double-Binding Traceability)

Trong một dự án lớn, tài liệu kỹ thuật rất dễ bị lệch pha với mã nguồn thực tế (Documentation Drift). Để giải quyết triệt để vấn đề này, PARA Workspace áp dụng cơ chế **Double-Binding Traceability** (Liên kết hai chiều) giữa tài liệu (`docs/`) và mã nguồn (`src/`) thông qua công cụ Đồ thị mã nguồn Code-Graph (`para-graph`).

Dưới đây là chi tiết hoạt động của hai chiều liên kết này và cách khai thác chúng.

---

## 1. 📂 Chiều 1: Docs ➔ Code (Tài liệu hóa mã nguồn)

**Ý nghĩa:** Xác định một phần tài liệu Markdown đang thuyết minh cho đoạn code hoặc cấu phần nào trong mã nguồn.

### 🔗 Cơ chế thực thi (docAnchors)
Chiều liên kết này được thiết lập thủ công bằng cách chèn một chú thích neo đặc biệt (HTML comment anchor) ngay dưới tiêu đề của phần mô tả trong file Markdown:

```markdown
### [Tiêu đề mô tả tính năng]
<!-- @graph-node: [đường_dẫn_code_hoặc_định_danh] -->
```

*   **Đường dẫn file**: `src/lib/auth.ts`
*   **Chi tiết đến hàm**: `src/lib/auth.ts:verifySessionCookie`
*   **Ví dụ thực tế**:
    ```markdown
    ### Xác thực Session Cookie
    <!-- @graph-node: src/lib/auth.ts:verifySessionCookie -->
    Hàm này thực hiện giải mã và xác minh tính hợp lệ của Signed Cookie được gửi từ client...
    ```

### 📊 Lợi ích
*   **Xác định độ phủ tài liệu (Documentation Coverage)**: Đồ thị biết chính xác bao nhiêu phần trăm mã nguồn quan trọng đã được viết tài liệu.
*   **Tính điểm sức khỏe (Docs Health Score)**: Đóng góp một phần thông qua mức độ gán neo các cấu phần mã nguồn quan trọng (xem chi tiết ở mục 3).

---

## 2. 💻 Chiều 2: Code ➔ Docs (Ánh xạ ngược từ Mã nguồn)

**Ý nghĩa:** Từ một file code cụ thể, xác định xem nó đang được giải nghĩa bởi những tài liệu nào, hoặc liệu nó có đang bị bỏ quên hay không.

Bên cạnh neo từ phía tài liệu, Double-Binding yêu cầu thiết lập neo ngược từ phía mã nguồn thông qua cú pháp chú thích đặc biệt `@para-doc`.

### 🔗 Cú pháp rút gọn (Short-form Reference) — Khuyến nghị & Bắt buộc từ v0.17.4
Để tránh hỏng liên kết khi đổi tên hoặc di chuyển tệp tài liệu, lập trình viên chỉ cần sử dụng định danh CSA ID duy nhất được tiền tố bởi dấu `#` (hệ thống sẽ tự động quét đối chiếu động qua cơ sở dữ liệu SQLite):
```typescript
// @para-doc [#csa-verify-session]
export function verifySessionCookie(cookie: string) {
    // logic xác thực cookie...
}
```

### ⚠️ Cú pháp đầy đủ (Long-form Reference) — Đã bãi bỏ (Deprecated)
Hạn chế tối đa việc sử dụng cú pháp đầy đủ chứa đường dẫn vật lý:
```typescript
// @para-doc [doc-auth.md#csa-verify-session]
```
*Lý do*: Cách này gây liên kết cứng (coupling), dễ dẫn đến lỗi mồ côi (broken link) khi cấu trúc thư mục tài liệu thay đổi hoặc đổi tên tệp.

Khi chạy phân tích đồ thị, hệ thống sẽ đối chiếu song song:
1. Neo `<!-- @graph-node -->` trong tài liệu trỏ tới code.
2. Comment `// @para-doc` trong code trỏ ngược lại tài liệu.
Trạng thái **Đạt chuẩn / Đầy đủ (Completed)** 100% trên Dashboard chỉ được ghi nhận khi cả hai chiều liên kết này đều hợp lệ và khớp nhau.

### 🔍 Cơ chế tự động hóa đồ thị (Graph Enrichment)
Khi bạn chạy công cụ đồ thị (`para-graph build`), hệ thống sẽ quét tĩnh toàn bộ codebase để lập bản đồ gọi hàm (Call Graph). Sau đó, nó đối chiếu ngược lại với các neo trong thư mục `docs/`:

*   **Phát hiện Code chưa được tài liệu hóa (Unlinked Code)**: Hệ thống tự động liệt kê các tệp tin hoặc các God Nodes quan trọng chưa hề được liên kết đến bất kỳ tệp Markdown nào.
*   **Phát hiện Tài liệu lỗi thời (Stale Nodes)**: Nếu một hàm bị đổi tên, đổi tham số, hoặc file code bị xóa nhưng neo trong tài liệu vẫn trỏ tới thông tin cũ, hệ thống sẽ đánh dấu nút đó bị **Stale** (lỗi thời) và cảnh báo trên Dashboard.
*   **AI Context Bundling**: AI Agent có thể lấy ra toàn bộ các đoạn code liên quan đến một bài viết tài liệu cụ thể để tự động cập nhật nội dung một cách chính xác mà không bị ảo tưởng (Anti-Hallucination).

---

## 3. 📊 Cách tính Điểm số Sức khỏe (Docs Health Score Calculation)

Điểm số Sức khỏe tổng thể (Overall Health Status Score) hiển thị trên Dashboard phản ánh độ hoàn thiện, mức độ bao phủ và tính đồng bộ thực tế của tài liệu kỹ thuật so với mã nguồn thực tế.

### 🧮 Công thức tính toán
$$\text{Sức khỏe tổng thể} = \text{Độ bao phủ Đồ thị} \times \left(\frac{\text{Độ đồng bộ tài liệu}}{100}\right)$$

Trong đó:
1. **Độ bao phủ Đồ thị (Weighted Graph Coverage)**: 
   * Đo lường tỷ lệ bao phủ tài liệu của các cấu phần mã nguồn chính được định cấp độ quan trọng (trọng số mặc định: Cốt lõi/Critical = `5.0`, Trung bình = `2.0`, Bổ trợ = `0.5`).
   * Một cấu phần mã nguồn được cộng 100% trọng số nếu đạt chuẩn Double-Binding (vừa có neo `@graph-node` trong Markdown vừa có comment `@para-doc` trong code). Nếu chỉ có 1 trong 2 chiều liên kết, cấu phần đó chỉ đóng góp 50% trọng số.
2. **Độ đồng bộ tài liệu (Doc Sync Rate)**:
   * Tỷ lệ các tệp tài liệu khỏe mạnh (không chứa lỗi sai lệch/drift audit và không bị lỗi thời/stale) trên tổng số tài liệu của dự án.

### ⚙️ Các tùy chọn Hiệu chỉnh Chỉ số (Calibration Options)
Trong cửa sổ **Hiệu chỉnh chỉ số**, bạn có thể tùy chọn thay đổi các thành phần điểm số này:
* **Trọng số cấu phần**: Thay đổi trọng số (slider) để tăng mức đóng góp của cấu phần lõi hoặc giảm cấu phần phụ.
* **Kiểm tra comment neo**: Tắt tùy chọn này sẽ bỏ qua chiều liên kết ngược từ mã nguồn (`@para-doc`), cấu phần chỉ cần có neo tài liệu là nhận đủ 100% trọng số.
* **Bỏ qua cấu phần Bổ trợ**: Loại bỏ hoàn toàn các biến/hằng số phụ trợ (Low priority) ra khỏi tổng số trọng số cần bao phủ (giúp tăng điểm khi bỏ qua biến phụ).
* **Bỏ qua phạt tệp trễ hạn**: Bỏ qua hình phạt sụt giảm điểm số khi có tài liệu stale/drift, giữ hệ số độ đồng bộ luôn bằng 100%.

### 🛡️ Chỉ số phụ kiểm toán CSA Audit
Bảng điều khiển hiển thị thêm hai chỉ số kiểm toán quan trọng tương ứng với bộ quy tắc chốt chặn của CLI:
* **Tier 1 Specs Coverage (Hard Gate)**: Tỷ lệ bao phủ các neo đặc tả cứng nằm trong `artifacts/specs/`. Yêu cầu kiểm toán CLI đạt 100% để cho phép commit code.
* **Tier 2 Docs Coverage (Soft Gate)**: Tỷ lệ bao phủ các neo tài liệu hướng dẫn mềm nằm trong `docs/`. Yêu cầu đạt 50% để vượt qua.

---

## 🔁 Tóm tắt luồng tương tác hai chiều

```mermaid
graph TD
    subgraph Docs ["Tầng Tài liệu (docs/)"]
        DocA["README.md"]
        DocB["spec.md"]
    end

    subgraph Code ["Tầng Mã nguồn (src/)"]
        CodeA["auth.ts"]
        CodeB["reconciliation.ts"]
    end

    DocB -- "1. Neo @graph-node trong Markdown" --> CodeB
    CodeB -- "2. Chú thích @para-doc trong Code" --> DocB
    CodeA -- "3. Quét Graph & Phân tích tĩnh (Tự động)" --> DocA
    CodeB -- "Thay đổi logic/chữ ký" --> Stale["Cảnh báo Stale Node / Logic Drift"]
```


---

## 💡 Đề xuất câu lệnh & Prompt gợi ý

Dưới đây là các câu lệnh hữu ích được phân chia theo hai chiều liên kết giúp bạn dễ dàng đồng bộ tài liệu và mã nguồn:

### 📂 Chiều 1: Docs ➔ Code (Tài liệu trỏ tới Code)
*   **Kiểm tra độ phủ và chất lượng liên kết của tài liệu hiện tại**:
    ```text
    /docs [project-name] review --graph
    ```
*   **Tự động tạo khung tài liệu mới và neo graph-node thích hợp**:
    ```text
    /docs [project-name] new --graph
    ```

### 💻 Chiều 2: Code ➔ Docs (Mã nguồn trỏ ngược tới Tài liệu)
*   **Đồng bộ và cập nhật ngược tài liệu khi mã nguồn thay đổi (giải phóng stale nodes)**:
    ```text
    /docs [project-name] update --graph
    ```
*   **Tìm các file code quan trọng (God Nodes) chưa được liên kết ngược (Unlinked Code)**:
    ```text
    Liệt kê các God Nodes hoặc tệp mã nguồn chưa có comment neo @para-doc trỏ tới tài liệu của [project-name]
    ```
*   **Đối soát các chú thích neo `@para-doc` bị lệch vị trí trong code**:
    ```text
    Chạy lệnh đối soát comment neo @para-doc trong mã nguồn của dự án [project-name]
    ```

