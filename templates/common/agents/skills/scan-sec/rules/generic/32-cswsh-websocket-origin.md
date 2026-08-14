---
id: CSWSH-WEBSOCKET-ORIGIN
severity_max: HIGH
applies_to: typescript, javascript, python, go, php
---

# Cross-Site WebSocket Hijacking (CSWSH) & Unencrypted Transport

## Intent

Detects Cross-Site WebSocket Hijacking (CSWSH) vulnerabilities caused by failing to validate the HTTP `Origin` header during the initial WebSocket HTTP Upgrade handshake, or using unencrypted `ws://` protocols in production. Browsers automatically attach cookies and HTTP credentials during WebSocket upgrade requests. If Origin verification is missing, malicious third-party websites can hijack the WebSocket connection on behalf of authenticated users.

Reference OWASP Cheat Sheet Series: `WebSocket_Security_Cheat_Sheet.md`.

## When HIGH / CRITICAL

- WebSocket Upgrade handler omits checking `request.headers.get("Origin")`.
- WebSocket client connects via unencrypted `ws://` in production code.

## When MEDIUM / LOW

- WebSocket connection uses query parameters for secret token transmission (tokens logged in proxy access logs).

## Search patterns (suggestions)

```typescript
new WebSocket('ws://'
wss://
upgrade
webSocketHandler
```

## Examples

### BAD — Missing Origin Header Verification on WebSocket Upgrade
```typescript
// BAD: Accepts WebSocket connections from any malicious origin
export async function handleWebSocketUpgrade(request: Request) {
  const upgradeHeader = request.headers.get("Upgrade");
  if (upgradeHeader !== "websocket") return new Response("Expected WebSocket", { status: 426 });
  
  const pair = new WebSocketPair();
  // Missing Origin validation! CSWSH vulnerability!
  return new Response(null, { status: 101, webSocket: pair[0] });
}
```

### GOOD — Origin Verification & WSS Enforced
```typescript
// GOOD: Validate Origin header against exact trusted origin list
export async function handleWebSocketUpgrade(request: Request) {
  const origin = request.headers.get("Origin");
  const ALLOWED_ORIGINS = ["https://vanphong.net", "https://www.vanphong.net"];
  
  if (!origin || !ALLOWED_ORIGINS.includes(origin)) {
    return new Response("Unauthorized Origin", { status: 403 });
  }

  const pair = new WebSocketPair();
  return new Response(null, { status: 101, webSocket: pair[0] });
}
```

## Fix recommendation

1. Always enforce `wss://` (WebSocket Secure) protocol in production environments.
2. Validate the `Origin` header during the HTTP Upgrade handshake against an explicit whitelist of trusted application domains.
3. Authenticate WebSocket sessions using ticket-based tokens or short-lived auth tokens passed in subprotocol or initial handshake headers, rather than relying solely on ambient cookies.
