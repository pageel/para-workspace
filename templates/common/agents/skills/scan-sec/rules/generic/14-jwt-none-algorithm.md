---
id: JWT-NONE-ALGORITHM
severity_max: CRITICAL
applies_to: all
---

# JWT None Algorithm / Weak Secret

## Intent

JWT (JSON Web Token) cho phép `alg: "none"` → token **không cần chữ ký**. Hacker tự tạo token `{"user_id": 1, "role": "admin"}` với alg=none, server vẫn accept → impersonate bất kỳ user nào. Hoặc secret yếu (`"secret"`, `"changeme"`, `"jwt_secret"`) — hacker brute-force bằng `hashcat -m 16500` mất vài giây.

Vibe coder hay copy code JWT mẫu, để default secret, không khai báo cụ thể algorithm khi verify → mở `alg: none` mặc định.

## Khi nào CRITICAL

- `jwt.verify(token, secret, { algorithms: [..., 'none'] })` — chấp nhận none
- `jwt.verify(token, secret)` không truyền `algorithms` (một số lib default cho phép none)
- JWT secret hardcoded yếu: `"secret"`, `"changeme"`, `"jwt"`, độ dài < 32 bytes
- Env var có default yếu: `JWT_SECRET = os.environ.get("JWT_SECRET", "secret")`
- Algorithm confusion: server config HS256 nhưng cũng accept RS256 (hoặc ngược lại) — cho phép key confusion attack

## Khi nào HIGH (giảm cấp)

- Secret đủ độ dài nhưng vẫn từ-điển (có thể brute-force)
- Dùng symmetric HS256 cross-service (nên RS256 với public/private key)
- JWT không có `exp` claim (token không expire)

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Grep** tìm import JWT library và mọi nơi `verify` / `decode` / `sign`
2. **Read** code verify:
   - Có truyền `algorithms` explicit không?
   - Algorithm có whitelist (`["HS256"]`) hay accept tùy header?
3. **Trace secret**:
   - Đến từ env var? Default value là gì?
   - Hardcoded? Length? Entropy?
4. **Check expiration**: `expiresIn`, `exp` claim có set không?
5. **Algorithm confusion**: server verify dùng cùng secret cho cả HS và RS? Đây là vuln nguy hiểm — RS public key dùng làm HS secret.

## Search patterns (gợi ý — KHÔNG chạy literal, dùng Grep tool)

### Node.js (`jsonwebtoken`)

```
jwt\.verify\s*\(
jwt\.decode\s*\(    # decode KHÔNG verify chữ ký — luôn flag
jwt\.sign\s*\(
algorithms:\s*\[[^\]]*["']none["']
algorithm:\s*["']none["']
```

### Python (`pyjwt`, `python-jose`)

```
jwt\.decode\s*\(    # check có verify=True và algorithms=[...]
jwt\.encode\s*\(
algorithms\s*=\s*\[[^\]]*["']none["']
verify\s*=\s*False
options\s*=\s*\{[^}]*verify_signature.*False
```

### Go (`golang-jwt`, `dgrijalva/jwt-go`)

```
jwt\.Parse\s*\(   # version cũ vulnerable to alg confusion
ParseWithClaims
SigningMethodNone
```

### Secret detection

```
JWT_SECRET\s*=\s*["'](secret|changeme|jwt|password|key|test|123)["']
jwt_secret\s*[:=]\s*["'][^"']{1,20}["']   # secret quá ngắn
process\.env\.JWT_SECRET\s*\|\|\s*["']    # default fallback
os\.environ\.get\s*\(\s*["']JWT_SECRET["']\s*,\s*["']
```

## Examples

### CRITICAL — flag

```javascript
// Express — accept alg=none
const jwt = require('jsonwebtoken');
const payload = jwt.verify(token, process.env.JWT_SECRET, {
  algorithms: ['HS256', 'none']  // 'none' = no signature
});
```

```javascript
// Decode KHÔNG verify
const payload = jwt.decode(token);  // không check chữ ký
if (payload.role === 'admin') { /* ... */ }
```

```python
# pyjwt — verify=False
payload = jwt.decode(token, options={"verify_signature": False})
```

```python
# Default secret yếu
JWT_SECRET = os.environ.get('JWT_SECRET', 'secret')   # fallback "secret"
jwt.encode({'user': uid}, JWT_SECRET, algorithm='HS256')
```

```go
// Algorithm confusion — không check method type
token, _ := jwt.Parse(tokenString, func(t *jwt.Token) (interface{}, error) {
    return []byte(secret), nil   // accept bất kỳ alg, RS256 attack qua đây
})
```

### NOT critical — không flag

```javascript
// Whitelist algorithm + secret dài (env)
const payload = jwt.verify(token, process.env.JWT_SECRET, {
  algorithms: ['HS256'],   // explicit
  maxAge: '1h'
});
// JWT_SECRET là random 64-byte string trong .env
```

```python
# Verify đầy đủ + check alg
payload = jwt.decode(
    token,
    settings.JWT_SECRET,   # 64-byte random
    algorithms=['HS256'],
    options={'require': ['exp', 'iat']}
)
```

```go
// Check signing method explicit
token, err := jwt.Parse(tokenString, func(t *jwt.Token) (interface{}, error) {
    if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
        return nil, fmt.Errorf("unexpected signing method: %v", t.Header["alg"])
    }
    return []byte(secret), nil
})
```

## Fix recommendation

1. **Luôn whitelist algorithm explicit:**
   ```javascript
   jwt.verify(token, secret, { algorithms: ['HS256'] });   // không 'none'
   ```
2. **Secret đủ mạnh** — sinh bằng `openssl rand -base64 64` (≥ 256 bit entropy)
3. **Lưu secret trong env / secret manager** (xem rule `01-hardcoded-secret`)
4. **Dùng asymmetric** (RS256 / ES256) nếu có nhiều service verify — private key chỉ ở auth service
5. **Set expiration ngắn** (`expiresIn: '15m'`) + dùng refresh token
6. **Verify mọi claim quan trọng** (`exp`, `iat`, `aud`, `iss`)
7. **Đừng dùng** `jwt.decode()` cho authorization — chỉ verify

## Cross-references

- Cross-check với `01-hardcoded-secret`: JWT secret leak
- Cross-check với `12-broken-access-control`: JWT yếu = auth check vô nghĩa
- Cross-check với `17-verbose-error-debug-mode`: JWT error có thể leak secret hint
