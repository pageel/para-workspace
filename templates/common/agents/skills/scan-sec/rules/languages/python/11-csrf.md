---
id: CSRF
severity_max: HIGH
applies_to: python
---

# CSRF (Cross-Site Request Forgery) — Python Specialization

> Override cho rule chung `rules/generic/11-csrf.md`. Áp dụng khi `primary_language: python`.

## Intent (Python-specific)

Django có CSRF middleware bật mặc định — nhưng vibe code rất hay `@csrf_exempt` "để cho dễ test" rồi quên bật lại. Flask **không** có CSRF built-in — phải dùng `Flask-WTF` hoặc tự sinh token; vibe code thường skip luôn. FastAPI cũng không có CSRF — nhiều người tưởng JWT-trong-cookie là an toàn, nhưng cookie auto-send → vẫn dính CSRF. Cookie `SameSite=None` mà không có CSRF token = leo cầu sang phía attacker.

## Khi nào HIGH

- Django: `@csrf_exempt` trên view state-changing (POST/PUT/DELETE) — đặc biệt nguy nếu view xử lý transfer tiền, đổi password, đổi email
- Django settings: `MIDDLEWARE` thiếu `django.middleware.csrf.CsrfViewMiddleware`
- Django `CSRF_TRUSTED_ORIGINS = ['*']` hoặc list quá rộng (`['*.com']`)
- Flask: form/POST endpoint không kèm CSRF token (không dùng `Flask-WTF` và không có middleware tự custom)
- Flask-WTF: `WTF_CSRF_ENABLED = False` trong config production
- FastAPI: cookie-based auth không có CSRF token + `SameSite=Lax/None`
- Cookie `SESSION_COOKIE_SAMESITE = 'None'` mà không có `Secure=True` + CSRF token
- DRF: `authentication_classes = []` hoặc `SessionAuthentication` không enforce CSRF (vibe code hay quên CSRF với DRF session)

## Khi nào MEDIUM (giảm cấp)

- API auth bằng **Bearer token trong Authorization header** (không phải cookie) — CSRF-safe by design
- Endpoint chỉ GET / read-only — không thay đổi state
- Endpoint có check `Origin`/`Referer` header rõ ràng
- Cookie có `SameSite=Strict` (gần như miễn CSRF cross-site)

## Cách reasoning

1. **Grep**:
   - Django: `@csrf_exempt`, `csrf_exempt`, `CSRF_TRUSTED_ORIGINS`, `CsrfViewMiddleware`
   - Flask: `WTF_CSRF_ENABLED`, `CSRFProtect`, `csrf.protect`
   - FastAPI: `CSRFMiddleware`, `fastapi_csrf_protect`
   - Cookie config: `SESSION_COOKIE_SAMESITE`, `CSRF_COOKIE_SAMESITE`, `set_cookie`
2. **Read** view/handler — phương thức HTTP gì? Thay đổi state gì?
3. **Auth model** — JWT trong header hay session/cookie?
4. **Verify**:
   - Form HTML có `{% csrf_token %}` (Django) hoặc `{{ form.csrf_token }}` (Flask-WTF)?
   - AJAX gửi `X-CSRFToken` header? Read từ cookie?
   - SameSite cookie giá trị gì?

## Search patterns

```
# Django csrf_exempt
@csrf_exempt
@method_decorator\(\s*csrf_exempt\s*\)
csrf_exempt\s*\(

# Django settings - middleware thiếu hoặc bypass
MIDDLEWARE\s*=\s*\[[^\]]*\] # phải chứa CsrfViewMiddleware
CSRF_TRUSTED_ORIGINS\s*=\s*\[[^\]]*['"]\*['"]\]
CSRF_COOKIE_SECURE\s*=\s*False
CSRF_USE_SESSIONS\s*=\s*False  # info only

# Flask-WTF tắt
WTF_CSRF_ENABLED\s*=\s*False
csrf\.exempt
@csrf\.exempt

# Flask không có protect
from\s+flask_wtf\.csrf\s+import.*CSRFProtect  # nếu thiếu = nghi vấn

# Cookie SameSite
SESSION_COOKIE_SAMESITE\s*=\s*['"]None['"]
CSRF_COOKIE_SAMESITE\s*=\s*['"]None['"]
set_cookie\s*\([^)]*samesite\s*=\s*['"]None['"]
set_cookie\s*\([^)]*samesite\s*=\s*['"]Lax['"][^)]*\)  # với state-changing endpoint

# FastAPI cookie auth không CSRF
response\.set_cookie\s*\([^)]*httponly\s*=\s*True[^)]*\)  # check có CSRF token kèm không

# DRF
authentication_classes\s*=\s*\[\s*\]
permission_classes\s*=\s*\[\s*AllowAny\s*\]
```

## Examples

### HIGH — flag

```python
# Django csrf_exempt trên state-changing
from django.views.decorators.csrf import csrf_exempt

@csrf_exempt
def transfer_money(request):
    amount = request.POST['amount']
    to_account = request.POST['to']
    Transfer.objects.create(
        from_user=request.user, to=to_account, amount=amount
    )
    return JsonResponse({'ok': True})
# Attacker host form auto-submit từ evil.com → user click = mất tiền
```

```python
# Django settings tin tưởng wildcard
# settings.py
CSRF_TRUSTED_ORIGINS = ['*']  # equivalent to no protection
SESSION_COOKIE_SAMESITE = 'None'
CSRF_COOKIE_SECURE = False
```

```python
# Flask không CSRF
@app.post('/change-password')
def change_password():
    new_pw = request.form['password']
    current_user.set_password(new_pw)
    db.session.commit()
    return 'OK'
# Không có Flask-WTF + cookie session = CSRF
```

```python
# Flask-WTF tắt CSRF
class Config:
    SECRET_KEY = 'x'
    WTF_CSRF_ENABLED = False  # HIGH
app.config.from_object(Config)
```

```python
# FastAPI cookie auth không CSRF
@app.post('/api/delete-account')
async def delete_account(token: str = Cookie(...)):
    user = verify_jwt(token)
    await delete_user(user.id)
    return {"ok": True}
# Cookie auto-send từ any origin → CSRF
```

```python
# DRF SessionAuthentication không enforce CSRF với @csrf_exempt
class TransferView(APIView):
    authentication_classes = [SessionAuthentication]
    @method_decorator(csrf_exempt)
    def post(self, request):
        ...
```

### NOT critical — không flag

```python
# Django mặc định — CSRF middleware bật
# settings.py
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',  # bật
    'django.contrib.auth.middleware.AuthenticationMiddleware',
]
SESSION_COOKIE_SAMESITE = 'Lax'
SESSION_COOKIE_SECURE = True
```

```python
# JWT Bearer trong header — không phải cookie → CSRF-safe
@app.post('/transfer')
def transfer(token: str = Header(..., alias='Authorization')):
    user = verify_jwt(token.split(' ')[1])
    ...
```

```python
# Flask-WTF bật rõ
from flask_wtf.csrf import CSRFProtect
csrf = CSRFProtect(app)

# Form template
# <form method=post>
#   {{ form.csrf_token }}
#   ...
# </form>
```

```python
# FastAPI với fastapi-csrf-protect
from fastapi_csrf_protect import CsrfProtect

@app.post('/api/x')
async def x(request: Request, csrf_protect: CsrfProtect = Depends()):
    csrf_protect.validate_csrf(request)
    ...
```

## Fix recommendation

1. **Django** — KHÔNG bao giờ `@csrf_exempt` trên view state-changing. Nếu cần exempt cho webhook → verify HMAC/signature thay thế:
   ```python
   @csrf_exempt
   def stripe_webhook(request):
       sig = request.headers['Stripe-Signature']
       event = stripe.Webhook.construct_event(request.body, sig, WEBHOOK_SECRET)
       # verify thay CSRF
   ```
2. **Django settings** — production:
   ```python
   CSRF_COOKIE_SECURE = True
   CSRF_COOKIE_SAMESITE = 'Lax'
   SESSION_COOKIE_SECURE = True
   SESSION_COOKIE_SAMESITE = 'Lax'
   CSRF_TRUSTED_ORIGINS = ['https://app.example.com']  # KHÔNG '*'
   ```
3. **Flask** — bật `Flask-WTF`:
   ```python
   from flask_wtf.csrf import CSRFProtect
   csrf = CSRFProtect(app)
   # AJAX cần gửi X-CSRFToken header
   ```
4. **FastAPI** — dùng `fastapi-csrf-protect` HOẶC chuyển sang JWT trong header (không dùng cookie auth):
   ```python
   # Token trong Authorization header → miễn CSRF
   ```
5. **AJAX/SPA**: đọc CSRF token từ cookie, set vào header `X-CSRFToken`. Django/Flask-WTF đều support.
6. **Cookie hardening**:
   ```python
   response.set_cookie('session', token, httponly=True, secure=True, samesite='Lax')
   ```
7. **Double Submit Cookie pattern** nếu không thể server-store: cookie + header trùng giá trị → server verify match.

## Cross-references

- Python `14-jwt-none-algorithm`: JWT trong cookie cần CSRF token; JWT trong header thì không
- Python `15-cors-misconfig`: CORS + credentials misconfig phối hợp với CSRF
- Generic `12-broken-access-control`: CSRF chỉ là bypass auth context, nguyên nhân gốc là permission model
