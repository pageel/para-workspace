---
id: SSRF
severity_max: HIGH
applies_to: python
---

# SSRF (Server-Side Request Forgery) — Python Specialization

> Override cho rule chung `rules/generic/09-ssrf.md`. Áp dụng khi `primary_language: python`.

## Intent (Python-specific)

Vibe code Python rất thường viết các tính năng "fetch URL", "webhook", "import from URL", "screenshot URL", "import RSS" — dùng `requests`, `urllib`, `httpx`, `aiohttp` để fetch URL người dùng cung cấp. Không validate → attacker fetch `http://169.254.169.254/latest/meta-data/iam/security-credentials/` (AWS metadata endpoint) chiếm token IAM, hoặc fetch `http://localhost:6379` (Redis), `http://10.0.0.1:8080` (internal service). Cùng họ: **Open Redirect** — `flask.redirect(request.args['next'])` mà không whitelist host → phishing trên domain của bạn.

## Khi nào CRITICAL/HIGH (cap HIGH)

- `requests.get/post/request(user_url)` không validate host
- `urllib.request.urlopen(user_url)` / `urllib3.request`
- `httpx.get/post/request` sync hoặc async với L1 URL
- `aiohttp.ClientSession().get(user_url)`
- `flask.redirect(request.args.get('next'))` không whitelist (Open Redirect)
- Django `HttpResponseRedirect(request.GET['next'])` không gọi `url_has_allowed_host_and_scheme()`
- FastAPI `RedirectResponse(url=request.query['next'])` không validate
- Webhook URL được fetch từ DB nhưng nguồn gốc là L1 (user nhập lúc subscribe)
- Hosting trên AWS/GCP/Azure (có metadata endpoint) — tăng impact

## Khi nào MEDIUM (giảm cấp)

- URL từ env/config (L3) — vẫn chấp nhận nếu chỉ admin set
- Có validate host bằng allowlist domain
- Có chặn IP private (RFC1918) + loopback trước khi fetch
- Endpoint chỉ admin với guard rõ ràng

## Cách reasoning

1. **Grep** sink: `requests\.(get|post|put|delete|head|patch|request)`, `urlopen`, `httpx\.`, `aiohttp\.`, `redirect\(`, `HttpResponseRedirect`, `RedirectResponse`
2. **Read** function chứa call, trace URL từ:
   - Flask: `request.args`, `request.form`, `request.json`
   - Django: `request.GET`, `request.POST`, `request.data` (DRF)
   - FastAPI: query/body parameter, `Body()`, `Query()`
3. **Trace L1→sink** — đặc biệt chú ý URL đi vòng qua DB (subscriber webhook URL, RSS feed URL được lưu DB)
4. **Verify**:
   - Có parse URL và check host whitelist?
   - Có chặn IP private/loopback bằng `ipaddress.ip_address(socket.gethostbyname(host)).is_private`?
   - Có giới hạn scheme (`http`/`https` only)?
   - Open redirect: có dùng `is_safe_url` (Django) hoặc whitelist domain (Flask)?
   - `requests` có `allow_redirects=False` không (chống follow redirect lừa)?

## Search patterns

```
# requests library
requests\.(get|post|put|delete|head|patch|request)\s*\(\s*(request\.|f["'])
requests\.Session\(\)\.\w+\s*\(\s*(request\.|f["'])

# urllib
urllib\.request\.urlopen\s*\(\s*(request\.|f["'])
urlopen\s*\(\s*(request\.|f["'])

# httpx (sync + async)
httpx\.(get|post|put|delete|head|patch|request)\s*\(\s*(request\.|f["'])
httpx\.AsyncClient\(\)\.\w+\s*\(

# aiohttp
aiohttp\.ClientSession\([^)]*\)\.\w+\s*\(\s*(request\.|f["'])
session\.get\s*\(\s*(request\.|f["'])

# Open Redirect
flask.*redirect\s*\(\s*request\.(args|form|values)
HttpResponseRedirect\s*\(\s*request\.(GET|POST)
RedirectResponse\s*\(\s*(url\s*=\s*)?(request\.|.*query)

# AWS metadata target trong code (red flag)
169\.254\.169\.254
metadata\.google\.internal

# fetch / urlretrieve
urlretrieve\s*\(\s*(request\.|f["'])
```

## Examples

### HIGH — flag

```python
# Flask + requests fetch URL user
@app.post('/fetch')
def fetch_url():
    url = request.json['url']  # L1
    r = requests.get(url, timeout=5)
    return jsonify(content=r.text[:1000])
# Exploit: url=http://169.254.169.254/latest/meta-data/iam/security-credentials/role-name
# → trả về AWS credentials trong response
```

```python
# Django webhook subscription
def trigger_webhook(request):
    hook = Webhook.objects.get(id=request.POST['hook_id'])
    requests.post(hook.url, json={'event': 'x'})  # L2: URL từ DB, gốc L1
    # User register webhook URL = http://localhost:8500/v1/agent/services/ (Consul)
```

```python
# FastAPI screenshot service
@app.post('/screenshot')
async def screenshot(url: str):  # L1
    async with httpx.AsyncClient() as client:
        r = await client.get(url)
    return {"html": r.text}
```

```python
# Open Redirect Flask
@app.route('/login')
def login():
    next_url = request.args.get('next', '/')  # L1
    if authenticated:
        return redirect(next_url)  # /login?next=https://evil.com → phishing
```

```python
# Open Redirect Django thiếu is_safe_url
def post_login(request):
    nxt = request.GET.get('next', '/')
    return HttpResponseRedirect(nxt)  # cần url_has_allowed_host_and_scheme
```

```python
# aiohttp với user URL
async def proxy(request):
    target = request.query['url']  # L1
    async with aiohttp.ClientSession() as s:
        async with s.get(target) as r:
            return web.Response(text=await r.text())
```

### NOT critical — safe

```python
# Allowlist host
from urllib.parse import urlparse
ALLOWED_HOSTS = {'api.partner.com', 'cdn.example.com'}

@app.post('/fetch')
def fetch_url():
    url = request.json['url']
    host = urlparse(url).hostname
    if host not in ALLOWED_HOSTS:
        abort(400)
    return requests.get(url, timeout=5).text
```

```python
# Chặn IP private + loopback
import ipaddress, socket
from urllib.parse import urlparse

def is_safe_url(url):
    host = urlparse(url).hostname
    try:
        ip = ipaddress.ip_address(socket.gethostbyname(host))
    except ValueError:
        return False
    return not (ip.is_private or ip.is_loopback or ip.is_link_local or ip.is_reserved)

if is_safe_url(url):
    requests.get(url)
```

```python
# Django open redirect safe
from django.utils.http import url_has_allowed_host_and_scheme

nxt = request.GET.get('next', '/')
if url_has_allowed_host_and_scheme(nxt, allowed_hosts={request.get_host()}):
    return HttpResponseRedirect(nxt)
return HttpResponseRedirect('/')
```

```python
# requests với allow_redirects=False (chống follow → bypass)
requests.get(url, timeout=5, allow_redirects=False)
```

## Fix recommendation

1. **Validate URL nhiều tầng**:
   - Parse: `urlparse(url)`, kiểm `scheme in {'http', 'https'}`
   - Resolve DNS → check IP không phải private/loopback/metadata IP
   - Block 169.254.169.254, fd00::/8, 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 127.0.0.0/8
2. **Allowlist domain** nếu domain space hẹp:
   ```python
   ALLOWED = {'webhook.partner.com', 'api.stripe.com'}
   if urlparse(url).hostname not in ALLOWED:
       raise ValueError("Host not allowed")
   ```
3. **Tắt redirect follow**: `requests.get(url, allow_redirects=False)`. Nếu phải follow → re-validate sau mỗi redirect.
4. **Open Redirect**:
   ```python
   # Django
   from django.utils.http import url_has_allowed_host_and_scheme
   if not url_has_allowed_host_and_scheme(nxt, allowed_hosts={request.get_host()}):
       nxt = '/'
   # Flask: tự whitelist hoặc dùng werkzeug.urls.url_parse
   ```
5. **Dùng lib chuyên**: `ssrf-protect`, `dns-rebinding-protector`, hoặc proxy qua egress gateway có policy.
6. **Tắt IMDSv1 trên AWS** (yêu cầu IMDSv2 với token) — defense in depth ở infra.

## Cross-references

- Generic `12-broken-access-control`: SSRF endpoint thường thiếu auth
- Generic `17-verbose-error-debug-mode`: response leak ra error có thể chứa nội dung internal
- Python `15-cors-misconfig`: SSRF + CORS misconfig = chain exploit
