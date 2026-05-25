---
id: JWT-NONE-ALGORITHM
severity_max: CRITICAL
applies_to: typescript
---

# JWT None Algorithm — TypeScript/JavaScript Specialization

> Override cho rule chung `rules/generic/14-jwt-none-algorithm.md`. Áp dụng khi `primary_language: typescript`.

## Intent (TypeScript-specific)

`jsonwebtoken` package là chuẩn de-facto Node, nhưng:
- **Version < 9.0.0**: nếu `verify(token, secret)` không truyền `algorithms` option → chấp nhận MỌI alg trong header. Attacker đổi `alg` thành `none` → bỏ chữ ký luôn → token vẫn pass verify.
- **Algorithm confusion**: nếu server dùng RS256 (public/private key), attacker dùng public key (thường lộ) làm HMAC secret, sign HS256 token → server verify với "secret" = public key → pass.
- **OWASP Juice Shop v0.4.x** dùng `jsonwebtoken` cũ — lỗi này là quest classic.
- **Frontend "auth"**: đọc JWT từ localStorage, decode payload check `role` → chỉ là UX, không bảo mật. Real authz PHẢI ở backend.
- `jws.decode()` / `jwt.decode()` trả payload mà KHÔNG verify — flag nếu được dùng cho auth.

## Khi nào CRITICAL

- `jwt.verify(token, secret)` KHÔNG có `{ algorithms: [...] }` option (với `jsonwebtoken` bất kỳ version)
- `jsonwebtoken` version < 9.0.0 trong `package.json` — đã có nhiều CVE, kể cả vector confusion
- `jwt.decode(token)` được dùng để extract user info rồi tin (không verify)
- Hardcoded JWT secret: `jwt.sign(data, 'secret')`, `jwt.sign(data, 'mysecret123')`
- Public key dùng làm HMAC secret (RS256→HS256 confusion possible)
- `express-jwt` < 6.0.0
- Verify chỉ dựa vào frontend decode (`atob(token.split('.')[1])`) để check role

## Khi nào HIGH (giảm cấp)

- Có `algorithms: ['HS256']` rõ ràng nhưng secret là literal string (cần env var)
- JWT bí mật dài, random nhưng vẫn hardcoded trong code (cross-ref HARDCODED-SECRET)
- Decode + verify rồi nhưng không check `exp`/`iss`/`aud`

## Cách reasoning

1. **Grep**: `jwt\.verify`, `jwt\.sign`, `jwt\.decode`, `jws\.`, `express-jwt`
2. **Check** `package.json`:
   - `jsonwebtoken` version: < 9.0.0 → flag
   - `express-jwt` version: < 6.0.0 → flag
3. **Read** verify call:
   - Có `algorithms: [...]` option?
   - Secret là env var hay hardcoded string?
   - Secret là public key (đọc từ `.pem` public) hay private?
4. **Check decode usage**: `jwt.decode` chỉ dùng cho debug/extract claim (không auth). Nếu dùng để check quyền → CRITICAL.
5. **Frontend**: nếu route guard React/Vue dùng `jwtDecode(token).role === 'admin'` → flag (yêu cầu backend re-check)

## Search patterns

```
# jsonwebtoken
require\(["']jsonwebtoken["']\)
from\s+["']jsonwebtoken["']
jwt\.verify\s*\(
jwt\.sign\s*\(
jwt\.decode\s*\(            # decode KHÔNG verify

# Missing algorithms option
jwt\.verify\s*\([^)]+\)     # cần inspect tay xem có algorithms không

# Hardcoded secret
jwt\.sign\s*\([^,]+,\s*["'][^"']+["']
jwt\.verify\s*\([^,]+,\s*["'][^"']+["']

# express-jwt
require\(["']express-jwt["']\)

# jws low-level
require\(["']jws["']\)
jws\.decode

# Frontend decode for authz
jwt-decode
jwtDecode\s*\(
atob\s*\([^)]*token

# Algorithm header tampering vectors (rarely shows in code, but PEM clue)
\.readFileSync\s*\([^)]*\.pem
publicKey
```

## Examples

### CRITICAL — flag

```typescript
// jwt.verify thiếu algorithms — accept alg:none
import jwt from 'jsonwebtoken';

app.get('/me', (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  const payload = jwt.verify(token!, SECRET);  // BAD: no algorithms
  res.json(payload);
  // Exploit: forge token with header {"alg":"none","typ":"JWT"}, signature empty
});
```

```typescript
// jsonwebtoken cũ trong package.json (OWASP Juice Shop pattern)
// "jsonwebtoken": "0.4.0"
// → multiple CVEs including algorithm confusion
```

```typescript
// Algorithm confusion — public key dùng làm HMAC secret
const publicKey = fs.readFileSync('public.pem');  // PEM của RSA pub

// Server expects RS256 nhưng không enforce
jwt.verify(token, publicKey);
// Attacker: sign HS256 với publicKey content as secret → pass
```

```typescript
// jwt.decode (không verify) làm auth check
app.use((req, res, next) => {
  const token = req.cookies.token;
  const payload = jwt.decode(token);  // KHÔNG VERIFY
  req.user = payload;
  next();
});
// Attacker tự sinh token bất kỳ, không cần signature
```

```typescript
// Hardcoded weak secret
const token = jwt.sign({ id: user.id }, 'secret');  // CRITICAL
const r = jwt.verify(token, 'secret');
```

```tsx
// Frontend "guard" với decode — không phải bảo mật
import jwtDecode from 'jwt-decode';
function AdminRoute({ children }) {
  const token = localStorage.getItem('jwt');
  const { role } = jwtDecode<{ role: string }>(token!);
  return role === 'admin' ? children : <Redirect to="/" />;
  // Attacker sửa localStorage hoặc tự forge token → vẫn truy cập backend
  //   backend PHẢI verify lại
}
```

### NOT critical — safe

```typescript
// Explicit algorithms + env secret
const payload = jwt.verify(token, process.env.JWT_SECRET!, {
  algorithms: ['HS256'],
  issuer: 'myapp',
  audience: 'myapp-api',
});
```

```typescript
// RS256 với public key + explicit algorithm
const publicKey = fs.readFileSync('public.pem');
const payload = jwt.verify(token, publicKey, {
  algorithms: ['RS256'],   // chỉ chấp nhận RS256, ngăn confusion
});
```

```typescript
// jsonwebtoken v9+ (default an toàn hơn)
// package.json: "jsonwebtoken": "^9.0.2"
jwt.verify(token, secret, { algorithms: ['HS256'] });
```

## Fix recommendation

1. **Upgrade**:
   ```bash
   npm install jsonwebtoken@^9
   npm install express-jwt@^8
   ```
   v9 enforces `algorithms` option more strictly.

2. **LUÔN truyền algorithms** explicit:
   ```typescript
   jwt.verify(token, secret, { algorithms: ['HS256'] });
   // Nếu RS256:
   jwt.verify(token, publicKey, { algorithms: ['RS256'] });
   ```

3. **Secret strong + env**: ít nhất 256 bit random:
   ```typescript
   // .env
   JWT_SECRET=<output of `openssl rand -base64 64`>
   ```

4. **Validate claims**:
   ```typescript
   jwt.verify(token, secret, {
     algorithms: ['HS256'],
     issuer: 'https://myapp.com',
     audience: 'myapp-api',
     maxAge: '15m',
   });
   ```

5. **Short-lived access + refresh token pattern** thay vì 1 JWT tồn tại lâu.

6. **KHÔNG dùng `jwt.decode`** cho authorization. Dùng `jwt.verify`.

7. **Frontend route guard**: chỉ là UX. Backend mỗi request PHẢI verify token. KHÔNG để frontend decide role.

8. **Defense in depth**: revocation list (Redis blacklist) cho logout/breach scenario; rotate signing key định kỳ.

## Cross-references

- TS `11-csrf`: JWT trong cookie cần CSRF protection
- TS `01-hardcoded-secret` (generic): JWT secret hardcoded = combined risk
- Generic `12-broken-access-control`: JWT verify ổn nhưng không check role trên endpoint = vẫn vỡ
- Generic `06-brute-force`: weak JWT secret có thể brute-force offline với `hashcat -m 16500`
