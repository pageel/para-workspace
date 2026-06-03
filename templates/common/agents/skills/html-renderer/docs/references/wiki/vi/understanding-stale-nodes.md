# Hiểu về các nút Stale (Bị lỗi thời) trong Code-Graph

Trong quá trình vận hành hệ thống Quản lý tài liệu và Đồ thị mã nguồn (Code-Graph) của PARA Workspace, nhà phát triển sẽ thường xuyên gặp phải khái niệm **Nút Stale (Nút bị lỗi thời)**. Việc hiểu rõ bản chất, nguyên nhân và cách xử lý trạng thái stale là rất quan trọng để đảm bảo tính đồng bộ 100% giữa tài liệu kiến trúc và mã nguồn thực tế.

---

## 1. 🔍 Nút Stale là gì?

**Nút Stale (Stale Node)** là một thực thể mã nguồn (hàm, lớp, tệp tin, hoặc API endpoint) đã được ghi nhận trong cơ sở dữ liệu đồ thị, nhưng **logic hoặc cấu trúc mã nguồn của nó đã bị thay đổi cục bộ so với lần gần nhất thông tin ngữ nghĩa (Semantic Description) được làm giàu (Enrich)**.

Khi một nút bị stale, thuộc tính `semantic.staleSince` của nó trong cơ sở dữ liệu đồ thị sẽ được gán nhãn thời gian (timestamp) ghi nhận thời điểm phát hiện thay đổi.

> [!NOTE]
> Trạng thái stale **chỉ cảnh báo sự thiếu đồng bộ về mặt mô tả ngữ nghĩa (AI Summary)** của mã nguồn trong tài liệu, hoàn toàn không ảnh hưởng đến logic chạy runtime của ứng dụng.

---

## 2. ⚡ Nguyên nhân khiến Nút bị Stale

Đồ thị mã nguồn Code-Graph giám sát sự thay đổi thông qua hai cơ chế chính:
1.  **Thay đổi chữ ký (Signature Change):** Tên hàm, tham số đầu vào, kiểu dữ liệu trả về hoặc phạm vi dòng (startLine/endLine) của thực thể bị thay đổi.
2.  **Thay đổi nội dung file (MD5 Hash Change):** Tệp tin chứa thực thể mã nguồn bị chỉnh sửa cục bộ (ví dụ: bổ sung chú thích neo `@para-doc`, chỉnh sửa logic nghiệp vụ bên trong hàm).

Khi nhà phát triển chạy lệnh xây dựng lại đồ thị (`para-graph build`), công cụ phân tích tĩnh sẽ quét toàn bộ mã nguồn, tính toán lại mã MD5 Hash của từng tệp tin và so sánh chữ ký của các thực thể. Nếu phát hiện sai khác so với dữ liệu hiện tại trong đồ thị:
*   Đồ thị sẽ bảo lưu thông tin ngữ nghĩa cũ để tránh mất mát dữ liệu do AI sinh ra trước đó.
*   Đồ thị sẽ tự động đánh dấu nút đó là `staleSince = [Thời điểm quét]` để cảnh báo lập trình viên rằng mô tả của nút này có thể không còn phản ánh chính xác logic code mới.

---

## 3. ⚠️ Ảnh hưởng của Nút Stale đối với chất lượng tài liệu

Nếu hệ thống tồn tại quá nhiều nút stale:
*   **Attention Decay (Suy giảm sự chú ý của AI):** Khi AI Agent đọc thông tin từ đồ thị để viết/cập nhật tài liệu, thông tin cũ bị lệch pha có thể dẫn đến việc viết tài liệu sai lệch logic (hallucination).
*   **Docs Health Score:** Điểm số sức khỏe tài liệu trên Bảng điều khiển (Dashboard) sẽ hiển thị số lượng Stale Docs tăng lên, làm giảm mức độ tin cậy của tài liệu kỹ thuật.

---

## 4. 🛠️ Quy trình 3 bước xử lý triệt để Nút Stale

Để đưa số lượng nút bị stale về $0$ và đồng bộ hóa hoàn toàn hệ thống tài liệu, nhà phát triển thực hiện quy trình chuẩn sau:

### Bước 1: Commit các thay đổi cục bộ (Git Commit)
Trước khi làm sạch đồ thị, hãy đảm bảo toàn bộ mã nguồn thay đổi cục bộ đã được kiểm thử thành công và commit lên Git. Việc này giúp cố định mã MD5 hash của các tệp tin.

### Bước 2: Liên kết lại tài liệu (Link Docs)
Chạy lệnh liên kết lại để neo chính xác các vị trí chú thích trong tài liệu và code:
```bash
./para para-graph link [project-name]
# Hoặc chạy trực tiếp qua node
node Projects/para-graph/repo/dist/cli.js link [project-name]
```
Lệnh này quét toàn bộ neo `<!-- @graph-node -->` trong tài liệu Markdown và đối chiếu với code để giải phóng các liên kết neo cũ.

### Bước 3: Làm giàu lại ngữ nghĩa (Semantic Enrichment)
Đối với các nút lõi (God Nodes) bị stale, chạy quy trình làm giàu ngữ nghĩa để AI phân tích lại code mới và cập nhật `semantic.summary`:
*   Trong giao diện Dashboard, tích hợp chọn các nút bị stale và nhấn **Copy Prompt AI** hoặc sử dụng tính năng **Chat với Agent** để yêu cầu cập nhật.
*   Agent sẽ gọi công cụ MCP `graph_enrich` để ghi nhận mô tả mới, giải phóng hoàn toàn nhãn `staleSince` về `null`.

---

## 📊 Bảng so sánh nhanh

| Đặc điểm | Nút Stale (Stale Node) | Neo hỏng (Broken Link) |
| :--- | :--- | :--- |
| **Bản chất** | Code thay đổi logic/nội dung nhưng mô tả chưa cập nhật. | Neo tài liệu trỏ tới một hàm/file không còn tồn tại trong code. |
| **Độ nguy hại** | 🟡 Trung bình (Tài liệu có thể bị cũ). | 🔴 Cao (Tài liệu chứa đường dẫn/tham chiếu sai lệch). |
| **Cách xử lý** | Chạy `link` tài liệu và chạy `graph_enrich` cập nhật mô tả. | Sửa lại comment neo hoặc xóa tham chiếu thừa trong tài liệu Markdown. |

---

## 💡 Đề xuất câu lệnh & Prompt gợi ý

Dưới đây là một số câu lệnh và prompt hữu ích để xử lý các nút stale (lỗi thời) và đồng bộ tài liệu:

*   **Tự động cập nhật tài liệu đồng bộ với thay đổi mã nguồn**:
    ```text
    /docs [project-name] update --graph
    ```
*   **Liên kết lại các neo tài liệu bị lệch**:
    ```text
    /para para-graph link [project-name]
    ```
*   **Làm giàu ngữ nghĩa (enrich) cho các nút bị stale bằng AI**:
    Sử dụng công cụ MCP `graph_enrich` hoặc yêu cầu Agent:
    ```text
    Cập nhật và làm giàu ngữ nghĩa (enrich) cho các nút đang bị stale trong đồ thị của dự án [project-name]
    ```

