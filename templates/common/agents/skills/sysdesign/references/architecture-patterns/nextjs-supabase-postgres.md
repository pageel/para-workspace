---
tags: [fullstack, ssr, rsc, realtime, managed-db]
stack: [nextjs, supabase, postgres, vercel, drizzle]
scale: [medium, large]
complexity: intermediate
---

# Reference Architecture: Fullstack Modern (Next.js + Supabase)

## 1. Topology
*   **Infra**: Next.js hosted on Vercel (Edge + Serverless Functions). Database and Auth Gateway hosted on Supabase (managed Postgres).
*   **Communication**: Server-side fetching (RSC — React Server Components) + Client-side real-time subscription via Supabase SDK.
*   **Edge Functions**: Supabase Edge Functions (Deno) for custom backend logic outside Next.js.

## 2. API & Routing Contract
*   Folder structure: `src/app/api/.../route.ts` (App Router convention).
*   Standard JWT Bearer token extracted from client headers via Supabase Auth.
*   **Server Actions**: Use Next.js Server Actions for form mutations (zero API route needed).
*   **Error Format**:
    ```json
    { "success": false, "error": { "code": "NOT_FOUND", "message": "Resource not found" } }
    ```

## 3. Database Schema (Postgres / Drizzle ORM)
```typescript
import { pgTable, uuid, text, timestamp, boolean } from "drizzle-orm/pg-core";

export const users = pgTable("users", {
  id: uuid("id").primaryKey().defaultRandom(),
  email: text("email").notNull().unique(),
  displayName: text("display_name"),
  isActive: boolean("is_active").default(true),
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),
});

export const posts = pgTable("posts", {
  id: uuid("id").primaryKey().defaultRandom(),
  authorId: uuid("author_id").references(() => users.id, { onDelete: "cascade" }),
  title: text("title").notNull(),
  content: text("content"),
  publishedAt: timestamp("published_at"),
  createdAt: timestamp("created_at").defaultNow(),
});
```

## 4. Row Level Security (RLS)
*   Enable RLS on **all** tables by default — this is non-negotiable with Supabase.
*   Policy patterns:
    ```sql
    -- Users can only read their own data
    CREATE POLICY "Users read own" ON users
      FOR SELECT USING (auth.uid() = id);

    -- Authors can CRUD their own posts
    CREATE POLICY "Authors manage posts" ON posts
      FOR ALL USING (auth.uid() = author_id);

    -- Public can read published posts
    CREATE POLICY "Public read published" ON posts
      FOR SELECT USING (published_at IS NOT NULL);
    ```

## 5. Real-time Subscriptions
*   Enable Supabase Realtime on tables that need live updates:
    ```typescript
    const channel = supabase
      .channel('posts-changes')
      .on('postgres_changes', { event: '*', schema: 'public', table: 'posts' }, (payload) => {
        console.log('Change received:', payload);
      })
      .subscribe();
    ```
*   **Caution**: Only enable on tables with controlled write frequency. High-write tables may overwhelm client connections.

## 6. Security
*   **Auth Flow**: Supabase Auth (email/password, OAuth providers) → JWT stored in `httpOnly` cookie via Next.js middleware.
*   **Middleware Protection**: `src/middleware.ts` checks auth state on protected routes before rendering.
*   **Environment Variables**: Supabase URL and `anon` key are public-safe. `service_role` key MUST stay server-side only.

## 7. Observability
*   **Logging**: Next.js server logs → Vercel Log Drains or `pino` to external aggregator.
*   **Supabase Dashboard**: Built-in query performance, auth events, and storage metrics.
*   **Health Check**: API route `GET /api/healthz` that pings Supabase connection pool.
