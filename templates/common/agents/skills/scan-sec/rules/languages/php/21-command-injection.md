---
id: COMMAND-INJECTION
severity_max: CRITICAL
applies_to: php
---

# Command Injection (PHP)

## Intent

PHP có **6 nhóm function exec shell**:
- `system($cmd)` — chạy + echo output
- `exec($cmd, $output, $code)` — chạy, output vào array
- `shell_exec($cmd)` — chạy, return output string
- `passthru($cmd)` — chạy, binary output thẳng vào response
- Backticks `` `$cmd` `` — alias `shell_exec`
- `popen($cmd, $mode)`, `proc_open($cmd, ...)`

**Tất cả** đều spawn shell `/bin/sh -c $cmd` mặc định → string `$cmd` bị shell parse → attacker chèn `;`, `|`, `&&`, `$()`, backtick → RCE.

PHP vibe code đặc biệt dính vì:
- ImageMagick wrapper: `system("convert " . $_GET['file'] . " out.jpg")`
- FFmpeg: `shell_exec("ffmpeg -i $input output.mp4")`
- Git command: `exec("git clone $repo")`
- Ping check: `shell_exec("ping -c 1 $host")`

`escapeshellarg()` / `escapeshellcmd()` help nhưng **vẫn có bypass** (option injection: `-o ProxyCommand=...` cho ssh, `-f` for find).

## Khi nào CRITICAL

- L1 input ghép vào string truyền `system`/`exec`/`shell_exec`/`passthru`/backticks
- Không có escape hoặc whitelist
- Web server chạy với quyền `www-data` có thể đọc file app + DB credential

## Khi nào HIGH

- Có `escapeshellarg()` quanh biến NHƯNG vẫn dùng `system(...)` — chống basic injection NHƯNG nếu command nhận option (`-o`, `-f`, `--`) thì attacker vẫn chèn argument: `escapeshellarg("--upload-pack=/bin/sh")` vẫn nguy hiểm với `git clone`
- `escapeshellcmd()` toàn câu — escape metachar nhưng KHÔNG escape option, vẫn argument injection

## Khi nào MEDIUM

- Whitelist regex chặt (`^[a-zA-Z0-9._-]+$`) + escapeshellarg — chống cả command + argument injection
- Endpoint chỉ admin với re-auth

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Grep** sinks: `system\s*\(`, `exec\s*\(`, `shell_exec`, `passthru`, `popen`, `proc_open`, backtick literal
2. **Read** call site:
   - Argument có chứa biến từ L1?
   - Có `escapeshellarg` / `escapeshellcmd`?
   - Lưu ý: `escapeshellarg($x)` trả về `'$x'` (quoted) — chống command injection cơ bản, nhưng nếu $x bắt đầu bằng `-` thì shell treat như option của command tiếp theo
3. **Trace L1**: `$_GET`, `$_POST`, `$_FILES['x']['name']` (cực untrusted), Laravel `$request->input`, `Request::file()->getClientOriginalName()`
4. **Verify**:
   - Có whitelist regex?
   - Có `proc_open` với array args (PHP 7.4+ `proc_open(['cmd','arg'], ...)` không qua shell) — safer pattern
   - Có dùng dedicated PHP library thay vì exec? (vd: `Intervention/Image` thay vì `convert` CLI)

## Search patterns (PHP-specific)

```
# Direct sinks
system\s*\(
exec\s*\(
shell_exec\s*\(
passthru\s*\(
popen\s*\(
proc_open\s*\(
pcntl_exec\s*\(

# Backtick — khó grep nhưng có thể tìm
=\s*`[^`]*\$\w+

# Sprintf-style build
sprintf\s*\([^,]+,\s*\$_(GET|POST|FILES)

# Common patterns
"\s*\$_(GET|POST|REQUEST)\[[^\]]+\]\s*"     # superglobal in shell string
".*"\s*\.\s*\$_(GET|POST|REQUEST)

# Filename from upload
\$_FILES\[[^\]]+\]\['name'\]
->getClientOriginalName\s*\(

# Laravel
shell_exec\s*\(.*request\(\)
Process::run\s*\(                            # Symfony Process — safer if array args
```

## Examples

### CRITICAL — flag

```php
<?php
// ImageMagick wrapper
$file = $_GET['file'];
system("convert " . $file . " /tmp/out.jpg");
// ?file=x.jpg;cat /etc/passwd → RCE
```

```php
<?php
// Ping check
$host = $_POST['host'];
echo shell_exec("ping -c 1 " . $host);
// host=8.8.8.8;id → output append id
```

```php
<?php
// Backtick
$repo = $_GET['repo'];
$output = `git clone $repo /tmp/repo`;
// repo=x.git;rm -rf /
```

```php
// Laravel — file upload + ffmpeg
$file = $request->file('video');
$name = $file->getClientOriginalName();  // attacker control name
$path = $file->store('videos');
shell_exec("ffmpeg -i {$path} out.mp4");
// Filename: "; rm -rf /tmp; #.mp4" → RCE
```

```php
<?php
// escapeshellarg nhưng vẫn argument injection
$file = escapeshellarg($_GET['file']);
system("convert $file out.jpg");
// ?file=-version → convert nhận -version → tùy command, có thể leak
// Với git clone: ?repo=--upload-pack=/tmp/x.sh → RCE
```

### NOT critical — safer

```php
<?php
// Whitelist + escapeshellarg
$file = $_GET['file'];
if (!preg_match('/^[a-zA-Z0-9._-]+$/', $file)) {
    http_response_code(400);
    die('bad filename');
}
$safe = escapeshellarg('/uploads/' . $file);
system("convert $safe /tmp/out.jpg");
// Whitelist chặn `-` ở đầu nên không argument injection
```

```php
// proc_open với array args (PHP 7.4+) — KHÔNG qua shell
$proc = proc_open(
    ['ffmpeg', '-i', $inputPath, '-y', $outputPath],
    [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']],
    $pipes
);
// args tách rời, không bị shell parse
```

```php
// Dùng thư viện PHP thay vì exec
use Intervention\Image\ImageManagerStatic as Image;
Image::make($inputPath)->resize(800, 600)->save($outputPath);
// Không exec shell
```

```php
// Symfony Process với array — safer
use Symfony\Component\Process\Process;
$process = new Process(['git', 'clone', $repoUrl, $destDir]);
$process->run();
// Tuy nhiên vẫn cần validate $repoUrl chống option injection (`-o ProxyCommand`)
```

## Fix recommendation

1. **Tránh exec hoàn toàn**: dùng PHP library thuần (`Intervention/Image`, `getID3`, `League\Flysystem`, `ZipArchive`).
2. **Nếu phải exec**, dùng `proc_open` với **array args** (PHP 7.4+) hoặc Symfony `Process` với array — KHÔNG qua shell, không bị command injection. CHỈ còn nguy cơ argument injection (chèn option).
3. **Chống argument injection**: thêm `--` separator (`convert -- $file out.jpg`) để command không parse arg sau như option. Validate biến KHÔNG bắt đầu bằng `-`.
4. **Whitelist regex chặt**: `^[a-zA-Z0-9._-]+$` cho filename, `^[a-zA-Z0-9.]+$` cho hostname.
5. **`escapeshellarg` cho mọi argument**, KHÔNG dùng `escapeshellcmd` cho cả câu (kém hiệu quả).
6. **Drop privileges**: PHP-FPM chạy với user riêng, `disable_functions = exec,system,shell_exec,passthru,popen,proc_open` trong php.ini cho user-facing scope (nếu app không cần exec).
7. **chroot / container**: limit scope nếu exec bắt buộc.
8. **KHÔNG dùng filename gốc của upload** (`getClientOriginalName`) — generate UUID + extension whitelist.

## Cross-references

- Rule `01-hardcoded-secret`: env var leak qua subprocess inherit (PHP-FPM environment)
- Rule `12-broken-access-control`: cmd injection trên endpoint public = RCE full server
- Rule `17-verbose-error-debug-mode`: stderr/stdout của exec đưa vào response (`passthru`) leak command
- Rule `08-insecure-deserialization`: cùng họ "code execution" — PHP có nhiều con đường RCE
