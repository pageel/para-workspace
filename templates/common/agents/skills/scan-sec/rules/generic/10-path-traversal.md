---
id: PATH-TRAVERSAL
severity_max: HIGH
applies_to: all
---

# Path Traversal

## Intent

Code thao tác file với path chứa user input (L1). Attacker truyền `../../../../etc/passwd`, `..\\..\\Windows\\System32\\drivers\\etc\\hosts`, hoặc absolute path `/etc/shadow` để **đọc file hệ thống, ghi đè config, leak source code, đọc `.env`, đọc private key SSH** — từ đó lateral move hoặc chiếm server.

Vibe code dính khi AI sinh code "download/preview file theo tên" mà ghép tên trực tiếp vào path.

## Khi nào HIGH

- L1 input đi vào file API: `open`, `fs.readFile`, `fs.createReadStream`, `file_get_contents`, `fopen`, `os.path.join`, `Path()` mà KHÔNG normalize + check prefix
- Endpoint trả về nội dung file (đọc) hoặc cho phép upload/ghi file với tên user-supplied
- Có thể đọc file ngoài thư mục được phép

## Khi nào MEDIUM (giảm cấp)

- Có chmod chặn ở mức OS (user app chỉ đọc được 1 dir) — vẫn nên có check ở app
- Filename đã được validate regex chặt (`^[a-zA-Z0-9_-]+\.(jpg|png)$`)
- Endpoint require admin

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Grep** các file API (xem dưới)
2. **Read** function: path xây từ đâu, ghép như nào?
3. **Trace** L1-L4:
   - `req.query.filename`, `req.params.path`, `request.args["file"]`, form upload `filename` → L1
   - Database stored filename (do user upload trước đó) → L1 stored (có thể là `../../`)
4. **Verify mitigation**:
   - Có `path.resolve()` / `os.path.realpath()` rồi check `startsWith(baseDir)` không?
   - Có check `..` / null byte / encoded `%2e%2e%2f` không?
   - Có whitelist filename regex không?
5. Trên Windows chú ý: `\\`, `C:\`, `\\?\` prefix, alternate stream `file.txt:hidden`.

## Search patterns (gợi ý — KHÔNG chạy literal, dùng Grep tool)

### JS/Node

```
fs\.(readFile|readFileSync|createReadStream|writeFile|unlink)\s*\(\s*[^"'`]
path\.join\s*\(\s*[^"'`,]+,\s*req\.
res\.sendFile\s*\(\s*[^"']*req\.
res\.download\s*\(\s*[^"']*req\.
express\.static\s*\(\s*req\.
```

### Python

```
open\s*\(\s*[^"']+(\+|f["']|%|format)
open\s*\(\s*request\.
send_file\s*\(\s*request\.
os\.path\.join\s*\([^)]*request\.
pathlib\.Path\s*\(\s*request\.
```

### PHP

```
file_get_contents\s*\(\s*\$_(GET|POST|REQUEST)
fopen\s*\(\s*\$_(GET|POST|REQUEST)
readfile\s*\(\s*\$_(GET|POST|REQUEST)
include\s*\(\s*\$_(GET|POST|REQUEST)        # cực nguy hiểm — LFI → RCE
require\s*\(\s*\$_(GET|POST|REQUEST)
```

### Encoded payloads (regression test)

```
\.\./|\.\.\\
%2e%2e%2f|%2e%2e/|%252e
\\x00|%00                                    # null byte
```

## Examples

### HIGH — flag

```javascript
// Express — đọc file theo tên user nhập
app.get("/download", (req, res) => {
  const file = path.join("/var/uploads", req.query.name);   // L1
  res.sendFile(file);
});
// Attacker: GET /download?name=../../etc/passwd
```

```python
# Flask
@app.route("/read")
def read():
    filename = request.args.get("f")        # L1
    with open(f"./data/{filename}") as fp:  # ../../etc/passwd
        return fp.read()
```

```php
<?php
// LFI cổ điển → có thể RCE qua log poisoning
$page = $_GET['page'];
include("./pages/" . $page . ".php");   // ?page=../../../../var/log/apache2/access
```

```javascript
// Static file với prefix user
app.use("/static", express.static(req.query.dir));   // !!! cực nguy hiểm
```

```python
# Lưu file upload với tên gốc
@app.route("/upload", methods=["POST"])
def upload():
    f = request.files["file"]
    f.save(f"./uploads/{f.filename}")   # filename có thể là "../../etc/cron.d/x"
```

### NOT high — không flag (hoặc downgrade)

```javascript
// Resolve + check prefix
const safeJoin = (base, userPath) => {
  const target = path.resolve(base, userPath);
  if (!target.startsWith(path.resolve(base) + path.sep)) {
    throw new Error("Path traversal");
  }
  return target;
};
app.get("/download", (req, res) => {
  try {
    const file = safeJoin("/var/uploads", req.query.name);
    res.sendFile(file);
  } catch {
    res.status(400).end();
  }
});
```

```python
# Whitelist regex + basename
import re, os
PATTERN = re.compile(r"^[a-zA-Z0-9_-]+\.(pdf|png|jpg)$")
@app.route("/read")
def read():
    fn = request.args["f"]
    if not PATTERN.match(fn):
        abort(400)
    full = os.path.realpath(os.path.join("./data", fn))
    if not full.startswith(os.path.realpath("./data") + os.sep):
        abort(400)
    return open(full).read()
```

```python
# Lưu upload với UUID, KHÔNG dùng filename gốc
import uuid
ext = os.path.splitext(f.filename)[1].lower()
if ext not in {".png", ".jpg"}: abort(400)
new_name = f"{uuid.uuid4()}{ext}"
f.save(f"./uploads/{new_name}")
```

## Fix recommendation

1. **Normalize + check prefix**:
   ```javascript
   const base = path.resolve("/var/uploads");
   const target = path.resolve(base, userPath);
   if (!target.startsWith(base + path.sep)) throw new Error("traversal");
   ```
   Python:
   ```python
   import os
   base = os.path.realpath("./data")
   target = os.path.realpath(os.path.join(base, user_path))
   if not target.startswith(base + os.sep):
       raise ValueError("traversal")
   ```
2. **Whitelist filename regex**:
   ```python
   import re
   if not re.fullmatch(r"[a-zA-Z0-9_-]+\.(png|jpg|pdf)", filename):
       abort(400)
   ```
3. **Upload**: KHÔNG giữ tên file gốc — đổi sang UUID. Lưu metadata `original_name` riêng trong DB.
4. **Block null byte + encoded `..`**: hầu hết framework đã handle, nhưng nên decode + check một lần:
   ```python
   from urllib.parse import unquote
   decoded = unquote(filename)
   if ".." in decoded or "\0" in decoded:
       abort(400)
   ```
5. **OS-level**: chạy app dưới user ít quyền, chroot/jail, container readonly FS với volume mount cụ thể.
6. **PHP LFI**: KHÔNG bao giờ `include`/`require` với input L1. Dùng dispatcher whitelist:
   ```php
   $pages = ['home','about','contact'];
   $page = in_array($_GET['page'] ?? '', $pages) ? $_GET['page'] : 'home';
   include "./pages/{$page}.php";
   ```

## Cross-references

- Rule `09-ssrf`: `file://` scheme — SSRF có thể đọc file giống path traversal
- Rule `01-hardcoded-secret`: path traversal đọc `.env` → leak secret
- Rule `17-verbose-error-debug-mode`: error "ENOENT: /etc/passwd" confirm exploit thành công
