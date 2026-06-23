# Reference Architecture: Traditional REST API (Express + MongoDB)

## 1. Topology
*   **Infra**: Dockerized container running on VPS. Reverse-proxied via Nginx.
*   **Storage**: MongoDB cluster.

## 2. API Contract
*   Route separation: `src/routes/`, `src/controllers/`.
*   Validation middleware using `zod`.

## 3. Storage Mongoose Schema
```typescript
import { Schema, model } from 'mongoose';

const UserSchema = new Schema({
  email: { type: String, required: true, unique: true },
  createdAt: { type: Date, default: Date.now }
});
export const User = model('User', UserSchema);
```

## 4. Containerization
```dockerfile
# Dockerfile
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
CMD ["npm", "start"]
```
