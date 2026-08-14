---
id: DOCKER-ROOT-EXECUTION
severity_max: HIGH
applies_to: dockerfile, docker
---

# Dockerfile Root Execution & Socket Exposure

## Intent

Detects Dockerfiles running container processes as the privileged `root` user (missing explicit non-root `USER` directive), mounting the host Docker socket `/var/run/docker.sock`, or copying sensitive host credential files (`.env`, `id_rsa`) into image build layers. Running as root inside a container increases the impact of container escape vulnerabilities.

Reference OWASP Cheat Sheet Series: `Docker_Security_Cheat_Sheet.md`.

## When HIGH / CRITICAL

- Container image runs without specifying a non-root `USER` directive (defaulting to `root`).
- Host Docker socket `/var/run/docker.sock` is mounted into container volumes.
- Dockerfile `COPY` or `ADD` commands copy private SSH keys (`id_rsa`) or `.env` files into final build images.

## When MEDIUM / LOW

- Dockerfile uses `latest` tag in `FROM` instruction instead of pinned image SHA/version tag.

## Search patterns (suggestions)

```dockerfile
USER root
/var/run/docker.sock
COPY.*\.env
COPY.*id_rsa
FROM.*:latest
```

## Examples

### BAD — Running as Root & Mounting Docker Socket
```dockerfile
# BAD: Missing USER directive (runs as root) and mounts host Docker socket
FROM node:20-alpine
WORKDIR /app
COPY . .
RUN npm ci
CMD ["node", "server.js"]
```

### GOOD — Non-Root User & Multi-Stage Minimal Build
```dockerfile
# GOOD: Explicit non-root USER and pinned base image
FROM node:20-alpine AS runner
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Create and switch to non-root user
RUN addgroup -g 1001 -S nodejs && adduser -u 1001 -S nodejs -G nodejs
USER nodejs

EXPOSE 3000
CMD ["node", "server.js"]
```

## Fix recommendation

1. Create a dedicated non-root user and group (`USER node` or `USER 1001`) in Dockerfiles.
2. Never mount `/var/run/docker.sock` inside application containers.
3. Use `.dockerignore` to prevent copying `.env`, `.git`, or credential files into build contexts.
