---
id: INSECURE-DESERIALIZATION
severity_max: CRITICAL
applies_to: all
---

# Insecure Deserialization

## Intent

Code dùng `pickle.loads`, `yaml.load`, `eval`, `unserialize`, `ObjectInputStream`, `BinaryFormatter` trên dữ liệu user-controlled (L1). Các API này có thể **chạy code tùy ý khi deserialize** — attacker gửi payload đặc chế là **RCE ngay trên server**, lấy shell, đọc env, chiếm DB.

Đây không phải "lỗi nhỏ" — là **Remote Code Execution thẳng**, không cần leo thang. Vibe code dính khi AI sinh code "tiện nhanh" với `pickle` hoặc `yaml.load` mặc định (không safe loader).

## Khi nào CRITICAL

- L1 input (request body, cookie, query, file upload, message queue payload) đi vào: `pickle.loads`, `pickle.load`, `cPickle.loads`, `yaml.load` (không có `Loader=SafeLoader`), `marshal.loads`, `eval`, `exec`, `unserialize` (PHP), `ObjectInputStream` (Java), `BinaryFormatter.Deserialize` / `SoapFormatter` / `NetDataContractSerializer` (.NET), `Node vm.runInNewContext` với user input
- Không có signature/HMAC check trước khi deserialize

## Khi nào HIGH (giảm cấp)

- Input là L2 (DB) mà DB đó user có thể ghi gián tiếp — vẫn rất nguy hiểm
- Dùng `pickle` cho data internal (Redis cache giữa các service) và Redis không expose public — vẫn rủi ro nếu Redis compromise

## Cách reasoning (KHÔNG pattern-match thuần)

1. **Grep** các API nguy hiểm (xem dưới)
2. **Read** function chứa call: input đến từ đâu?
3. **Trace** L1-L4:
   - `pickle.loads(request.cookies["session"])` → L1 → CRITICAL ngay
   - `pickle.loads(redis.get("user_cache"))` → L2 → cần xem ai ghi vào Redis
   - `pickle.loads(open("./trusted.pkl").read())` → L3 nếu file là static
4. **Verify safe variant**:
   - YAML: phải có `yaml.safe_load` hoặc `Loader=yaml.SafeLoader`
   - JSON: `json.loads` an toàn (không thực thi code) — không flag
   - `ast.literal_eval` an toàn — không flag
5. **Eval / exec** trên L1 ALMOST ALWAYS critical — không có lý do hợp lệ trừ khi sandbox kỹ.

## Search patterns (gợi ý — KHÔNG chạy literal, dùng Grep tool)

### Python

```
pickle\.loads?\s*\(
cPickle\.loads?\s*\(
marshal\.loads?\s*\(
yaml\.load\s*\(                              # KHÔNG có safe_
shelve\.open\s*\(
^eval\s*\(                                   # KHÔNG phải .eval của framework
^exec\s*\(
```

### PHP

```
unserialize\s*\(
phar://                                      # phar deserialization
```

### Java

```
ObjectInputStream
readObject\s*\(
XMLDecoder
```

### .NET

```
BinaryFormatter
SoapFormatter
NetDataContractSerializer
LosFormatter
JavaScriptSerializer.*TypeNameHandling
```

### Node.js

```
node-serialize
vm\.runInNewContext\s*\(
vm\.runInThisContext\s*\(
Function\s*\(\s*req\.                        # new Function(userCode)
```

## Examples

### CRITICAL — flag

```python
# Flask — pickle từ cookie là RCE
import pickle, base64
@app.route("/restore", methods=["POST"])
def restore():
    data = base64.b64decode(request.cookies["session"])
    state = pickle.loads(data)   # L1 → RCE
    return jsonify(state)
```

```python
# yaml.load mặc định = FullLoader, vẫn có thể RCE qua !!python/object/apply
import yaml
config = yaml.load(request.data)   # KHÔNG safe_load
```

```php
<?php
// Cookie chứa serialized object — gadget chain → RCE
$user = unserialize($_COOKIE['user_data']);
```

```python
# eval trên input — game over
result = eval(request.args.get("formula"))   # ?formula=__import__('os').system('rm -rf /')
```

```javascript
// Node — new Function với input
app.post("/calc", (req, res) => {
  const fn = new Function("return " + req.body.expr);
  res.json({ result: fn() });
});
```

```csharp
// .NET
var formatter = new BinaryFormatter();
var obj = formatter.Deserialize(Request.InputStream);   // RCE
```

### NOT critical — không flag (hoặc downgrade)

```python
# JSON — an toàn (không thực thi code)
import json
data = json.loads(request.data)
```

```python
# yaml safe_load — an toàn
import yaml
config = yaml.safe_load(request.data)
# hoặc
config = yaml.load(request.data, Loader=yaml.SafeLoader)
```

```python
# ast.literal_eval — chỉ parse literal, không exec
import ast
data = ast.literal_eval(request.form["data"])
```

```python
# pickle chỉ dùng cho file static trong repo
import pickle
with open("./model.pkl", "rb") as f:
    model = pickle.load(f)   # L3 — file controlled, OK nếu file commit
```

## Fix recommendation

1. **KHÔNG deserialize untrusted data** với pickle/yaml.load/unserialize. Đổi sang JSON cho mọi data từ client:
   ```python
   # Trước (BAD)
   data = pickle.loads(request.data)
   # Sau (GOOD)
   import json
   data = json.loads(request.data)
   ```
2. **YAML**: luôn dùng `yaml.safe_load`:
   ```python
   import yaml
   config = yaml.safe_load(f)
   ```
3. **PHP**: chuyển từ `unserialize` sang `json_decode($data, true)`. Nếu phải `unserialize`, dùng option `["allowed_classes" => false]`.
4. **Java**: tránh `ObjectInputStream`. Dùng JSON (Jackson/Gson) hoặc Protobuf. Nếu phải, set `ObjectInputFilter`.
5. **.NET**: KHÔNG dùng `BinaryFormatter` (Microsoft đã deprecated). Dùng `System.Text.Json` / `Newtonsoft.Json` với `TypeNameHandling.None`.
6. **Nếu BẮT BUỘC dùng pickle/serialize**: ký HMAC trước:
   ```python
   import hmac, hashlib, pickle
   secret = os.environ["PICKLE_SECRET"].encode()
   def sign(data: bytes) -> bytes:
       sig = hmac.new(secret, data, hashlib.sha256).digest()
       return sig + data
   def verify_and_load(blob: bytes):
       sig, data = blob[:32], blob[32:]
       expected = hmac.new(secret, data, hashlib.sha256).digest()
       if not hmac.compare_digest(sig, expected):
           raise ValueError("Bad signature")
       return pickle.loads(data)
   ```
7. **eval/exec**: gần như không bao giờ có lý do hợp lệ. Nếu cần parse expression (math), dùng `ast.literal_eval` hoặc lib như `simpleeval`, `asteval` (sandbox).

## Cross-references

- Rule `02-sql-injection`: cùng họ injection — pickle/eval là "code injection"
- Rule `17-verbose-error-debug-mode`: traceback của pickle lộ class internal → giúp build gadget chain
- Rule `20-outdated-dependency`: lib cũ có gadget chain công khai → exploit dễ hơn
