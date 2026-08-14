---
id: SUBRESOURCE-INTEGRITY-SRI
severity_max: HIGH
applies_to: html, astro, jsx, tsx
---

# Missing Subresource Integrity (SRI) for External Scripts

## Intent

Detects external JavaScript or CSS assets fetched from third-party Content Delivery Networks (CDNs) that lack Subresource Integrity (`integrity="sha384-..."`) and `crossorigin="anonymous"` attributes. If the third-party CDN server or script file is compromised, attackers can inject malicious XSS payloads directly into the application for all users.

Reference OWASP Cheat Sheet Series: `Third_Party_Javascript_Management_Cheat_Sheet.md`.

## When HIGH / CRITICAL

- HTML/Astro `<script src="https://cdn...">` tag loads external JavaScript without `integrity` cryptographic hash.
- Sensitive authentication or payment pages load unpinned external CDN scripts.

## When MEDIUM / LOW

- External stylesheet `<link rel="stylesheet">` missing `integrity` attribute.

## Search patterns (suggestions)

```html
<script\s+src=["']https://(cdn|unpkg|cdnjs)
<script\s+src=["']http://
```

## Examples

### BAD — Unpinned External CDN Script Tag
```html
<!-- BAD: If cdnjs or unpkg is compromised, attacker can inject arbitrary XSS -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/lodash.js/4.17.21/lodash.min.js"></script>
```

### GOOD — Cryptographic SRI Hash Verification
```html
<!-- GOOD: Browser validates SHA-384 hash before executing external script -->
<script 
  src="https://cdnjs.cloudflare.com/ajax/libs/lodash.js/4.17.21/lodash.min.js" 
  integrity="sha512-WAVzgMvb2P2D24p4hF2v56R3BqV..." 
  crossorigin="anonymous"
></script>
```

## Fix recommendation

1. Self-host third-party JavaScript libraries whenever possible to maintain full control over client application code.
2. If CDN hosting is required, generate and enforce Subresource Integrity (SRI) cryptographic hashes (`integrity="sha384-..."` or `sha512-...`) along with `crossorigin="anonymous"`.
