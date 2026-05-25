---
id: SQL-INJECTION
severity_max: CRITICAL
applies_to: python
---

# SQL Injection — Python Specialization

> Override cho rule chung `rules/generic/02-sql-injection.md`. Áp dụng khi `primary_language: python`.

## Intent (Python-specific)

Python ecosystem có nhiều cách query DB: **SQLAlchemy** (Core + ORM), **Django ORM**, **psycopg2**, **mysql.connector**, **asyncpg**. Mỗi cái đều có lối thoát "raw" (`.raw()`, `.extra()`, `text()`, `cursor.execute` với string format) mà vibe code rất dễ dùng f-string `f"SELECT ... {user_id}"` — trông giống parameterized nhưng thực ra là string concat. Đặc biệt nguy với Django + Flask + FastAPI vì routing nhận query string/JSON body làm input thẳng.

## Khi nào CRITICAL

- f-string / `.format()` / `%` / `+` concat trực tiếp trong `cursor.execute`, `text()`, `.raw()`, `.extra(where=...)`
- SQLAlchemy `db.execute(text(f"... {input}"))` không có bind params
- Django `.raw(f"... {input}")` hoặc `.extra(where=[f"... {input}"])`
- psycopg2/mysql.connector `cursor.execute(f"... {input}")` thay vì `cursor.execute("... %s", (input,))`
- `.filter(**dict)` với dict đến trực tiếp từ `request.POST`/`request.GET`/`request.json` — operator injection (`__gt`, `__regex`)
- Endpoint public (Flask route không `@login_required`, Django view không middleware auth, FastAPI không `Depends(get_current_user)`)

## Khi nào HIGH (giảm cấp)

- Input từ env/config (L3) chứ không phải request
- Whitelist regex chặt trước concat (vd: `if col in ALLOWED_COLUMNS`) — chấp nhận cho ORDER BY/tên bảng
- Endpoint chỉ admin với guard rõ ràng (`@user_passes_test(is_staff)`, FastAPI dependency `verify_admin`)
- Pydantic model strict + ép kiểu (`int(user_id)`) trước query

## Cách reasoning

1. **Grep** các sink: `cursor.execute`, `text\(`, `\.raw\(`, `\.extra\(`, `session.execute`, `db.execute`, `connection.execute`
2. **Read** view/handler chứa call, trace biến từ:
   - Django: `request.GET`, `request.POST`, `request.body`, `request.FILES`, `request.headers`, kwargs view (`pk`, `slug`)
   - Flask: `request.args`, `request.form`, `request.json`, `request.files`, `request.cookies`
   - FastAPI: parameter function (path/query/body parameter tự bind), `Body()`, `Query()`, `Path()`
3. **Trace L1→sink**:
   - L1 = trực tiếp HTTP
   - L2 = đọc từ DB rồi dùng lại (stored injection)
   - L3 = env/config
   - L4 = constant
4. **Verify**:
   - psycopg2/MySQLdb: dùng `%s` placeholder + tuple? Hay f-string?
   - SQLAlchemy: `text("... :id")` + `.params(id=...)`?
   - Django: `.raw("... %s", [id])` với positional binding?

## Search patterns

```
# psycopg2 / mysql.connector / sqlite3
cursor\.execute\s*\(\s*f["']
cursor\.execute\s*\(\s*["'][^"']*["']\s*%
cursor\.execute\s*\(\s*["'][^"']*["']\s*\+
cursor\.execute\s*\(\s*["'][^"']*\{[^}]*\}["']\.format

# SQLAlchemy text() với f-string
text\s*\(\s*f["']
text\s*\(\s*["'][^"']*["']\s*\+
session\.execute\s*\(\s*f["']
db\.execute\s*\(\s*f["']

# Django ORM raw/extra
\.raw\s*\(\s*f["']
\.raw\s*\(\s*["'][^"']*["']\s*\+
\.extra\s*\(\s*where\s*=\s*\[\s*f["']
\.extra\s*\(\s*where\s*=\s*\[\s*["'][^"']*["']\s*\+

# Operator injection via .filter(**dict) / get(**dict)
\.filter\s*\(\s*\*\*\s*(request\.(GET|POST|data)|kwargs)
\.get\s*\(\s*\*\*\s*request\.

# Generic SQL keyword in f-string near execute
f["'][^"']*(SELECT|INSERT|UPDATE|DELETE|DROP)\s+[^"']*\{

# asyncpg / aiomysql
\.fetch\s*\(\s*f["']
\.execute\s*\(\s*f["'][^"']*(SELECT|INSERT|UPDATE|DELETE)
```

## Examples

### CRITICAL — flag

```python
# Flask + SQLAlchemy text() với f-string
@app.route('/users/<int:uid>')
def get_user(uid):
    user_id = request.args.get('id')  # L1
    result = db.session.execute(
        text(f"SELECT * FROM users WHERE id = {user_id}")
    )
    return jsonify(result.fetchall())
# Exploit: ?id=1 OR 1=1 --
```

```python
# Django ORM .raw() concat
def search(request):
    q = request.GET.get('q')  # L1
    users = User.objects.raw(
        f"SELECT * FROM auth_user WHERE username LIKE '%{q}%'"
    )
    return render(request, 'list.html', {'users': users})
```

```python
# Django .extra() với where concat
def filter_view(request):
    col_value = request.POST['v']  # L1
    qs = Product.objects.extra(where=[f"price > {col_value}"])
    return JsonResponse(list(qs.values()))
```

```python
# psycopg2 cursor.execute với f-string
@app.post('/login')
def login():
    email = request.json['email']  # L1
    cur = conn.cursor()
    cur.execute(f"SELECT id FROM users WHERE email = '{email}'")
    row = cur.fetchone()
```

```python
# FastAPI + operator injection qua **dict
@app.post('/search')
async def search(filters: dict):  # L1 — Pydantic-less dict
    # filters = {"username__regex": ".*", "is_staff": True}
    users = User.objects.filter(**filters)  # bypass auth checks
    return list(users.values())
```

### NOT critical — không flag (hoặc downgrade)

```python
# SQLAlchemy text() với bind params — SAFE
result = db.session.execute(
    text("SELECT * FROM users WHERE id = :id"),
    {"id": user_id}
)
```

```python
# Django ORM typed API — SAFE by design
users = User.objects.filter(username=request.GET['q'])
# ORM tự escape

# Django .raw() với positional binding — SAFE
User.objects.raw("SELECT * FROM auth_user WHERE id = %s", [user_id])
```

```python
# psycopg2 với %s placeholder — SAFE
cur.execute("SELECT * FROM users WHERE id = %s", (user_id,))
```

```python
# Whitelist tên cột ORDER BY
ALLOWED = {'name', 'created_at', 'price'}
sort = request.GET.get('sort')
if sort not in ALLOWED:
    sort = 'created_at'
qs = Product.objects.raw(f"SELECT * FROM product ORDER BY {sort}")
```

## Fix recommendation

1. **psycopg2 / mysql.connector / sqlite3** — luôn dùng `%s` placeholder + tuple:
   ```python
   # BAD
   cur.execute(f"SELECT * FROM u WHERE id = {uid}")
   # GOOD
   cur.execute("SELECT * FROM u WHERE id = %s", (uid,))
   ```
2. **SQLAlchemy** — `text()` luôn kèm bind:
   ```python
   db.execute(text("SELECT * FROM u WHERE id = :id"), {"id": uid})
   # Hoặc dùng ORM/Core typed: session.query(User).filter(User.id == uid)
   ```
3. **Django ORM** — ưu tiên typed API (`.filter`, `.get`, `.exclude`). Nếu cần raw, dùng positional `%s`:
   ```python
   User.objects.raw("SELECT * FROM auth_user WHERE id = %s", [uid])
   ```
4. **Tránh `.filter(**dict)`** với dict từ request — whitelist field name trước:
   ```python
   ALLOWED_FILTERS = {'username', 'email'}
   clean = {k: v for k, v in request.GET.items() if k in ALLOWED_FILTERS}
   User.objects.filter(**clean)
   ```
5. **Ép kiểu** với Pydantic / form validation trước khi đẩy xuống query:
   ```python
   class UserQuery(BaseModel):
       id: int  # FastAPI tự reject nếu không phải int
   ```
6. **Defense in depth**: DB user least privilege, bật `query_logging` chỉ dev (cross-ref `VERBOSE-ERROR-DEBUG-MODE`).

## Cross-references

- Python `07-mass-assignment`: `User(**request.json)` cũng tận dụng cùng class lỗi
- Python `17-verbose-error-debug-mode`: Django/Flask debug leak full SQL stack trace
- Generic `04-idor`: SQLi + thiếu ownership check = full DB compromise
- Generic `12-broken-access-control`: endpoint public cần guard auth trước khi check SQLi
