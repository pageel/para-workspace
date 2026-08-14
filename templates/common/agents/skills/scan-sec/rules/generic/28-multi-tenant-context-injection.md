---
id: MULTI-TENANT-CONTEXT-INJECTION
severity_max: CRITICAL
applies_to: typescript, javascript, python, go, php, dotnet
---

# Multi-Tenant Context Injection & IDOR

## Intent

Detects trusting client-supplied tenant identifiers (e.g. `req.headers['x-tenant-id']`, `req.query.tenant_id`, `req.body.tenant_id`) to query multi-tenant data without cross-checking against the authenticated user's session token. Attackers can manipulate tenant IDs to impersonate other tenants and read/write unauthorized corporate data.

Reference OWASP Cheat Sheet Series: `Multi_Tenant_Security_Cheat_Sheet.md`.

## When CRITICAL

- Unvalidated client-supplied tenant ID is passed directly into database queries or file access routines.
- User authentication passes, but tenant authorization check is missing.

## When HIGH / MEDIUM

- Tenant ID is derived from URL parameter without verifying if the user belongs to that tenant.

## Search patterns (suggestions)

```typescript
req.headers['x-tenant-id']
req.query.tenant_id
params.tenantId
```

## Examples

### BAD — Trusting Client-Supplied Tenant Header
```typescript
// BAD: Attacker can send X-Tenant-ID: "victim-corp" header to read victim data
export async function getTenantLeads(req: Request, db: D1Database) {
  const tenantId = req.headers.get("X-Tenant-ID"); // UNTRUSTED!
  return await db.prepare("SELECT * FROM leads WHERE tenant_id = ?").bind(tenantId).all();
}
```

### GOOD — Deriving Tenant Context from Authenticated Session Token
```typescript
// GOOD: Tenant ID is securely extracted from cryptographically verified JWT / Session
export async function getTenantLeads(req: Request, db: D1Database) {
  const user = await verifyAuthToken(req); // Cryptographically verified JWT
  const tenantId = user.tenantId; // Derived from verified session
  return await db.prepare("SELECT * FROM leads WHERE tenant_id = ?").bind(tenantId).all();
}
```

## Fix recommendation

1. Always derive tenant context from the verified session or JWT token, never from unauthenticated headers or request parameters.
2. If client must specify target tenant ID (e.g. multi-tenant admin), verify the authenticated user has explicit permission for that `tenant_id` before executing database queries.
