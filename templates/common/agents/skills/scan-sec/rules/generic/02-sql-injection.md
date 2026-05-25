---
id: SQL-INJECTION
severity_max: CRITICAL
applies_to: all
---

# SQL Injection

## Intent

Input từ user (L1) được ghép thẳng vào câu SQL bằng string concat hoặc f-string. Attacker gửi `' OR 1=1--` hoặc `'; DROP TABLE users;--` để **dump toàn bộ DB, xóa table, leo thang admin, đọc file hệ thống** (qua `LOAD_FILE` MySQL hoặc `pg_read_file` Postgres).

Đây là lỗ hổng kinh điển nhưng vibe code rất hay dính vì AI sinh code "cho nhanh" bằng f-string thay vì dùng parameterized query.

## Khi nào CRITICAL

- L1 input (req.body, req.query, req.params, $_GET, $_POST, request.args, msg.text) ghép vào câu SQL bằng `+`, `%s % `, f-string, template string, `.format()`
- Endpoint không có auth hoặc ai cũng gọi được
- Dùng raw query qua `db.execute()`, `cursor.execute()`, `mysqli_query`, `mysql_query`, `db.query()` mà KHÔNG truyền params riêng

## Khi nào HIGH (giảm cấp)

- Input có thể trace về L3/L4 (hardcoded list, enum, env var) — không phải L1 trực tiếp
- Có whitelist/regex kiểm tra trước (vd: chỉ cho phép `[a-z]+`)
- Endpoint chỉ admin gọi được (có middleware check role) — vẫn nguy hiểm vì insider/escalation, nhưng impact thấp hơn

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Grep** tìm các call site đến `execute`, `query`, `raw`, `exec` (xem patterns dưới)
2. **Read** đầy đủ function chứa call: xem biến truyền vào câu SQL đến từ đâu
3. **Trace** ngược lên L1-L4 (xem `references/data-flow-classification.md`):
   - Biến đó là param của route handler? → L1
   - Đọc từ DB rồi nhét lại vào query khác? → L2 (vẫn rủi ro stored SQLi)
   - Hardcoded constant? → L3, safe
4. **Verify sanitization**: có `escape()`, có parameterized (`?`, `$1`, `:name`) không?
5. Chỉ flag khi L1 → SQL sink WITHOUT params/escape

## Search patterns (gợi ý — KHÔNG chạy literal, dùng Grep tool)

### Python

```
# String building
(execute|executemany|raw)\s*\(\s*f["'].*\{
(execute|executemany|raw)\s*\(\s*["'].*%\s*[a-zA-Z_]
(execute|executemany|raw)\s*\(\s*["'].*\+\s*[a-zA-Z_]
\.format\s*\(.*\)\s*\)?\s*$         # near .execute()
# ORM raw
\.raw\s*\(\s*f["']
text\s*\(\s*f["']                   # SQLAlchemy text()
```

### Node.js

```
\.query\s*\(\s*`[^`]*\$\{           # template literal trong .query()
\.query\s*\(\s*["'][^"']*\+
db\.run\s*\(\s*`.*\$\{
sequelize\.query\s*\(\s*`.*\$\{
```

### PHP

```
mysql_query\s*\(\s*["'][^"']*\$
mysqli_query\s*\(.*\$_(GET|POST|REQUEST)
->query\s*\(\s*["'][^"']*\$
->exec\s*\(\s*["'][^"']*\$
```

### Go

```
db\.(Query|Exec|QueryRow)\s*\(\s*fmt\.Sprintf
db\.(Query|Exec|QueryRow)\s*\(\s*".*"\s*\+
```

## Examples

### CRITICAL — flag

```python
# Flask handler — username là L1
@app.route("/login", methods=["POST"])
def login():
    username = request.form["username"]   # L1
    password = request.form["password"]   # L1
    cursor.execute(f"SELECT * FROM users WHERE username='{username}' AND password='{password}'")
```

```javascript
// Express — req.params.id là L1
app.get("/user/:id", (req, res) => {
  db.query(`SELECT * FROM users WHERE id = ${req.params.id}`, (err, rows) => {
    res.json(rows);
  });
});
```

```php
<?php
// $_GET['q'] là L1
$q = $_GET['q'];
$result = mysqli_query($conn, "SELECT * FROM products WHERE name LIKE '%$q%'");
```

```go
// chi router — name là L1
name := chi.URLParam(r, "name")
rows, _ := db.Query(fmt.Sprintf("SELECT * FROM accounts WHERE name='%s'", name))
```

### NOT critical — không flag (hoặc downgrade)

```python
# Parameterized — an toàn
cursor.execute("SELECT * FROM users WHERE username=%s AND password=%s", (username, password))
```

```javascript
// Tham số riêng — an toàn
db.query("SELECT * FROM users WHERE id = ?", [req.params.id]);
// Prisma / ORM với binding cũng an toàn
const user = await prisma.user.findUnique({ where: { id: Number(req.params.id) } });
```

```python
# Whitelist enum trước khi nhét vào ORDER BY (cột không tham số hóa được)
ALLOWED = {"name", "created_at", "price"}
sort = request.args.get("sort")
if sort not in ALLOWED:
    abort(400)
cursor.execute(f"SELECT * FROM products ORDER BY {sort}")  # safe vì whitelist
```

## Fix recommendation

1. **Dùng parameterized query / prepared statement**:
   ```python
   # Trước (BAD)
   cursor.execute(f"SELECT * FROM users WHERE id={user_id}")
   # Sau (GOOD)
   cursor.execute("SELECT * FROM users WHERE id=%s", (user_id,))
   ```
2. **Dùng ORM cho query thường**: SQLAlchemy, Prisma, GORM, Eloquent, Django ORM — chúng tự bind tham số.
3. **Tham số không bind được (table name, column name, ORDER BY direction)**: dùng whitelist enum, KHÔNG nhận trực tiếp từ L1.
4. **Tránh dynamic SQL builder** kiểu f-string. Nếu phải build dynamic, dùng query builder của ORM (knex, sqlx).
5. **Defense in depth**: principle of least privilege cho DB user (read-only nếu chỉ select), bật log, dùng WAF.

## Cross-references

- Rule `17-verbose-error-debug-mode`: error SQL trả về full query → giúp attacker exploit nhanh hơn
- Rule `04-idor`: SQLi + thiếu auth ownership = nuke toàn DB
- Rule `07-mass-assignment`: cùng họ "input ghép thẳng" nhưng nhắm vào ORM model
