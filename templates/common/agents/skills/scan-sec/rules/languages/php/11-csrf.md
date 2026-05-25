---
id: CSRF
severity_max: HIGH
applies_to: php
---

# CSRF — Cross-Site Request Forgery (PHP)

## Intent

Endpoint state-changing (POST/PUT/DELETE) trong PHP không có CSRF token / origin check → attacker host `<form action="https://target.com/transfer" method=POST>` trên site evil, victim đăng nhập sẵn target.com vào trang evil → form auto-submit (qua JS hoặc `<img>` cho GET) → request đi kèm cookie session → server thực thi.

PHP-specific:
- **Plain PHP**: KHÔNG có CSRF protection mặc định — dev phải tự implement token.
- **Laravel**: `VerifyCsrfToken` middleware auto-apply với route group `web` (trong `app/Http/Kernel.php`). Route trong `api` group dùng token bearer, KHÔNG có CSRF cookie check — nhưng API thường dùng session cookie qua Sanctum thì vẫn cần.
- **Symfony**: Form component tự generate token. Manual form thì cần `csrf_token()`.
- **WordPress**: `wp_nonce_field` / `check_admin_referer` / `wp_verify_nonce`. Plugin custom AJAX endpoint hay quên.

## Khi nào HIGH

- Endpoint state-changing dùng session cookie auth, không có CSRF token verify
- Laravel route được khai báo trong `web.php` nhưng được add vào `$except` của `VerifyCsrfToken` middleware
- WordPress AJAX (`admin-ajax.php`) handler không gọi `check_ajax_referer`
- SameSite cookie không set (hoặc `None`) — trình duyệt cũ vẫn gửi cross-site

## Khi nào MEDIUM (giảm cấp)

- SameSite=Lax/Strict trên session cookie (modern browser block CSRF cho POST cross-site)
- Endpoint chỉ accept JSON với custom header `Content-Type: application/json` (preflight CORS chặn simple form)
- Có CORS allowlist chặt + check `Origin` header

## Khi nào INFO

- API endpoint dùng `Authorization: Bearer ...` (không session cookie) — CSRF không áp dụng vì attacker không có token

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Identify auth model**: session cookie hay bearer token? Nếu bearer → CSRF N/A.
2. **List state-changing endpoints** (POST/PUT/DELETE/PATCH):
   - Plain PHP: file `.php` xử lý `$_POST`
   - Laravel: `routes/web.php`, `routes/api.php`, controller methods
   - WordPress: hook `wp_ajax_*`, `wp_ajax_nopriv_*`, plugin action
3. **For each, verify CSRF check**:
   - Laravel: middleware `web` group? Check `$except` list trong `VerifyCsrfToken`.
   - WordPress: `check_ajax_referer('action_name', 'nonce')` hoặc `wp_verify_nonce`?
   - Plain PHP: hash_equals session token với request token?
4. **Check SameSite**: `session_set_cookie_params(['samesite' => 'Lax'])` hoặc Laravel `config/session.php` `same_site`

## Search patterns (PHP-specific)

```
# Laravel — endpoint state-changing
Route::(post|put|patch|delete)\s*\(
->post\s*\(.*Controller
->put\s*\(.*Controller

# Laravel CSRF exception (RED FLAG nếu nhiều)
protected\s+\$except\s*=\s*\[
VerifyCsrfToken

# Plain PHP — form processing
\$_POST\[                                    # POST handler — check có token verify

# WordPress AJAX
add_action\s*\(\s*['"]wp_ajax_
add_action\s*\(\s*['"]wp_ajax_nopriv_
# Nonce verify
check_ajax_referer\s*\(
wp_verify_nonce\s*\(
check_admin_referer\s*\(

# SameSite cookie
session_set_cookie_params
samesite
```

## Examples

### HIGH — flag

```php
<?php
// Plain PHP — không có token check
session_start();
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $amount = $_POST['amount'];
    $to = $_POST['to'];
    transfer_money($_SESSION['user_id'], $to, $amount);  // BAD
}
```

```php
// Laravel — route trong $except
// app/Http/Middleware/VerifyCsrfToken.php
protected $except = [
    '/transfer',  // BAD: bypass CSRF cho endpoint state-changing
    'api/*',      // OK nếu API thực sự dùng bearer, nhưng cần verify
];
```

```php
<?php
// WordPress plugin AJAX không nonce
add_action('wp_ajax_delete_post', 'my_delete');
function my_delete() {
    $id = $_POST['post_id'];
    wp_delete_post($id);  // BAD: không check_ajax_referer
    wp_die();
}
```

### NOT critical — safe

```php
<?php
// Plain PHP — token CSRF
session_start();
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (!isset($_POST['csrf_token']) || !hash_equals($_SESSION['csrf_token'], $_POST['csrf_token'])) {
        http_response_code(403);
        die('CSRF');
    }
    transfer_money(...);
}
// Trong form:
// <input type="hidden" name="csrf_token" value="<?= htmlspecialchars($_SESSION['csrf_token']) ?>">
```

```php
// Laravel — middleware web auto check, form blade @csrf
// resources/views/transfer.blade.php
<form method="POST" action="/transfer">
    @csrf
    ...
</form>
// Hoặc AJAX gửi header X-CSRF-TOKEN từ meta tag
```

```php
// WordPress — nonce
add_action('wp_ajax_delete_post', 'my_delete');
function my_delete() {
    check_ajax_referer('delete_post_action', 'nonce');  // OK
    if (!current_user_can('delete_posts')) wp_die();
    wp_delete_post($_POST['post_id']);
    wp_die();
}
```

```php
// SameSite cookie
// Laravel config/session.php
'same_site' => 'lax',
'secure' => true,
'http_only' => true,
```

## Fix recommendation

1. **Laravel**: KHÔNG add route quan trọng vào `$except`. Form Blade dùng `@csrf`. AJAX gửi `X-CSRF-TOKEN` từ `<meta name="csrf-token">`.
2. **WordPress**:
   - `wp_nonce_field('action_name', 'nonce_name')` trong form
   - `check_admin_referer('action_name', 'nonce_name')` trong handler
   - AJAX: `wp_localize_script` truyền nonce → JS gửi → server `check_ajax_referer`
3. **Plain PHP**:
   - Generate token: `$_SESSION['csrf_token'] = bin2hex(random_bytes(32));`
   - Verify: `hash_equals($_SESSION['csrf_token'], $_POST['csrf_token'])` (constant-time compare)
   - Rotate sau mỗi lần dùng cho sensitive action
4. **SameSite**: set `Lax` (default modern) hoặc `Strict` cho session cookie.
5. **Origin header check**: backup defense — verify `Origin`/`Referer` header trùng app domain.
6. **Re-authenticate** cho action cực nhạy (xóa account, đổi password, chuyển tiền): require nhập lại mật khẩu.

## Cross-references

- Rule `12-broken-access-control`: CSRF + IDOR = attacker force victim xóa tài nguyên người khác
- Rule `04-idor`: cùng họ "missing check" — CSRF check authenticity of request, IDOR check authorization of resource
- Rule `17-verbose-error-debug-mode`: stack trace leak CSRF token nếu log to response
