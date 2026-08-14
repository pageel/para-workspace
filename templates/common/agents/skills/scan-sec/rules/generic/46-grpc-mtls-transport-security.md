---
id: GRPC-MTLS-TRANSPORT-SECURITY
severity_max: HIGH
applies_to: typescript, javascript, python, go
---

# Insecure gRPC Transport & Missing mTLS Verification

## Intent

Detects gRPC client or server instances initialized using insecure plaintext transport (`grpc.insecure()` or `insecure.NewCredentials()`), or microservice communication lacking mutual TLS (mTLS) certificate verification. In microservice architectures, unencrypted gRPC HTTP/2 channels allow internal eavesdropping, credential interception, and unauthorized inter-service procedure invocation.

Reference OWASP Cheat Sheet Series: `gRPC_Security_Cheat_Sheet.md`.

## When HIGH / CRITICAL

- Production gRPC server or client uses `insecure.NewCredentials()` or `grpc.credentials.createInsecure()`.
- Internal microservice gRPC endpoints omit client certificate verification (mTLS).

## When MEDIUM / LOW

- gRPC connection uses TLS 1.0 or 1.1 instead of TLS 1.2+.

## Search patterns (suggestions)

```typescript
createInsecure\(
insecure\.NewCredentials\(
grpc\.insecure\(
```

## Examples

### BAD — Insecure Plaintext gRPC Channel
```go
// BAD: Unencrypted gRPC connection vulnerable to eavesdropping and MITM
conn, err := grpc.Dial("auth-service:50051", grpc.WithInsecure())
```

### GOOD — Mutual TLS (mTLS) Transport Credentials
```go
// GOOD: Require mutual TLS certificate validation for both client and server
cert, err := tls.LoadX509KeyPair("client.crt", "client.key")
caCert, err := ioutil.ReadFile("ca.crt")
caCertPool := x509.NewCertPool()
caCertPool.AppendCertsFromPEM(caCert)

creds := credentials.NewTLS(&tls.Config{
    Certificates: []tls.Certificate{cert},
    RootCAs:      caCertPool,
    MinVersion:   tls.VersionTLS12,
})

conn, err := grpc.Dial("auth-service:50051", grpc.WithTransportCredentials(creds))
```

## Fix recommendation

1. Always enforce TLS 1.2+ for all gRPC production client and server channels.
2. Implement Mutual TLS (mTLS) for microservice-to-microservice gRPC communication to enforce Zero Trust identity verification.
