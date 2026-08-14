---
id: CRYPTO-WEAK-CIPHER-ALGORITHM
severity_max: CRITICAL
applies_to: typescript, javascript, python, go, php, dotnet
---

# Legacy Weak Cryptographic Ciphers & Insecure Modes

## Intent

Detects usage of deprecated or cryptographically broken encryption algorithms (DES, 3DES, RC4, Blowfish, RSA keys < 2048 bits) or insecure cipher modes (ECB mode `AES-ECB`). AES in Electronic Codebook (ECB) mode encrypts identical plaintext blocks into identical ciphertext blocks, leaking structural patterns to attackers.

Reference OWASP Cheat Sheet Series: `Cryptographic_Storage_Cheat_Sheet.md` & `Key_Management_Cheat_Sheet.md`.

## When CRITICAL

- Symmetric encryption uses `AES-ECB` or legacy broken ciphers (`DES`, `RC4`, `3DES`).
- Asymmetric RSA keys generated with length < 2048 bits.

## When HIGH / MEDIUM

- AES-CBC mode used without HMAC signature verification (vulnerable to Padding Oracle attacks).

## Search patterns (suggestions)

```typescript
createCipheriv('aes-128-ecb'
createCipher('des'
createCipher('rc4'
createCipheriv('aes-256-ecb'
modulusLength:\s*(1024|512)
```

## Examples

### BAD — Insecure AES-ECB Mode & Short RSA Key
```typescript
// BAD: AES-ECB mode leaks data patterns; 1024-bit RSA is vulnerable to factorization
const cipher = crypto.createCipheriv("aes-256-ecb", key, null);

const { publicKey, privateKey } = crypto.generateKeyPairSync("rsa", {
  modulusLength: 1024 // BAD: Key length too short!
});
```

### GOOD — Authenticated AES-GCM Mode & RSA ≥ 2048 / ECC Curve25519
```typescript
// GOOD: AES-GCM mode provides authenticated encryption; RSA >= 2048 or Curve25519
const iv = crypto.randomBytes(12);
const cipher = crypto.createCipheriv("aes-256-gcm", key, iv);

const { publicKey, privateKey } = crypto.generateKeyPairSync("rsa", {
  modulusLength: 2048 // GOOD: Minimum 2048 bits
});
```

## Fix recommendation

1. Use authenticated symmetric encryption algorithms: **AES-256-GCM** or **ChaCha20-Poly1305** with unique random Initialization Vectors (IVs).
2. Never use Electronic Codebook (ECB) mode for multi-block encryption.
3. Enforce RSA key length ≥ 2048 bits (ideally 4096 bits) or adopt Elliptic Curve Cryptography (**Curve25519**).
