---
id: HARDCODED-SECRET-VAULT-BYPASS
severity_max: CRITICAL
applies_to: typescript, javascript, python, yaml, json, env
---

# Plaintext Secret Storage & Vault Bypass

## Intent

Detects static application source files or configuration manifests containing hardcoded high-entropy secret tokens (such as AWS Access Keys `AKIA...`, Stripe Secret Keys `sk_live_...`, GitHub Personal Access Tokens `ghp_...`, JWT secret strings, or private RSA keys). Hardcoding plaintext credentials in Git repositories leads to catastrophic credential leaks, automated bot harvesting, and total infrastructure compromise.

Reference OWASP Cheat Sheet Series: `Secrets_Management_Cheat_Sheet.md`.

## When CRITICAL

- Production API keys, private keys (`-----BEGIN PRIVATE KEY-----`), or database passwords hardcoded in source code or committed `.env` files.
- CI/CD workflow scripts printing secret environment variables in plain text build logs.

## When HIGH / MEDIUM

- Example configuration files (`config.example.json`) containing non-placeholder real credential strings.

## Search patterns (suggestions)

```typescript
AKIA[0-9A-Z]{16}
sk_live_[0-9a-zA-Z]{24}
ghp_[0-9a-zA-Z]{36}
-----BEGIN PRIVATE KEY-----
password\s*:\s*["'][^"']{8,}["']
```

## Examples

### BAD — Hardcoded Production Secret Key in Code
```typescript
// BAD: Secret key committed directly in application source code
const STRIPE_SECRET_KEY = "sk_test_dummy_placeholder_key_not_real";
const DB_PASSWORD = "SuperSecretPassword123!";
```

### GOOD — Dynamic Environment Injection via Secrets Manager
```typescript
// GOOD: Access secrets dynamically from Cloudflare Env / Process Environment
export async function fetchPayment(env: Env) {
  const stripeKey = env.STRIPE_SECRET_KEY; // Injected via secure secrets vault
  const stripe = new Stripe(stripeKey);
  // ...
}
```

## Fix recommendation

1. Remove all hardcoded credential strings from source code immediately and revoke/rotate compromised keys.
2. Inject secrets dynamically at runtime using platform environment variables (Cloudflare Secrets, HashiCorp Vault, AWS Secrets Manager, or GitHub Encrypted Secrets).
3. Enforce pre-commit git hooks (such as `trufflehog` or `git-secrets`) to block secret commits.
