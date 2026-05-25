---
id: VERBOSE-ERROR-DEBUG-MODE
severity_max: HIGH
applies_to: typescript
---

# Verbose Error / Debug Mode — TypeScript/JavaScript Specialization

> Override cho rule chung `rules/generic/17-verbose-error-debug-mode.md`. Áp dụng khi `primary_language: typescript`.

## Intent (TypeScript-specific)

Node app có nhiều "debug helper" lộ stack trace, query SQL, request body, file path trên prod:
- Express `errorhandler` package (Connect-style) — viết "DO NOT use in production" trong README nhưng vibe code copy bỏ qua
- `morgan('dev')` log request body / query verbose
- Sequelize `logging: console.log` log toàn bộ SQL
- NestJS exception filter trả `error.stack` về response
- Next.js `productionBrowserSourceMaps: true` ship source map prod → reverse engineer business logic
- React/Vue: log full error object → có thể chứa API response nhạy cảm

Khác PHP (Laravel Ignition có lịch sử RCE → CRITICAL), Node verbose error thường là HIGH: leak path/schema/query → giúp attacker plan exploit, không trực tiếp RCE.

## Khi nào HIGH

- `app.use(errorhandler())` từ package `errorhandler` không guard `NODE_ENV !== 'production'`
- `app.use(morgan('dev'))` chạy mọi env (dev format log request body keys)
- Sequelize `new Sequelize(..., { logging: console.log })` không tắt prod
- Express handler: `res.status(500).json({ error: err.stack })` hoặc `.json(err)`
- NestJS `app.useGlobalFilters(filter)` mà filter trả `exception.stack` về JSON response
- `process.env.DEBUG = '*'` hardcoded
- `productionBrowserSourceMaps: true` trong `next.config.js`
- Prisma `log: ['query', 'info', 'warn', 'error']` không guard env
- `console.error(err)` trong API handler — không leak qua HTTP nhưng leak qua server log (HIGH nếu log → SaaS / phải audit)

## Khi nào MEDIUM/LOW

- Verbose log chỉ trong `if (process.env.NODE_ENV === 'development')`
- Error response generic `{ error: 'Internal server error' }` + log stack đến server (đúng pattern)
- Sentry / Datadog SDK redact sensitive automatically

## Cách reasoning

1. **Grep** sink: `errorhandler`, `morgan\(['"]dev`, `logging\s*:\s*console`, `err\.stack`, `useGlobalFilters`
2. **Check** `next.config.js`/`next.config.ts` cho `productionBrowserSourceMaps`, `reactStrictMode`
3. **Verify env guard**: middleware có wrap trong `if (NODE_ENV !== 'production')` không?
4. **Read** exception filter / error middleware return body — có `err.stack`, `err.message`, full `err` object?

## Search patterns

```
# Express errorhandler
require\(["']errorhandler["']\)
import\s+errorhandler\s+from
app\.use\s*\(\s*errorhandler\s*\(

# morgan dev format
morgan\s*\(\s*["']dev["']
morgan\s*\(\s*["']combined["']    # combined OK, dev verbose

# Sequelize logging
new\s+Sequelize\s*\([^)]*logging\s*:\s*console
\{\s*logging\s*:\s*console\.log

# Prisma log
new\s+PrismaClient\s*\(\s*\{[^}]*log\s*:

# Express custom error leak
res\.(status|json)\s*\([^)]*err\.stack
res\.json\s*\(\s*err\s*\)
res\.json\s*\(\s*\{\s*[^}]*error\s*:\s*err\s*\}
res\.send\s*\([^)]*err\.message

# NestJS
useGlobalFilters
catch\s*\(\s*exception
exception\.stack
exception\.getResponse

# Next.js
productionBrowserSourceMaps\s*:\s*true
console\.error.*req\.

# DEBUG env
process\.env\.DEBUG\s*=
DEBUG\s*=\s*\*
```

## Examples

### HIGH — flag

```typescript
// errorhandler trên prod — full stack trace trả về browser
import errorhandler from 'errorhandler';
app.use(errorhandler());  // no guard
// 500 response sẽ là HTML với full stack, source code snippet
```

```typescript
// Sequelize logging console.log prod
const sequelize = new Sequelize(process.env.DB_URL!, {
  logging: console.log,  // mọi SQL ra stdout
});
// Stdout vào CloudWatch / Papertrail → ai access log có thể đọc SQL
```

```typescript
// Express error middleware leak stack
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  res.status(500).json({
    error: err.message,
    stack: err.stack,   // BAD
    request: req.body,  // BAD x2
  });
});
```

```typescript
// NestJS — filter trả stack
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  catch(exception: any, host: ArgumentsHost) {
    const res = host.switchToHttp().getResponse();
    res.status(500).json({
      message: exception.message,
      stack: exception.stack,  // BAD
    });
  }
}
```

```typescript
// Next.js — source map prod
// next.config.js
module.exports = {
  productionBrowserSourceMaps: true,  // attacker thấy code TS gốc
};
```

```typescript
// Prisma log tất cả query prod
const prisma = new PrismaClient({
  log: ['query', 'info', 'warn', 'error'],
});
```

### NOT critical — safe

```typescript
// errorhandler guard env
if (process.env.NODE_ENV === 'development') {
  app.use(errorhandler());
} else {
  app.use((err: Error, req, res, next) => {
    logger.error({ err, requestId: req.id }); // log server-side only
    res.status(500).json({ error: 'Internal server error' });
  });
}
```

```typescript
// Sequelize: log dev only
const sequelize = new Sequelize(DB_URL, {
  logging: process.env.NODE_ENV !== 'production' ? console.log : false,
});
```

```typescript
// NestJS filter generic
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  catch(exception: any, host: ArgumentsHost) {
    const status = exception instanceof HttpException ? exception.getStatus() : 500;
    this.logger.error(exception);  // server-side
    host.switchToHttp().getResponse().status(status).json({
      statusCode: status,
      message: status === 500 ? 'Internal server error' : exception.message,
    });
  }
}
```

```typescript
// Next.js no source maps
module.exports = {
  productionBrowserSourceMaps: false,  // default
};
```

## Fix recommendation

1. **Generic error response** prod:
   ```typescript
   app.use((err, req, res, next) => {
     const isProd = process.env.NODE_ENV === 'production';
     logger.error({ err, path: req.path, requestId: req.id });
     res.status(500).json(isProd
       ? { error: 'Internal server error', requestId: req.id }
       : { error: err.message, stack: err.stack });
   });
   ```

2. **Centralized logger** (pino, winston) → server-side log, không leak qua response.

3. **Sequelize/Prisma**: tắt query log prod hoặc redirect vào structured logger với redaction:
   ```typescript
   logging: (msg) => logger.debug({ sql: msg }),
   ```

4. **NestJS** dùng built-in `Logger` + custom filter generic message.

5. **Next.js**: `productionBrowserSourceMaps: false`. Nếu cần source map cho Sentry, upload private rồi xóa public.

6. **Remove debug packages** prod: trong `Dockerfile` build, dùng `npm prune --production`.

7. **Header**:
   ```typescript
   app.disable('x-powered-by');  // ẩn "X-Powered-By: Express"
   ```
   Hoặc dùng `helmet()`.

8. **Audit log**: redact PII / secret trước khi log (pino-redact, winston-redact).

## Cross-references

- TS `01-hardcoded-secret` (generic): secret leak qua error message
- TS `02-sql-injection`: query trả về trong error → schema leak hỗ trợ exploit nhanh hơn
- TS `09-ssrf`: error chứa internal IP/hostname → leak network topology
- Generic `12-broken-access-control`: error message khác nhau giữa "user not found" / "wrong password" = user enumeration
