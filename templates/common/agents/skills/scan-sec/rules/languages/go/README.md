# Go Specialization

These rule files override generic rules when scan-sec detects the primary language as Go.

## How override works

When scan-sec scans a repo and detects primary language `go`, for each rule id present in BOTH `rules/generic/<id>.md` AND `rules/languages/go/<id>.md`, the language-specific version REPLACES the generic. Generic rules without a language override apply as-is.

Override matching is by frontmatter `id`, not filename — but convention is to use the same numeric prefix as the generic counterpart for human navigation.

## Files in this folder

| File | Rule ID | What it specializes |
|---|---|---|
| `02-sql-injection.md` | SQL-INJECTION | GORM `Raw`/`Exec`/`Where` patterns, `database/sql` with `fmt.Sprintf`, sqlx, placeholder `?` vs `$1`, whitelist cho ORDER BY |
| `08-insecure-deserialization.md` | INSECURE-DESERIALIZATION | `encoding/gob`, `gopkg.in/yaml.v2` CVE history, `json.Unmarshal` vào `interface{}`, type assertion panic |
| `09-ssrf.md` | SSRF | `net/http` Get/Do với URL từ L1, Colly `Visit` không `AllowedDomains`, DNS rebinding qua custom `DialContext`, AWS metadata endpoint |
| `17-verbose-error-debug-mode.md` | VERBOSE-ERROR-DEBUG-MODE | `gin.DebugMode`, `fiber.Config{Debug: true}`, `c.JSON(500, err.Error())` leak GORM error, `net/http/pprof` exposure, `slog` verbose |
| `21-command-injection.md` | COMMAND-INJECTION | `exec.Command("sh", "-c", ...)` vs args tách rời, uploaded filename → exec, whitelist enum |

## Reasoning still applies

Language overrides do NOT skip the L1–L4 data flow analysis. They provide MORE PRECISE patterns and examples for Go idioms (GORM, gin, fiber, echo, chi, gorilla/mux, net/http stdlib), but the LLM agent must still:

1. **Grep** with Go-specific patterns
2. **Read** handlers fully
3. **Trace** L1 (request) → L2 (DB) → L3 (config) → L4 (constant)
4. **Verify** sanitization context (placeholder, whitelist, `http.MaxBytesReader`, custom `DialContext`)

Naive pattern matching is NOT enough — Go has many idioms (goroutines, channels, interfaces) that make data flow complex.

## Frameworks covered

- `net/http` (stdlib)
- Gin (`github.com/gin-gonic/gin`)
- Echo (`github.com/labstack/echo/v4`)
- Fiber (`github.com/gofiber/fiber/v2`)
- Chi (`github.com/go-chi/chi/v5`)
- Gorilla Mux (`github.com/gorilla/mux`)
- GORM (`gorm.io/gorm`)
- sqlx (`github.com/jmoiron/sqlx`)
- Colly scraper (`github.com/gocolly/colly`)

## Contributing

To add a new Go-specific override:

1. Pick a rule id from `rules/generic/`
2. Copy generic file's frontmatter, change `applies_to: go`
3. Replace search patterns + examples with Go-specific idioms
4. Keep Intent + L1–L4 reasoning approach
5. Test by running `/scan-sec` on a Go repo containing that vulnerability
