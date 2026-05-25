# PHP Specialization

These rule files override generic rules when vbsec detects the primary language as PHP.

## How override works

When vbsec scans a repo and detects primary language `php`, for each rule id present in BOTH `rules/generic/<id>.md` AND `rules/languages/php/<id>.md`, the language-specific version REPLACES the generic. Generic rules without a language override apply as-is.

Override matching is by frontmatter `id`, not filename — but convention is to use the same numeric prefix as the generic counterpart.

## Files in this folder

| File | Rule ID | What it specializes |
|---|---|---|
| `02-sql-injection.md` | SQL-INJECTION | `mysqli_query`/PDO `query` không prepare, Laravel `DB::raw`/`whereRaw`, WordPress `$wpdb->query` vs `$wpdb->prepare`, Eloquent auto-binding |
| `08-insecure-deserialization.md` | INSECURE-DESERIALIZATION | `unserialize($_GET/$_COOKIE)` + magic method RCE, Phar deserialization qua `file_exists`, Laravel cookie với APP_KEY leak, WP `maybe_unserialize` |
| `11-csrf.md` | CSRF | Laravel `VerifyCsrfToken` + `$except`, WordPress `wp_nonce_field`/`check_ajax_referer`, plain PHP token, SameSite cookie |
| `17-verbose-error-debug-mode.md` | VERBOSE-ERROR-DEBUG-MODE | Laravel `APP_DEBUG=true` + Ignition page leak APP_KEY (CVE-2021-3129), Symfony `APP_ENV=dev` + Web Profiler, WordPress `WP_DEBUG_DISPLAY`, php.ini `display_errors` |
| `21-command-injection.md` | COMMAND-INJECTION | `system`/`exec`/`shell_exec`/`passthru`/backticks/`popen`/`proc_open`, escapeshellarg argument injection bypass, `proc_open` array args (PHP 7.4+) |

## Reasoning still applies

Language overrides do NOT skip the L1–L4 data flow analysis. Họ cung cấp pattern và example chính xác hơn cho PHP idiom, nhưng LLM agent vẫn phải:

1. **Grep** với pattern PHP-specific (superglobals, Eloquent, wpdb)
2. **Read** function chứa sink đầy đủ
3. **Trace** L1 (`$_GET`/`Request::input`) → L2 (DB meta) → L3 (env) → L4 (constant)
4. **Verify** sanitization (`prepare`, `escapeshellarg`, nonce, `allowed_classes`)

Đặc biệt PHP có nhiều "magic" (autoload, magic method, type juggling) làm pattern match thuần kém hiệu quả — cần reasoning thực sự.

## Frameworks covered

- Plain PHP (legacy mysql_*, mysqli, PDO)
- Laravel (≥ 8.x)
- Symfony (≥ 5.x)
- WordPress (core + plugin patterns)
- CodeIgniter (mention trong examples)

## PHP-specific note

PHP có **nhiều CVE classic** liên quan đến deserialize và debug mode (CVE-2021-3129 Ignition RCE, PHPMailer CVE-2016-10033, Drupalgeddon, vv) — agent nên cross-check `composer.lock` / dependency version cùng lúc với pattern scan.

## Contributing

To add a new PHP-specific override:

1. Pick a rule id from `rules/generic/`
2. Copy generic frontmatter, change `applies_to: php`
3. Replace pattern + example bằng PHP idiom
4. Keep Intent + L1–L4 reasoning approach
5. Test bằng `/vbs-scan-security` trên PHP repo có vulnerability đó
