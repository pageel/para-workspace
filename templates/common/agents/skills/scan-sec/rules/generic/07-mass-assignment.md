---
id: MASS-ASSIGNMENT
severity_max: CRITICAL
applies_to: all
---

# Mass Assignment

## Intent

Endpoint nhận `req.body` rồi **spread/merge toàn bộ vào model/DB** không lọc field. Attacker thêm field `is_admin: true`, `role: "admin"`, `balance: 999999`, `email_verified: true`, `user_id: 1` vào JSON request — **tự nâng quyền lên admin, đổi tiền, đổi owner, bypass verify email**.

Vibe code cực dính vì AI hay viết `Object.assign(user, req.body)` / `User.create(**request.json)` cho "ngắn gọn". Đây là một dạng của Broken Access Control trong OWASP Top 10.

## Khi nào CRITICAL

- Endpoint dùng `Object.assign(model, req.body)`, `{...model, ...req.body}`, `new Model(req.body)`, `Model.create(**request.json)` mà KHÔNG có whitelist
- Model chứa field nhạy cảm: `is_admin`, `role`, `permissions`, `user_id`, `owner_id`, `balance`, `verified`, `is_staff`, `is_superuser`
- Endpoint accessible cho user thường (không phải admin-only)

## Khi nào HIGH (giảm cấp)

- Endpoint admin-only (có check role) — vẫn rủi ro nếu admin nhập nhầm hoặc bị compromise
- Model không có field nguy hiểm (chỉ có `name`, `bio`, `avatar`...) — nhưng vẫn nên whitelist

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Grep** các pattern spread/merge body (xem dưới)
2. **Read** function: model được tạo/update là gì? Có những field nào?
3. **Trace** field model: schema có field nào nguy hiểm? (xem migration, schema.prisma, models.py)
4. **Verify whitelist**:
   - Express/Mongoose: có dùng `pick(req.body, [...])` (lodash) không?
   - Rails: có dùng `params.require(:user).permit(:name, :email)` không?
   - Laravel: model có `$fillable` hoặc `$guarded` không?
   - Django: có dùng `ModelForm` / serializer `fields = [...]` không?
5. Endpoint PATCH/PUT thường nguy hiểm hơn POST vì update existing record.

## Search patterns (gợi ý — KHÔNG chạy literal, dùng Grep tool)

### Express / Node

```
Object\.assign\s*\(\s*[a-zA-Z_]+\s*,\s*req\.body
\.\.\.req\.body                                      # spread trong object
new\s+\w+\s*\(\s*req\.body\s*\)                      # mongoose new Model(req.body)
\.create\s*\(\s*req\.body\s*\)                       # Sequelize / Prisma / Mongoose
\.update\s*\(\s*req\.body\s*\)
\.findByIdAndUpdate\s*\([^,]+,\s*req\.body
```

### Python (Django / Flask / FastAPI)

```
Model\(\*\*request\.(json|form|data)\)
\.objects\.create\s*\(\s*\*\*request\.
setattr\s*\(\s*\w+\s*,\s*key\s*,\s*value\s*\)        # iterate qua request.json
for\s+k\s*,\s*v\s+in\s+request\.json\.items
```

### Ruby on Rails

```
\.update\s*\(\s*params\[:\w+\]\s*\)\s*$              # KHÔNG có .permit
\.new\s*\(\s*params\[:\w+\]\s*\)\s*$
\.create\s*\(\s*params\[:\w+\]\s*\)\s*$
```

### PHP / Laravel

```
->fill\s*\(\s*\$request->all\(\)\s*\)
::create\s*\(\s*\$request->all\(\)\s*\)
::update\s*\(\s*\$request->all\(\)\s*\)
```

## Examples

### CRITICAL — flag

```javascript
// Express + Mongoose — bất kỳ ai cũng tự thành admin
app.patch("/api/users/me", requireAuth, async (req, res) => {
  const user = await User.findById(req.user.id);
  Object.assign(user, req.body);   // L1 → toàn bộ field, kể cả isAdmin
  await user.save();
  res.json(user);
});
// Attacker: PATCH /api/users/me { "isAdmin": true }
```

```python
# Flask — tạo user kèm role
@app.route("/api/users", methods=["POST"])
def create_user():
    user = User(**request.json)   # L1 spread vào model
    db.session.add(user)
    db.session.commit()
    return jsonify(user.to_dict())
# Attacker: POST {"username":"x","password":"x","role":"admin"}
```

```ruby
# Rails — KHÔNG có strong params
def update
  @user = User.find(params[:id])
  @user.update(params[:user])   # mass assign — admin field lọt
end
```

```php
<?php
// Laravel — không có $fillable
class User extends Model {}
// Controller
public function store(Request $request) {
    User::create($request->all());   // is_admin lọt qua
}
```

```javascript
// Prisma
await prisma.user.update({
  where: { id: req.user.id },
  data: req.body,   // ! toàn bộ body
});
```

### NOT critical — không flag (hoặc downgrade)

```javascript
// Express — whitelist với lodash.pick
import { pick } from "lodash";
app.patch("/api/users/me", requireAuth, async (req, res) => {
  const updates = pick(req.body, ["name", "bio", "avatar"]);
  const user = await User.findByIdAndUpdate(req.user.id, updates, { new: true });
  res.json(user);
});
```

```python
# FastAPI Pydantic — schema lọc tự động
class UserUpdate(BaseModel):
    name: str | None = None
    bio: str | None = None
    # KHÔNG khai báo role / is_admin — bị reject

@app.patch("/api/users/me")
def update_me(data: UserUpdate, user: User = Depends(current_user)):
    for k, v in data.dict(exclude_unset=True).items():
        setattr(user, k, v)
```

```ruby
# Rails strong params
def update
  @user.update(user_params)
end
private
def user_params
  params.require(:user).permit(:name, :bio, :avatar)
end
```

```php
<?php
// Laravel với $fillable
class User extends Model {
    protected $fillable = ['name', 'email', 'bio'];   // role KHÔNG trong list
}
```

## Fix recommendation

1. **Whitelist field rõ ràng** (allow-list, không phải deny-list):
   ```javascript
   import { pick } from "lodash";
   const ALLOWED = ["name", "bio", "avatar"];
   const updates = pick(req.body, ALLOWED);
   ```
2. **Dùng DTO / schema validation**:
   - FastAPI: Pydantic model
   - NestJS: class-validator + `whitelist: true, forbidNonWhitelisted: true`
   - Joi / Zod / Yup ở Express
   - Marshmallow ở Flask
3. **Framework convention**:
   - Rails: `params.require(:x).permit(:a, :b)` luôn luôn
   - Laravel: `$fillable` array ở mọi model
   - Django: `ModelForm` / serializer `fields = [...]`
4. **Tách endpoint update profile vs update role**:
   - `PATCH /api/users/me` — chỉ field user tự sửa
   - `PATCH /api/admin/users/:id/role` — admin-only endpoint
5. **Audit log**: ghi lại request body khi update field nhạy cảm (role, balance) để detect.

## Cross-references

- Rule `04-idor`: mass assignment + IDOR = đổi owner của resource người khác
- Rule `02-sql-injection`: cùng họ "trust input", khác sink
- Rule `17-verbose-error-debug-mode`: validation error lộ tên field hidden
