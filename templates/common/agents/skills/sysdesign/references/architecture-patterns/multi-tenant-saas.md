---
tags: [multi-tenant, saas, isolation, horizontal-pattern]
stack: [any]
scale: [medium, large, enterprise]
complexity: advanced
---

# Reference Architecture: Multi-Tenant SaaS (Horizontal Pattern)

> **Note:** This is a **horizontal architecture pattern** — it applies across technology stacks.
> Combine this pattern with a specific stack pattern (e.g., Workers+D1, Next.js+Supabase, FastAPI+Postgres).

## 1. Tenant Isolation Strategies

| Strategy | Data Isolation | Complexity | Cost | Use When |
|:--|:--|:--|:--|:--|
| **Shared DB, Shared Schema** | Row-level (`tenant_id` column) | 🟢 Low | 🟢 Low | < 100 tenants, no compliance needs |
| **Shared DB, Separate Schema** | Schema-level (`tenant_x.users`) | 🟡 Medium | 🟡 Medium | 100-1000 tenants, moderate isolation |
| **Separate DB per Tenant** | Full database isolation | 🔴 High | 🔴 High | Enterprise, strict compliance (HIPAA/SOC2) |

### Recommended Default: Shared DB + Row-Level Isolation

```sql
-- Every table MUST include tenant_id
CREATE TABLE posts (
  id TEXT PRIMARY KEY,
  tenant_id TEXT NOT NULL,
  title TEXT NOT NULL,
  content TEXT,
  created_at INTEGER DEFAULT (strftime('%s', 'now'))
);

-- Composite index for tenant-scoped queries
CREATE INDEX idx_posts_tenant ON posts(tenant_id, created_at DESC);

-- CRITICAL: All queries MUST filter by tenant_id
-- ❌ SELECT * FROM posts WHERE id = ?
-- ✅ SELECT * FROM posts WHERE tenant_id = ? AND id = ?
```

## 2. Tenant Resolution

How to identify which tenant a request belongs to:

| Method | Example | Pros | Cons |
|:--|:--|:--|:--|
| **Subdomain** | `acme.app.com` | Clean separation, easy routing | DNS wildcard setup, SSL certs |
| **Path prefix** | `app.com/acme/...` | Simple, no DNS config | Routing complexity, URL pollution |
| **Custom domain** | `cms.acme.com` | Professional, branded | CNAME management, SSL per domain |
| **Header/Token** | `X-Tenant-ID: acme` | API-first, flexible | Requires auth middleware |

### Subdomain Resolution Example
```typescript
function resolveTenant(request: Request): string {
  const hostname = new URL(request.url).hostname;
  // acme.pageel.app → "acme"
  const subdomain = hostname.split('.')[0];
  if (subdomain === 'www' || subdomain === 'api') {
    throw new Error('Invalid tenant subdomain');
  }
  return subdomain;
}
```

## 3. Data Architecture

### Tenant Configuration Table
```sql
CREATE TABLE tenants (
  id TEXT PRIMARY KEY,
  slug TEXT UNIQUE NOT NULL,         -- Subdomain or path prefix
  display_name TEXT NOT NULL,
  custom_domain TEXT,                -- Optional CNAME
  plan TEXT DEFAULT 'free' CHECK(plan IN ('free', 'pro', 'enterprise')),
  config TEXT DEFAULT '{}',          -- JSON: feature flags, limits
  created_at INTEGER DEFAULT (strftime('%s', 'now'))
);
```

### Tenant-Scoped Access Pattern
```typescript
// Middleware: inject tenant context into every request
async function tenantMiddleware(c: Context, next: Next) {
  const tenantSlug = resolveTenant(c.req.raw);
  const tenant = await db.prepare('SELECT * FROM tenants WHERE slug = ?').bind(tenantSlug).first();
  if (!tenant) return c.json({ error: 'Tenant not found' }, 404);
  c.set('tenant', tenant);
  await next();
}

// Every DB query MUST scope by tenant
const posts = await db.prepare(
  'SELECT * FROM posts WHERE tenant_id = ? ORDER BY created_at DESC LIMIT ?'
).bind(tenant.id, limit).all();
```

## 4. Security Considerations

*   **Tenant Data Leakage**: The #1 multi-tenant risk. EVERY query MUST include `WHERE tenant_id = ?`.
*   **Cross-Tenant Request Forgery**: Validate `tenant_id` in auth token matches the requested resource's `tenant_id`.
*   **Rate Limiting per Tenant**: Separate rate limits per tenant (not per IP) to prevent noisy neighbor.
*   **Audit Logging**: Include `tenant_id` in every audit log entry for compliance and forensics.
*   **Tenant Admin vs Super Admin**: Two RBAC layers — tenant-scoped admin and platform-wide super admin.

## 5. Scaling & Performance

*   **Query Performance**: Always use composite indexes `(tenant_id, <sort_column>)`.
*   **Noisy Neighbor**: Monitor per-tenant query volume. Throttle or migrate heavy tenants to dedicated resources.
*   **Tenant Onboarding**: Automate tenant provisioning (create DB records, seed defaults, configure DNS).
*   **Tenant Offboarding**: Soft-delete tenant → 30-day grace period → hard-delete all scoped data.
