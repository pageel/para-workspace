---
id: MASS-ASSIGNMENT
severity_max: CRITICAL
applies_to: python
---

# Mass Assignment — Python Specialization

> Override cho rule chung `rules/generic/07-mass-assignment.md`. Áp dụng khi `primary_language: python`.

## Intent (Python-specific)

Vibe code Python rất hay viết `User(**request.json)` hoặc `ModelForm` với `fields = '__all__'` — thay vì khai báo whitelist field nhận từ client, code đẩy nguyên payload vào model. Attacker thêm field như `is_staff: true`, `is_superuser: true`, `role: "admin"`, `balance: 999999`, `user_id: 1` → leo quyền hoặc chỉnh dữ liệu user khác. Trên Django đặc biệt nguy vì `User` model có sẵn `is_superuser`. Trên FastAPI Pydantic mặc định `extra="ignore"` (SAFE) nhưng vibe code thường override thành `"allow"` để "linh hoạt".

## Khi nào CRITICAL

- Django `ModelForm` với `fields = '__all__'` hoặc `exclude = []` rỗng
- Django `Model(**request.POST)` / `Model.objects.create(**request.POST)`
- Django `queryset.update(**request.POST)` / `.filter(...).update(**request.data)`
- Flask + SQLAlchemy: `User(**request.json)` rồi `db.session.commit()`
- FastAPI/Pydantic: `Config.extra = "allow"` HOẶC nhận `dict` thay vì `BaseModel`
- Model có field nhạy: `is_admin`, `is_staff`, `is_superuser`, `role`, `permissions`, `balance`, `owner_id`, `user_id`, `tenant_id`
- Endpoint public (không guard) hoặc user-level (chứ không phải admin-only)

## Khi nào HIGH (giảm cấp)

- Form/Pydantic có `fields = ['name', 'email']` whitelist rõ ràng nhưng thiếu vài field cần
- Endpoint admin-only với decorator `@user_passes_test(is_staff)` rõ ràng
- Model không có field nhạy (chỉ `title`, `content`)
- `**request.json` nhưng có `pop()` các field nhạy trước (vd: `data.pop('is_admin', None)`)

## Cách reasoning

1. **Grep** sink: `\*\*request\.`, `Model\(\*\*`, `\.create\(\*\*`, `\.update\(\*\*`, `fields\s*=\s*['"]__all__['"]`, `extra\s*=\s*["']allow["']`
2. **Read** view/handler, xác định model nhận data
3. **Inspect model**: model có field nhạy không? Chạy `grep -E "(is_admin|is_staff|is_superuser|role|balance)" models.py`
4. **Trace source**: dict nhận từ `request.json`/`request.POST`/`request.data` (L1) hay đã filter qua serializer/form whitelist?
5. **Verify**:
   - DRF: `serializer.fields` có whitelist rõ?
   - Pydantic: model có `extra="forbid"` hay `"ignore"`?
   - Django form: `Meta.fields` liệt kê cụ thể?

## Search patterns

```
# Django ModelForm vô whitelist
fields\s*=\s*['"]__all__['"]
exclude\s*=\s*\[\s*\]
exclude\s*=\s*\(\s*\)

# Spread request data vào model
\*\*request\.(POST|GET|data|json)
\*\*request\.(POST|GET|data|json)\.(dict|copy)
Model\(\s*\*\*
\.objects\.create\s*\(\s*\*\*
\.objects\.filter\([^)]*\)\.update\s*\(\s*\*\*

# Flask/SQLAlchemy
\w+\(\s*\*\*request\.(json|form|values)
db\.session\.add\s*\([^)]*\*\*

# FastAPI/Pydantic - extra="allow"
extra\s*=\s*["']allow["']
class\s+Config\s*:[^}]*extra\s*=\s*["']allow["']
model_config\s*=\s*ConfigDict\([^)]*extra\s*=\s*["']allow["']

# Nhận dict thay vì BaseModel
async\s+def\s+\w+\s*\([^)]*:\s*dict\s*[,)]
def\s+\w+\s*\([^)]*=\s*Body\(\.\.\.\)\s*\)\s*->\s*

# setattr loop từ request
for\s+\w+\s*,\s*\w+\s+in\s+request\.(POST|data|json)\.items\(\)\s*:[^:]*setattr
```

## Examples

### CRITICAL — flag

```python
# Django ModelForm fields='__all__' — bao gồm is_staff, is_superuser
from django.contrib.auth.models import User
from django.forms import ModelForm

class UserForm(ModelForm):
    class Meta:
        model = User
        fields = '__all__'  # Attacker POST is_staff=1 → admin

def update_profile(request):
    form = UserForm(request.POST, instance=request.user)
    if form.is_valid():
        form.save()
```

```python
# Flask + SQLAlchemy spread
@app.post('/users')
def create_user():
    user = User(**request.json)  # body: {"email": "x", "is_admin": true}
    db.session.add(user)
    db.session.commit()
    return jsonify(id=user.id)
```

```python
# Django queryset.update bulk từ request
@require_POST
def edit_account(request, account_id):
    Account.objects.filter(id=account_id).update(**request.POST.dict())
    # Attacker POST balance=999999&owner_id=1 → chiếm account
```

```python
# FastAPI Pydantic extra="allow"
class UserUpdate(BaseModel):
    name: str
    email: str
    model_config = ConfigDict(extra="allow")  # cho phép is_admin lọt

@app.post('/users/{uid}')
async def update(uid: int, data: UserUpdate):
    user = await get_user(uid)
    for field, value in data.model_dump().items():
        setattr(user, field, value)
    await user.save()
```

```python
# FastAPI nhận dict — bỏ qua type checking
@app.post('/profile')
async def update_profile(data: dict, current_user=Depends(get_user)):
    for k, v in data.items():
        setattr(current_user, k, v)  # data có thể chứa is_superuser
    await current_user.save()
```

### NOT critical — không flag

```python
# Django ModelForm whitelist rõ
class UserForm(ModelForm):
    class Meta:
        model = User
        fields = ['first_name', 'last_name', 'email']  # explicit
```

```python
# FastAPI Pydantic strict (mặc định, hoặc explicit forbid)
class UserUpdate(BaseModel):
    name: str
    email: EmailStr
    model_config = ConfigDict(extra="forbid")
    # Pydantic reject nếu có field thừa

@app.post('/users/{uid}')
async def update(uid: int, data: UserUpdate):
    user = await get_user(uid)
    user.name = data.name
    user.email = data.email
    await user.save()
```

```python
# Whitelist + pop trường nhạy
SAFE = {'name', 'email', 'bio'}
clean = {k: v for k, v in request.json.items() if k in SAFE}
user = User(**clean)
```

```python
# Django REST Framework serializer whitelist
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['username', 'email']  # explicit, không '__all__'
        read_only_fields = ['is_staff', 'is_superuser']
```

## Fix recommendation

1. **Django form/serializer** — luôn whitelist `fields = ['a', 'b']`, không bao giờ `'__all__'`:
   ```python
   class UserForm(ModelForm):
       class Meta:
           model = User
           fields = ['first_name', 'last_name', 'email']
   ```
2. **Pydantic** — `extra="forbid"` cho update endpoint, KHÔNG `"allow"`:
   ```python
   class UserUpdate(BaseModel):
       model_config = ConfigDict(extra="forbid")
       name: str | None = None
       email: EmailStr | None = None
   ```
3. **Không bao giờ** `Model(**request.json)` thẳng. Validate qua schema trước:
   ```python
   data = UserUpdateSchema(**request.json).model_dump(exclude_unset=True)
   user = User(**data)
   ```
4. **Bulk update** — chỉ định field rõ:
   ```python
   # BAD
   Account.objects.filter(id=aid).update(**request.POST)
   # GOOD
   Account.objects.filter(id=aid).update(name=request.POST['name'])
   ```
5. **DRF**: `read_only_fields = ['is_staff', 'is_superuser', 'role']` trong Meta.
6. **Defense**: kết hợp với rule `04-idor` (kiểm tra ownership): `user_id` không được set từ request.

## Cross-references

- Python `02-sql-injection`: `.filter(**dict)` từ request = cùng họ với SQLi operator injection
- Generic `04-idor`: mass assignment + thiếu owner check = chiếm tài khoản người khác
- Generic `12-broken-access-control`: lý do tận cùng là không tách biệt admin-field vs user-field
