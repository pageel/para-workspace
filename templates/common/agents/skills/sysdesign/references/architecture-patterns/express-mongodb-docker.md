---
tags: [rest-api, server, nosql, containerized]
stack: [express, mongodb, mongoose, docker, nginx]
scale: [small, medium, large]
complexity: intermediate
---

# Reference Architecture: Traditional REST API (Express + MongoDB)

## 1. Topology
*   **Infra**: Dockerized container running on VPS (Ubuntu). Reverse-proxied via Nginx with TLS termination.
*   **Storage**: MongoDB cluster (standalone for dev, replica set for production).
*   **Scaling**: Horizontal scaling via Docker Compose replicas behind Nginx load balancer.

## 2. API Contract
*   Route separation: `src/routes/`, `src/controllers/`, `src/services/`, `src/models/`.
*   Validation middleware using `zod` schemas per endpoint.
*   **Versioning**: URL-based (`/api/v1/...`) or Header-based (`Accept-Version: 1`).
*   **Error Format**:
    ```json
    { "success": false, "error": { "code": "VALIDATION_ERROR", "message": "Email is required", "details": [] } }
    ```
*   **Pagination**: Cursor-based for large collections, skip/limit for small datasets.

## 3. Storage Mongoose Schema
```typescript
import { Schema, model } from 'mongoose';

const UserSchema = new Schema({
  email: { type: String, required: true, unique: true, lowercase: true, trim: true },
  passwordHash: { type: String, required: true, select: false },
  role: { type: String, enum: ['admin', 'user'], default: 'user' },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

UserSchema.index({ email: 1 });
UserSchema.index({ createdAt: -1 });

export const User = model('User', UserSchema);
```

## 4. Containerization
```dockerfile
# Dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
USER node
CMD ["node", "src/index.js"]
```

```yaml
# docker-compose.yml (excerpt)
services:
  api:
    build: .
    ports: ["3000:3000"]
    environment:
      - MONGO_URI=mongodb://mongo:27017/app
    depends_on: [mongo]
  mongo:
    image: mongo:7
    volumes: [mongo-data:/data/db]
volumes:
  mongo-data:
```

## 5. Security
*   **Helmet**: `app.use(helmet())` for security headers.
*   **Rate Limiting**: `express-rate-limit` on auth endpoints (max 10 requests/min per IP).
*   **CORS**: Strict origin allowlist via `cors({ origin: ['https://example.com'] })`.
*   **Input Sanitization**: `express-mongo-sanitize` to prevent NoSQL injection (`$gt`, `$ne`).

## 6. Observability
*   **Logging**: `winston` or `pino` with JSON format → stdout → log aggregator.
*   **Health Check**: `GET /healthz` returns `{ "status": "ok", "db": "connected" }`.
*   **Metrics**: `prom-client` for Prometheus-compatible metrics (`/metrics` endpoint).
