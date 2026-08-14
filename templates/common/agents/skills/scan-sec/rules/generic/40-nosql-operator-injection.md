---
id: NOSQL-OPERATOR-INJECTION
severity_max: CRITICAL
applies_to: typescript, javascript, python, php
---

# NoSQL Operator Injection & Unsanitized Queries

## Intent

Detects NoSQL Injection vulnerabilities in MongoDB, Mongoose, or Document DB queries. When user input (from `req.body` or `req.query`) is passed directly into a query object without type validation, an attacker can supply a JSON object containing query operators (such as `{"$ne": ""}` or `{"$gt": ""}`). This manipulates the query logic to bypass authentication or dump entire database collections.

Reference OWASP Cheat Sheet Series: `NoSQL_Security_Cheat_Sheet.md`.

## When CRITICAL

- Login or authentication query accepts object input for username/password fields without string type checking.
- Untrusted user input is passed into `$where` or `mapReduce` Javascript evaluation functions.

## When HIGH / MEDIUM

- MongoDB query uses `$or` or `$and` containing un-sanitized user input objects.

## Search patterns (suggestions)

```typescript
find\(\{\$where:
\.find\(req\.body
\.findOne\(req\.body
mongoSanitize
```

## Examples

### BAD — Unsanitized Object Input Allows Auth Bypass
```typescript
// BAD: Attacker posts { username: "admin", password: { "$ne": "" } } to log in without password
export async function handleLogin(req: Request, db: any) {
  const { username, password } = await req.json();
  
  // Vulnerable NoSQL Query: password accepts object operator {$ne: ""}
  const user = await db.collection("users").findOne({ username, password });
  if (user) return new Response("Logged in", { status: 200 });
}
```

### GOOD — Explicit String Type Verification & Input Sanitization
```typescript
// GOOD: Enforce string types for query parameters or use mongo-sanitize
export async function handleLogin(req: Request, db: any) {
  const { username, password } = await req.json();
  
  // Reject non-string query inputs
  if (typeof username !== "string" || typeof password !== "string") {
    return new Response("Invalid payload", { status: 400 });
  }

  const user = await db.collection("users").findOne({
    username: String(username),
    passwordHash: await hashPassword(String(password))
  });

  if (user) return new Response("Logged in", { status: 200 });
}
```

## Fix recommendation

1. Enforce strict string type validation (`typeof val === "string"`) for all query fields received from HTTP payloads.
2. Use middleware libraries like `express-mongo-sanitize` to strip `$` and `.` characters from user input keys.
3. Avoid `$where` or dynamic JavaScript evaluation inside NoSQL query operators.
