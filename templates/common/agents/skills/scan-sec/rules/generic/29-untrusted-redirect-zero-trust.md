---
id: UNTRUSTED-REDIRECT-ZERO-TRUST
severity_max: HIGH
applies_to: typescript, javascript, python, go, php
---

# Unvalidated Open Redirects & Zero Trust Violation

## Intent

Detects unvalidated redirect URLs (e.g. `res.redirect(req.query.next)`) where untrusted user input controls the target destination URL. Attackers use open redirects in phishing attacks or to leak OAuth Authorization Codes / JWT Tokens via `Referer` headers to malicious third-party origins.

Reference OWASP Cheat Sheet Series: `Zero_Trust_Architecture_Cheat_Sheet.md` & `Unvalidated_Redirects_and_Forwards_Cheat_Sheet.md`.

## When HIGH

- User input directly controls redirect location without domain whitelisting.
- Authentication callback endpoints redirect to arbitrary external origins.

## When MEDIUM / LOW

- Redirect targets relative paths starting strictly with `/` (excluding `//` scheme-relative URLs).

## Search patterns (suggestions)

```typescript
res.redirect(
Response.redirect(
window.location.href = 
```

## Examples

### BAD — Unvalidated Redirect Target
```typescript
// BAD: Attacker passes next=https://evil.com/phish to steal user credentials
export function handleLoginSuccess(req: Request) {
  const url = new URL(req.url);
  const next = url.searchParams.get("next") || "/dashboard";
  return Response.redirect(next, 302); // Open Redirect vulnerability!
}
```

### GOOD — Relative Path Verification & Domain Whitelisting
```typescript
// GOOD: Enforce relative paths or whitelist exact trusted origins
export function handleLoginSuccess(req: Request) {
  const url = new URL(req.url);
  const next = url.searchParams.get("next") || "/dashboard";
  
  // Ensure next parameter is a strictly relative path starting with single '/'
  if (!next.startsWith("/") || next.startsWith("//") || next.includes("\\")) {
    return Response.redirect("/dashboard", 302);
  }
  
  return Response.redirect(new URL(next, url.origin).toString(), 302);
}
```

## Fix recommendation

1. Avoid taking target redirect destinations from user request parameters.
2. If dynamic redirect is required, enforce strict relative paths (check `startsWith("/")` and reject `//`) or whitelist exact allowed destination domains.
