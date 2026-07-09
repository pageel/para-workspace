---
tags: [edge, serverless, sql, kv-cache, global-distribution]
stack: [cloudflare-workers, d1, kv, hono]
scale: [small, medium]
complexity: intermediate
---

# Reference Architecture: Serverless Edge (Workers + D1 + KV)

## 1. Topology
*   **Infra**: Hosted on Cloudflare Global Network. Zero cold starts with Workers.
*   **Data Flow**: Client ➔ Cloudflare Edge DNS ➔ Worker ➔ D1 (SQL) / KV (Cache/Sessions).
*   **Deployment**: `wrangler deploy` — atomic global rollout.
*   **Routing**: Workers intercept requests at the edge. Use `wrangler.toml` routes for domain mapping.

## 2. API Contract Guidelines
*   Use `hono` as router for minimal overhead and middleware composition.
*   Use standard request headers for validation (`Content-Type`, `Authorization`).
*   JSON response contracts matching edge limits (max Worker response: 25MB).
*   **Error Format**:
    ```json
    { "success": false, "error": { "code": "AUTH_REQUIRED", "message": "Invalid session" } }
    ```
*   **Rate Limiting**: Use `request.cf.asn` or IP-based rate limiting via KV counters with TTL.

## 3. Database Schema Layout (D1)
*   D1 is SQLite-based — no `SERIAL` or `AUTO_INCREMENT`. Use `TEXT PRIMARY KEY` with UUIDs.
*   Timestamps stored as `INTEGER` (Unix epoch) for consistency across edge locations.
```sql
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role TEXT DEFAULT 'user' CHECK(role IN ('admin', 'user')),
  created_at INTEGER DEFAULT (strftime('%s', 'now'))
);

CREATE INDEX idx_users_email ON users(email);
```

## 4. Caching Strategy
*   Use Cloudflare KV for session storage (TTL: 86400s / 24h).
*   Cache-aside pattern: Check KV ➔ if miss ➔ Query D1 ➔ Write to KV.
*   **KV Namespace Naming**: `SESSION_KV`, `CONFIG_KV` — bind in `wrangler.toml`.
*   **Cache Invalidation**: On mutation (user update/delete), explicitly `KV.delete(sessionKey)`.

## 5. Security Considerations
*   **Secrets**: All keys (`JWT_SECRET`, `COOKIE_SECRET`) via `wrangler secret put`. NEVER in `wrangler.toml`.
*   **CORS**: Strict origin allowlist — no wildcard `*` in production.
*   **Cookie Security**: `HttpOnly`, `Secure`, `SameSite=Strict` for session cookies.
*   **Input Validation**: Validate all request bodies with `zod` before D1 queries.

## 6. Observability
*   **Logging**: `console.log()` in Workers → Cloudflare Logpush or `wrangler tail`.
*   **Metrics**: Workers Analytics (invocations, errors, latency) via Cloudflare Dashboard.
*   **Health Check**: Dedicated `GET /healthz` route returning `{ "status": "ok", "timestamp": Date.now() }`.
