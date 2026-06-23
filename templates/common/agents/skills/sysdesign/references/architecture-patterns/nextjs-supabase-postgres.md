# Reference Architecture: Fullstack Modern (Next.js + Supabase)

## 1. Topology
*   **Infra**: Next.js hosted on Vercel. Database and API Gateway hosted on Supabase (Postgres).
*   **Communication**: Server-side fetching (RSC) + Client-side subscription via Supabase SDK.

## 2. API & Routing Contract
*   Folder structure: `src/app/api/.../route.ts`.
*   Standard JWT Bearer token extracted from client headers.

## 3. Database Schema (Postgres / Drizzle)
```typescript
import { pgTable, uuid, text, timestamp } from "drizzle-orm/pg-core";

export const users = pgTable("users", {
  id: uuid("id").primaryKey().defaultRandom(),
  email: text("email").notNull().unique(),
  createdAt: timestamp("created_at").defaultNow(),
});
```

## 4. Row Level Security (RLS)
*   Enable RLS on all tables by default.
*   Policy: `CREATE POLICY "Allow select for owner" ON users FOR SELECT USING (auth.uid() = id);`
