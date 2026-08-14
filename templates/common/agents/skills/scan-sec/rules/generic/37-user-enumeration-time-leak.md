---
id: USER-ENUMERATION-TIME-LEAK
severity_max: HIGH
applies_to: typescript, javascript, python, go, php, dotnet
---

# User Account Enumeration & Response Timing Leaks

## Intent

Detects User Account Enumeration vulnerabilities in authentication, registration, or password reset endpoints. Returning distinct error messages (e.g., "Email not found" vs "Incorrect password") or introducing response timing discrepancies (quick early exit when account does not exist) allows attackers to harvest valid user account emails for targeted phishing or credential stuffing attacks.

Reference OWASP Cheat Sheet Series: `Forgot_Password_Cheat_Sheet.md` & `Authentication_Cheat_Sheet.md`.

## When HIGH / CRITICAL

- Password reset or login endpoint explicitly reveals whether an email/username exists in the database.
- Forgot password endpoint exits immediately without executing dummy password verification logic, creating a timing side-channel leak.

## When MEDIUM / LOW

- Missing rate limiting on password reset request endpoints.

## Search patterns (suggestions)

```typescript
"Email not found"
"User does not exist"
"Account not registered"
if (!user) return res.status(404)
```

## Examples

### BAD — Revealing Account Existence & Early Exit Timing Leak
```typescript
// BAD: Attacker enumerates registered emails by checking for 404 response
export async function handleForgotPassword(req: Request, db: Database) {
  const { email } = await req.json();
  const user = await db.findUserByEmail(email);
  
  if (!user) {
    return new Response("User does not exist", { status: 404 }); // Exposes account existence!
  }
  
  await sendResetEmail(user);
  return new Response("Reset link sent", { status: 200 });
}
```

### GOOD — Uniform Generic Response & Constant-Time Logic
```typescript
// GOOD: Uniform generic message for both existing and non-existing accounts
export async function handleForgotPassword(req: Request, db: Database, ctx: ExecutionContext) {
  const { email } = await req.json();
  const user = await db.findUserByEmail(email);
  
  if (user) {
    ctx.waitUntil(sendResetEmail(user)); // Fire-and-forget async execution
  } else {
    // Perform dummy work to prevent timing side-channel analysis
    await dummyHashWork();
  }
  
  // Always return the exact same generic message
  return new Response("If your email is registered, a password reset link has been sent.", { status: 200 });
}
```

## Fix recommendation

1. Return uniform generic status messages (e.g., "If your account exists, instructions have been sent") for all password reset and registration attempts.
2. Ensure constant-time execution paths for both valid and invalid account lookups to eliminate timing side-channel leaks.
