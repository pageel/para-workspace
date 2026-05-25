---
id: VERBOSE-ERROR-DEBUG-MODE
severity_max: HIGH
applies_to: all
---

# Verbose Error / Debug Mode in Production

## Intent

Bật debug mode hoặc trả stack trace ra response cho user → hacker đọc được **đường dẫn file server, tên DB, query SQL, version framework, env var, secret**. Tệ nhất là **Werkzeug / Flask debug** với `/console` → cho phép chạy Python tùy ý trong browser → **RCE full server**.

Vibe coder thường để `DEBUG=True` trong production vì "tiện debug khi user báo lỗi" — đây là RCE/leak path trải sẵn.

## Khi nào HIGH

- `DEBUG=True` trong Django settings production
- Flask `app.run(debug=True)` hoặc `FLASK_ENV=development` ở production
- Werkzeug debugger console enabled (`use_debugger=True`)
- Rails `config.consider_all_requests_local = true` trong production
- ASP.NET `<customErrors mode="Off">` trong web.config production
- Spring `server.error.include-stacktrace=always` hoặc `include-message=always`
- Next.js `productionBrowserSourceMaps: true` (lộ source map cho user)
- Stack trace returned trong API error response (`res.json({ error: err.stack })`)

## Khi nào MEDIUM (giảm cấp)

- Debug enabled chỉ qua env var nhưng default = production
- Log stack trace ra server log (không trả response) — OK nhưng phải đảm bảo log không public
- Source map deploy ra public nhưng không có secret trong source

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Grep** tìm flag debug / verbose error theo framework
2. **Read** config:
   - Có check `NODE_ENV === 'production'` hay `if not DEBUG` không?
   - Hay hardcoded `DEBUG = True`?
3. **Trace error handler**:
   - Express `app.use((err, req, res, next) => res.json({ error: err.stack }))` → lộ stack
   - Flask không có custom 500 → Werkzeug HTML trace mặc định
4. **Source map**: `next.config.js`, `webpack.config.js`, `vite.config.js`

## Search patterns (gợi ý — KHÔNG chạy literal, dùng Grep tool)

### Python

```
DEBUG\s*=\s*True
app\.run\s*\([^)]*debug\s*=\s*True
FLASK_ENV\s*=\s*["']development["']
use_debugger\s*=\s*True
DJANGO_DEBUG\s*=\s*True
```

### Node.js

```
res\.(json|send)\s*\(\s*\{[^}]*(stack|err\.stack|error\.stack)
NODE_ENV\s*!==?\s*["']production["']    # check inverse — code có hành vi khác production?
console\.error\s*\(.*\)\s*;\s*res\.   # log + return error chi tiết
```

### Java / Spring

```
server\.error\.include-stacktrace\s*=\s*always
server\.error\.include-message\s*=\s*always
logging\.level\.root\s*=\s*DEBUG
```

### Rails / Ruby

```
config\.consider_all_requests_local\s*=\s*true
config\.action_dispatch\.show_exceptions\s*=\s*false
```

### ASP.NET

```
<customErrors\s+mode="Off"
<compilation[^>]+debug="true"
```

### Next.js / source maps

```
productionBrowserSourceMaps\s*:\s*true
sourceMap\s*:\s*true   # trong production build config
devtool\s*:\s*["']source-map["']   # exposed nếu deploy
```

## Examples

### CRITICAL / HIGH — flag

```python
# Django settings.py — production
DEBUG = True
ALLOWED_HOSTS = ['*']
# User → bất kỳ lỗi nào → trang debug đầy đủ stack + env + settings
```

```python
# Flask production
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=True)   # Werkzeug console → RCE
```

```javascript
// Express — gửi stack trace cho client
app.use((err, req, res, next) => {
  res.status(500).json({
    error: err.message,
    stack: err.stack,        // lộ đường dẫn file, library version
    sql: err.sql              // lộ schema DB
  });
});
```

```yaml
# Spring application-prod.yml
server:
  error:
    include-stacktrace: always
    include-message: always
```

```javascript
// next.config.js
module.exports = {
  productionBrowserSourceMaps: true,   // user inspect source code đầy đủ
};
```

### NOT critical — không flag

```python
# Django — switch theo env
import os
DEBUG = os.environ.get('DJANGO_DEBUG', 'False') == 'True'
ALLOWED_HOSTS = ['app.example.com'] if not DEBUG else ['*']
```

```javascript
// Express — generic error response in production
app.use((err, req, res, next) => {
  logger.error(err);   // log internal
  if (process.env.NODE_ENV === 'production') {
    return res.status(500).json({ error: 'Internal server error' });
  }
  res.status(500).json({ error: err.message, stack: err.stack });
});
```

```yaml
# Spring — chỉ include khi explicit query param "?trace=true" trong dev
server:
  error:
    include-stacktrace: never
    include-message: never
```

## Fix recommendation

1. **Tắt debug trong production:**
   ```python
   # Django
   DEBUG = False
   ALLOWED_HOSTS = ['app.example.com']
   ```
2. **Custom error handler** trả message generic:
   ```javascript
   app.use((err, req, res, next) => {
     logger.error(err);
     res.status(500).json({ error: 'Something went wrong', requestId: req.id });
   });
   ```
3. **Tách env**: `.env.development` (DEBUG=true) vs `.env.production` (DEBUG=false). Deployment chỉ load `.env.production`.
4. **Tắt source map production** (hoặc upload Sentry/Datadog only, không public):
   ```javascript
   // webpack
   devtool: process.env.NODE_ENV === 'production' ? false : 'source-map'
   ```
5. **Werkzeug pin**: nếu cần debug remote, dùng `werkzeug.debug.DebuggedApplication` với PIN, KHÔNG bật ở internet-facing server.
6. **Sentry / error tracking** thay vì return stack: log full ở Sentry, return generic ở client.
7. **Audit log đường ra**: grep code base cho `err.stack`, `traceback.format_exc`, `e.printStackTrace()` xem có route nào leak không.

## Cross-references

- Cross-check với `01-hardcoded-secret`: stack trace có thể leak secret trong env
- Cross-check với `02-sql-injection` (nếu có): SQL error reveal schema → SQLi dễ hơn
- Cross-check với `14-jwt-none-algorithm`: JWT error message hint about secret
