---
id: SSRF
severity_max: CRITICAL
applies_to: go
---

# SSRF — Server-Side Request Forgery (Go)

## Intent

Code Go nhận URL từ L1 (request body / query) rồi gọi `http.Get`, `http.Post`, `http.Client.Do`, hoặc dùng scraper Colly `c.Visit(url)` mà **không validate host**. Attacker:

- Trỏ vào `http://169.254.169.254/latest/meta-data/` để dump AWS IAM credentials
- Trỏ `http://localhost:6379` (Redis), `http://localhost:9200` (Elasticsearch) để đọc/ghi data nội bộ
- Trỏ `file://` qua `http.Client` custom transport → đọc file local
- DNS rebinding: domain attacker control trỏ đầu tiên 1.2.3.4, sau khi check pass thì trỏ 127.0.0.1

Go đặc biệt nguy hiểm vì các microservice chạy trong K8s thường có metadata endpoint, service mesh sidecar, và Colly scraper là use case rất phổ biến (build SaaS scraping).

## Khi nào CRITICAL

- L1 URL → `http.Get`/`http.Post`/`http.Client.Do` không validate host
- Colly `c.Visit(userURL)` không có `colly.AllowedDomains(...)` hoặc `colly.URLFilters(...)`
- Service chạy trong cloud (AWS/GCP/Azure) — có metadata endpoint
- Service có thể reach internal network (default deployment)

## Khi nào HIGH (giảm cấp)

- Có validate host nhưng chỉ regex hời hợt (`strings.Contains(url, "example.com")` — bypass bằng `evil.com?x=example.com`)
- Có `AllowedDomains` Colly nhưng list quá rộng
- Chạy egress firewall chặn private IP — vẫn flag nhưng impact giảm

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Grep** outbound HTTP sinks: `http.Get`, `http.Post`, `http.Head`, `http.PostForm`, `http.NewRequest`, `client.Do`, `colly.NewCollector`, `c.Visit`
2. **Read** call site: URL từ đâu?
3. **Trace L1**:
   - `c.Query("url")`, `req.URL.Query().Get("u")`, struct field từ `BindJSON` → L1
   - Webhook URL config admin set → L3 (nhưng vẫn check nếu attacker compromise admin)
4. **Verify validate**:
   - Có `url.Parse` + check `u.Scheme == "https"` + check host whitelist?
   - Có resolve DNS rồi reject private IP (`10.*`, `172.16-31.*`, `192.168.*`, `127.*`, `169.254.*`, `::1`, `fc00::/7`)?
   - Colly có `AllowedDomains` đúng cụ thể?
5. **Time-of-check vs time-of-use**: DNS rebinding — check IP rồi mới `Dial` → attacker swap. Cần custom `DialContext` validate sau resolve.

## Search patterns (Go-specific)

```
# stdlib net/http với URL từ var
http\.Get\s*\(\s*\w+
http\.Post\s*\(\s*\w+
http\.Head\s*\(\s*\w+
http\.NewRequest\s*\(\s*[^,]+,\s*\w+
\.Do\s*\(\s*req\s*\)                    # check req tạo từ user URL

# Colly
colly\.NewCollector\s*\(
\.Visit\s*\(\s*\w+
# negative search: nếu KHÔNG có AllowedDomains nearby → flag
colly\.AllowedDomains
colly\.URLFilters

# resty / req / valyala fasthttp
client\.R\(\)\.Get\s*\(\s*\w+
fasthttp\.Get\s*\(

# IPFS / gRPC dial với user input
grpc\.Dial\s*\(\s*\w+
```

## Examples

### CRITICAL — flag

```go
// gin handler — userURL = L1, no validation
func fetchPreview(c *gin.Context) {
    userURL := c.Query("url")
    resp, err := http.Get(userURL)  // BAD
    // ...
}
```

```go
// Colly scraper without AllowedDomains
func scrape(c *gin.Context) {
    target := c.Query("site")
    co := colly.NewCollector()  // no AllowedDomains → mọi URL chạy
    co.OnHTML("title", func(e *colly.HTMLElement) { ... })
    co.Visit(target)  // BAD
}
```

```go
// http.NewRequest + client.Do
func proxy(w http.ResponseWriter, r *http.Request) {
    target := r.URL.Query().Get("u")
    req, _ := http.NewRequest("GET", target, nil)
    resp, _ := http.DefaultClient.Do(req)  // BAD
    io.Copy(w, resp.Body)  // còn leak metadata response
}
```

### NOT critical — validated

```go
// Allowlist host chặt
var allowedHosts = map[string]bool{"api.partner.com": true, "cdn.partner.com": true}

func fetch(c *gin.Context) {
    raw := c.Query("url")
    u, err := url.Parse(raw)
    if err != nil || u.Scheme != "https" || !allowedHosts[u.Host] {
        c.JSON(400, gin.H{"error": "bad url"})
        return
    }
    resp, _ := http.Get(u.String())  // OK vì allowlist + https
}
```

```go
// Colly với AllowedDomains
co := colly.NewCollector(
    colly.AllowedDomains("example.com", "www.example.com"),
)
co.Visit(target)  // bị limit
```

```go
// Custom DialContext chặn private IP (chống DNS rebinding)
client := &http.Client{
    Transport: &http.Transport{
        DialContext: func(ctx context.Context, network, addr string) (net.Conn, error) {
            host, port, _ := net.SplitHostPort(addr)
            ips, _ := net.DefaultResolver.LookupIPAddr(ctx, host)
            for _, ip := range ips {
                if ip.IP.IsPrivate() || ip.IP.IsLoopback() || ip.IP.IsLinkLocalUnicast() {
                    return nil, errors.New("blocked private IP")
                }
            }
            return (&net.Dialer{}).DialContext(ctx, network, addr)
        },
    },
}
```

## Fix recommendation

1. **Allowlist host** — chặn theo whitelist tên domain cụ thể.
2. **Resolve IP và reject private range** trong custom `DialContext` (xem example).
3. **Restrict scheme** chỉ `https://` (chặn `file://`, `gopher://`, `dict://`).
4. **Colly**: bắt buộc `AllowedDomains` hoặc `URLFilters` regex.
5. **Network segmentation**: deploy egress proxy / NAT gateway chặn ra metadata endpoint (`169.254.169.254`). AWS IMDSv2 yêu cầu session token nhưng vẫn cần block.
6. **Set Timeout**: `http.Client{Timeout: 10*time.Second}` để limit blast radius.
7. **Không proxy response body** trực tiếp về user (leak info).

## Cross-references

- Rule `01-hardcoded-secret`: SSRF dump AWS metadata = leak IAM key → cross-reference incident response
- Rule `12-broken-access-control`: SSRF + IDOR = nguy hiểm gấp đôi
- Rule `17-verbose-error-debug-mode`: error body leak qua response giúp attacker recon
