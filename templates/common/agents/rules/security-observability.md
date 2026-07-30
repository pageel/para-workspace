# Rule: Security & Observability in Configurations

> Rule for security, environment variable segregation, cookie scopes, rendering compatibility, and fallback observability.

## Scope

- [x] Global (applies to all projects in workspace)

## Triggers

- Creating or modifying configuration files (e.g., `wrangler.toml`, `.env`, `settings.json`, config maps) or settings endpoints.
- Defining cookie settings (`Set-Cookie` headers).
- Implementing fallback logic for key system variables.
- Modifying frontend/hybrid components (Astro, Next.js, Nuxt, SvelteKit) involving dynamic data fetch or database queries.

## Constraints

### C1: SDK Generalization (No Production Secrets in Git)
*   Agent **MUST NOT** hardcode production credentials, API keys, private emails, or real contact details (e.g. real hotline phone numbers) directly in codebase files.
*   All templates and default source code fallbacks **MUST** use generic, standard mock placeholders (e.g., `"info@example.com"`, `"0900000000"`, `"example.com"`).
*   Production-specific values **MUST** be populated exclusively through server environment variables (vars/secrets) or dynamic database fields.

### C2: Cookie Scope Isolation
*   Whenever a session token, CSRF cookie, or settings token is set via `Set-Cookie`, the Agent **MUST** verify its path scope.
*   The path constraint **MUST** match the prefix of all endpoints using the cookie. (e.g., if `/api/admin/email-setting` and `/api/admin/settings` both require the token, the cookie path must be `/api/admin`, not `/api/admin/settings`).

### C3: Rendering Alignment Pre-flight
*   Before implementing DB queries or dynamic server calls inside frontend templates, the Agent **MUST** check the project's build output mode (`static` / SSG vs `server` / SSR / Hybrid).
*   **IF static (SSG)**: Do not write direct DB/server queries in frontend templates. Use asynchronous client-side scripts to fetch from public API endpoints.
*   **IF server (SSR)**: Direct DB/server queries inside server-side rendered components are allowed.

### C4: Graceful Degradation & Fallback Observability
*   When rẽ nhánh dự phòng (fallback) to resolve configurations, the Agent **MUST NOT** silently ignore empty or missing environment/database keys.
*   If a critical setting falls back to its default placeholder, the system **MUST** log an explicit warning (`console.warn`) explaining the fallback reason and suggesting configuration updates.

### C5: User Env Chat Handoff & Pre-Plan Dev Gate
*   When a plan or task introduces new environment variables or secrets (`env.*` / `secrets`), the Agent **MUST**:
    1. **Task Traceability:** Register an explicit task `[📝]` in the Plan for environment documentation (Rule 1).
    2. **Workflow Standard:** Compile/update environment setup guide using the `/docs` workflow (Rule 2).
    3. **Mandatory User Chat Handoff:** Output the exact setup commands (e.g. `npx wrangler secret put <KEY>` / Dashboard) directly to the User in Chat (Rule 3).
    4. **Pre-Plan Dev Gate:** Verify environment readiness in Phase 0 before starting Phase 1 code implementation (Rule 4).

## Plan & Dev Workflow Improvements

### 1. Pre-Implementation Design Block (Planning)
When creating or updating an Implementation Plan (`/plan`), the Agent **MUST** include a **"Pre-Implementation Design Block"** specifying:
- **Build Mode check**: Confirming if the target workspace uses SSG, SSR, or Hybrid.
- **Cookies & Scope Matrix**: Defining path and security attributes for any new cookies.
- **Secrets & Fallback Strategy**: Defining the environment variables required, fallback default placeholders, and warning log locations.

### 2. Generalization Linter (Development)
During implementation (`/plan dev` phase), the Agent **MUST** review edited code for hardcoded secrets or production details before proposing git staging or commits.
