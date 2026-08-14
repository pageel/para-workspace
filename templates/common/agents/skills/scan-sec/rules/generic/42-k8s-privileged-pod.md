---
id: K8S-PRIVILEGED-POD
severity_max: CRITICAL
applies_to: yaml, yml
---

# Over-Privileged Kubernetes Pod Security Context

## Intent

Detects Kubernetes Deployment/Pod manifest misconfigurations where containers are granted host-level privileges (`privileged: true`, `allowPrivilegeEscalation: true`, `hostNetwork: true`, `hostPID: true`, or `runAsRoot: true`). Privileged containers have access to all host kernel capabilities and devices, allowing attackers who compromise the container to escape directly to the host Kubernetes node.

Reference OWASP Cheat Sheet Series: `Kubernetes_Security_Cheat_Sheet.md`.

## When CRITICAL

- Pod securityContext contains `privileged: true`.
- Pod uses `hostNetwork: true` or `hostPID: true`.
- Security context explicitly permits privilege escalation (`allowPrivilegeEscalation: true`).

## When HIGH / MEDIUM

- Pod missing `readOnlyRootFilesystem: true` or capabilities drop (`capabilities: drop: ["ALL"]`).

## Search patterns (suggestions)

```yaml
privileged:\s*true
allowPrivilegeEscalation:\s*true
hostNetwork:\s*true
hostPID:\s*true
runAsUser:\s*0
```

## Examples

### BAD — Over-Privileged Kubernetes Pod Manifest
```yaml
# BAD: Privileged container with host network access
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vulnerable-app
spec:
  template:
    spec:
      hostNetwork: true # BAD: Shares host network namespace
      containers:
        - name: web
          image: nginx
          securityContext:
            privileged: true # BAD: Full host root capabilities!
```

### GOOD — Hardened Restricted Pod Security Context
```yaml
# GOOD: Restricted security context with dropped capabilities and non-root execution
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 10001
        fsGroup: 10001
      containers:
        - name: web
          image: nginx:1.25-alpine
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop:
                - ALL
```

## Fix recommendation

1. Set `privileged: false` and `allowPrivilegeEscalation: false` across all Pod security contexts.
2. Enforce `runAsNonRoot: true` and drop unnecessary Linux capabilities (`capabilities: drop: ["ALL"]`).
3. Apply Kubernetes Pod Security Standards at `restricted` enforcement level.
