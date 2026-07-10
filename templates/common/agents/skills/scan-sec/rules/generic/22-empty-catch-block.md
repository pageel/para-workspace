---
id: EMPTY-CATCH-BLOCK
severity_max: MEDIUM
applies_to: all
---

# Empty Catch Block / Silent Exception Swallowing (A10:2025)

## Intent

Swallowing or ignoring exceptions without logging, rethrowing, or handling them. This leads to the program continuing execution in an undefined state (fail open), hiding critical security failures (such as authentication bypass, database transaction failures, or logic errors), allowing attackers to bypass validation checks.

Vibe coders often leave empty catch blocks like `catch(e) {}` during debugging and forget to clean them up, exposing the application to secure-by-accident vulnerabilities.

## When to Flag HIGH / MEDIUM

- **HIGH**: The empty catch block is located within authentication, authorization, cryptography, database transaction, or access control logic.
- **MEDIUM**: The empty catch block is located in standard business logic.

## Reasoning Strategy

1. **Grep** for try-catch blocks that are empty, or only contain comments, pass, or return statements without error handling or logging.
2. **Trace**:
   - What action does the try block perform? Is it verifying tokens, checking passwords, or executing financial transactions?
   - If the try block fails and the catch block is swallowed, what happens next? If the program returns `true` or proceeds (fail-open), it is a severe vulnerability.
3. **Verify**:
   - Does it log the error using a logging utility (`console.error`, `logger.error`, `log.Printf`)?
   - Does it rethrow the error (`throw err`, `raise`, `return err`)?
   - Does it implement a safe fallback (fail-closed)?

## Search Patterns (Examples)

### TypeScript / JavaScript
```regex
catch\s*\([^)]*\)\s*\{\s*\}
catch\s*\([^)]*\)\s*\{\s*\/\/.*\}
catch\s*\([^)]*\)\s*\{\s*pass\s*;?\s*\}
```

### Python
```regex
except\s*(?:[a-zA-Z0-9_]+)?\s*:\s*pass
except\s*(?:[a-zA-Z0-9_]+)?\s*:\s*\#.*
```

### Go
```regex
if\s+err\s*!=\s*nil\s*\{\s*\}
if\s+err\s*!=\s*nil\s*\{\s*\/\/.*\}
```

## Examples

### HIGH — flag

```javascript
// Express middleware auth check - Empty catch allows bypass
app.use((req, res, next) => {
  try {
    const user = jwt.verify(req.headers.token, SECRET);
    req.user = user;
  } catch (err) {
    // Empty catch block / swallow error!
    // Non-authenticated user proceeds with req.user as undefined
  }
  next(); 
});
```

```python
# Python - Swallowing JWT decryption error
def verify_access(token):
    try:
        data = decrypt_token(token)
        return data["is_admin"]
    except Exception:
        pass # Swallows error and execution continues
```

### NOT high — no flag (or downgrade)

```javascript
// Logs error details properly
try {
  performAction();
} catch (err) {
  logger.error("Failed to perform action", err);
}
```

```go
// Go - Returns error to caller (fail-closed)
res, err := db.Query("...")
if err != nil {
    return nil, err
}
```

## Fix Recommendation

1. **Rethrow or Return Error**: Pass the error to a higher-level handler to halt dangerous execution flows.
2. **Log the Exception**: Always log the error details to audit trails for monitoring.
3. **Fail-Closed**: Set access control variables to deny by default if any validation step fails.
