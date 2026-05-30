# Hướng dẫn tối ưu hóa Blast Radius và xử lý God Nodes

Trong kiến trúc phần mềm, **Blast Radius (Bán kính ảnh hưởng)** cao và sự xuất hiện của các **God Nodes (Nút cốt lõi có kết nối quá lớn)** là hai thách thức lớn ảnh hưởng trực tiếp đến khả năng bảo trì và độ tin cậy của hệ thống. 

Tài liệu này cung cấp các giải pháp thực tế để kiểm soát và tối ưu hóa các chỉ số này.

---

## 1. Cách nhận diện và đánh giá rủi ro của God Nodes

Một thành phần mã nguồn (hàm, class hoặc file) được coi là **God Node** khi nó có bậc đồ thị trực tiếp `Degree >= 20`.
- **Rủi ro:** Khi sửa đổi một God Node, bạn có nguy cơ làm lỗi dây chuyền toàn bộ các module phụ thuộc phía trên (Upstream).
- **Phân loại:**
  - *God Nodes hợp lệ:* Các module dùng chung mang tính hạ tầng như `DB Client`, `Logger`, `Auth Helper`.
  - *God Nodes độc hại:* Các file hoặc hàm chứa quá nhiều business logic hỗn hợp (ví dụ: `reconciliation.ts` gánh cả khớp khách hàng, đối soát hóa đơn, tạo báo cáo và gửi email).

---

## 2. Chiến lược tối ưu hóa Blast Radius

Để giảm thiểu bán kính ảnh hưởng của một thành phần mã nguồn, hãy áp dụng các nguyên tắc sau:

### 🧩 Áp dụng Nguyên lý Đơn nhiệm (Single Responsibility Principle - SRP)
- Chia nhỏ các file hoặc hàm lớn gánh vác nhiều trách nhiệm thành các hàm phụ trợ độc lập.
- Điều này giúp phân tán luồng liên kết đi (Outdegree) và giảm thiểu số lượng module phụ thuộc ngược (Indegree).

### 🛡️ Đóng gói qua Giao diện (Dependency Inversion / Interfaces)
- Thay vì để các module trực tiếp gọi (import) code thực thi của nhau, hãy cho chúng phụ thuộc vào các Interface hoặc Abstract Class.
- Khi đó, Upstream Blast Radius sẽ bị ngắt quãng tại ranh giới của Interface, giúp bạn dễ dàng thay đổi code thực thi mà không làm ảnh hưởng các module gọi nó.

### 🧪 Viết Unit Test bao phủ chặt chẽ
- Bất kỳ nút nào có `Blast Radius > 5` đều bắt buộc phải có Unit Test kiểm thử đầy đủ các trường hợp biên (edge cases).
- Đảm bảo việc refactor code không làm thay đổi hành vi đầu ra mong muốn của hàm.
