---
id: SSRF
severity_max: HIGH
applies_to: typescript
---

# SSRF — TypeScript/JavaScript Specialization

> Override cho rule chung `rules/generic/09-ssrf.md`. Áp dụng khi `primary_language: typescript`.

## Intent (TypeScript-specific)

Node app rất hay có feature "fetch URL hộ user" — image proxy, webhook, URL preview, OG metadata, screenshot service, RSS importer. Attacker đưa URL nội bộ (`http://localhost:6379`, `http://169.254.169.254/latest/meta-data/iam/`, `http://internal-db:5432`) → app server gửi request → leak data hoặc đánh sang service nội bộ.

Next.js đặc biệt nguy hiểm: `getServerSideProps`, route handler, Image Optimization API (`/_next/image?url=...`) đều chạy server-side với access internal network nhưng URL thường là L1 từ query/body.

## Khi nào HIGH (CRITICAL nếu chạm AWS metadata / internal admin port)

- `fetch(userUrl)`, `axios.get(userUrl)`, `got(userUrl)`, `node-fetch(userUrl)` với userUrl trực tiếp từ request
- Next.js `getServerSideProps`: `await fetch(context.query.url)`
- Next.js route handler: `await fetch(searchParams.get('url'))`
- Image proxy: download → save: `axios.get(req.body.imageUrl, { responseType: 'stream' })`
- Webhook delivery: `fetch(user.webhookUrl, { method: 'POST', body })` mà không check `webhookUrl` thuộc allowlist
- Open redirect (kèm): `res.redirect(req.query.next)` không validate
- HTTP module trực tiếp: `http.get(req.body.url, ...)`, `https.request({ host: userHost })`
- HeadlessChrome/Puppeteer/Playwright: `page.goto(req.body.url)` chạy trên server

## Khi nào MEDIUM (giảm cấp)

- URL host đã match allowlist cố định (`['api.partner.com', 'cdn.partner.com']`)
- Đã reject RFC1918 (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`), loopback (`127.0.0.0/8`), link-local (`169.254.0.0/16`)
- Dùng `ssrf-req-filter` / `request-filtering-agent` package
- Outbound qua proxy chỉ cho phép public IP

## Cách reasoning

1. **Grep** sink: `fetch\(`, `axios\.(get|post|put|delete|request)`, `got\(`, `node-fetch`, `http\.get`, `https\.request`, `page\.goto`
2. **Read** function: trace URL argument
3. **Trace L1→sink**:
   - Express: `req.body.url`, `req.query.url`, `req.params.url`
   - Next.js Pages API: `req.body.url`, `req.query.url`
   - Next.js App router: `searchParams.get('url')`, `await request.json()` → `.url`
   - NestJS: `@Body() body.url`, `@Query('url') url`
4. **Verify**:
   - Có `new URL(userUrl)` để parse + check `.hostname` trong allowlist?
   - Có resolve DNS rồi check IP không phải private?
   - DNS rebinding: check IP sau resolve, dùng cùng IP để fetch (`lookup` option của axios/http)

## Search patterns

```
# Fetch family
fetch\s*\(\s*req\.
fetch\s*\(\s*[a-zA-Z_$][a-zA-Z0-9_$]*[Uu]rl\s*\)
axios\.(get|post|put|delete|request|head|options)\s*\(
got\s*\(\s*[^)]*\)        # got is mostly URL-as-first-arg
node-fetch
import\s+fetch\s+from

# Next.js patterns
getServerSideProps[^}]*fetch
context\.query\.url
searchParams\.get\(

# Node http stdlib
http\.get\s*\(\s*req\.
http\.(get|request)\s*\(\s*\{[^}]*host:\s*req\.
https\.(get|request)

# Headless browser
page\.goto\s*\(\s*req\.
browser\.newPage\(\)[^.]*\.goto

# Open redirect (related)
res\.redirect\s*\(\s*req\.

# Image / file proxy
\.pipe\s*\(\s*fs\.createWriteStream  # often paired with fetch userUrl
```

## Examples

### HIGH/CRITICAL — flag

```typescript
// Express — URL preview với user URL
app.get('/preview', async (req, res) => {
  const url = req.query.url as string;  // L1
  const response = await fetch(url);
  const html = await response.text();
  res.send(extractOG(html));
  // Exploit: ?url=http://169.254.169.254/latest/meta-data/iam/security-credentials/
});
```

```typescript
// Next.js Pages API — image proxy
export default async function handler(req, res) {
  const url = req.query.url as string;
  const r = await fetch(url);
  const buf = await r.arrayBuffer();
  res.send(Buffer.from(buf));
  // Exploit: ?url=http://localhost:6379 (Redis), http://internal-admin:8080
}
```

```typescript
// Next.js App router
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const target = searchParams.get('webhook')!;  // L1
  await fetch(target, { method: 'POST', body: JSON.stringify(data) });
}
```

```typescript
// NestJS — image download
@Post('avatar/import')
async importAvatar(@Body('url') url: string) {  // L1
  const r = await axios.get(url, { responseType: 'arraybuffer' });
  await fs.writeFile(`/uploads/${nanoid()}.png`, r.data);
}
```

```typescript
// Puppeteer screenshot service
app.post('/screenshot', async (req, res) => {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  await page.goto(req.body.url);  // L1 — có thể đọc file:// hoặc internal
  const png = await page.screenshot();
  res.type('png').send(png);
});
```

### NOT critical — safe

```typescript
// Allowlist + URL parse
const ALLOWED_HOSTS = new Set(['cdn.partner.com', 'api.partner.com']);

app.get('/proxy', async (req, res) => {
  let parsed: URL;
  try { parsed = new URL(req.query.url as string); }
  catch { return res.status(400).end(); }
  if (!ALLOWED_HOSTS.has(parsed.hostname)) return res.status(403).end();
  if (parsed.protocol !== 'https:') return res.status(400).end();
  const r = await fetch(parsed.toString());
  res.send(await r.text());
});
```

```typescript
// ssrf-req-filter library
import { ssrfFilter } from 'ssrf-req-filter';
const agent = ssrfFilter();  // refuse private IPs
await fetch(url, { agent });
```

```typescript
// DNS resolve + check trước fetch
import dns from 'dns/promises';
import net from 'net';

async function safeFetch(url: string) {
  const u = new URL(url);
  const { address } = await dns.lookup(u.hostname);
  if (isPrivateIP(address)) throw new Error('Blocked private IP');
  // Force connect to resolved IP (avoid DNS rebinding)
  return fetch(url, { lookup: () => Promise.resolve({ address, family: 4 }) });
}
```

## Fix recommendation

1. **Allowlist** host nếu được:
   ```typescript
   const allowed = ['api.partner.com'];
   const { hostname } = new URL(url);
   if (!allowed.includes(hostname)) throw new Error('Forbidden host');
   ```

2. **Block private/loopback/link-local IPs** + scheme allowlist:
   ```typescript
   import { isIP } from 'net';
   const BANNED = [/^10\./, /^192\.168\./, /^172\.(1[6-9]|2\d|3[01])\./, /^127\./, /^169\.254\./, /^0\./];
   function isPrivate(ip: string) { return BANNED.some(r => r.test(ip)); }
   ```

3. **DNS rebinding protection**: resolve hostname → check IP → fetch bằng IP đó (không re-resolve). Dùng custom `lookup` của `http.Agent`.

4. **Package sẵn**:
   - `ssrf-req-filter` (drop-in agent)
   - `request-filtering-agent`
   - `axios` với custom `httpAgent: ssrfFilter()`

5. **Outbound qua egress proxy**: nếu app trong VPC, ép tất cả outbound qua HTTP proxy chỉ cho phép public IP (block 169.254.169.254, 10/8...).

6. **Open redirect**: validate `next` URL bằng `new URL(next, base).origin === base.origin` trước khi `res.redirect`.

7. **Image processing**: thay vì download URL phía server, redirect client side hoặc dùng signed-URL từ CDN trusted.

## Cross-references

- TS `15-cors-misconfig`: SSRF + CORS mở = exfiltrate data từ internal API
- TS `08-insecure-deserialization`: SSRF tới internal service rồi serialize payload
- Generic `10-path-traversal`: kèm `file://` scheme trong SSRF = đọc local file
- Generic `12-broken-access-control`: SSRF qua trusted-IP bypass auth
