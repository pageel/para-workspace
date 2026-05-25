---
id: SSRF
severity_max: HIGH
applies_to: all
---

# Server-Side Request Forgery (SSRF)

## Intent

Server gửi HTTP request đến URL do user nhập (L1). Attacker chỉ định URL kiểu `http://169.254.169.254/latest/meta-data/iam/security-credentials/` để **đọc credential AWS IAM**, hoặc `http://localhost:8080/admin`, `http://internal-db:5432`, `file:///etc/passwd`, `gopher://...` để **đánh vào dịch vụ nội bộ, đọc file local, port-scan VPC, leo lên RCE**.

Feature thường dính: webhook callback, image preview/proxy, RSS reader, OAuth callback verify, "import từ URL", screenshot service, link unfurl.

## Khi nào HIGH

- Endpoint gọi `fetch / axios / requests / curl / file_get_contents / HttpClient` với URL từ L1 mà KHÔNG validate host
- App chạy trên cloud (AWS/GCP/Azure) — có metadata service tấn công được
- App có dịch vụ nội bộ không yêu cầu auth (admin panel, Redis, Elasticsearch trên localhost)

## Khi nào MEDIUM (giảm cấp)

- Có validate scheme `http/https` nhưng không chặn IP nội bộ
- App chạy hoàn toàn isolated (no cloud metadata, không có service nội bộ)
- Response không trả về cho user (blind SSRF) — khó exploit hơn nhưng vẫn nguy hiểm (DNS rebinding, port scan timing)

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Grep** các HTTP client call (xem dưới)
2. **Read** function: URL truyền vào đến từ đâu?
3. **Trace** L1-L4:
   - URL từ `req.body.url`, `req.query.url`, `req.params.callback` → L1 → cần validate
   - URL từ DB nhưng user-controlled (vd: `user.webhook_url` set lúc đăng ký) → L1 stored
   - URL hardcoded → L3, safe
4. **Verify validation**:
   - Có check scheme (chỉ allow `https:`) không?
   - Có resolve DNS rồi check IP không nằm trong: `127.0.0.0/8`, `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`, `169.254.0.0/16`, `::1`, `fc00::/7`?
   - Có allowlist domain không?
   - Có check redirect (302 → internal) không?
5. Chú ý DNS rebinding: lúc validate trả IP public, lúc fetch DNS trả lại 127.0.0.1.

## Search patterns (gợi ý — KHÔNG chạy literal, dùng Grep tool)

### JavaScript / Node

```
fetch\s*\(\s*req\.
fetch\s*\(\s*[a-zA-Z_]+\.url
axios\.(get|post|put|delete|request)\s*\(\s*req\.
axios\.(get|post|put|delete|request)\s*\(\s*[a-zA-Z_]+\.url
http\.request\s*\(\s*\{?\s*host
got\s*\(\s*req\.
```

### Python

```
requests\.(get|post|put|delete|request)\s*\(\s*[a-zA-Z_]+\s*[,)]
urllib\.request\.urlopen\s*\(
urlopen\s*\(
httpx\.(get|post|client)
aiohttp\.ClientSession.*\.get
```

### PHP

```
file_get_contents\s*\(\s*\$
curl_setopt\s*\(.*CURLOPT_URL\s*,\s*\$
fopen\s*\(\s*\$[a-zA-Z_]+\s*,
```

### Go / Java

```
http\.Get\s*\(
http\.Post\s*\(
http\.NewRequest\s*\(
HttpClient.*\.GetAsync                       # .NET
new URL\s*\(                                 # Java
```

### Suspicious schemes / hosts

```
file://|gopher://|dict://|ftp://|ldap://    # phải block
169\.254\.169\.254                           # AWS metadata
metadata\.google\.internal                   # GCP metadata
127\.0\.0\.1|localhost|0\.0\.0\.0
```

## Examples

### HIGH — flag

```javascript
// Express — webhook fetch không validate
app.post("/api/webhook/test", async (req, res) => {
  const r = await fetch(req.body.url);   // L1 → SSRF
  res.json({ status: r.status, body: await r.text() });
});
// Attacker: { "url": "http://169.254.169.254/latest/meta-data/iam/security-credentials/admin-role" }
```

```python
# Flask — image proxy không validate host
@app.route("/proxy-image")
def proxy_image():
    url = request.args.get("url")   # L1
    r = requests.get(url)
    return r.content, 200, {"Content-Type": r.headers["Content-Type"]}
```

```php
<?php
// PDF generator — fetch URL từ user
$html = file_get_contents($_POST['url']);   // L1
echo render_pdf($html);
```

```javascript
// OAuth callback verify
app.post("/oauth/verify", async (req, res) => {
  const tokenInfo = await axios.get(req.body.introspect_url);   // attacker control URL
});
```

### NOT high — không flag (hoặc downgrade)

```javascript
// Allowlist domain
const ALLOWED = ["images.unsplash.com", "cdn.example.com"];
app.get("/proxy", async (req, res) => {
  const u = new URL(req.query.url);
  if (!ALLOWED.includes(u.hostname)) return res.status(400).end();
  if (u.protocol !== "https:") return res.status(400).end();
  const r = await fetch(u);
  res.set("Content-Type", r.headers.get("content-type"));
  r.body.pipe(res);
});
```

```python
# Validate host + IP
import ipaddress, socket
from urllib.parse import urlparse

BLOCKED_NETS = [
    ipaddress.ip_network("127.0.0.0/8"),
    ipaddress.ip_network("10.0.0.0/8"),
    ipaddress.ip_network("172.16.0.0/12"),
    ipaddress.ip_network("192.168.0.0/16"),
    ipaddress.ip_network("169.254.0.0/16"),
]

def safe_url(url: str) -> bool:
    u = urlparse(url)
    if u.scheme not in {"http", "https"}: return False
    ip = ipaddress.ip_address(socket.gethostbyname(u.hostname))
    return not any(ip in net for net in BLOCKED_NETS)
```

```javascript
// URL hardcoded — L3, OK
await fetch("https://api.stripe.com/v1/charges", { ... });
```

## Fix recommendation

1. **Allowlist domain** — phương pháp mạnh nhất nếu biết trước domain hợp lệ:
   ```javascript
   const ALLOWED_HOSTS = ["api.partner.com", "webhook.example.io"];
   const u = new URL(userUrl);
   if (!ALLOWED_HOSTS.includes(u.hostname)) throw new Error("blocked");
   ```
2. **Validate scheme**: chỉ `http:` và `https:`. Cấm `file:`, `gopher:`, `dict:`, `ldap:`, `ftp:`.
3. **Resolve DNS → check IP không phải private/loopback/link-local**:
   ```python
   import socket, ipaddress
   ip = ipaddress.ip_address(socket.gethostbyname(host))
   if ip.is_private or ip.is_loopback or ip.is_link_local or ip.is_reserved:
       raise SSRFError()
   ```
4. **Chặn redirect** hoặc validate lại URL ở mỗi redirect:
   ```javascript
   fetch(url, { redirect: "manual" });
   ```
5. **Dùng outbound proxy**: cho service chạy qua proxy chỉ allow domain bên ngoài, chặn 127.0.0.1, 169.254.169.254, RFC1918 ranges.
6. **AWS metadata**: bật IMDSv2 (yêu cầu token) — IMDSv1 SSRF trivial:
   ```bash
   aws ec2 modify-instance-metadata-options --http-tokens required ...
   ```
7. **Network policy**: dùng VPC security group / k8s NetworkPolicy chặn outbound đến internal subnet từ service web.

## Cross-references

- Rule `01-hardcoded-secret`: SSRF lấy được IAM role → exfil credentials còn nguy hiểm hơn hardcoded secret
- Rule `10-path-traversal`: cùng họ "URL/file path từ user" — file:// SSRF gần với path traversal
- Rule `17-verbose-error-debug-mode`: error response chứa nội dung fetch → SSRF exfil
