---
id: OAUTH2-DEPRECATED-IMPLICIT-FLOW
severity_max: HIGH
applies_to: typescript, javascript, python, go, php
---

# OAuth2 Deprecated Implicit Grant & Missing PKCE

## Intent

Detects usage of the deprecated OAuth2 Implicit Grant flow (`response_type=token` or `response_type=id_token token`) or authorization code grants missing PKCE (`code_challenge` and `code_verifier`). The Implicit Flow is officially deprecated by RFC 9700 §2.1.2 and removed from OAuth 2.1 because access tokens are exposed in URL fragments (`#access_token=...`), which leak via browser history, Referer headers, and server logs.

Reference OWASP Cheat Sheet Series: `OAuth2_Cheat_Sheet.md`.

## When HIGH / CRITICAL

- OAuth client initializes authorization requests with `response_type=token`.
- Authorization Code flow for SPAs / Mobile apps omits PKCE parameters (`code_challenge` / `code_challenge_method=S256`).

## When MEDIUM / LOW

- Authorization Server supports PKCE downgrade without enforcing `code_verifier` validation.

## Search patterns (suggestions)

```typescript
response_type=token
response_type:\s*["']token["']
response_type=id_token\s+token
code_challenge
```

## Examples

### BAD — Deprecated Implicit Grant Flow
```typescript
// BAD: Access token returned in URL fragment (Implicit Flow - DEPRECATED)
const authUrl = `https://auth.example.com/oauth/authorize?response_type=token&client_id=${clientId}&redirect_uri=${redirectUri}`;
```

### GOOD — Authorization Code Grant with PKCE (S256)
```typescript
// GOOD: Use Authorization Code Flow + PKCE
const codeVerifier = generateRandomBase64URL(64);
const codeChallenge = await sha256Base64URL(codeVerifier);

const authUrl = `https://auth.example.com/oauth/authorize?response_type=code&client_id=${clientId}&redirect_uri=${redirectUri}&code_challenge=${codeChallenge}&code_challenge_method=S256`;
```

## Fix recommendation

1. Migrate all OAuth2 integrations from Implicit Grant (`response_type=token`) to Authorization Code Grant with PKCE (`response_type=code` + `code_challenge_method=S256`).
2. Enforce `code_challenge` parameter validation on the Authorization Server token endpoint.
