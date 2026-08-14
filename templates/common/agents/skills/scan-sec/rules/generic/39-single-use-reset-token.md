---
id: SINGLE-USE-RESET-TOKEN
severity_max: CRITICAL
applies_to: typescript, javascript, python, go, php, dotnet
---

# Reusable Password Reset Tokens & Long Expiry TTL

## Intent

Detects password reset tokens, OTPs, or activation links that remain valid after initial consumption, or have excessively long expiration time-to-live (TTL > 15 minutes). If a reset token is not invalidated immediately upon first use (`used = true`), an attacker who intercepts the link (via browser history or server logs) can reuse it to hijack the victim's account.

Reference OWASP Cheat Sheet Series: `Forgot_Password_Cheat_Sheet.md` & `Session_Management_Cheat_Sheet.md`.

## When CRITICAL

- Password reset verification handler updates user password without marking the reset token as consumed (`used = 1` or deleting token row).
- Reset token TTL exceeds 15 minutes without revocation.

## When HIGH / MEDIUM

- Reset tokens generated using weak pseudorandom generators (`Math.random()`).

## Search patterns (suggestions)

```typescript
Math.random()
expires_at
token_expiry
```

## Examples

### BAD — Reusable Token & Math.random() Generation
```typescript
// BAD: Token is generated with Math.random() and not marked used after password reset!
export async function resetPassword(req: Request, db: Database) {
  const { token, newPassword } = await req.json();
  const resetRow = await db.findToken(token);
  
  if (!resetRow || resetRow.expiresAt < Date.now()) {
    return new Response("Invalid token", { status: 400 });
  }
  
  await db.updatePassword(resetRow.userId, newPassword);
  // Missing token invalidation! Attacker can reuse `token`!
  return new Response("Password updated", { status: 200 });
}
```

### GOOD — Cryptographic Randomness, Single-Use Invalidation & Short Expiry
```typescript
// GOOD: Use crypto.randomUUID() / crypto.getRandomValues(), short 15m TTL, and single-use consume
export async function resetPassword(req: Request, db: Database) {
  const { token, newPassword } = await req.json();
  
  // Single-use transaction: check valid, unconsumed, and unexpired token
  const resetRow = await db.findValidToken(token); // Checks used = 0 AND expires_at > NOW()
  if (!resetRow) {
    return new Response("Invalid or expired token", { status: 400 });
  }
  
  await db.transaction(async (tx) => {
    await tx.updatePassword(resetRow.userId, newPassword);
    await tx.markTokenAsUsed(token); // Single-use invalidation!
    await tx.revokeAllUserSessions(resetRow.userId); // Invalidate active sessions
  });

  return new Response("Password updated securely", { status: 200 });
}
```

## Fix recommendation

1. Generate all password reset tokens using cryptographically secure random number generators (`crypto.randomUUID()` or `crypto.getRandomValues()`).
2. Mark tokens as consumed (`used = true`) or delete them immediately within a single atomic database transaction upon password reset.
3. Limit password reset token TTL to maximum 15 minutes.
