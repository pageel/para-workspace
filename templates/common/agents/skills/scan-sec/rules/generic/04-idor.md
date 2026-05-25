---
id: IDOR
severity_max: HIGH
applies_to: all
---

# Insecure Direct Object Reference (IDOR)

## Intent

Endpoint nhận `id` từ user và trả về / sửa resource **mà không kiểm tra resource đó thuộc về user nào**. Attacker chỉ cần đổi số trong URL: `GET /api/orders/123` → `GET /api/orders/124` để **đọc đơn hàng người khác, đọc CMND, xem hóa đơn, sửa profile, xóa tài khoản khác**.

Vibe code cực dính lỗi này vì frontend ẩn nav nên dev tưởng "ai biết URL đâu", nhưng API gọi trực tiếp được. Đây là top 1 trong OWASP Top 10 2021 (Broken Access Control).

## Khi nào HIGH

- Endpoint nhận ID qua URL param / query / body và truy vấn DB **chỉ bằng ID đó**, không kèm `user_id = current_user`
- Resource là dữ liệu cá nhân, đơn hàng, chat, file upload, profile, billing
- Có auth (đã login) nhưng KHÔNG có ownership check

## Khi nào MEDIUM (giảm cấp)

- Resource là public (vd: bài blog đã publish, sản phẩm catalog)
- ID là UUID v4 random (khó đoán) — vẫn rủi ro nếu UUID leak qua nơi khác
- Endpoint chỉ admin gọi (có middleware role check), nhưng vẫn nên có ownership

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Grep** các route handler: `app.get`, `@app.route`, `router.get/post/put/delete` với path chứa `:id`, `<id>`, `{id}`
2. **Read** body handler đầy đủ: query DB chỉ bằng `id`, hay có thêm `user_id` / `owner_id`?
3. **Trace**: ID đến từ URL → L1. Resource trả về có chứa data nhạy cảm không?
4. **Verify auth layer**:
   - Middleware có gắn `req.user` từ JWT/session không?
   - Query có `WHERE id=? AND user_id=?` hoặc `.filter(owner=request.user)` không?
   - Có ACL/policy layer (CanCan, Pundit, casbin) không?
5. Chú ý: chỉ có `requireAuth` middleware (check đã login) **KHÔNG ĐỦ** — phải check ownership của từng resource.

## Search patterns (gợi ý — KHÔNG chạy literal, dùng Grep tool)

### Routes nhận ID

```
@app\.route\s*\([^)]*<int:id>
router\.(get|put|patch|delete)\s*\(\s*["'][^"']*:id
app\.(get|put|patch|delete)\s*\(\s*["'][^"']*:id
Route::(get|put|patch|delete)\s*\(\s*["'][^"']*\{id\}
\.MapGet\s*\(\s*"[^"]*\{id\}
```

### Query không có user_id

```
findById\s*\(\s*req\.params\.id\s*\)         # Mongoose
\.findUnique\s*\(\s*\{\s*where:\s*\{\s*id    # Prisma — check tiếp có user_id không
Model\.objects\.get\s*\(\s*id\s*=             # Django — KHÔNG có user
\.find\s*\(\s*params\[:id\]\s*\)              # Rails
SELECT.*FROM.*WHERE\s+id\s*=\s*\?            # raw SQL — chỉ id
```

### Dấu hiệu thiếu ownership

```
# Có req.user nhưng không dùng trong query
req\.user\.id                                # tốt — kiểm tra dùng ở đâu
current_user\.id
```

## Examples

### HIGH — flag

```javascript
// Express — bất kỳ ai login đều xem được order của người khác
app.get("/api/orders/:id", requireAuth, async (req, res) => {
  const order = await Order.findById(req.params.id);   // KHÔNG check user
  res.json(order);
});
```

```python
# Django — thiếu ownership
@login_required
def view_invoice(request, invoice_id):
    invoice = Invoice.objects.get(id=invoice_id)   # bất kỳ ai cũng đọc được
    return render(request, "invoice.html", {"invoice": invoice})
```

```php
<?php
// Laravel — không filter theo user
public function show($id) {
    $document = Document::find($id);
    return view('document.show', compact('document'));
}
```

```javascript
// PATCH endpoint — bất kỳ ai đổi được profile người khác
app.patch("/api/users/:id", requireAuth, async (req, res) => {
  await User.updateOne({ _id: req.params.id }, req.body);  // không check ownership
});
```

### NOT high — không flag (hoặc downgrade)

```javascript
// Có ownership check
app.get("/api/orders/:id", requireAuth, async (req, res) => {
  const order = await Order.findOne({ _id: req.params.id, userId: req.user.id });
  if (!order) return res.status(404).end();
  res.json(order);
});
```

```python
# Django — filter theo owner
@login_required
def view_invoice(request, invoice_id):
    invoice = get_object_or_404(Invoice, id=invoice_id, owner=request.user)
    return render(request, "invoice.html", {"invoice": invoice})
```

```ruby
# Rails — Pundit authorize
def show
  @document = Document.find(params[:id])
  authorize @document   # policy check
end
```

```javascript
// Resource public (bài blog đã publish) — OK
app.get("/api/posts/:id", async (req, res) => {
  const post = await Post.findOne({ _id: req.params.id, status: "published" });
  res.json(post);
});
```

## Fix recommendation

1. **Luôn filter theo owner trong query**:
   ```javascript
   // Trước (BAD)
   const order = await Order.findById(req.params.id);
   // Sau (GOOD)
   const order = await Order.findOne({ _id: req.params.id, userId: req.user.id });
   ```
2. **Dùng policy/ACL layer**:
   - Rails: Pundit / CanCanCan
   - Node: casbin, accesscontrol
   - Django: `django-guardian`, `PermissionRequiredMixin`
   - Laravel: Policies + `authorize()`
3. **Soft 404 khi không sở hữu**: trả 404 (không phải 403) để tránh leak thông tin "resource tồn tại".
4. **UUID v4 thay vì auto-increment INT**: phòng thủ phụ, không thay thế ownership check.
5. **Test E2E**: tạo 2 user, user A tạo resource, user B thử truy cập bằng ID — phải bị từ chối. Viết test này cho mọi resource endpoint.

## Cross-references

- Rule `02-sql-injection`: IDOR + SQLi = nuke
- Rule `07-mass-assignment`: cùng họ "trust input" — input có thể chứa `user_id` ghi đè owner
- Rule `11-csrf`: PUT/DELETE IDOR endpoint mà thiếu CSRF = exploit qua link
