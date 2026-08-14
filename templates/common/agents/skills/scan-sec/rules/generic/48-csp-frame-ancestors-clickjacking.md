---
id: CSP-FRAME-ANCESTORS-CLICKJACKING
severity_max: HIGH
applies_to: typescript, javascript, html, astro
---

# Missing CSP frame-ancestors & Clickjacking Protection

## Intent

Detects missing or misconfigured Content Security Policy `frame-ancestors` directives and missing `X-Frame-Options` response headers. Without proper framing controls, attackers can embed sensitive pages (such as `/admin`, checkout, or settings pages) inside invisible `<iframe>` elements on malicious sites to trick users into executing unauthorized actions (Clickjacking / UI Redressing).

Reference OWASP Cheat Sheet Series: `HTTP_Headers_Cheat_Sheet.md` & `Clickjacking_Defense_Cheat_Sheet.md`.

## When HIGH / CRITICAL

- Administrative or state-changing page HTTP responses omit `frame-ancestors` directive in Content-Security-Policy.
- Missing `X-Frame-Options: DENY` or `SAMEORIGIN` header on legacy HTTP response handlers.

## When MEDIUM / LOW

- Static asset responses (`.png`, `.css`) missing framing headers.

## Search patterns (suggestions)

```typescript
X-Frame-Options
frame-ancestors
Content-Security-Policy
```

## Examples

### BAD — Missing Framing Protection Headers
```typescript
// BAD: Response allows framing by any malicious third-party site
export async function onRequest(context) {
  const response = await context.next();
  // Missing Content-Security-Policy or X-Frame-Options header!
  return response;
}
```

### GOOD — Enforced CSP frame-ancestors 'none' & SAMEORIGIN
```typescript
// GOOD: Protect against framing via CSP frame-ancestors and X-Frame-Options
export async function onRequest(context) {
  const response = await context.next();
  const headers = new Headers(response.headers);
  
  headers.set("Content-Security-Policy", "frame-ancestors 'none';");
  headers.set("X-Frame-Options", "DENY");
  
  return new Response(response.body, { ...response, headers });
}
```

## Fix recommendation

1. Include `frame-ancestors 'none'` (or `frame-ancestors 'self'`) in the `Content-Security-Policy` header of all HTML responses.
2. Provide `X-Frame-Options: DENY` (or `SAMEORIGIN`) as a fallback for legacy web browsers.
