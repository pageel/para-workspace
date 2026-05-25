---
id: CORS-MISCONFIG
severity_max: HIGH
applies_to: all
---

# CORS Misconfiguration

## Intent

CORS sai cho phép **website của hacker đọc data từ API của bạn dưới danh nghĩa user đã login**. Vibe coder gặp lỗi CORS thường copy snippet `Access-Control-Allow-Origin: *` + `Allow-Credentials: true` để "fix nhanh" — đây là combo nguy hiểm nhất: bất kỳ site nào (`evil.com`) chạy `fetch('https://yourapi.com/me', { credentials: 'include' })` đều đọc được response (cookie session đi kèm).

Hoặc echo origin header (`Allow-Origin: ${req.headers.origin}`) — tương đương `*` về tính bảo mật.

## Khi nào HIGH

- `Access-Control-Allow-Origin: *` **kết hợp** với cookie/credentials request (browser tự block nhưng nhiều framework tự echo origin để bypass)
- Echo origin: `res.setHeader('Access-Control-Allow-Origin', req.headers.origin)` + `Allow-Credentials: true`
- Whitelist regex yếu: `/.*example\.com.*/` → match `evil-example.com.attacker.com`
- `cors({ origin: true, credentials: true })` trong Express (= echo origin)
- `null` origin được accept (sandboxed iframe có thể abuse)

## Khi nào MEDIUM (giảm cấp)

- `Allow-Origin: *` nhưng KHÔNG có credentials và API không trả data nhạy cảm (public data)
- Whitelist cố định nhiều domain bao gồm cả test domain (`localhost`, `*.ngrok.io` còn trong production)
- Preflight cache (`Access-Control-Max-Age`) quá dài

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Grep** tìm CORS config: middleware, header setting, framework option
2. **Read** xác định:
   - Origin: cụ thể, wildcard `*`, hay echo dynamic?
   - Credentials: true/false?
   - API có authenticated endpoint không (có dùng cookie/Authorization)?
3. **Combo nguy hiểm**: Origin dynamic + Credentials true + API có authenticated endpoint = HIGH
4. **Check regex** nếu có whitelist: `^https://app\.example\.com$` (an toàn) vs `example\.com` (không anchor, bypass dễ)

## Search patterns (gợi ý — KHÔNG chạy literal, dùng Grep tool)

### Node.js / Express

```
cors\s*\(\s*\{[^}]*origin\s*:\s*(true|"\*"|\*)
cors\s*\(\s*\{[^}]*credentials\s*:\s*true
res\.(setHeader|header)\s*\(\s*["']Access-Control-Allow-Origin["']\s*,\s*req\.headers\.origin
res\.(setHeader|header)\s*\(\s*["']Access-Control-Allow-Origin["']\s*,\s*["']\*["']
```

### Python

```
# Flask-CORS
CORS\s*\(\s*\w+,\s*origins\s*=\s*["']\*["']
CORS\s*\(\s*\w+,\s*supports_credentials\s*=\s*True

# Django-cors-headers
CORS_ALLOW_ALL_ORIGINS\s*=\s*True
CORS_ALLOWED_ORIGIN_REGEXES\s*=\s*\[
CORS_ALLOW_CREDENTIALS\s*=\s*True

# FastAPI
CORSMiddleware\([^)]*allow_origins\s*=\s*\["\*"\]
allow_credentials\s*=\s*True
```

### Other

```
Access-Control-Allow-Origin
crossOrigin: ["']\*["']
header\s*\(\s*["']Access-Control-Allow-Origin:\s*\*["']
```

## Examples

### CRITICAL combo — flag HIGH

```javascript
// Express — combo origin echo + credentials
app.use(cors({
  origin: true,           // echo lại origin → wildcard với credentials
  credentials: true       // cookie/auth header đi qua
}));
```

```javascript
// Manual header set
app.use((req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', req.headers.origin);  // echo
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  next();
});
```

```python
# FastAPI — wildcard + credentials
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,   # combo nguy hiểm
    allow_methods=["*"],
)
```

```python
# Django — regex bypass-able
CORS_ALLOWED_ORIGIN_REGEXES = [r"https://.*\.example\.com"]   # match evil.example.com.attacker.com
CORS_ALLOW_CREDENTIALS = True
```

### NOT critical — không flag (hoặc downgrade)

```javascript
// Whitelist cố định, anchor đầy đủ
const allowed = ['https://app.example.com', 'https://admin.example.com'];
app.use(cors({
  origin: (origin, cb) => {
    cb(null, allowed.includes(origin));
  },
  credentials: true
}));
```

```python
# FastAPI — explicit origin list
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://app.example.com"],
    allow_credentials=True,
    allow_methods=["GET", "POST"],
)
```

```javascript
// Public API, không credentials
app.use(cors({ origin: '*' }));   // chỉ public read-only data
```

## Fix recommendation

1. **Whitelist origin cụ thể, anchor regex:**
   ```javascript
   const allowed = new Set([
     'https://app.example.com',
     'https://admin.example.com'
   ]);
   app.use(cors({
     origin: (origin, cb) => cb(null, !origin || allowed.has(origin)),
     credentials: true
   }));
   ```
2. **Không bao giờ combo `*` + `credentials: true`** — browser tự block nhưng đừng dựa vào.
3. **Đừng echo `Origin` header** mà không verify trong whitelist trước.
4. **Regex phải có anchor**: `^https://([\w-]+\.)?example\.com$`
5. **Tách subdomain risk**: nếu `*.example.com` whitelist, attacker chỉ cần XSS trên `blog.example.com` là chiếm session app.example.com.
6. **Preflight cache** thấp: `Access-Control-Max-Age: 600` (10 phút) thay vì 24h.

## Cross-references

- Cross-check với `03-xss` (nếu có): XSS trên subdomain whitelist = chiếm API
- Cross-check với `12-broken-access-control`: CORS không thay thế authorization
- Cross-check với `08-csrf` (nếu có): CORS và CSRF cùng pattern preflight
