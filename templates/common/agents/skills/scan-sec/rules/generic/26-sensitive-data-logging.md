---
id: SENSITIVE-DATA-LOGGING
severity_max: HIGH
applies_to: typescript, javascript, go, python, php, dotnet
---

# Sensitive Data Logging

## Intent

Logging sensitive information (Passwords, JWT Tokens, API Keys, Credit Cards, PII) into log files (`console.log`, `logger.info`, `audit_logs`). Attackers or unauthorized personnel with read access to system logs could exploit this exposed data.

Reference OWASP Cheat Sheet Series: `Logging_Cheat_Sheet.md` & `Nodejs_Security_Cheat_Sheet.md`.

## When HIGH / CRITICAL

- Logging raw login payload containing `password` or `access_token` into public/database logs.
- Logging `Authorization` header or Cookies containing Session Tokens into console or log sinks.

## When MEDIUM / LOW

- Logging non-sensitive audit metadata (Username, IP address, Timestamp) for security auditing.

## Search patterns (suggestions)

```
console\.log\(.*password
console\.log\(.*token
console\.log\(.*secret
logger\.(info|debug|error)\(.*password
```

## Examples

### BAD — Sensitive Data Leak in Log
```typescript
console.log("Login attempt:", { username, password }); // BAD: Password leaked to console/log
```

### GOOD — Sanitize Sensitive Data Before Logging
```typescript
console.log("Login attempt:", { username, timestamp: Date.now() }); // GOOD: Safe audit metadata
```

## Fix recommendation

1. Remove all `console.log` invocations that print sensitive credentials (`password`, `token`, `secret`, `credit_card`).
2. Apply masking or sanitization before writing to log sinks:
   ```typescript
   function maskSecret(str: string): string {
     return str ? str.substring(0, 4) + "****" : "";
   }
   ```
