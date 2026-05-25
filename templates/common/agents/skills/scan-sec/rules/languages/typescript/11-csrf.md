---
id: CSRF
severity_max: HIGH
applies_to: typescript
---

# CSRF — TypeScript/JavaScript Specialization

> Override cho rule chung `rules/generic/11-csrf.md`. Áp dụng khi `primary_language: typescript`.

## Intent (TypeScript-specific)

Express ecosystem có lịch sử CSRF phức tạp:
- **`csurf` deprecated tháng 4/2022** — vẫn còn rất nhiều repo dùng. Không còn maintain, có CVE chưa fix.
- Nhiều vibe coder nghĩ JWT là "tự CSRF-safe" → đúng nếu JWT trong `Authorization` header, **SAI nếu JWT trong cookie**.
- Next.js App Router Server Actions tự sinh nonce → CSRF-safe by default cho action handlers, NHƯNG API routes (`/api/*`) thì không.
- NestJS không có CSRF mặc định — phải tự thêm middleware.

## Khi nào HIGH

- Express app có session/cookie auth, có state-changing route (POST/PUT/DELETE) nhưng KHÔNG có CSRF middleware
- Dùng `csurf` package (deprecated) — flag để chuyển sang giải pháp khác
- JWT lưu trong cookie KHÔNG có `SameSite=Strict|Lax` HOẶC không có CSRF token kèm
- NestJS controller có `@Post/@Put/@Delete` không có CsrfGuard hoặc middleware
- Next.js Pages API route POST không check token, dùng cookie session
- Cookie auth có `SameSite=None` mà không có CSRF token (cross-site cho phép)

## Khi nào MEDIUM/LOW

- API thuần dùng `Authorization: Bearer <jwt>` (browser không auto-send) — CSRF khó (nhưng XSS vẫn nguy hiểm hơn)
- Cookie có `SameSite=Strict` + chỉ same-origin call (giảm hầu hết CSRF cổ điển)
- Next.js App Router Server Actions (`'use server'`) — built-in CSRF protection
- GET endpoint thuần (không state-changing) — không cần CSRF

## Cách reasoning

1. **Verify auth model**:
   - Đọc middleware: `express-session`, `cookie-session`, `passport` (cookie)? → cần CSRF
   - Hay `passport-jwt` với `extractFromAuthHeader`? → không cần CSRF (vẫn cần XSS guard)
   - JWT trong cookie? (`req.cookies.token`) → cần CSRF
2. **Grep** routes/controllers: tìm `app.post`, `router.put`, `@Post`, `@Put`, `@Delete`
3. **Verify** middleware chain có CSRF token check không
4. **Check cookie config**: `cookie: { sameSite: ?, secure: ?, httpOnly: ? }`

## Search patterns

```
# Express csurf (deprecated)
require\(["']csurf["']\)
import\s+csurf\s+from
app\.use\(\s*csrf\(

# Cookie/session middleware → cần CSRF
express-session
cookie-session
cookieParser
req\.session
req\.cookies\.token       # JWT in cookie pattern

# State-changing routes without CSRF context
app\.(post|put|delete|patch)\s*\(
router\.(post|put|delete|patch)\s*\(
@(Post|Put|Delete|Patch)\(    # NestJS

# Cookie config
sameSite\s*:\s*["'](none)["']    # red flag if cookie auth
\.cookie\s*\([^,]+,\s*[^,]+,\s*\{[^}]*\}    # parse options

# Next.js
export\s+(async\s+)?function\s+(POST|PUT|DELETE|PATCH)    # App router handler
NextResponse\.json[^;]*cookies
```

## Examples

### HIGH — flag

```typescript
// Express với session cookie nhưng KHÔNG có CSRF
import session from 'express-session';

app.use(session({ secret: 'x', cookie: { sameSite: 'lax' } }));

app.post('/transfer', (req, res) => {
  // Attacker từ evil.com submit form → cookie tự gửi → tiền chuyển
  doTransfer(req.session.userId, req.body.toAccount, req.body.amount);
});
```

```typescript
// JWT trong cookie KHÔNG có CSRF token
app.post('/login', (req, res) => {
  const token = jwt.sign({ id: user.id }, SECRET);
  res.cookie('token', token, { httpOnly: true });  // sameSite default = 'lax' với modern Express
                                                    // nhưng nếu set 'none' hoặc không có CSRF token → HIGH
});

app.post('/api/delete-account', authMiddleware, (req, res) => {
  // CSRF: form POST từ evil.com vẫn gửi cookie token
});
```

```typescript
// csurf — deprecated package (flag warning)
import csurf from 'csurf';
app.use(csurf());  // package no longer maintained
```

```typescript
// NestJS thiếu CSRF guard
@Controller('users')
export class UsersController {
  @Delete(':id')  // No @UseGuards(CsrfGuard)
  async remove(@Param('id') id: string, @Session() session) {
    await this.svc.remove(id);
  }
}
```

```typescript
// Next.js Pages API route — cookie auth, không check CSRF
export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') return res.status(405).end();
  const session = await getServerSession(req, res, authOptions);  // cookie-based
  await prisma.user.delete({ where: { id: session.user.id } });
  // CSRF possible nếu không validate origin/token
}
```

### NOT critical — safe

```typescript
// Bearer JWT — không bị CSRF
app.post('/api/transfer', passport.authenticate('jwt', { session: false }), (req, res) => {
  // jwt từ Authorization header, browser không auto-send từ cross-origin
});
```

```typescript
// Next.js App Router Server Action — built-in CSRF
// app/actions.ts
'use server';
export async function deleteAccount() {
  const session = await getServerSession();
  await prisma.user.delete({ where: { id: session.user.id } });
}
// React form action={deleteAccount} → tự sinh nonce
```

```typescript
// Express với double-submit cookie pattern
import { doubleCsrf } from 'csrf-csrf';
const { doubleCsrfProtection } = doubleCsrf({ getSecret: () => SECRET });

app.use(doubleCsrfProtection);
app.post('/transfer', (req, res) => { /* token validated by middleware */ });
```

```typescript
// SameSite=Strict + cookie auth (defense layer chính)
app.use(session({
  cookie: { sameSite: 'strict', secure: true, httpOnly: true },
}));
```

## Fix recommendation

1. **Thay `csurf` bằng modern alternative**:
   - `csrf-csrf` (double-submit cookie pattern, được maintain)
   - Tự implement: sinh token random per session, render vào form, check trong middleware

2. **Cookie config tối thiểu** cho cookie auth:
   ```typescript
   app.use(session({
     secret: process.env.SESSION_SECRET!,
     cookie: {
       httpOnly: true,
       secure: true,                // HTTPS only
       sameSite: 'lax',             // hoặc 'strict' nếu không cần cross-site nav
       maxAge: 1000 * 60 * 60 * 24, // 1 day
     },
   }));
   ```

3. **Bearer JWT pattern (recommend cho API)**:
   ```typescript
   // Lưu JWT trong memory (React state) hoặc Authorization header
   fetch('/api/x', { headers: { Authorization: `Bearer ${token}` } });
   // KHÔNG lưu trong cookie (trừ khi có CSRF token đi kèm)
   ```

4. **NestJS** middleware:
   ```typescript
   import { doubleCsrf } from 'csrf-csrf';
   const { doubleCsrfProtection } = doubleCsrf({ getSecret: () => process.env.CSRF_SECRET! });
   app.use(doubleCsrfProtection);
   ```

5. **Next.js**: ưu tiên App Router Server Actions (built-in CSRF). Pages API route → check `req.headers.origin` matches `req.headers.host` + dùng SameSite cookie.

6. **Defense in depth**:
   - `Origin` / `Referer` header check trên POST
   - Custom header pattern: yêu cầu request kèm `X-Requested-With: XMLHttpRequest` (browser block cross-origin set custom header)

## Cross-references

- TS `15-cors-misconfig`: CORS `credentials: true` + origin echo = phá luôn SameSite (request từ trusted origin bị MITM/XSS)
- TS `03-xss`: XSS bypass mọi CSRF token (đọc DOM được)
- TS `14-jwt-none-algorithm`: JWT yếu trong cookie = double trouble
