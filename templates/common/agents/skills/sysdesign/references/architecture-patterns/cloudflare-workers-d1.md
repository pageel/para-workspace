# Reference Architecture: Serverless Edge (Workers + D1 + KV)

## 1. Topology
*   **Infra**: Hosted on Cloudflare Global Network.
*   **Data Flow**: Client ➔ Cloudflare Edge DNS ➔ Worker ➔ D1 (SQL) / KV (Cache/Sessions).

## 2. API Contract Guidelines
*   Use `hono` as router for minimal overhead.
*   Use standard request headers for validation.
*   JSON response contracts matching edge limits.

## 3. Database Schema Layout (D1)
```sql
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  created_at INTEGER DEFAULT (strftime('%s', 'now'))
);
```

## 4. Caching Strategy
*   Use Cloudflare KV for session storage (TTL: 86400s).
*   Cache-aside pattern: Check KV ➔ if miss ➔ Query D1 ➔ Write to KV.
