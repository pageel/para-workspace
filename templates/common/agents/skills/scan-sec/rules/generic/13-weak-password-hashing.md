---
id: WEAK-PASSWORD-HASHING
severity_max: CRITICAL
applies_to: all
---

# Weak Password Hashing

## Intent

Lưu password dưới dạng plain text, MD5, SHA1, hoặc SHA256 không salt. Khi DB bị leak (mà DB **luôn luôn bị leak** sớm muộn), hacker dùng **rainbow table** crack MD5/SHA1 trong vài giây — toàn bộ password user bị lộ. User thường dùng cùng password cho nhiều site, nên leak DB của bạn = leak Gmail/bank của họ.

Password phải hash bằng **bcrypt / argon2 / scrypt** với cost factor đủ cao (chậm có chủ đích để chống brute-force GPU).

## Khi nào CRITICAL

- Password lưu plain text (so sánh `==` không qua hash)
- Hash bằng MD5 / SHA1 / SHA256 / SHA512 thô (không salt, không slow KDF)
- Custom hash `sha256(salt + password)` — vẫn nhanh, GPU crack được
- Salt hardcoded chung cho mọi user (`salt = "mysalt"`)
- bcrypt cost factor quá thấp (`bcrypt.hashSync(pwd, 4)` — nên ≥ 10)

## Khi nào HIGH (giảm cấp)

- bcrypt cost 8-9 (chấp nhận được nhưng nên tăng)
- Hash bằng PBKDF2 với iteration count < 100k (nên ≥ 600k theo OWASP 2023)
- Dùng SHA256 nhưng có HMAC + per-user salt (vẫn yếu hơn argon2 nhưng đỡ)

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Grep** tìm pattern hash crypto liên quan đến password
2. **Read** đoạn signup/login để xác nhận:
   - Variable name có chứa `password`, `pwd`, `pass` không?
   - Function được gọi để **hash khi register** và **verify khi login**?
3. **Trace**:
   - L1: password user nhập (plain)
   - Phải qua hashing function → L4 (lưu vào DB)
   - Nếu compare `password == user.password` (plain) → CRITICAL
4. **Đặc biệt**: kiểm tra password reset flow — nhiều khi register dùng bcrypt nhưng reset password lại lưu plain

## Search patterns (gợi ý — KHÔNG chạy literal, dùng Grep tool)

### Hash functions yếu

```
# Node.js
crypto\.createHash\s*\(\s*["'](md5|sha1|sha256|sha512)["']
require\s*\(\s*["']md5["']\s*\)

# Python
hashlib\.(md5|sha1|sha256|sha512)\s*\(
import\s+md5

# PHP
\bmd5\s*\(|\bsha1\s*\(|hash\s*\(\s*["'](md5|sha1|sha256)["']

# Go
md5\.Sum|sha1\.Sum|sha256\.Sum

# Ruby
Digest::(MD5|SHA1|SHA256)\.hexdigest
```

### Password-specific

```
password\s*==\s*       # so sánh plain text
\.password\s*=\s*req\.body\.password   # lưu plain
```

### Hash KDF tốt (KHÔNG flag)

```
bcrypt\.(hash|compare|hashSync|compareSync)
argon2\.(hash|verify)
scrypt\.|crypto\.scrypt
PasswordHasher|werkzeug\.security\.(generate_password_hash|check_password_hash)
Devise|BCrypt::Password
password_hash\s*\(\s*\$?\w+,\s*PASSWORD_(DEFAULT|BCRYPT|ARGON2)
```

## Examples

### CRITICAL — flag

```javascript
// Express signup — MD5
const crypto = require('crypto');
const hash = crypto.createHash('md5').update(req.body.password).digest('hex');
await db.users.insert({ email, password: hash });
```

```python
# Django custom user — SHA256 thô
import hashlib
def set_password(self, raw):
    self.password = hashlib.sha256(raw.encode()).hexdigest()
```

```php
// Login — plain text compare
$user = $db->query("SELECT * FROM users WHERE email='$email'")->fetch();
if ($user['password'] === $_POST['password']) {  // plain text
    $_SESSION['user'] = $user;
}
```

```python
# Salt hardcoded chung cho mọi user
SALT = "myapp_salt_2024"
hash = hashlib.sha256((SALT + password).encode()).hexdigest()
```

### NOT critical — không flag

```javascript
// bcrypt với cost mặc định 10
const bcrypt = require('bcrypt');
const hash = await bcrypt.hash(password, 12);
// login:
const ok = await bcrypt.compare(req.body.password, user.password);
```

```python
# Django dùng built-in (PBKDF2 với iteration cao)
from django.contrib.auth.hashers import make_password, check_password
user.password = make_password(raw_password)
```

```python
# argon2 — recommended
from argon2 import PasswordHasher
ph = PasswordHasher()
hash = ph.hash(password)
ph.verify(hash, password)
```

## Fix recommendation

1. **Chuyển sang bcrypt / argon2 / scrypt** với cost phù hợp:
   ```javascript
   // Node.js
   const bcrypt = require('bcrypt');
   const hash = await bcrypt.hash(password, 12);  // cost 12, ~250ms
   ```
   ```python
   # Python
   from argon2 import PasswordHasher
   ph = PasswordHasher(time_cost=3, memory_cost=65536, parallelism=4)
   ```
   ```php
   // PHP — built-in
   $hash = password_hash($pwd, PASSWORD_ARGON2ID);
   password_verify($pwd, $hash);
   ```
2. **Migration cho user cũ**: lúc user login lần kế tiếp, re-hash với algorithm mới và update DB. Không cần force reset password.
3. **Per-user random salt** — các thư viện trên tự sinh và lưu kèm hash (không cần tự làm).
4. **Cost calibration**: chọn cost sao cho hash mất ~250ms trên server production (cân bằng UX vs anti-brute-force).
5. **Pepper** (tùy chọn): thêm secret server-side ngoài salt — leak DB không đủ crack, cần leak cả config.

## Cross-references

- Cross-check với `01-hardcoded-secret`: pepper / encryption key cho password store
- Cross-check với `12-broken-access-control`: leak password list qua admin endpoint không có auth
- Cross-check với `06-brute-force-login` (nếu có rule): rate-limit login endpoint
