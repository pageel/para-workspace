---
id: CORS-MISCONFIG
severity_max: HIGH
applies_to: typescript
---

# CORS Misconfiguration — TypeScript/JavaScript Specialization

> Override cho rule chung `rules/generic/15-cors-misconfig.md`. Áp dụng khi `primary_language: typescript`.

## Intent (TypeScript-specific)

`cors` package của Express là middleware phổ biến nhất Node. Vibe code thường viết `app.use(cors())` — không tham số. Default của `cors()` là `Access-Control-Allow-Origin: *` cho phép MỌI origin. Nguy hiểm thành CRITICAL khi:
- Kết hợp `credentials: true` (browser sẽ block `*` + credentials, nhưng `origin: true` echo origin → bypass)
- API trả về data nhạy cảm dựa trên cookie session
- App có cả cookie auth + public API

Pattern sai phổ biến nhất là `origin: true` (echo lại request Origin) kèm `credentials: true` → attacker tạo site evil.com, fetch API kèm cookie → đọc response như user.

## Khi nào HIGH (CRITICAL nếu credentials: true)

- `app.use(cors())` no-arg trên app có cookie/session auth
- `cors({ origin: true, credentials: true })` — echo origin, accept all
- `cors({ origin: '*', credentials: true })` — không hợp lệ về CORS spec nhưng có user copy paste
- Regex origin không có anchor `$`: `cors({ origin: /\.example\.com/ })` match `evil.example.com.attacker.com`
- Whitelist function dùng `.includes()` / regex không chặt:
  ```typescript
  cors({ origin: (origin, cb) => cb(null, origin?.includes('example.com')) })
  // → 'evil-example.com.attacker.com' pass
  ```
- NestJS `app.enableCors()` không tham số
- Fastify `@fastify/cors` với `origin: true`
- Next.js custom headers `Access-Control-Allow-Origin: *` trong `next.config.js` cho route có cookie

## Khi nào MEDIUM/LOW

- `origin: '*'` cho API thuần public, không cookie auth, không trả info nhạy cảm
- Whitelist array cố định: `origin: ['https://app.example.com']`
- Đã có CSP + SameSite cookie + bearer JWT auth (CORS attack giảm hiệu lực)

## Cách reasoning

1. **Grep** sink: `cors\(`, `enableCors`, `Access-Control-Allow-Origin`, `@fastify/cors`
2. **Read** option object: `origin`, `credentials`, `methods`, `allowedHeaders`
3. **Check auth model**:
   - Cookie session / `req.cookies.token` → CORS misconfig CRITICAL
   - Bearer JWT từ header → CORS misconfig vẫn HIGH (info leak) nhưng không escalate auth
4. **Verify** origin matching:
   - String array exact match → safe
   - Regex with `^...$` anchor → safe
   - Regex without anchor or `.includes()` → unsafe
   - Function `(origin, cb) => cb(null, true)` → unsafe (echoes back)

## Search patterns

```
# cors package
require\(["']cors["']\)
import\s+cors\s+from
app\.use\s*\(\s*cors\s*\(\s*\)\s*\)        # no-arg = wildcard
cors\s*\(\s*\{[^}]*origin\s*:\s*true       # echo origin
cors\s*\(\s*\{[^}]*origin\s*:\s*["']\*["'] # wildcard
cors\s*\(\s*\{[^}]*credentials\s*:\s*true

# Function origin callback (need to read body)
origin\s*:\s*\(.*\)\s*=>\s*cb\(

# Regex origin pattern (check anchor)
origin\s*:\s*/[^/]+/    # then check has $ at end

# NestJS
\.enableCors\s*\(\s*\)
\.enableCors\s*\(\s*\{[^}]*origin\s*:\s*true

# Manual headers
res\.header\s*\(\s*["']Access-Control-Allow-Origin["']\s*,\s*["']\*["']
res\.header\s*\(\s*["']Access-Control-Allow-Origin["']\s*,\s*req\.headers\.origin

# Fastify
@fastify/cors
fastify\.register\s*\([^,]*cors

# Next.js
Access-Control-Allow-Origin
```

## Examples

### HIGH/CRITICAL — flag

```typescript
// Express — wildcard cors với session
import cors from 'cors';
import session from 'express-session';

app.use(session({ secret: 'x' }));
app.use(cors());  // = origin: '*' — browser block credentials BUT...

app.get('/api/me', (req, res) => res.json(req.session.user));
```

```typescript
// origin: true (echo) + credentials → CRITICAL
app.use(cors({
  origin: true,        // echoes Origin header
  credentials: true,
}));
// evil.com fetch('/api/me', { credentials: 'include' }) → đọc data của user
```

```typescript
// Regex thiếu anchor
app.use(cors({
  origin: /\.example\.com/,   // match 'evil.example.com.attacker.com'
  credentials: true,
}));
```

```typescript
// Hàm whitelist yếu
app.use(cors({
  origin: (origin, cb) => {
    if (origin?.includes('example.com')) cb(null, true);
    else cb(new Error('Not allowed'));
  },
  credentials: true,
}));
// 'https://evil-example.com.attacker.com' includes 'example.com' → pass
```

```typescript
// NestJS
async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors();  // = wildcard
  await app.listen(3000);
}
```

```typescript
// Next.js next.config.js
module.exports = {
  async headers() {
    return [{
      source: '/api/:path*',
      headers: [
        { key: 'Access-Control-Allow-Origin', value: '*' },
        { key: 'Access-Control-Allow-Credentials', value: 'true' },  // contradictory + dangerous
      ],
    }];
  },
};
```

### NOT critical — safe

```typescript
// Allowlist cụ thể
app.use(cors({
  origin: ['https://app.example.com', 'https://www.example.com'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
}));
```

```typescript
// Regex có anchor
app.use(cors({
  origin: /^https:\/\/([a-z0-9-]+\.)?example\.com$/,
  credentials: true,
}));
```

```typescript
// Function whitelist với exact match
const allowed = new Set(['https://app.example.com', 'https://admin.example.com']);
app.use(cors({
  origin: (origin, cb) => cb(null, !origin || allowed.has(origin)),
  credentials: true,
}));
```

```typescript
// Public API thuần (không cookie), wildcard chấp nhận được
app.use(cors({ origin: '*' }));  // không credentials, response không phụ thuộc cookie
```

## Fix recommendation

1. **Allowlist array** thay vì echo:
   ```typescript
   const allowed = ['https://app.example.com'];
   app.use(cors({
     origin: (origin, cb) => {
       if (!origin) return cb(null, true);          // same-origin, mobile app
       if (allowed.includes(origin)) return cb(null, true);
       return cb(new Error('CORS blocked'));
     },
     credentials: true,
     maxAge: 600,
   }));
   ```

2. **Env-driven config**:
   ```typescript
   const allowed = (process.env.CORS_ORIGINS ?? '').split(',').filter(Boolean);
   ```

3. **Regex CHẶT**: anchor `^...$`, escape `.`:
   ```typescript
   /^https:\/\/([a-z0-9-]+\.)?example\.com$/
   ```

4. **Preflight cache + method restriction**:
   ```typescript
   cors({
     methods: ['GET', 'POST'],
     allowedHeaders: ['Authorization', 'Content-Type'],
     maxAge: 86400,
   });
   ```

5. **Tách public API và private API**: public dùng `origin: '*'` không credentials; private dùng allowlist + credentials.

6. **NestJS**:
   ```typescript
   app.enableCors({
     origin: ['https://app.example.com'],
     credentials: true,
   });
   ```

7. **Defense in depth**: cookie `SameSite=Lax|Strict` (giảm CSRF), CSRF token, `Origin`/`Referer` header check.

## Cross-references

- TS `11-csrf`: CORS misconfig phá luôn SameSite mitigation cho CSRF
- TS `03-xss`: XSS từ trusted origin + CORS rộng = data exfil
- TS `09-ssrf`: SSRF + CORS mở phía nội bộ admin = internal API leak
- Generic `12-broken-access-control`: CORS không thay thế auth check
