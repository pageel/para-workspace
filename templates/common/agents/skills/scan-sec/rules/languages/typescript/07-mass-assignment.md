---
id: MASS-ASSIGNMENT
severity_max: CRITICAL
applies_to: typescript
---

# Mass Assignment — TypeScript/JavaScript Specialization

> Override cho rule chung `rules/generic/07-mass-assignment.md`. Áp dụng khi `primary_language: typescript`.

## Intent (TypeScript-specific)

Node ORM/ODM (Mongoose, Sequelize, TypeORM, Prisma) đều có pattern `Model.create(data)` / `new Model(data).save()` — và `data` thường chính là `req.body`. Nếu schema có field nhạy cảm như `role`, `isAdmin`, `balance`, `verified`, `emailVerified`, `permissions` → attacker thêm field đó vào JSON body, **leo thang quyền chỉ với 1 request**.

Express `app.use(express.json())` parse mọi key trong body — KHÔNG filter gì. NestJS có DTO + class-validator nhưng nếu không bật `whitelist: true` trong `ValidationPipe` thì extra field vẫn pass.

## Khi nào CRITICAL

- `new Model(req.body).save()` hoặc `Model.create(req.body)` với schema có field nhạy cảm (`role`, `isAdmin`, `balance`, `permissions`, `verified`, `emailVerified`, `is_admin`)
- `Model.findByIdAndUpdate(id, req.body)` (Mongoose) hoặc `Model.update(req.body)` (Sequelize) — update với toàn bộ body
- `Object.assign(existingUser, req.body)` rồi `.save()`
- Spread `{ ...req.body }` vào `repo.save()` / `prisma.user.create({ data: ... })`
- NestJS `@Body() body: any` không có DTO + ValidationPipe `{ whitelist: true }`

## Khi nào HIGH (giảm cấp)

- Schema KHÔNG có field nhạy cảm (vd: chỉ có name, email, message — public profile)
- Đã có DTO + `whitelist: true` + `forbidNonWhitelisted: true`
- Đã pick field explicitly: `const { name, email } = req.body`
- Mongoose schema dùng `strict: 'throw'` + field nhạy cảm có `select: false`

## Cách reasoning

1. **Grep** sink: `new \w+\(req`, `\.create\(req`, `findByIdAndUpdate`, `findOneAndUpdate`, `Object\.assign`, `\.\.\.req\.body`
2. **Read** model/schema để xem có field nhạy cảm không
3. **Trace req.body → sink**:
   - Direct: `Model.create(req.body)`
   - Indirect: `const data = req.body` → `Model.create(data)`
   - Spread: `{ ...req.body, createdBy: userId }` — `createdBy` không bảo vệ được nếu attacker gửi `role`
4. **Verify**:
   - Có DTO class với `@IsString()` etc + ValidationPipe whitelist?
   - Có explicit field pick? `pick(req.body, ['name', 'email'])`
   - Mongoose `strict: 'throw'` schema option?
   - Schema có `role` field nhưng route dùng `Model.create({ ...req.body, role: 'user' })` — vẫn bị nếu thứ tự ngược

## Search patterns

```
# Mongoose
new \w+\s*\(\s*req\.(body|query|params)\s*\)
\w+\.create\s*\(\s*req\.body\s*\)
\.findByIdAndUpdate\s*\([^,]+,\s*req\.body
\.findOneAndUpdate\s*\([^,]+,\s*req\.body

# Sequelize
\w+\.create\s*\(\s*req\.body
\w+\.update\s*\(\s*req\.body
\w+\.bulkCreate\s*\(\s*req\.body

# TypeORM
repo\.save\s*\(\s*\{\s*\.\.\.req\.body
repo\.merge\s*\([^,]+,\s*req\.body
repo\.create\s*\(\s*req\.body

# Prisma
prisma\.\w+\.create\s*\(\s*\{\s*data:\s*req\.body
prisma\.\w+\.update\s*\([^)]*data:\s*req\.body

# Object.assign / spread
Object\.assign\s*\([^,]+,\s*req\.(body|query)
\{\s*\.\.\.req\.body\s*\}

# NestJS — DTO bypass dấu hiệu
@Body\(\)\s+\w+\s*:\s*any
@Body\(\)\s+\w+\s*$       # không annotate type
```

## Examples

### CRITICAL — flag

```typescript
// Mongoose — new Model(req.body)
const userSchema = new Schema({
  email: String,
  password: String,
  role: { type: String, default: 'user' },  // ← nhạy cảm
  isAdmin: { type: Boolean, default: false },
});

app.post('/register', async (req, res) => {
  const user = new User(req.body);
  await user.save();
  // Attacker body: {"email":"x@x","password":"x","isAdmin":true}
});
```

```typescript
// Sequelize — Model.create với role field
@Table
class User extends Model {
  @Column email: string;
  @Column password: string;
  @Column role: string;  // ← admin/user
}

app.post('/signup', async (req, res) => {
  const user = await User.create(req.body);  // role có thể được set
});
```

```typescript
// TypeORM — merge req.body
@Put(':id')
async update(@Param('id') id: number, @Body() body: any) {
  const user = await this.repo.findOneBy({ id });
  this.repo.merge(user, body);  // body có thể có { role: 'admin' }
  return this.repo.save(user);
}
```

```typescript
// Prisma — data: req.body
export async function PUT(request: Request) {
  const body = await request.json();
  return prisma.user.update({
    where: { id: body.id },
    data: body,  // role, isAdmin có thể bị set
  });
}
```

```typescript
// NestJS — không có DTO whitelist
@Post()
create(@Body() body: any) {  // ← any cho phép bất kỳ field
  return this.userService.create(body);
}
```

### NOT critical — safe

```typescript
// Explicit field pick
app.post('/register', async (req, res) => {
  const { email, password, name } = req.body;
  const user = await User.create({ email, password, name, role: 'user' });
});
```

```typescript
// NestJS DTO + ValidationPipe whitelist
class CreateUserDto {
  @IsEmail() email: string;
  @IsString() @MinLength(8) password: string;
  @IsString() name: string;
  // KHÔNG có role/isAdmin
}

// main.ts
app.useGlobalPipes(new ValidationPipe({
  whitelist: true,
  forbidNonWhitelisted: true,
}));

@Post()
create(@Body() dto: CreateUserDto) {  // chỉ 3 field
  return this.svc.create(dto);
}
```

```typescript
// Mongoose strict schema + pick
const schema = new Schema({...}, { strict: 'throw' });
// Vẫn nên pick field tin cậy
const allowed = pick(req.body, ['email', 'name']);
await User.create(allowed);
```

```typescript
// zod parse — chỉ field định nghĩa pass qua
const UserInput = z.object({ email: z.string().email(), name: z.string() });
const data = UserInput.parse(req.body);  // strip extra field
await prisma.user.create({ data: { ...data, role: 'user' } });
```

## Fix recommendation

1. **NestJS** (mạnh nhất): bật `whitelist: true` + `forbidNonWhitelisted: true` toàn cục:
   ```typescript
   app.useGlobalPipes(new ValidationPipe({
     whitelist: true,
     forbidNonWhitelisted: true,
     transform: true,
   }));
   ```
   Mọi `@Body() dto: CreateUserDto` chỉ giữ field có trong DTO.

2. **Express/Fastify**: dùng Zod / Yup / Joi để parse, KHÔNG truyền `req.body` thô:
   ```typescript
   const schema = z.object({ email: z.string().email(), name: z.string() });
   const safe = schema.parse(req.body);
   const user = await User.create({ ...safe, role: 'user' });
   ```

3. **Mongoose**: schema với `strict: 'throw'` + field nhạy cảm có `select: false`:
   ```typescript
   const userSchema = new Schema({
     email: String,
     role: { type: String, default: 'user', select: false },
   }, { strict: 'throw' });
   ```
   Update routes: dùng `runValidators: true` + chỉ patch field tin cậy.

4. **Authorization layer riêng**: thay đổi `role` PHẢI qua endpoint admin riêng (`PATCH /admin/users/:id/role`) với guard, không bao giờ qua user-facing update.

5. **Lodash `pick`**: pattern đơn giản nhất:
   ```typescript
   import { pick } from 'lodash';
   const safe = pick(req.body, ['email', 'name']);
   ```

## Cross-references

- TS `02-sql-injection`: NoSQL/SQL injection thường đi đôi với mass assignment trong Mongoose
- TS `12-broken-access-control` (generic): mass assignment LÀ một dạng leo quyền nếu field `role`/`isAdmin` lộ
- Generic `04-idor`: cập nhật user khác + mass assign role = IDOR + privilege escalation
