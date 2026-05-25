---
id: XSS
severity_max: HIGH
applies_to: typescript
---

# XSS — TypeScript/JavaScript Specialization

> Override cho rule chung `rules/generic/03-xss.md`. Áp dụng khi `primary_language: typescript`.

## Intent (TypeScript-specific)

Frontend framework hiện đại (React, Vue, Angular) **mặc định an toàn**: text binding tự escape HTML. Nhưng mỗi framework có một escape hatch để inject raw HTML — và đó chính là chỗ vibe code đụng phải. Đặc biệt:
- React `dangerouslySetInnerHTML` — tên đã warning sẵn, vẫn dùng hằng ngày
- Vue `v-html` — ngắn, dễ dùng, dễ sai
- Angular `bypassSecurityTrustHtml/Script/Url` — bypass DomSanitizer
- jQuery legacy `.html()` — vẫn còn rất nhiều code Node dùng

Backend Node cũng dính: `res.send('<h1>' + user.name + '</h1>')`, template engine không escape (vd: EJS với `<%- %>` thay vì `<%= %>`).

## Khi nào HIGH (CRITICAL nếu input là L1)

- `dangerouslySetInnerHTML={{ __html: userInput }}` với userInput từ `req`/state/props chưa qua DOMPurify
- Vue `v-html="userInput"` với userInput từ API/route
- Angular `bypassSecurityTrustHtml(userInput)` hoặc `bypassSecurityTrustScript(userInput)` (Script là CRITICAL)
- Angular template `[innerHTML]="userContent"` không sanitize
- Express/Koa `res.send('<...>' + req.X + '<...>')` hoặc `res.write(userInput)` với Content-Type text/html
- EJS `<%- userInput %>`, Pug `!{userInput}`, Handlebars `{{{userInput}}}` (triple brace)
- jQuery `$(el).html(userInput)`, `.append(htmlString)`, `.before/after(html)`

## Khi nào MEDIUM (giảm cấp)

- HTML đã qua `DOMPurify.sanitize(input)` với config mặc định
- Content do admin tạo trong WYSIWYG, lưu DB rồi render (vẫn nên cảnh báo nhưng risk thấp hơn)
- React `dangerouslySetInnerHTML` chỉ render static HTML từ constant/markdown library trusted

## Cách reasoning

1. **Grep** sink: `dangerouslySetInnerHTML`, `v-html`, `bypassSecurityTrust`, `\[innerHTML\]`, `\.html\(`, `<%-`, `{{{`
2. **Read** component/handler: trace giá trị nhét vào sink
3. **Trace L1→sink**:
   - React: prop từ parent → từ API call → từ user input/URL → L1
   - Vue: data từ `axios.get`/store action → L1
   - Angular: subscribe Observable từ HttpClient → L1
   - Backend: `req.body.html`, `req.query.content` → L1
4. **Verify sanitization**: có `DOMPurify.sanitize()`? Có markdown library tự escape (vd: `marked` v4+ default escape)? Có CSP `script-src 'self'` (mitigation phụ)?

## Search patterns

### React
```
dangerouslySetInnerHTML\s*=\s*\{\{\s*__html
dangerouslySetInnerHTML
```

### Vue
```
v-html\s*=
:innerHTML\s*=    # ít gặp hơn
```

### Angular
```
bypassSecurityTrust(Html|Script|Style|Url|ResourceUrl)
\[innerHTML\]\s*=
DomSanitizer
```

### Backend / template
```
res\.(send|write|end)\s*\(\s*["'`][^"'`]*<[a-z]
res\.send\([^)]*\+\s*req\.
<%-\s*[^%]*%>           # EJS unescaped
\{\{\{[^}]+\}\}\}        # Handlebars triple brace
!\{[^}]+\}              # Pug unescaped
```

### Legacy jQuery
```
\$\([^)]+\)\.html\(
\.append\s*\(\s*["'`][^"'`]*<
\.(before|after|prepend)\s*\(\s*[^)]*req\.
```

### Sink-style functions
```
document\.write\s*\(
\.innerHTML\s*=
\.outerHTML\s*=
new Function\(           # eval-like
```

## Examples

### HIGH/CRITICAL — flag

```tsx
// React — dangerouslySetInnerHTML với content từ API (có thể bị compromise)
function Post({ id }: { id: string }) {
  const [html, setHtml] = useState('');
  useEffect(() => {
    fetch(`/api/post/${id}`).then(r => r.json()).then(d => setHtml(d.body));
  }, [id]);
  return <article dangerouslySetInnerHTML={{ __html: html }} />;
}
```

```vue
<!-- Vue 3 — v-html từ route param -->
<template>
  <div v-html="content"></div>
</template>
<script setup>
const route = useRoute();
const content = route.query.content;  // L1 từ URL
</script>
```

```typescript
// Angular — bypassSecurityTrustHtml
@Component({ template: `<div [innerHTML]="safeHtml"></div>` })
export class CommentComponent {
  safeHtml: SafeHtml;
  constructor(private sanitizer: DomSanitizer, private route: ActivatedRoute) {
    this.route.queryParams.subscribe(p => {
      this.safeHtml = this.sanitizer.bypassSecurityTrustHtml(p.html);  // BAD
    });
  }
}
```

```typescript
// Express — concat HTML
app.get('/welcome', (req, res) => {
  res.send(`<h1>Hello ${req.query.name}</h1>`);
  // ?name=<script>alert(document.cookie)</script>
});
```

```typescript
// EJS template — <%- %> không escape
// <h1>Welcome <%- user.name %></h1>
res.render('welcome', { user: { name: req.body.name } });
```

### NOT critical — safe

```tsx
// React — text binding tự escape
function Post({ title }: { title: string }) {
  return <h1>{title}</h1>;  // safe, even with <script> in title
}
```

```tsx
// React — dangerouslySetInnerHTML với DOMPurify
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(html) }} />
```

```vue
<!-- Vue text interpolation — safe -->
<template>
  <div>{{ content }}</div>
</template>
```

```typescript
// Express với template engine escape (EJS <%= %>)
// <h1>Hello <%= name %></h1>  ← auto-escaped
res.render('welcome', { name: req.query.name });
```

## Fix recommendation

1. **Mặc định**: dùng text binding của framework (React `{value}`, Vue `{{ value }}`, Angular `{{ value }}`). KHÔNG dùng raw HTML sink trừ khi BUỘC.
2. **Khi buộc render HTML** (markdown, WYSIWYG output): sanitize bằng DOMPurify:
   ```typescript
   import DOMPurify from 'isomorphic-dompurify'; // works SSR + client
   const clean = DOMPurify.sanitize(dirty, { ALLOWED_TAGS: ['p','b','i','em','strong','a'] });
   ```
3. **Angular**: KHÔNG dùng `bypassSecurityTrust*` với user input. Nếu cần render HTML từ trusted source, sanitize trước với DOMPurify rồi mới bypass.
4. **CSP** (defense in depth): set header `Content-Security-Policy: default-src 'self'; script-src 'self'`. Helmet middleware:
   ```typescript
   import helmet from 'helmet';
   app.use(helmet({ contentSecurityPolicy: { directives: { defaultSrc: ["'self'"] } } }));
   ```
5. **Cookies**: set `HttpOnly` để JS không đọc được session cookie ngay cả khi có XSS:
   ```typescript
   res.cookie('session', token, { httpOnly: true, secure: true, sameSite: 'lax' });
   ```
6. **Markdown**: dùng `marked` v4+ (default escape) hoặc `markdown-it` với `html: false`.

## Cross-references

- TS `15-cors-misconfig`: CORS sai + XSS = exfiltrate cookies từ origin khác
- TS `17-verbose-error-debug-mode`: error trang HTML tự built không escape stack trace
- Generic `06-brute-force`: stored XSS trong username field → render khắp app
- Generic `12-broken-access-control`: XSS + no CSRF token = chain to full takeover
