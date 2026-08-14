---
id: GRAPHQL-QUERY-DEPTH-DOS
severity_max: HIGH
applies_to: typescript, javascript, python, go
---

# GraphQL Unbounded Query Depth & DoS

## Intent

Detects GraphQL API endpoints lacking Query Depth Limiters, Query Complexity Analysis, or having Schema Introspection enabled in production. Malicious or poorly constructed nested GraphQL queries (e.g. `user { friends { friends { friends ... } } }`) consume excessive CPU/RAM on resolvers, causing Denial of Service (DoS) for the application.

Reference OWASP Cheat Sheet Series: `GraphQL_Cheat_Sheet.md`.

## When HIGH / CRITICAL

- GraphQL server initialization omits depth limiting plugins (e.g. `graphql-depth-limit` or `graphql-query-complexity`).
- Schema Introspection (`introspection: true`) is explicitly enabled in Production environment.

## When MEDIUM / LOW

- GraphQL server lacks query pagination `first` / `limit` caps on array resolvers.

## Search patterns (suggestions)

```typescript
createGraphQLHandler\(
ApolloServer\(
introspection:\s*true
graphql-depth-limit
```

## Examples

### BAD — Unbounded GraphQL Server Configuration
```typescript
// BAD: No query depth limit or complexity analysis — vulnerable to DoS!
const server = new ApolloServer({
  typeDefs,
  resolvers,
  introspection: true // Enabled in production!
});
```

### GOOD — Enforced Query Depth Limit & Disabled Introspection in Prod
```typescript
import depthLimit from 'graphql-depth-limit';

// GOOD: Depth limited to max 7 levels, introspection disabled in prod
const server = new ApolloServer({
  typeDefs,
  resolvers,
  validationRules: [depthLimit(7)],
  introspection: process.env.NODE_ENV !== "production"
});
```

## Fix recommendation

1. Install and enforce `graphql-depth-limit` (recommended depth ≤ 10) or query complexity limiters.
2. Disable Introspection (`introspection: false`) in Production to prevent Attack Surface mapping.
3. Apply strict pagination caps (e.g. max `first: 100`) on all array list resolvers.
