# PHP Specialization

These rule files override generic rules when scan-sec detects the primary language as PHP.

## How override works

When scan-sec scans a repo and detects primary language `php`, for each rule id present in BOTH `rules/generic/<id>.md` AND `rules/languages/php/<id>.md`, the language-specific version REPLACES the generic. Generic rules without a language override apply as-is.

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

Language overrides do NOT skip the L1–L4 data flow analysis. They provide MORE PRECISE patterns and examples for PHP idioms, but the LLM agent must still:

1. **Grep** with PHP-specific patterns (superglobals, Eloquent, wpdb)
2. **Read** the function containing the sink fully
3. **Trace** L1 (`$_GET`/`Request::input`) → L2 (DB meta) → L3 (env) → L4 (constant)
4. **Verify** sanitization (`prepare`, `escapeshellarg`, nonce, `allowed_classes`)

PHP has many magic features (autoload, magic methods, type juggling) that make naive pattern matching ineffective — true security reasoning is required.

## Frameworks covered

- Plain PHP (legacy mysql_*, mysqli, PDO)
- Laravel (≥ 8.x)
- Symfony (≥ 5.x)
- WordPress (core + plugin patterns)
- CodeIgniter (mentioned in examples)

## PHP-specific note

PHP has **many classic CVEs** related to deserialization and debug modes (e.g., CVE-2021-3129 Ignition RCE, PHPMailer CVE-2016-10033, Drupalgeddon). The agent should cross-check dependency versions in `composer.lock` alongside pattern scans.

## Contributing

To add a new PHP-specific override:

1. Pick a rule id from `rules/generic/`
2. Copy generic frontmatter, change `applies_to: php`
3. Replace patterns and examples with PHP idioms
4. Keep Intent + L1–L4 reasoning approach
5. Test by running `/scan-sec` on a PHP repo containing that vulnerability
