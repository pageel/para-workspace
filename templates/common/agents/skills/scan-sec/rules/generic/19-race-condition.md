---
id: RACE-CONDITION
severity_max: HIGH
applies_to: all
---

# Race Condition (TOCTOU) on Financial / Inventory Ops

## Intent

**Time-of-check vs time-of-use (TOCTOU)**: code đọc state → check điều kiện → cập nhật state, **giữa 3 bước có concurrent request khác chen vào**. Kết quả: double-spend, oversell, infinite coupon, withdraw vượt balance.

Pattern điển hình:
```python
balance = get_balance(user)        # đọc 100
if balance >= amount:              # check 100 >= 50 OK
    balance -= amount              # 100 - 50 = 50
    save_balance(user, balance)    # ghi 50
```

Nếu 2 request `amount=50` chạy song song, cả hai đều thấy `balance=100`, cả hai trừ về 50, kết quả: trừ 1 lần dù rút 2 lần → mất 50.

Vibe coder hay sinh code "đọc → if → ghi" không bọc transaction / row lock.

## Khi nào HIGH

- Endpoint financial / wallet / payment / withdrawal có pattern read-modify-write **không** transaction
- Inventory / stock decrement không atomic
- Coupon / discount redeem không check race (1 coupon dùng được nhiều lần)
- Quota / credit usage không atomic
- File rename / move có check `if exists` rồi mới rename (symlink race)

## Khi nào MEDIUM (giảm cấp)

- Race trên non-financial counter (likes, views) — sai số chấp nhận được
- Code có lock nhưng lock không bao phủ đúng critical section
- Code dùng optimistic locking (version column) nhưng không retry → user gặp error

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Grep** tìm hàm liên quan tiền/quota: `balance`, `wallet`, `credit`, `stock`, `inventory`, `quota`, `coupon`, `withdraw`, `transfer`, `redeem`
2. **Read** handler đó:
   - Có `BEGIN TRANSACTION` / `db.transaction()` / `with transaction.atomic():` không?
   - Có `SELECT ... FOR UPDATE` hoặc `WHERE balance >= ?` trong UPDATE không?
   - Hay là pattern `SELECT → check → UPDATE`?
3. **Trace concurrent**:
   - Endpoint async chấp nhận nhiều request đồng thời (mặc định Node, Go)
   - Single-thread (Python WSGI sync) vẫn race ở DB level
4. **Atomic operation check**: `UPDATE wallet SET balance = balance - 50 WHERE user_id = ? AND balance >= 50` — đây là an toàn (atomic). Còn select-modify-update không atomic.

## Search patterns (gợi ý — KHÔNG chạy literal, dùng Grep tool)

### Pattern read-modify-write

```
# Tìm get balance / get stock
get_?(balance|stock|inventory|quota|credit|wallet)
findOne.*\.balance|findOne.*\.stock
SELECT\s+balance\s+FROM
.balance\s*-=|.stock\s*-=|.credit\s*-=
```

### Tìm thiếu lock

```
# Tìm các nơi update tiền nhưng KHÔNG có transaction
\.update\([^)]*balance|\.save\(\)
UPDATE\s+\w+\s+SET\s+balance\s*=\s*\?  # update absolute value (warn)
```

### Lock / transaction patterns (an toàn)

```
SELECT\s+.*\s+FOR\s+UPDATE
\.transaction\(|begin\s*\(\)
with\s+transaction\.atomic
db\.session\.begin_nested
db\.transaction\s*\{
SERIALIZABLE
```

## Examples

### HIGH — flag

```javascript
// Express — wallet withdraw không lock
app.post('/api/withdraw', async (req, res) => {
  const user = await User.findById(req.user.id);
  if (user.balance >= req.body.amount) {
    user.balance -= req.body.amount;
    await user.save();                       // race: 2 request đồng thời cùng pass
    await Payout.create({ userId: user.id, amount: req.body.amount });
  }
  res.json({ ok: true });
});
```

```python
# Django — stock decrement không atomic
def buy(request, product_id):
    product = Product.objects.get(id=product_id)
    if product.stock > 0:
        product.stock -= 1
        product.save()                       # oversell
        Order.objects.create(user=request.user, product=product)
```

```python
# Coupon redeem race
def redeem(code):
    c = Coupon.objects.get(code=code)
    if not c.used:
        c.used = True
        c.save()                              # 2 request cùng dùng 1 coupon
        user.credit += c.amount
        user.save()
```

```javascript
// File rename TOCTOU
if (!fs.existsSync(target)) {                 // check
    fs.writeFileSync(target, data);           // use → giữa hai bước attacker tạo symlink
}
```

### NOT critical — không flag

```javascript
// Atomic SQL update với điều kiện
const result = await db.query(
  'UPDATE wallet SET balance = balance - $1 WHERE user_id = $2 AND balance >= $1',
  [amount, userId]
);
if (result.rowCount === 0) throw new Error('Insufficient funds');
```

```python
# Django transaction + select_for_update
from django.db import transaction
def withdraw(request):
    with transaction.atomic():
        user = User.objects.select_for_update().get(id=request.user.id)
        if user.balance < amount:
            raise ValidationError("Insufficient")
        user.balance -= amount
        user.save()
        Payout.objects.create(user=user, amount=amount)
```

```python
# Stock decrement atomic
from django.db.models import F
updated = Product.objects.filter(id=product_id, stock__gte=1).update(stock=F('stock') - 1)
if not updated:
    raise OutOfStock()
```

## Fix recommendation

1. **Atomic UPDATE với điều kiện:**
   ```sql
   UPDATE wallet
     SET balance = balance - :amount
     WHERE user_id = :uid AND balance >= :amount;
   -- check affected rows; nếu 0 → insufficient
   ```
2. **SELECT ... FOR UPDATE** trong transaction (pessimistic lock):
   ```python
   with transaction.atomic():
       w = Wallet.objects.select_for_update().get(user_id=uid)
       if w.balance < amount: raise
       w.balance -= amount
       w.save()
   ```
3. **Optimistic locking** với version column:
   ```sql
   UPDATE wallet SET balance = ?, version = version + 1
     WHERE id = ? AND version = ?;
   ```
   Retry khi version mismatch.
4. **Idempotency key** cho payment / withdraw: client gửi UUID, server reject duplicate.
5. **Database constraint**: `CHECK (balance >= 0)` — DB tự reject nếu race xảy ra.
6. **Queue serialization**: route tất cả op của 1 user qua 1 worker (Redis stream, partition by user_id).
7. **Audit log** mọi balance change — phát hiện sớm khi inconsistency xảy ra.

## Cross-references

- Cross-check với `12-broken-access-control`: race + thiếu auth = nhân đôi vấn đề
- Cross-check với `18-missing-rate-limit`: race xảy ra dễ khi attacker spam request
- Cross-check với `02-sql-injection` (nếu có): cả hai liên quan DB layer
