---
id: VERBOSE-ERROR-DEBUG-MODE
severity_max: HIGH
applies_to: go
---

# Verbose Error / Debug Mode (Go)

## Intent

Trong Go web framework, **debug mode để bật** trong production sẽ trả về stack trace, SQL query, env var, route map cho client. Attacker recon nhanh, tìm DB schema (qua GORM error), tìm internal IP / service name, leak secret nằm trong panic message.

Cụ thể:
- `gin.SetMode(gin.DebugMode)` hoặc thiếu `gin.SetMode(gin.ReleaseMode)` → in route map + debug log lúc start, panic dump full stack vào response nếu dùng `gin.Recovery()` cũ.
- `fiber.Config{Debug: true}` → tương tự, in stack trace.
- `c.String(500, err.Error())` hoặc `c.JSON(500, gin.H{"error": err.Error()})` — leak nguyên message gốc (vd: GORM trả về full SQL, file path).
- `slog.SetDefault(slog.New(slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelDebug, AddSource: true})))` chạy production → log file:line lộ ra qua log aggregator hoặc qua `/debug/pprof`.
- `net/http/pprof` import side-effect: `_ "net/http/pprof"` đăng ký `/debug/pprof/*` lên `http.DefaultServeMux`. Public exposure = giveaway full goroutine / heap / cpu profile.

## Khi nào HIGH

- `gin.DebugMode` (default nếu không set ReleaseMode) trong build production
- `fiber.Config{Debug: true}` trong prod
- Error message gốc trả về user qua HTTP response trong handler production
- `net/http/pprof` import được nhưng route không có middleware auth

## Khi nào MEDIUM (giảm cấp)

- Debug bật nhưng route bị firewall / VPN gate
- Error trả về sau khi đã `errors.New("internal error")` (đã wrap, nhưng vẫn log raw — leak qua log)
- slog level Info nhưng có `AddSource: true` — leak code path trong log (không phải response)

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Grep** debug switches: `gin.DebugMode`, `gin.SetMode`, `fiber.Config`, `echo.Debug`, `pprof`, `slog.LevelDebug`
2. **Read** entry point (`main.go`, `cmd/server/main.go`) xem mode set thế nào, có check `os.Getenv("ENV")` không
3. **Trace** error handler:
   - Có middleware central handle error?
   - Trong handler, `err.Error()` có bị return về client raw không?
   - GORM error có sanitize không?
4. **Verify**:
   - `os.Getenv("GIN_MODE")` = "release"? Hoặc code có `if os.Getenv("ENV") == "prod"` rồi set release?
   - pprof endpoint có auth?

## Search patterns (Go-specific)

```
# gin debug mode
gin\.SetMode\s*\(\s*gin\.DebugMode
gin\.SetMode\s*\(\s*"debug"
# nếu không có gin.SetMode(gin.ReleaseMode) trong main → default DebugMode → flag

# fiber
fiber\.Config\s*\{[^}]*Debug:\s*true

# echo
e\.Debug\s*=\s*true

# pprof exposed
import\s+_\s+"net/http/pprof"
"runtime/pprof"

# error leak to response
c\.JSON\s*\([^,]+,\s*[^)]*err\.Error\(\)
c\.String\s*\([^,]+,\s*err\.Error\(\)
http\.Error\s*\(w,\s*err\.Error\(\),

# slog verbose
slog\.LevelDebug
AddSource:\s*true
slog\.NewTextHandler\s*\([^,]+,\s*\&slog\.HandlerOptions\{[^}]*Level:\s*slog\.LevelDebug

# panic trả về response (không recover hoặc recover dump trace)
debug\.Stack\(\)
runtime\.Stack\(
```

## Examples

### HIGH — flag

```go
// main.go — không set release mode
func main() {
    r := gin.Default()  // default DebugMode nếu không SetMode
    r.GET("/users/:id", getUser)
    r.Run(":8080")
}
```

```go
// fiber debug bật
app := fiber.New(fiber.Config{
    Debug: true,
    AppName: "prod-api",
})
```

```go
// leak GORM error
func getUser(c *gin.Context) {
    var u User
    if err := db.First(&u, c.Param("id")).Error; err != nil {
        c.JSON(500, gin.H{"error": err.Error()})
        // err: "ERROR: column \"is_deleted\" does not exist (SQLSTATE 42703)"
        // → leak schema
    }
}
```

```go
// pprof exposed
import (
    "net/http"
    _ "net/http/pprof"  // BAD nếu serve trên public port
)
func main() {
    go http.ListenAndServe(":6060", nil)  // pprof endpoint public
}
```

```go
// slog verbose prod
logger := slog.New(slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{
    Level:     slog.LevelDebug,
    AddSource: true,
}))
slog.SetDefault(logger)
```

### NOT critical — safe

```go
// Set ReleaseMode dựa env
func main() {
    if os.Getenv("ENV") == "production" {
        gin.SetMode(gin.ReleaseMode)
    }
    r := gin.New()
    r.Use(gin.Recovery())  // recovery NHƯNG không print stack to response (mặc định không print từ gin v1.8+)
    r.Run(":8080")
}
```

```go
// Error mapping — không leak raw
func getUser(c *gin.Context) {
    var u User
    if err := db.First(&u, c.Param("id")).Error; err != nil {
        slog.Error("db error", "err", err)  // log internal
        if errors.Is(err, gorm.ErrRecordNotFound) {
            c.JSON(404, gin.H{"error": "not found"})
            return
        }
        c.JSON(500, gin.H{"error": "internal error"})
        return
    }
    c.JSON(200, u)
}
```

```go
// pprof on separate port + middleware auth
pprofMux := http.NewServeMux()
pprofMux.HandleFunc("/debug/pprof/", basicAuth(pprof.Index))
go http.ListenAndServe("127.0.0.1:6060", pprofMux)  // localhost only
```

## Fix recommendation

1. **Luôn `gin.SetMode(gin.ReleaseMode)` trong prod** — guard bằng env var.
2. **Fiber/echo**: tắt `Debug` trong build production. Dùng config từ env.
3. **Central error handler**: middleware map error → public message + log internal.
4. **Wrap error trước khi return**: `fmt.Errorf("failed: %w", err)` cho log, nhưng response chỉ trả `"internal error"`.
5. **pprof**: KHÔNG import vào `http.DefaultServeMux` public. Dùng mux riêng + bind `127.0.0.1` + auth.
6. **slog**: dùng `LevelInfo` trong prod, `AddSource: false`. Log tới stdout cho log aggregator, không log secret.
7. **Recover middleware không dump trace**: gin v1.8+ default OK. Custom recover: chỉ log stack server-side, response chỉ "panic" string generic.

## Cross-references

- Rule `01-hardcoded-secret`: secret có thể nằm trong error message (vd: DSN với password) → debug mode leak
- Rule `02-sql-injection`: SQLi + verbose error = attacker exfil DB schema nhanh
- Rule `09-ssrf`: SSRF response body return user — chính là verbose error pattern
