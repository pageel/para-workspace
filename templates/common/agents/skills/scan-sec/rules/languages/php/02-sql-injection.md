---
id: SQL-INJECTION
severity_max: CRITICAL
applies_to: php
---

# SQL Injection (PHP)

## Intent

PHP là môi trường có lịch sử SQLi nặng nhất web (legacy mysql_*, mysqli, PDO không prepare). Vibe code PHP đặc biệt dễ dính vì:

- `$_GET`, `$_POST`, `$_REQUEST`, `$_COOKIE` là **superglobals L1** trực tiếp interpolate vào string SQL.
- `mysqli_query($conn, "SELECT ... $_GET[id]")` — vẫn còn rất nhiều trong code WordPress plugin và legacy.
- Laravel `DB::raw()`, `whereRaw()`, `selectRaw()` với string concat — bypass Eloquent's auto-binding.
- WordPress `$wpdb->query("SELECT ... $id")` không `prepare` — classic plugin RCE.

## Khi nào CRITICAL

- L1 ghép thẳng vào SQL string: `mysqli_query`, `PDO::query`, `$wpdb->query`, `$wpdb->get_results` không `prepare`
- Laravel `DB::raw("... {$input}")`, `whereRaw("col = '$val'")` với `$val` từ Request
- `DB::select(DB::raw($sql))` với `$sql` tự build từ user input
- Endpoint không có middleware `auth`

## Khi nào HIGH (giảm cấp)

- Đã có `mysqli_real_escape_string` / `addslashes` — escape giảm risk nhưng KHÔNG đủ (charset multi-byte bypass, không escape integer context)
- Whitelist regex chặt trước concat (vd: chỉ cho phép `[0-9]+` cho integer ID)
- Endpoint chỉ admin gọi (middleware `can:admin`)
- WordPress plugin chỉ chạy trong wp-admin với capability check

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Grep** sinks: `mysqli_query`, `mysql_query`, `->query(`, `->exec(`, `$wpdb->query`, `$wpdb->get_`, `DB::raw`, `whereRaw`, `selectRaw`, `havingRaw`, `orderByRaw`
2. **Read** function chứa call: trace biến từ `$_GET`, `$_POST`, `$_REQUEST`, `Request::input`, `$request->name`, `request()->all()`
3. **Trace L1→sink**:
   - `$_GET['id']` → biến local → SQL string → L1 direct
   - Eloquent model attribute đọc từ DB rồi dùng trong query khác → L2 (stored)
   - Constant `DB_NAME` → L4 safe
4. **Verify**:
   - PDO có `->prepare()` + `->bindParam()` / `->execute([...])` không?
   - `$wpdb->prepare("SELECT ... %d", $id)` placeholder?
   - Laravel `Model::where('col', $val)` (Eloquent tự bind) hay `whereRaw`?

## Search patterns (PHP-specific)

```
# Legacy mysql/mysqli
mysql_query\s*\(\s*["'][^"']*\$
mysqli_query\s*\([^,]+,\s*["'][^"']*\$
mysqli::query

# PDO không prepare
->query\s*\(\s*["'][^"']*\$
->exec\s*\(\s*["'][^"']*\$

# WordPress wpdb
\$wpdb->(query|get_results|get_row|get_var|get_col)\s*\(\s*["'][^"']*\$
# NEGATIVE: $wpdb->prepare(...) → safe
\$wpdb->prepare

# Laravel raw
DB::raw\s*\(\s*["'][^"']*\{?\$
DB::statement\s*\(\s*["'][^"']*\$
->whereRaw\s*\(\s*["'][^"']*\{?\$
->selectRaw\s*\(\s*["'][^"']*\{?\$
->havingRaw\s*\(
->orderByRaw\s*\(

# Superglobals trong SQL string
"[^"]*\$_(GET|POST|REQUEST|COOKIE)
```

## Examples

### CRITICAL — flag

```php
<?php
// Legacy mysqli + $_GET trực tiếp
$id = $_GET['id'];
$result = mysqli_query($conn, "SELECT * FROM users WHERE id = $id");
// ?id=1 OR 1=1 → dump all
```

```php
<?php
// PDO không prepare
$stmt = $pdo->query("SELECT * FROM products WHERE name = '" . $_POST['name'] . "'");
```

```php
<?php
// WordPress plugin
global $wpdb;
$user_id = $_GET['user_id'];
$results = $wpdb->get_results("SELECT * FROM {$wpdb->prefix}users WHERE ID = $user_id");
// BAD: không prepare
```

```php
// Laravel — whereRaw với Request input
Route::get('/search', function (Request $request) {
    $term = $request->query('q');
    return DB::table('products')
        ->whereRaw("name LIKE '%{$term}%'")  // BAD
        ->get();
});
```

```php
// Laravel — DB::select raw build
$sort = $request->input('sort');
$users = DB::select("SELECT * FROM users ORDER BY $sort");  // BAD
```

### NOT critical — safe

```php
<?php
// PDO prepared
$stmt = $pdo->prepare("SELECT * FROM users WHERE id = :id");
$stmt->execute(['id' => $_GET['id']]);
$user = $stmt->fetch();
```

```php
<?php
// WordPress $wpdb->prepare
$results = $wpdb->get_results(
    $wpdb->prepare("SELECT * FROM {$wpdb->users} WHERE ID = %d", $user_id)
);
```

```php
// Laravel Eloquent — tự bind
$users = User::where('email', $request->email)->get();  // safe
// Hoặc whereRaw có binding
$products = DB::table('products')->whereRaw('name LIKE ?', ['%'.$term.'%'])->get();
```

```php
// Whitelist enum cho ORDER BY (cột không bind được)
$allowed = ['name', 'created_at', 'price'];
$sort = $request->input('sort', 'created_at');
if (!in_array($sort, $allowed, true)) {
    abort(400);
}
$users = DB::table('users')->orderBy($sort)->get();  // safe
```

## Fix recommendation

1. **PDO prepare** mọi query có biến:
   ```php
   // BAD
   $pdo->query("SELECT * FROM u WHERE id=$id");
   // GOOD
   $stmt = $pdo->prepare("SELECT * FROM u WHERE id=:id");
   $stmt->execute(['id' => $id]);
   ```
2. **Laravel**: ưu tiên Eloquent / Query Builder. Nếu phải raw, dùng placeholder:
   ```php
   DB::select('SELECT * FROM u WHERE id = ?', [$id]);
   DB::table('u')->whereRaw('id = ?', [$id]);
   ```
3. **WordPress**: LUÔN dùng `$wpdb->prepare()` với placeholder `%d`, `%s`, `%f`.
4. **Tham số không bind được** (table name, ORDER direction): whitelist `in_array($val, $allowed, true)`.
5. **Tránh `mysqli_real_escape_string`** làm sanitization chính — dùng prepared statement.
6. **Tắt error display trên prod** (cross-ref VERBOSE-ERROR rule) — leak query giúp attacker exploit nhanh.
7. **DB user least privilege**: app user không có DROP / GRANT / FILE.

## Cross-references

- Rule `17-verbose-error-debug-mode`: `APP_DEBUG=true` Laravel hiện full SQL trên Ignition error page → leak schema
- Rule `08-insecure-deserialization`: `unserialize` + SQLi = stored exploit nguy hiểm
- Rule `07-mass-assignment`: Laravel `$fillable` thiếu = update field nhạy cảm qua mass assignment
- Rule `04-idor`: SQLi + no auth = nuke DB
