---
id: JWT-NONE-ALGORITHM
severity_max: CRITICAL
applies_to: python
---

# JWT none Algorithm & Weak Secret — Python Specialization

> Override cho rule chung `rules/generic/14-jwt-none-algorithm.md`. Áp dụng khi `primary_language: python`.

## Intent (Python-specific)

Thư viện phổ biến nhất là `PyJWT` (`import jwt`). **Trước PyJWT 2.0**, `jwt.decode(token, key)` mặc định chấp nhận BẤT KỲ algorithm nào kể cả `none` — attacker forge token với header `{"alg":"none"}` và payload tùy ý. Sau 2.0 bắt buộc truyền `algorithms=[...]` nhưng vibe code vẫn hay copy ví dụ cũ. Thêm 2 lỗi phổ biến:
1. **Weak/default secret**: `os.environ.get('JWT_SECRET', 'secret')` — fallback `'secret'` là từ điển đầu tiên ai cũng brute.
2. **RS256/HS256 confusion**: server expect RS256 nhưng `decode` pass public key làm HMAC secret → attacker dùng public key (lấy được vì public) sign HS256 token → bypass.

## Khi nào CRITICAL

- `jwt.decode(token, key)` KHÔNG có argument `algorithms=[...]`
- `jwt.decode(token, key, algorithms=["none"])` (rõ ràng cho phép none)
- `jwt.decode(token, key, algorithms=["HS256", "none"])` (chấp nhận none trong list)
- PyJWT version <2.0 trong `requirements.txt` mà không pin `algorithms`
- Secret hardcoded: `jwt.encode(payload, 'secret', ...)`, `jwt.encode(payload, 'changeme', ...)`
- Fallback secret yếu: `os.environ.get('JWT_SECRET', 'secret')`, `or 'dev'`
- Pass RSA public key vào `jwt.decode` mà `algorithms=["HS256", "RS256"]` (cho phép HMAC verify với public key)
- Dùng `jwt.get_unverified_header()` rồi `jwt.decode(..., options={"verify_signature": False})` — auth dựa trên payload chưa verify
- `python-jose` / `authlib` cùng pattern (none accepted, weak secret)

## Khi nào HIGH (giảm cấp)

- Secret yếu nhưng chỉ dùng cho dev/test rõ ràng (file `test_*.py`, `conftest.py`)
- `verify_signature=False` trong test fixture
- Frontend decode JWT để hiển thị UI (không phải authz) — không phải lỗ hổng server

## Cách reasoning

1. **Grep** sink: `jwt\.decode`, `jwt\.encode`, `get_unverified`, `verify_signature\s*:\s*False`, `algorithms\s*=`
2. **Read** function — biến `key` từ đâu?
   - `os.environ` → check default fallback
   - Constant string → CRITICAL
   - File config → có trong gitignore không? (cross-ref `01-hardcoded-secret`)
3. **Inspect requirements.txt** / `pyproject.toml`:
   - `PyJWT<2` hoặc unpinned và lockfile <2 → mặc định nguy
   - `python-jose` <3.3.0 có CVE algorithm confusion
4. **Trace token verify path**: middleware/dependency nào kiểm token? Có verify expiration (`exp`)? Có check issuer (`iss`)?

## Search patterns

```
# PyJWT decode không algorithms
jwt\.decode\s*\([^)]*\)(?![^)]*algorithms\s*=)
# (regex tham khảo — agent grep từng pattern)
jwt\.decode\s*\(\s*\w+\s*,\s*[^,)]+\s*\)$
jwt\.decode\s*\([^)]*algorithms\s*=\s*\[[^\]]*['"]none['"]

# verify_signature tắt
verify_signature\s*[:=]\s*False
options\s*=\s*\{[^}]*verify_signature[^}]*False[^}]*\}

# get_unverified
jwt\.get_unverified_header\s*\(
jwt\.get_unverified_claims\s*\(

# Weak secret hardcoded
jwt\.encode\s*\([^,]+,\s*['"](secret|changeme|test|jwt|password|123)['"]
JWT_SECRET\s*=\s*['"](secret|changeme|jwt|test)['"]
SECRET_KEY\s*=\s*['"](secret|changeme|django-insecure)
os\.environ\.get\s*\(\s*['"]JWT_SECRET['"]\s*,\s*['"][^'"]+['"]

# python-jose
from\s+jose\s+import\s+jwt
jose\.jwt\.decode\s*\([^)]*\)

# requirements - PyJWT cũ
PyJWT[<=]2\.
PyJWT==1\.

# Algorithm confusion
algorithms\s*=\s*\[\s*['"]HS256['"]\s*,\s*['"]RS256['"]
```

## Examples

### CRITICAL — flag

```python
# PyJWT decode không algorithms
import jwt

def get_user_from_token(token):
    payload = jwt.decode(token, JWT_SECRET)  # PyJWT <2 chấp nhận none
    return payload['user_id']
# Attacker tạo token: header={"alg":"none"}, payload={"user_id":1}, signature=""
```

```python
# Explicit cho phép none
payload = jwt.decode(token, key, algorithms=["HS256", "none"])
```

```python
# Hardcoded weak secret
JWT_SECRET = "secret"  # CRITICAL
jwt.encode({"user_id": 1}, JWT_SECRET, algorithm="HS256")
```

```python
# Fallback secret yếu
import os
JWT_SECRET = os.environ.get('JWT_SECRET', 'secret')  # nếu prod thiếu env → fallback
```

```python
# Algorithm confusion RS256/HS256
# Server expect RS256 nhưng decode cho phép cả HS256
public_key = open('public.pem').read()  # public — ai cũng lấy được
jwt.decode(token, public_key, algorithms=["HS256", "RS256"])
# Attacker: sign HS256 token với key = public_key bytes
```

```python
# Decode không verify rồi tin payload
header = jwt.get_unverified_header(token)
claims = jwt.decode(token, options={"verify_signature": False})
user_id = claims['user_id']  # tin tưởng → bypass auth
```

```python
# python-jose tương tự
from jose import jwt
payload = jwt.decode(token, SECRET, algorithms=jwt.ALGORITHMS.SUPPORTED)  # chứa 'none'
```

```python
# Django settings dùng SECRET_KEY mặc định
# settings.py
SECRET_KEY = 'django-insecure-xxxxxx'  # template default — CRITICAL nếu prod
```

### NOT critical — không flag

```python
# PyJWT đúng cách
payload = jwt.decode(
    token,
    JWT_SECRET,
    algorithms=["HS256"],  # whitelist một algorithm
)
```

```python
# Secret từ env, không fallback
import os
JWT_SECRET = os.environ['JWT_SECRET']  # raise KeyError nếu thiếu
if len(JWT_SECRET) < 32:
    raise ValueError("JWT_SECRET phải ≥32 ký tự")
```

```python
# RS256 với public key chỉ verify
public_key = open('public.pem').read()
jwt.decode(token, public_key, algorithms=["RS256"])  # chỉ RS256
```

```python
# Verify expiration + issuer
jwt.decode(
    token, JWT_SECRET,
    algorithms=["HS256"],
    options={"require": ["exp", "iat", "iss"]},
    issuer="https://auth.example.com",
)
```

## Fix recommendation

1. **Luôn truyền `algorithms`** — whitelist một thuật toán cụ thể:
   ```python
   jwt.decode(token, key, algorithms=["HS256"])  # KHÔNG để default
   ```
2. **KHÔNG cho phép `none`** — kể cả trong list. Cũng KHÔNG mix `HS256` + `RS256` cùng key.
3. **Secret mạnh** — 32+ bytes random:
   ```python
   # generate once: python -c "import secrets; print(secrets.token_urlsafe(64))"
   JWT_SECRET = os.environ['JWT_SECRET']  # required, no default
   assert len(JWT_SECRET) >= 32
   ```
4. **Verify đầy đủ claims**:
   ```python
   jwt.decode(token, key, algorithms=["HS256"],
              options={"require": ["exp", "iat", "iss", "sub"]},
              issuer=ISSUER, audience=AUDIENCE)
   ```
5. **Update PyJWT ≥2.0**: trong `requirements.txt` pin `PyJWT>=2.4.0`.
6. **Không bao giờ tin `get_unverified_*`** cho authz. Chỉ dùng để inspect debug.
7. **Asymmetric khi cross-service**: dùng RS256/EdDSA với public key. Service không cần issue token chỉ cần public key.
8. **Rotation**: hỗ trợ multi-key (`kid` trong header) để rotate secret không downtime.
9. **Django** — `SECRET_KEY` phải khác mặc định template, không bắt đầu bằng `django-insecure-`:
   ```python
   SECRET_KEY = os.environ['DJANGO_SECRET_KEY']
   ```

## Cross-references

- Generic `01-hardcoded-secret`: JWT secret hardcode = lộ → forge token
- Generic `12-broken-access-control`: JWT verify lỗi = bypass auth toàn hệ thống
- Python `15-cors-misconfig`: nếu JWT trong cookie + CORS `Allow-Credentials=true` + `Origin=*` → CSRF + token theft
- Python `17-verbose-error-debug-mode`: Django `DEBUG=True` leak `SECRET_KEY` qua error page
