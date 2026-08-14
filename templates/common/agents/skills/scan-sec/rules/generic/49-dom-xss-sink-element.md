---
id: DOM-XSS-SINK-ELEMENT
severity_max: HIGH
applies_to: typescript, javascript, html, astro, jsx, tsx
---

# Hazardous DOM XSS Sinks & Unsafe DOM Manipulation

## Intent

Detects DOM-based Cross-Site Scripting (DOM XSS) vulnerabilities where untrusted DOM sources (such as `location.hash`, `location.search`, `document.referrer`, `window.name`, or `postMessage` data) are assigned directly into dangerous DOM execution sinks (`innerHTML`, `outerHTML`, `document.write`, `insertAdjacentHTML`). Attackers craft URLs containing malicious JavaScript fragments that execute automatically inside the user's browser session.

Reference OWASP Cheat Sheet Series: `DOM_based_XSS_Prevention_Cheat_Sheet.md`.

## When HIGH / CRITICAL

- Unsanitized URL query parameter or hash fragment assigned directly to `element.innerHTML` or `document.write()`.
- Untrusted `postMessage` event `event.data` passed to `eval()` or `innerHTML`.

## When MEDIUM / LOW

- Direct string concatenation in element `setAttribute("href", ...)` without `javascript:` protocol checks.

## Search patterns (suggestions)

```typescript
\.innerHTML\s*=
document\.write\(
\.insertAdjacentHTML\(
location\.hash
location\.search
```

## Examples

### BAD — Unsanitized URL Fragment Assigned to innerHTML
```javascript
// BAD: Attacker passes URL https://app.example.com/#<img src=x onerror=alert(1)>
const hash = decodeURIComponent(window.location.hash.substring(1));
document.getElementById("greeting").innerHTML = "Hello " + hash; // DOM XSS!
```

### GOOD — Safe textContent Assignment & TrustedTypes Sanitization
```javascript
// GOOD: Safe DOM assignment via textContent or DOMPurify
const hash = decodeURIComponent(window.location.hash.substring(1));

// textContent automatically encodes HTML special characters
document.getElementById("greeting").textContent = "Hello " + hash;
```

## Fix recommendation

1. Replace hazardous DOM sinks (`innerHTML`, `outerHTML`) with safe element assignment properties (`textContent` or `innerText`).
2. If HTML rendering is required, sanitize all dynamic HTML strings using `DOMPurify.sanitize()` or enforce `TrustedTypes` policies.
