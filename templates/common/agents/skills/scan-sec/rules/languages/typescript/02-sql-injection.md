---
id: SQL-INJECTION
severity_max: CRITICAL
applies_to: typescript
---

# SQL Injection — TypeScript/JavaScript Specialization

> Override cho rule chung `rules/generic/02-sql-injection.md`. Áp dụng khi `primary_language: typescript`.

## Intent (TypeScript-specific)

Node.js ecosystem có **rất nhiều ORM/query layer** (Sequelize, Prisma, TypeORM, Mongoose, Knex) và mỗi cái có một số API "raw" mà vibe code rất dễ dùng sai. Đặc biệt **template literal** (\`SELECT ... ${userInput}\`) trông giống parameterized nhưng KHÔNG phải — vẫn là string concat. Ngoài SQL truyền thống, Node còn có **NoSQL injection** với Mongoose (`$where`, operator injection qua `req.body`) — class lỗ hổng riêng nhưng cùng family.

## Khi nào CRITICAL

- Sequelize `sequelize.query(\`... ${input}\`)` hoặc `sequelize.query("... " + input)` không có `replacements`/`bind`
- Prisma `prisma.$queryRawUnsafe(userInput)` — API tên là "Unsafe" mà vẫn dùng với L1
- TypeORM `repo.query("... " + input)` hoặc `manager.query` với string concat
- Mongoose `$where: 'this.x == ' + input` — NoSQL injection có thể RCE qua JS execution trong Mongo
- Mongoose operator injection: `User.findOne({ email: req.body.email })` khi `req.body.email = { $ne: null }` → trả về user đầu tiên
- Knex `knex.raw("... " + input)`
- Endpoint public (Express, Fastify, Next.js API route, NestJS controller không có `@UseGuards`)

## Khi nào HIGH (giảm cấp)

- Input từ env/config (L3) không phải request
- Whitelist regex chặt (vd: `/^[a-z_]+$/.test(col)`) trước concat — chấp nhận cho ORDER BY/tên cột
- Endpoint chỉ admin với guard rõ ràng (`@UseGuards(AdminGuard)`, middleware verify role)
- Mongoose có schema strict + cast type trước query (`String(req.body.email)`)

## Cách reasoning

1. **Grep** các sink: `\.query\(`, `\$queryRaw`, `\$queryRawUnsafe`, `\.raw\(`, `\$where`, `\.execute\(`
2. **Read** handler/service chứa call: trace biến từ:
   - Express: `req.body`, `req.query`, `req.params`, `req.cookies`, `req.headers`
   - Fastify: `request.body`, `request.query`, `request.params`
   - Next.js Pages API: `req.body`, `req.query`
   - Next.js App Router: `request.json()`, `searchParams`, `params`
   - NestJS: `@Body()`, `@Query()`, `@Param()`, `@Headers()` decorator args
3. **Trace L1→sink**:
   - L1 = trực tiếp từ HTTP request
   - L2 = đọc từ DB rồi dùng lại trong query khác (stored injection)
   - L3 = env var / config file
   - L4 = constant trong code
4. **Verify**:
   - Sequelize có `{ replacements: { id }, type: QueryTypes.SELECT }`?
   - Prisma có dùng `prisma.$queryRaw\`... ${Prisma.sql\`${value}\`}\`` đúng cách? Hay `$queryRawUnsafe`?
   - Mongoose có cast `String(input)` hoặc validate schema kiểu trước query?

## Search patterns

```
# Sequelize raw query
sequelize\.query\s*\(\s*`[^`]*\$\{
sequelize\.query\s*\(\s*["'][^"']*["']\s*\+
\.query\s*\(\s*`[^`]*\$\{[^}]*req\.

# Prisma unsafe
\$queryRawUnsafe\s*\(
\$executeRawUnsafe\s*\(
# Prisma $queryRaw VỚI interpolation thường (KHÔNG dùng Prisma.sql) cũng nguy:
\$queryRaw\s*`[^`]*\$\{[^}]*\}[^`]*`   # cần verify có Prisma.sql wrap không

# TypeORM
repository\.query\s*\(\s*["'][^"']*["']\s*\+
manager\.query\s*\(\s*`[^`]*\$\{
createQueryBuilder\(\)[^.]*\.where\s*\(\s*["'][^"']*["']\s*\+

# Mongoose NoSQL injection
\$where\s*:\s*["'`]
\.find\s*\(\s*\{[^}]*:\s*req\.(body|query|params)\.
\.findOne\s*\(\s*req\.body\s*\)    # operator injection

# Knex raw
knex\.raw\s*\(\s*["'][^"']*["']\s*\+
\.whereRaw\s*\(\s*["'][^"']*["']\s*\+

# Mass-pattern: template literal trong query API
\.(query|execute|exec|raw)\s*\(\s*`[^`]*\$\{
```

## Examples

### CRITICAL — flag

```typescript
// Sequelize + Express — template literal concat
app.get('/users/:id', async (req, res) => {
  const id = req.params.id;  // L1
  const [users] = await sequelize.query(
    `SELECT * FROM users WHERE id = ${id}`
  );
  res.json(users);
});
// Exploit: GET /users/1 OR 1=1 -- → dump all
```

```typescript
// Prisma $queryRawUnsafe với user input
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const name = searchParams.get('name');  // L1
  const result = await prisma.$queryRawUnsafe(
    `SELECT * FROM users WHERE name = '${name}'`
  );
  return Response.json(result);
}
```

```typescript
// TypeORM query string concat
@Get('search')
async search(@Query('q') q: string) {  // L1
  return this.dataSource.query(
    "SELECT * FROM products WHERE name LIKE '%" + q + "%'"
  );
}
```

```typescript
// Mongoose NoSQL injection — $where với concat
app.get('/products', async (req, res) => {
  const filter = req.query.filter;  // L1
  // $where chạy JS trong MongoDB — RCE
  const products = await Product.find({
    $where: `this.name == '${filter}'`
  });
});
```

```typescript
// Mongoose operator injection
app.post('/login', async (req, res) => {
  // Attacker body: { "email": {"$ne": null}, "password": {"$ne": null} }
  // → trả về user đầu tiên, bypass auth
  const user = await User.findOne({
    email: req.body.email,
    password: req.body.password,
  });
});
```

### NOT critical — safe

```typescript
// Sequelize parameterized
const users = await sequelize.query(
  'SELECT * FROM users WHERE id = :id',
  { replacements: { id: req.params.id }, type: QueryTypes.SELECT }
);
```

```typescript
// Prisma typed query — safe by design
const users = await prisma.user.findMany({
  where: { email: req.body.email }
});

// Prisma raw có Prisma.sql wrap đúng cách
const r = await prisma.$queryRaw`SELECT * FROM users WHERE id = ${id}`;
// (Prisma tagged template literal tự bind, không phải JS template thường)
```

```typescript
// Mongoose với type cast + schema strict
const email = String(req.body.email);  // ép kiểu chặn $ne
const user = await User.findOne({ email });
```

```typescript
// Whitelist tên cột ORDER BY
const allowed = ['name', 'created_at', 'price'];
const sort = allowed.includes(req.query.sort as string) ? req.query.sort : 'created_at';
const r = await sequelize.query(`SELECT * FROM products ORDER BY ${sort}`);
```

## Fix recommendation

1. **Sequelize**: luôn dùng `replacements` (named) hoặc `bind` (positional):
   ```typescript
   await sequelize.query('SELECT * FROM u WHERE id = :id', {
     replacements: { id },
     type: QueryTypes.SELECT,
   });
   ```
2. **Prisma**: ưu tiên typed API (`findMany`, `findUnique`). Nếu cần raw, dùng `$queryRaw` tagged template — KHÔNG dùng `$queryRawUnsafe` với L1.
3. **TypeORM**: dùng QueryBuilder với `setParameters` hoặc repo methods:
   ```typescript
   repo.createQueryBuilder('u').where('u.name = :name', { name }).getMany();
   ```
4. **Mongoose**:
   - Cast input về primitive: `String(input)`, `Number(input)` trước khi nhét vào filter
   - Bật `mongoose-sanitize` middleware để strip `$`-prefixed keys khỏi `req.body`
   - TRÁNH `$where` hoàn toàn nếu được
5. **Knex**: dùng `.where('col', val)` thay vì `whereRaw` concat. Nếu `whereRaw` cần thiết, truyền binding array: `whereRaw('id = ?', [id])`.
6. **Defense in depth**: DB user least privilege; bật query logging trên dev, tắt trên prod (cross-ref `VERBOSE-ERROR`).

## Cross-references

- TS `03-xss`: input chưa sanitize cũng vào response → XSS
- TS `07-mass-assignment`: `req.body` nguyên xi vào `new Model()` = mass assignment
- TS `17-verbose-error-debug-mode`: Sequelize `logging: console.log` prod leak SQL
- Generic `04-idor`: SQLi + no ownership check = full DB compromise
