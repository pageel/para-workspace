---
id: SERVERLESS-STATE-LEAKAGE
severity_max: HIGH
applies_to: typescript, javascript, python, go
---

# Serverless & Edge Isolate State Leakage

## Intent

Detects mutable global or module-scoped state variables persisting across warm V8 Isolate / Serverless function invocations. In serverless environments (Cloudflare Workers, AWS Lambda, Vercel Edge), global memory is retained across warm requests. Storing request-specific data (User Tokens, Tenant IDs, IP Addresses, User Profiles) in global variables leaks data between different users.

Reference OWASP Cheat Sheet Series: `Serverless_FaaS_Security_Cheat_Sheet.md`.

## When HIGH / CRITICAL

- Global variables store user credentials, tokens, or request payload buffers.
- Global request context is modified during request handling without resetting per request.

## When MEDIUM / LOW

- Immutable global configuration constants (e.g., `const API_LIMIT = 100`).
- Read-only DB connection pools or SDK client instances initialized outside handler.

## Search patterns (suggestions)

```javascript
let currentUser;
let currentTenantId;
let globalSession;
let requestBuffer = [];
```

## Examples

### BAD — Global State Leakage Across Warm Requests
```typescript
// BAD: Shared global state persists across warm Worker invocations
let activeUser: any = null;

export default {
  async fetch(request: Request) {
    activeUser = await parseUser(request); // Leaks to next request if uninitialized!
    return new Response(`Hello ${activeUser.name}`);
  }
};
```

### GOOD — Scoped Request Context
```typescript
// GOOD: Scope all request data inside fetch handler / ExecutionContext
export default {
  async fetch(request: Request, env: Env, ctx: ExecutionContext) {
    const activeUser = await parseUser(request);
    return new Response(`Hello ${activeUser.name}`);
  }
};
```

## Fix recommendation

1. Remove all mutable global variables storing request-specific state.
2. Pass request context explicitly via parameters or Request-scoped AsyncLocalStorage / ExecutionContext.
3. Keep global scope strictly for immutable constants and singleton SDK clients.
