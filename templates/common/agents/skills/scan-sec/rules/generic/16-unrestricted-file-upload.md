---
id: UNRESTRICTED-FILE-UPLOAD
severity_max: CRITICAL
applies_to: all
---

# Unrestricted File Upload

## Intent

Endpoint upload không validate → hacker upload `shell.php` vào thư mục webroot, sau đó browse `https://yourapp.com/uploads/shell.php?cmd=cat+/etc/passwd` → **RCE (remote code execution)** chiếm server. Hoặc upload `evil.svg` chứa JavaScript → XSS khi user khác xem. Hoặc upload file siêu lớn → out-of-disk DoS.

Vibe coder dùng `multer` / `formidable` / `move_uploaded_file` mà không check extension, content-type, magic bytes, và lưu thẳng vào public folder.

## Khi nào CRITICAL

- Upload endpoint **không validate** extension HOẶC content-type
- File lưu trong webroot (thư mục được serve trực tiếp như `/public`, `/static`, `/uploads`) **và** server execute được code (PHP, JSP, etc.)
- Filename giữ nguyên từ client → path traversal (`../../etc/passwd`)
- Không giới hạn size → DoS

## Khi nào HIGH (giảm cấp)

- Có check extension nhưng dựa vào client-supplied `filename` (dễ bypass)
- File lưu trong static folder nhưng server không execute (Node serving static, không có handler PHP) — vẫn risk XSS qua SVG/HTML
- Có content-type check nhưng dùng client-supplied header (giả mạo dễ)

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Grep** tìm upload handler theo framework
2. **Read** handler:
   - Có whitelist extension không? List nào? (PHP, JSP, ASPX phải block)
   - Có check magic bytes (file signature) không?
   - Filename: dùng client-supplied hay generate random?
   - Lưu vào đâu? Webroot? Static-served folder?
3. **Trace**:
   - L1: `req.file`, `request.FILES`, `$_FILES`
   - File đi đâu? Có serve lại public không?
4. **Server execution context**: PHP/Apache execute mọi file `.php`. Nginx serve tĩnh đa số an toàn (nhưng SVG vẫn XSS được).

## Search patterns (gợi ý — KHÔNG chạy literal, dùng Grep tool)

### Node.js

```
require\s*\(\s*["']multer["']
multer\s*\(\s*\{
formidable
fs\.(writeFile|writeFileSync|createWriteStream)\s*\(.*req\.
```

### Python

```
# Django
forms\.FileField|FileField\(
request\.FILES\[
# Flask
request\.files\[
# secure_filename — nếu KHÔNG dùng → flag
secure_filename
```

### PHP

```
\$_FILES\[
move_uploaded_file\s*\(
file_put_contents\s*\(.*\$_(FILES|POST)
```

### Generic

```
upload|Upload|UPLOAD
saveAs|save_as|writeFile
multipart/form-data
```

## Examples

### CRITICAL — flag

```javascript
// Express + multer — không filter
const multer = require('multer');
const upload = multer({ dest: 'public/uploads/' });  // webroot!
app.post('/upload', upload.single('file'), (req, res) => {
  res.json({ url: '/uploads/' + req.file.filename });
});
// User upload shell.php → GET /uploads/shell.php execute trên Apache/Nginx+PHP
```

```php
// PHP — giữ nguyên filename, không check
<?php
$target = "uploads/" . basename($_FILES["file"]["name"]);
move_uploaded_file($_FILES["file"]["tmp_name"], $target);
// upload evil.php → uploads/evil.php execute
?>
```

```python
# Flask — dùng filename từ client
@app.route('/upload', methods=['POST'])
def upload():
    f = request.files['file']
    f.save(os.path.join('static/uploads', f.filename))   # path traversal + no extension check
    return 'OK'
```

```python
# Django form không validate
class UploadForm(forms.Form):
    file = forms.FileField()   # accept tất cả
# view: f = form.cleaned_data['file']; save_to('public/', f.name)
```

### NOT critical — không flag

```javascript
// multer với fileFilter + random filename + storage ngoài webroot
const upload = multer({
  dest: '/var/app/uploads/',   // KHÔNG trong public
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowed = ['image/jpeg', 'image/png'];
    cb(null, allowed.includes(file.mimetype));
  },
  filename: (req, file, cb) => {
    cb(null, crypto.randomUUID() + path.extname(file.originalname));
  }
});
// + Đọc magic bytes sau khi upload để confirm thật là image
```

```python
# Django — kiểm tra extension + content-type + magic
from django.core.exceptions import ValidationError
def validate_image(f):
    if f.content_type not in ['image/jpeg', 'image/png']:
        raise ValidationError('Invalid type')
    if f.size > 5_000_000:
        raise ValidationError('Too big')
    # check magic
    head = f.read(8); f.seek(0)
    if not (head.startswith(b'\xff\xd8') or head.startswith(b'\x89PNG')):
        raise ValidationError('Magic mismatch')
```

## Fix recommendation

1. **Whitelist extension** (allow list, không deny list):
   ```javascript
   const ALLOWED = new Set(['.jpg', '.jpeg', '.png', '.webp']);
   const ext = path.extname(file.originalname).toLowerCase();
   if (!ALLOWED.has(ext)) throw new Error('extension not allowed');
   ```
2. **Verify magic bytes** (file signature) — đừng tin extension/content-type:
   ```python
   import magic
   mime = magic.from_buffer(f.read(2048), mime=True); f.seek(0)
   if mime not in ALLOWED_MIME: raise
   ```
3. **Random filename**, không giữ filename client:
   ```javascript
   const safeName = crypto.randomUUID() + ext;
   ```
4. **Lưu ngoài webroot**, serve qua signed URL hoặc proxy controller:
   ```
   /var/app/uploads/  (filesystem)
   → GET /files/:id  → controller check auth → stream file
   ```
5. **Giới hạn size** ở middleware (`limits`, `client_max_body_size`)
6. **Object storage** (S3, GCS, R2): upload thẳng lên bucket, không qua server. Set bucket non-public.
7. **Scan virus** với ClamAV nếu user public (tải về xem được).
8. **Disable execution** trong upload folder: `.htaccess` `RemoveHandler .php` hoặc Nginx `location ~ \.php$ { return 403; }`

## Cross-references

- Cross-check với `04-path-traversal` (nếu có): filename `../../etc/passwd`
- Cross-check với `12-broken-access-control`: ai cũng upload được, hay chỉ user?
- Cross-check với `18-missing-rate-limit`: upload spam = DoS disk
