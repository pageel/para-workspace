---
id: SQL-INJECTION
severity_max: CRITICAL
applies_to: go
---

# SQL Injection (Go)

## Intent

Trong Go, lỗ hổng SQLi xuất hiện khi **L1 input** (chi.URLParam, gin Context.Query, mux.Vars, fiber Ctx.Params) được ghép thẳng vào câu SQL bằng `fmt.Sprintf` hoặc string `+`, thay vì dùng placeholder `?` / `$1` của `database/sql` hoặc parameterized API của GORM. Attacker dump DB, escalate, hoặc đọc file qua `LOAD_FILE`.

Go có vẻ "an toàn" hơn vì stdlib ép placeholder, **nhưng GORM `Raw()`, `Exec()`, `Where(string,...)` với string concat** vẫn vibe code rất hay sinh sai.

## Khi nào CRITICAL

- L1 input ghép vào `db.Raw(fmt.Sprintf(...))`, `db.Exec(fmt.Sprintf(...))`, `db.Query(fmt.Sprintf(...))`
- `gorm.DB.Where("name = " + userInput)` (truyền 1 string đã concat thay vì pattern `Where("name = ?", val)`)
- Raw query trên `*sql.DB` với `fmt.Sprintf("SELECT ... %s", userInput)`
- Endpoint dùng router public (chi, gin, echo, fiber, gorilla/mux, stdlib `net/http`) không có middleware auth

## Khi nào HIGH (giảm cấp)

- Input trace về env var / config (L3) không phải request
- Đã có whitelist (`if !slices.Contains(allowedCols, col) { return err }`) trước khi nhét vào ORDER BY
- Endpoint chỉ admin (middleware check role qua context value)

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Grep** các sink: `db.Raw`, `db.Exec`, `db.Query`, `.QueryRow`, `.Where(`, `tx.Raw`
2. **Read** handler chứa call: trace biến từ `chi.URLParam`, `c.Query`, `c.Param`, `r.FormValue`, `mux.Vars(r)`, `c.Params(...)` (fiber)
3. **Trace L1→sink**:
   - Goroutine? Channel? Vẫn L1 nếu nguồn gốc là request.
   - Struct field nhận qua `c.BindJSON(&payload)` — vẫn L1 (mass-assignment cross-check)
   - GORM `Find(&users, "id = ?", id)` — placeholder, safe
   - GORM `Find(&users, fmt.Sprintf("id = %d", id))` — NGUY HIỂM dù `%d` cũng có thể bị bypass nếu interface{} là string
4. **Verify**: có dùng `?` / `$1` separator? Có whitelist trước concat?

## Search patterns (Go-specific)

```
# GORM raw query với fmt.Sprintf
\.(Raw|Exec|Query|QueryRow)\s*\(\s*fmt\.Sprintf
\.(Raw|Exec)\s*\(\s*`[^`]*\$\{          # rare, but template strings exist
\.(Raw|Exec|Query)\s*\(\s*"[^"]*"\s*\+

# GORM Where với string concat (BAD)
\.Where\s*\(\s*fmt\.Sprintf
\.Where\s*\(\s*"[^"]*"\s*\+

# database/sql với Sprintf
db\.(Query|Exec|QueryRow|QueryContext|ExecContext)\s*\(\s*fmt\.Sprintf

# sqlx
\.NamedQuery\s*\(\s*fmt\.Sprintf
\.Select\s*\(.*fmt\.Sprintf

# Sink nguy hiểm khác
\.Order\s*\(\s*[^"]*userInput     # GORM Order với user input không whitelist
\.Group\s*\(.*\+
```

## Examples

### CRITICAL — flag

```go
// chi router + GORM
func GetUser(w http.ResponseWriter, r *http.Request) {
    name := chi.URLParam(r, "name")  // L1
    var users []User
    db.Raw(fmt.Sprintf("SELECT * FROM users WHERE name='%s'", name)).Scan(&users)
}
```

```go
// gin + GORM Where string concat
func ListProducts(c *gin.Context) {
    q := c.Query("q")  // L1
    var products []Product
    db.Where("name LIKE '%" + q + "%'").Find(&products)  // BAD
}
```

```go
// fiber + database/sql
func handler(c *fiber.Ctx) error {
    id := c.Params("id")  // L1
    row := sqlDB.QueryRow(fmt.Sprintf("SELECT * FROM accounts WHERE id=%s", id))
    // ...
}
```

```go
// echo + sqlx
func search(c echo.Context) error {
    term := c.QueryParam("term")  // L1
    sqlxDB.Select(&results, "SELECT * FROM items WHERE title='"+term+"'")
    return c.JSON(200, results)
}
```

### NOT critical — safe

```go
// Parameterized — safe
db.Where("name = ?", name).Find(&users)
db.Raw("SELECT * FROM users WHERE id = ?", id).Scan(&u)
sqlDB.QueryRow("SELECT * FROM accounts WHERE id = $1", id)
```

```go
// Whitelist trước ORDER BY (cột không bind được)
allowed := map[string]bool{"name": true, "created_at": true, "price": true}
sort := c.Query("sort")
if !allowed[sort] {
    c.JSON(400, gin.H{"error": "bad sort"})
    return
}
db.Order(sort).Find(&products)  // safe vì whitelist
```

```go
// Struct embedding với gorm:"-" tránh mass-assignment nhưng KHÔNG fix SQLi nếu raw query vẫn concat
type User struct {
    ID   uint
    Role string `gorm:"-"`  // skip column, không liên quan SQLi
}
```

## Fix recommendation

1. **Luôn dùng placeholder `?` (GORM/MySQL) hoặc `$1, $2` (Postgres pgx):**
   ```go
   // BAD
   db.Raw(fmt.Sprintf("SELECT * FROM u WHERE id=%d", id))
   // GOOD
   db.Raw("SELECT * FROM u WHERE id = ?", id).Scan(&u)
   ```
2. **GORM idiomatic**: dùng `Where("col = ?", val)`, `First(&u, id)`, struct queries. Tránh `Raw` trừ khi cần.
3. **Tên cột / ORDER BY**: whitelist với `map[string]bool` hoặc `slices.Contains`.
4. **`context.Context`** không liên quan trực tiếp nhưng dùng `QueryContext` để hủy query lỗi nhanh, giảm thời gian tấn công.
5. **Defense in depth**: DB user least privilege, bật slow query log, dùng read-replica cho query SELECT.

## Cross-references

- Rule `17-verbose-error-debug-mode`: GORM error trả về SQL string nếu `c.String(500, err.Error())` — leak schema
- Rule `07-mass-assignment`: `c.BindJSON(&user)` cho phép set field `Role` → cross-check
- Rule `04-idor`: SQLi + no ownership check = nuke DB
