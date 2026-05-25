---
id: INSECURE-DESERIALIZATION
severity_max: CRITICAL
applies_to: php
---

# Insecure Deserialization (PHP)

## Intent

PHP `unserialize()` là **RCE classic** vì nó tự gọi magic method (`__wakeup`, `__destruct`, `__toString`, `__call`) khi reconstruct object. Nếu trong codebase có class với `__destruct` thao tác file/SQL, attacker craft serialized string chứa class đó → khi `unserialize` chạy → RCE.

Phổ biến:
- `unserialize($_GET['data'])`, `unserialize($_COOKIE['session'])` — classic Phar/POP chain
- **Phar deserialization**: `file_exists()`, `file_get_contents()`, `fopen()`, `is_file()` trên `phar://` URI → auto unserialize metadata. Attacker upload file `.jpg` thực chất là `.phar`, gọi `file_exists('phar://upload.jpg/test')` → trigger.
- Laravel `Cookie::queue()` mã hóa session với APP_KEY — nếu APP_KEY leak → attacker forge cookie unserialize.
- WordPress meta value chứa serialized array, function `maybe_unserialize` chạy trên DB row do attacker insert (qua SQLi hoặc XSS update profile).

## Khi nào CRITICAL

- `unserialize($_GET / $_POST / $_COOKIE / $_REQUEST)` không có `['allowed_classes' => false]`
- File operation (`file_exists`, `fopen`, `file_get_contents`, `is_file`, `getimagesize`, `imagecreatefromjpeg`) với path L1 không validate scheme → `phar://` exploit
- `unserialize` của session/cookie không HMAC-verify trước
- Codebase chứa class có dangerous `__destruct` / `__wakeup` (Monolog, Symfony Process, Laravel — historical POP chains rất nhiều)

## Khi nào HIGH (giảm cấp)

- `unserialize($data, ['allowed_classes' => false])` — chặn object construction (PHP 7.0+)
- Có HMAC verify trước unserialize (Laravel session với APP_KEY)
- Phar disable qua `ini_set('phar.readonly', 'On')` — không chặn full nhưng giảm

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Grep** sinks: `unserialize`, `maybe_unserialize` (WP), file ops với user path
2. **Read** call site:
   - Argument là L1 (`$_GET/$_POST/$_COOKIE/$_REQUEST`, Laravel `request()->...`)?
   - Argument từ DB (`->meta_value`) → L2 stored, vẫn nguy hiểm
   - Có `allowed_classes => false` option?
3. **Trace L1**:
   - Form upload filename → `getimagesize($_FILES['x']['tmp_name'])` — tmp_name safe nhưng nếu code dùng `$_FILES['x']['name']` trong path → phar
   - Cookie raw bytes → unserialize trực tiếp
4. **Inventory POP chain candidates**: composer.json có `monolog`, `laravel/framework`, `guzzlehttp/psr7` cũ → check version (CVE-known POP chain)
5. **Verify HMAC**: Laravel cookie tự sign — kiểm APP_KEY không leak qua `.env` commit (cross-ref HARDCODED-SECRET)

## Search patterns (PHP-specific)

```
# unserialize trực tiếp
unserialize\s*\(\s*\$_(GET|POST|COOKIE|REQUEST|SESSION)
unserialize\s*\(\s*\$\w+\s*\)              # check $\w+ trace nguồn
maybe_unserialize\s*\(                      # WordPress wrapper

# Không có allowed_classes
unserialize\s*\([^)]+\)                    # negative check: thiếu "allowed_classes"

# Phar deserialization sink
file_exists\s*\(\s*\$\w+
file_get_contents\s*\(\s*\$\w+
fopen\s*\(\s*\$\w+
is_file\s*\(\s*\$\w+
getimagesize\s*\(\s*\$\w+
imagecreatefrom\w+\s*\(\s*\$\w+
md5_file\s*\(\s*\$\w+
sha1_file\s*\(\s*\$\w+

# Laravel cookie / session forge
decrypt\s*\(\s*\$\w+
Crypt::decrypt
unserialize\s*\(\s*decrypt
```

## Examples

### CRITICAL — flag

```php
<?php
// Classic — RCE qua POP chain nếu app có class dangerous
$data = unserialize($_COOKIE['user']);
// attacker craft cookie chứa O:8:"DangerCls":1:{s:4:"path";s:11:"/etc/passwd";}
```

```php
<?php
// Phar deserialization
$upload_path = $_GET['file'];  // attacker: phar://upload.phar/x
if (file_exists($upload_path)) {  // BAD: trigger phar unserialize
    echo "ok";
}
```

```php
<?php
// WordPress meta đọc qua maybe_unserialize
$meta = $wpdb->get_var("SELECT meta_value FROM wp_usermeta WHERE user_id = $id");
$data = maybe_unserialize($meta);  // L2: nếu attacker insert qua SQLi → RCE
```

```php
// Laravel — không validate uploaded file mime
$path = $request->input('avatar');  // attacker control path
getimagesize($path);  // BAD: phar://avatar.phar/x trigger unserialize
```

### NOT critical — safe

```php
<?php
// allowed_classes false — chỉ deserialize scalar/array
$data = unserialize($_COOKIE['user'], ['allowed_classes' => false]);
// $data sẽ là __PHP_Incomplete_Class cho mọi object → không trigger magic method
```

```php
<?php
// JSON thay vì serialize
$data = json_decode($_COOKIE['user'], true);  // safe
```

```php
// Validate scheme + extension trước file op
$path = $request->input('file');
if (!preg_match('/^[a-zA-Z0-9._-]+$/', basename($path))) abort(400);
if (preg_match('#^phar://#i', $path)) abort(400);
$full = storage_path('uploads/' . basename($path));
file_exists($full);  // safer
```

## Fix recommendation

1. **Thay `unserialize` bằng `json_decode`** cho mọi data từ user. JSON không có magic method.
2. **Nếu phải unserialize** (legacy session), dùng `['allowed_classes' => false]` hoặc whitelist `['allowed_classes' => [SafeClass::class]]`.
3. **HMAC verify trước unserialize**:
   ```php
   if (!hash_equals($expected_hmac, hash_hmac('sha256', $data, $key))) abort(400);
   $obj = unserialize($data);
   ```
4. **Phar protection**:
   - Validate scheme: `parse_url($path, PHP_URL_SCHEME)` reject `phar`
   - `ini_set('phar.readonly', 'On')` (giảm risk)
   - Chỉ dùng `realpath()` rồi check prefix
5. **Laravel APP_KEY**: KHÔNG commit `.env`, rotate nếu leak. APP_KEY leak = forge mọi session cookie.
6. **WordPress**: validate trước khi `maybe_unserialize` từ DB nếu DB write path có thể bị tamper.
7. **Composer audit**: chạy `composer audit` thường xuyên — POP chain phụ thuộc class trong dependency.

## Cross-references

- Rule `01-hardcoded-secret`: Laravel APP_KEY leak = forge serialized cookie
- Rule `02-sql-injection`: SQLi insert serialized payload → stored deserialization
- Rule `20-outdated-dependency`: Monolog/Guzzle/Symfony cũ có POP chain documented
- Rule `17-verbose-error-debug-mode`: Ignition error page Laravel (APP_DEBUG=true) từng RCE qua deserialization CVE-2021-3129
