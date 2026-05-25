---
id: VERBOSE-ERROR-DEBUG-MODE
severity_max: CRITICAL
applies_to: php
---

# Verbose Error / Debug Mode (PHP)

## Intent

PHP có lịch sử leak nặng vì:

- `display_errors = On` trong `php.ini` production → mọi notice/warning/fatal in trực tiếp ra HTML, leak file path, DB credential trong DSN, secret trong include path.
- **Laravel `APP_DEBUG=true`** trong `.env` production → Ignition error page hiện full stack trace, env var (bao gồm `APP_KEY`, `DB_PASSWORD`!), config dump, registered routes. CVE-2021-3129 Ignition còn cho RCE qua "Solution" feature.
- **Symfony `APP_ENV=dev`** trong prod → Web Profiler toolbar exposed `/_profiler`, hiện request/response/DB query/email/log của mọi request gần đây.
- WordPress `WP_DEBUG = true` → notice/warning hiện inline, leak plugin path + version → attacker biết chính xác CVE.
- `error_reporting(E_ALL)` + `ini_set('display_errors', 1)` cuối file.
- Custom `try/catch` echo `$e->getMessage()` hoặc `$e->getTraceAsString()` về client.

Đây là **CRITICAL** trong PHP (cao hơn Go) vì:
1. Laravel Ignition page leak APP_KEY → forge session cookie → ATO
2. PHP error message leak full path `/var/www/html/...` → attacker biết web root
3. Ignition RCE CVE đã có exploit public

## Khi nào CRITICAL

- Laravel `APP_DEBUG=true` trong production `.env`
- Symfony `APP_ENV=dev` trong prod
- `display_errors = On` trên prod php.ini hoặc set qua `ini_set` trong code
- Endpoint trả về `$e->getTraceAsString()` / `print_r($e)` / `var_dump($e)` về user
- WordPress `WP_DEBUG_DISPLAY = true` prod

## Khi nào HIGH

- `WP_DEBUG = true` nhưng `WP_DEBUG_DISPLAY = false` + `WP_DEBUG_LOG = true` — log vào file, không hiện response (vẫn rủi ro nếu log file public)
- `error_reporting(E_ALL)` nhưng `display_errors = Off` — log only

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Đọc `.env`** (hoặc `.env.example` + check production deploy doc): `APP_DEBUG`, `APP_ENV`, `WP_DEBUG`
2. **Grep `ini_set`** với `display_errors` / `error_reporting`
3. **Grep `getTraceAsString`, `getMessage`, `print_r`, `var_dump`, `dd(`, `dump(`** trong handler
4. **Check route `/_profiler`** (Symfony), `/telescope` (Laravel Telescope chỉ nên local), `/horizon` (chỉ admin), `/_debugbar`
5. **Verify environment detection**:
   - `app()->environment('production')` check rồi mới set debug?
   - `WP_ENVIRONMENT_TYPE` check?
6. **Cross-check `.env` commit**: nếu `.env` committed (cross-ref HARDCODED-SECRET) + APP_DEBUG=true → attacker biết debug ON

## Search patterns (PHP-specific)

```
# Laravel env
APP_DEBUG\s*=\s*true
APP_ENV\s*=\s*local|dev|development

# Symfony
APP_ENV\s*=\s*dev

# WordPress
define\s*\(\s*['"]WP_DEBUG['"]\s*,\s*true
define\s*\(\s*['"]WP_DEBUG_DISPLAY['"]\s*,\s*true

# Direct ini_set
ini_set\s*\(\s*['"]display_errors['"]\s*,\s*['"]?(1|On|on|true)
error_reporting\s*\(\s*E_ALL\s*\)

# Error leak to response
echo\s+\$e->getMessage
echo\s+\$e->getTraceAsString
print_r\s*\(\s*\$(e|exception|error)
var_dump\s*\(.*\$_(GET|POST|SESSION)
dd\s*\(                                      # Laravel dd() — fatal in dev, in response in some cases
dump\s*\(                                    # Symfony VarDumper

# Debug bar / profiler routes
\/_profiler
\/telescope
\/horizon
\/_debugbar
Laravel\\Telescope
```

## Examples

### CRITICAL — flag

```bash
# .env trong production
APP_NAME=MyApp
APP_ENV=production
APP_KEY=base64:realKey==
APP_DEBUG=true                # BAD: Ignition exposed
DB_PASSWORD=realpassword
```

```php
<?php
// Custom handler trả về trace
try {
    do_something();
} catch (\Exception $e) {
    http_response_code(500);
    echo $e->getTraceAsString();  // BAD
}
```

```php
<?php
// Symfony prod với APP_ENV=dev
// .env
APP_ENV=dev  # BAD trong prod → /_profiler exposed
```

```php
<?php
// wp-config.php production
define('WP_DEBUG', true);
define('WP_DEBUG_DISPLAY', true);  // BAD: error inline trên page
```

```php
<?php
// Code top-level
ini_set('display_errors', 1);
error_reporting(E_ALL);
// chạy trong prod → leak
```

```php
// Laravel handler echo error
public function show($id) {
    try {
        return User::findOrFail($id);
    } catch (\Throwable $e) {
        return response()->json(['error' => $e->getMessage(), 'trace' => $e->getTrace()], 500);
        // BAD: leak query, file path
    }
}
```

### NOT critical — safe

```bash
# .env production
APP_ENV=production
APP_DEBUG=false   # OK
LOG_LEVEL=warning
```

```php
<?php
// php.ini production
display_errors = Off
log_errors = On
error_log = /var/log/php/error.log
```

```php
// Laravel central handler — generic error
// app/Exceptions/Handler.php
public function render($request, Throwable $e) {
    Log::error($e);  // log internal
    if ($e instanceof ModelNotFoundException) {
        return response()->json(['error' => 'not found'], 404);
    }
    return response()->json(['error' => 'internal error'], 500);  // generic
}
```

```php
// wp-config.php production
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);       // log vào file, không hiện UI
define('WP_DEBUG_DISPLAY', false);
@ini_set('display_errors', 0);
```

## Fix recommendation

1. **Laravel**: `APP_DEBUG=false` trong production `.env`. Set qua deployment pipeline, KHÔNG commit `.env`.
2. **Symfony**: `APP_ENV=prod` trong production. Disable Web Profiler (`symfony/web-profiler-bundle` chỉ require-dev).
3. **WordPress**: `WP_DEBUG_DISPLAY=false`, log vào file ngoài web root (`/var/log/wp-debug.log`).
4. **php.ini prod**:
   ```
   display_errors = Off
   display_startup_errors = Off
   log_errors = On
   error_log = /var/log/php/error.log
   error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
   expose_php = Off
   ```
5. **Central error handler**: log internal, response generic. KHÔNG echo `$e->getMessage()`.
6. **Tắt `dd()`, `dump()`, `var_dump()`** trước commit. Lint rule (PHPStan / Larastan) catch.
7. **Block `/_profiler`, `/telescope`, `/_debugbar`** ở web server level (nginx/Apache) cho production domain.
8. **Update Laravel `facade/ignition`** lên ≥ 2.5.2 fix CVE-2021-3129.
9. **APP_KEY rotation**: nếu từng leak qua Ignition page → rotate ngay, mọi session cũ invalidate.

## Cross-references

- Rule `01-hardcoded-secret`: Ignition leak APP_KEY + DB_PASSWORD từ `.env` → secret rotation
- Rule `08-insecure-deserialization`: APP_KEY leak → forge serialized cookie (Laravel session)
- Rule `02-sql-injection`: SQLi + Ignition error = attacker thấy full query, schema instantly
- Rule `20-outdated-dependency`: Ignition < 2.5.2 CVE-2021-3129 RCE
