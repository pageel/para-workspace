---
id: MISSING-SECURITY-HEADERS
severity_max: HIGH
applies_to: typescript, javascript, go, python, php, dotnet
---

# Missing Security Headers

## Intent

Checks whether mandatory HTTP Security Headers are configured in the Web Server or API Response. Missing these headers exposes the application to Clickjacking, MIME-sniffing, XSS injection, or SSL stripping attacks.

Reference OWASP Cheat Sheet Series: `HTTP_Headers_Cheat_Sheet.md`.

## When HIGH

- Endpoints serving HTML/UI miss `Content-Security-Policy` (CSP) or `X-Frame-Options`.
- Responses returning sensitive data miss `X-Content-Type-Options: nosniff`.
- Production HTTPS servers miss `Strict-Transport-Security` (HSTS).

## When MEDIUM / LOW

- API returning static JSON misses `Referrer-Policy`.
- Server is running in Local Development environment (localhost / HTTP).

## Search patterns (suggestions)

```
# Missing X-Content-Type-Options: nosniff
# Missing X-Frame-Options: SAMEORIGIN / DENY
# Missing Content-Security-Policy
# Response headers fail to set default security headers
```

## Examples

### BAD — Missing Headers
```typescript
return new Response(JSON.stringify(data), {
  headers: { "Content-Type": "application/json" }
});
```

### GOOD — Complete Security Headers
```typescript
return new Response(JSON.stringify(data), {
  headers: {
    "Content-Type": "application/json",
    "X-Content-Type-Options": "nosniff",
    "X-Frame-Options": "SAMEORIGIN",
    "Referrer-Policy": "same-origin"
  }
});
```

## Fix recommendation

1. Configure middleware or Edge Worker to automatically attach the 5 OWASP standard Security Headers to every Response:
   - `X-Content-Type-Options: nosniff`
   - `X-Frame-Options: SAMEORIGIN`
   - `Referrer-Policy: same-origin`
   - `Permissions-Policy: geolocation=(), camera=(), microphone=()`
   - `Strict-Transport-Security: max-age=31536000; includeSubDomains` (on Production HTTPS)
