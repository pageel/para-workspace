# TypeScript/JavaScript Specialization

These rule files override generic rules when scan-sec detects primary language as `typescript`.

## Language detection scope

Scan-sec treats these as `typescript`:
- `.ts`, `.tsx` (TypeScript)
- `.js`, `.jsx`, `.mjs`, `.cjs` (JavaScript)

(Rationale: vibe coders often mix JS and TS in same project; patterns are near-identical at the JavaScript runtime level.)

## Files in this folder

| File | Rule ID | What it specializes |
|---|---|---|
| `02-sql-injection.md` | SQL-INJECTION | Sequelize, Prisma, TypeORM, Mongoose, Knex |
| `03-xss.md` | XSS | React `dangerouslySetInnerHTML`, Vue `v-html`, Angular `bypassSecurityTrustHtml`/`[innerHTML]`, jQuery `.html()` |
| `07-mass-assignment.md` | MASS-ASSIGNMENT | Mongoose `new Model(req.body)`, Sequelize/Prisma/TypeORM `create(req.body)`, NestJS DTOs |
| `08-insecure-deserialization.md` | INSECURE-DESERIALIZATION | `js-yaml` v3 unsafe, `vm.runInNewContext`, `notevil`, `node-serialize` |
| `09-ssrf.md` | SSRF | `fetch`/`axios`/`got` with user URL, Next.js `getServerSideProps`, webhook URL |
| `11-csrf.md` | CSRF | Express `csurf` (deprecated), NestJS, Next.js API routes vs Server Actions, SameSite |
| `14-jwt-none-algorithm.md` | JWT-NONE-ALGORITHM | `jsonwebtoken` versions, missing `algorithms`, RS256/HS256 confusion, frontend decode |
| `15-cors-misconfig.md` | CORS-MISCONFIG | `cors()` no-arg, regex without `$` anchor, `origin: true` echo |
| `17-verbose-error-debug-mode.md` | VERBOSE-ERROR-DEBUG-MODE | `errorhandler()` in prod, source maps, NestJS exception filters |
| `21-command-injection.md` | COMMAND-INJECTION | `child_process.exec` vs `execFile`, shell template literals, ShellJS |

## Framework coverage

### Backend
- Express, Fastify, Koa, Hapi
- NestJS
- Next.js (Pages router + App router differences)
- Node stdlib (net/http, child_process, vm, fs)

### Frontend
- React (CRA, Vite, Next.js client)
- Vue 3 (Composition + Options API, Nuxt)
- Angular (v15+)
- jQuery (legacy)

### ORM/DB
- Sequelize, Prisma, TypeORM, Mongoose, Knex.js

## Generic rules that apply as-is (no TS-specific override needed)

These generic rules from `rules/generic/` apply to TS without specialization because the patterns are language-agnostic enough:
- `01-hardcoded-secret.md` (env vars are language-agnostic)
- `04-idor.md` (logic-level, framework-agnostic)
- `05-slopsquatting.md` (npm-specific patterns are already in generic)
- `06-brute-force.md` (rate-limit middleware is well-named per framework)
- `10-path-traversal.md` (fs ops with user input)
- `12-broken-access-control.md` (route auth)
- `13-weak-password-hashing.md` (crypto API names span languages)
- `16-unrestricted-file-upload.md` (multer, formidable patterns in generic)
- `18-missing-rate-limit.md`, `19-race-condition.md`, `20-outdated-dependency.md`

## Contributing

To improve a TypeScript override:
1. Test on a real TS repo (e.g., clone OWASP Juice Shop)
2. Run `/scan-sec all`
3. Check both: did scan-sec catch real issues? Did it flag any false positives?
4. Update the appropriate file in this folder with new patterns or refined reasoning

To add a new TS-specific rule (rule id not in 21 canonical):
- DON'T add a new id. Map your new patterns into one of the 21 canonical rules.
- If truly novel class, open an issue in the scan-sec ecosystem.
