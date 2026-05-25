---
id: CORS-MISCONFIG
severity_max: HIGH
applies_to: python
---

# CORS Misconfiguration — Python Specialization

> Override cho rule chung `rules/generic/15-cors-misconfig.md`. Áp dụng khi `primary_language: python`.

## Intent (Python-specific)

Vibe code Python thường vẽ CORS theo kiểu "cho qua hết để frontend chạy được": `CORS(app)` không argument trên Flask, `CORS_ALLOW_ALL_ORIGINS = True` trên Django, `allow_origins=["*"]` trên FastAPI. Sai lầm chết người là **kết hợp `allow_credentials=True` với origin wildcard** — trình duyệt sẽ gửi cookie sang bất kỳ origin nào server echo lại → attacker host trang evil.com đọc API có cookie auth của user.

Lỗi tinh tế hơn: dùng regex pattern không anchor cuối (`r".*\.example\.com"`) → khớp `evil.com.example.attacker.com` (subdomain takeover) hoặc `evil-example.com`.

## Khi nào HIGH

- `flask_cors.CORS(app)` không argument → default `origins='*'`
- Flask `CORS(app, supports_credentials=True, origins='*')` — CRITICAL combo
- Django `CORS_ALLOW_ALL_ORIGINS = True` + `CORS_ALLOW_CREDENTIALS = True`
- Django `CORS_ALLOWED_ORIGIN_REGEXES = [r".*\.example\.com"]` không có `$` anchor → bypass
- Django `CORS_ALLOWED_ORIGIN_REGEXES = [r"^https?://.*"]` quá rộng
- FastAPI `CORSMiddleware(allow_origins=["*"], allow_credentials=True)` — browser sẽ reject nhưng vibe code thường reflect origin từ request header → bypass
- Reflect origin từ header (echo) không validate: `response.headers['Access-Control-Allow-Origin'] = request.headers['Origin']`
- Set thủ công wildcard: `response.headers['Access-Control-Allow-Origin'] = '*'` + cookie auth

## Khi nào MEDIUM (giảm cấp)

- `allow_origins=["*"]` NHƯNG `allow_credentials=False` — vẫn lộ data public nhưng không đánh cắp được cookie
- Whitelist origin cụ thể: `allow_origins=["https://app.example.com"]` — SAFE
- Endpoint không trả data nhạy cảm (public API key info, healthcheck) — không flag

## Cách reasoning

1. **Grep**:
   - Flask: `flask_cors`, `CORS\(`, `CORS_ORIGINS`, `supports_credentials`
   - Django: `CORS_ALLOW_ALL_ORIGINS`, `CORS_ALLOWED_ORIGINS`, `CORS_ALLOWED_ORIGIN_REGEXES`, `CORS_ALLOW_CREDENTIALS`
   - FastAPI: `CORSMiddleware`, `allow_origins`, `allow_credentials`
2. **Identify combos nguy hiểm**:
   - `allow_origins=["*"]` + `allow_credentials=True` → HIGH
   - Reflect origin từ request → HIGH
   - Regex thiếu anchor `^...$` → HIGH
3. **Check endpoint sensitivity**:
   - Có cookie/session auth không? Có Bearer JWT không?
   - API trả data người dùng (PII, balance, history)?
4. **Verify**: production config khác dev không? `if settings.DEBUG: allow=*` chấp nhận nếu DEBUG=False prod.

## Search patterns

```
# Flask-CORS
from\s+flask_cors\s+import\s+CORS
CORS\s*\(\s*app\s*\)  # no args = all origins
CORS\s*\([^)]*supports_credentials\s*=\s*True[^)]*origins\s*=\s*['"]?\*
CORS\s*\([^)]*origins\s*=\s*['"]?\*[^)]*supports_credentials
CORS\s*\([^)]*resources\s*=\s*\{[^}]*origins['"]\s*:\s*['"]?\*

# Django
CORS_ALLOW_ALL_ORIGINS\s*=\s*True
CORS_ORIGIN_ALLOW_ALL\s*=\s*True   # legacy package
CORS_ALLOW_CREDENTIALS\s*=\s*True
CORS_ALLOWED_ORIGIN_REGEXES\s*=\s*\[[^\]]*r?["'][^"']*[^$]["']\s*[\],]  # regex không $
CORS_ALLOWED_ORIGINS\s*=\s*\[[^\]]*\*

# FastAPI / Starlette
from\s+fastapi\.middleware\.cors\s+import\s+CORSMiddleware
CORSMiddleware[^)]*allow_origins\s*=\s*\[\s*["']\*["']\s*\][^)]*allow_credentials\s*=\s*True
add_middleware\s*\(\s*CORSMiddleware

# Manual set wildcard
response\.headers\[['"]Access-Control-Allow-Origin['"]\]\s*=\s*['"]?\*
.*Access-Control-Allow-Origin.*request\.headers\[['"]?Origin
```

## Examples

### HIGH — flag

```python
# Flask-CORS no-arg = allow all
from flask_cors import CORS
app = Flask(__name__)
CORS(app)  # default: origins='*' + supports_credentials=False
# Vẫn lộ data API public nhưng không lấy được cookie

# Worse: bật credentials
CORS(app, supports_credentials=True, origins='*')  # CRITICAL combo
```

```python
# Django settings combo nguy
# settings.py
CORS_ALLOW_ALL_ORIGINS = True
CORS_ALLOW_CREDENTIALS = True
# Attacker host evil.com → fetch /api/me với cookie auth → đọc PII
```

```python
# Django regex thiếu $ anchor
CORS_ALLOWED_ORIGIN_REGEXES = [
    r"^https://.*\.example\.com",  # thiếu $ → khớp evil.example.com.attacker.com
]
CORS_ALLOW_CREDENTIALS = True
```

```python
# FastAPI wildcard + credentials
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,  # browser sẽ reject combo này
    allow_methods=["*"],
    allow_headers=["*"],
)
# Nhưng nếu kèm reflect origin thủ công → bypass
```

```python
# Reflect origin (echo) — bypass browser check
@app.after_request
def add_cors(response):
    origin = request.headers.get('Origin')
    response.headers['Access-Control-Allow-Origin'] = origin  # echo blindly
    response.headers['Access-Control-Allow-Credentials'] = 'true'
    return response
```

```python
# FastAPI middleware tự viết phản chiếu
@app.middleware("http")
async def cors_handler(request, call_next):
    response = await call_next(request)
    response.headers['Access-Control-Allow-Origin'] = request.headers.get('origin', '*')
    response.headers['Access-Control-Allow-Credentials'] = 'true'
    return response
```

### NOT critical — không flag

```python
# Whitelist origin cụ thể
from fastapi.middleware.cors import CORSMiddleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://app.example.com", "https://admin.example.com"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["Authorization", "Content-Type"],
)
```

```python
# Flask whitelist
CORS(app, resources={
    r"/api/*": {
        "origins": ["https://app.example.com"],
        "supports_credentials": True,
    }
})
```

```python
# Django regex chuẩn anchor đầu cuối
CORS_ALLOWED_ORIGIN_REGEXES = [
    r"^https://[\w-]+\.example\.com$",  # có cả ^ và $
]
```

```python
# Wildcard origin nhưng KHÔNG credentials — public API
CORS(app, origins='*', supports_credentials=False)
# Vẫn lộ data public nhưng không token theft → acceptable cho public API
```

## Fix recommendation

1. **Whitelist tuyệt đối**, KHÔNG wildcard nếu có credentials:
   ```python
   # FastAPI
   app.add_middleware(
       CORSMiddleware,
       allow_origins=[
           "https://app.example.com",
           "https://admin.example.com",
       ],
       allow_credentials=True,
       allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
       allow_headers=["Authorization", "Content-Type"],
   )
   ```
2. **Regex phải anchor cả 2 đầu**:
   ```python
   # Django
   CORS_ALLOWED_ORIGIN_REGEXES = [
       r"^https://[\w-]+\.example\.com$",
   ]
   ```
3. **Reflect origin có validate**:
   ```python
   ALLOWED = {"https://app.example.com", "https://admin.example.com"}
   origin = request.headers.get('Origin')
   if origin in ALLOWED:
       response.headers['Access-Control-Allow-Origin'] = origin
       response.headers['Vary'] = 'Origin'  # quan trọng cho cache
   ```
4. **Env-based origin** — config riêng dev/prod:
   ```python
   CORS_ALLOWED_ORIGINS = os.environ['CORS_ALLOWED_ORIGINS'].split(',')
   # .env prod: CORS_ALLOWED_ORIGINS=https://app.example.com
   # .env dev: CORS_ALLOWED_ORIGINS=http://localhost:3000
   ```
5. **Methods/Headers cũng whitelist** — không `allow_methods=["*"]` + credentials.
6. **Vary: Origin** trong response để CDN cache không nhầm lẫn origin.
7. **Tách public vs private endpoints**: `/api/public/*` có thể `*`, `/api/me/*` whitelist.
8. **Test bằng curl** với header `Origin: https://evil.com` xem có lọt không.

## Cross-references

- Python `11-csrf`: CORS sai + cookie auth = chain với CSRF
- Python `14-jwt-none-algorithm`: JWT trong cookie + CORS misconfig = token theft cross-origin
- Generic `12-broken-access-control`: CORS chỉ là transport layer, auth thực sự ở permission model
