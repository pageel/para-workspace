---
id: INSECURE-DESERIALIZATION
severity_max: CRITICAL
applies_to: python
---

# Insecure Deserialization — Python Specialization

> Override cho rule chung `rules/generic/08-insecure-deserialization.md`. Áp dụng khi `primary_language: python`.

## Intent (Python-specific)

Python có **lớp lỗ hổng đặc biệt nguy hiểm hơn các ngôn ngữ khác**: `pickle.loads()` cho phép arbitrary code execution **by design** — chính Python docs có cảnh báo "WARNING: Never unpickle data received from an untrusted source". Cùng họ: `marshal`, `shelve`, `dill`, `jsonpickle`. `yaml.load()` không kèm `SafeLoader` cũng cho phép RCE qua `!!python/object/apply:os.system`. Vibe code rất hay dùng pickle để cache, session, queue (Celery), ML model — và load lại từ Redis/file/network mà không verify nguồn.

## Khi nào CRITICAL

- `pickle.loads(data)` / `pickle.load(file)` với data từ:
  - HTTP request (L1)
  - Redis/Memcached/queue không kiểm soát producer
  - File user upload
  - Cookie session (Django pre-default-JSON, Flask `pickle` session)
- `yaml.load(data)` KHÔNG có `Loader=SafeLoader` hoặc `yaml.safe_load`
- `marshal.loads`, `marshal.load` với input untrusted
- `dill.loads` / `dill.load` (siêu tập của pickle, còn permissive hơn)
- `jsonpickle.decode(data)` — mặc định cho phép `py/object` reference class
- `shelve.open(user_controlled_path)` — backing store là pickle
- `eval(user_input)` / `exec(user_input)` — RCE trực tiếp (cũng cross-ref `21-command-injection`)
- `compile(user_input, ...) + exec` — biến tướng eval
- Celery `task_serializer = 'pickle'` (default đã JSON từ 4.0+ nhưng vibe code có thể bật pickle)

## Khi nào HIGH (giảm cấp)

- Input từ trusted internal source có HMAC/signature verify trước khi unpickle
- `pickle.loads` trong test fixture rõ ràng
- `yaml.load` với `Loader=SafeLoader` (đây thực ra là SAFE — nếu code đã đúng thì không flag)

## Cách reasoning

1. **Grep** sink: `pickle\.loads?`, `marshal\.loads?`, `yaml\.load\(`, `dill\.loads?`, `jsonpickle\.decode`, `shelve\.open`, `\beval\(`, `\bexec\(`
2. **Read** function chứa call. Source của bytes/string là gì?
   - L1: `request.body`, `request.files`, `request.cookies`, request param
   - L2: Redis key, file path từ DB
   - L3: file config local
   - L4: hardcoded bytes
3. **Verify**:
   - `yaml.load` có `Loader=SafeLoader` hoặc `yaml.SafeLoader`?
   - pickle có HMAC sign verify trước không (`hmac.compare_digest`)?
   - Celery config có `accept_content = ['json']` không?
   - Session backend là gì? (`SESSION_ENGINE` Django, `SESSION_TYPE` Flask)

## Search patterns

```
# Pickle - CRITICAL by default
pickle\.loads?\s*\(
cPickle\.loads?\s*\(
_pickle\.loads?\s*\(

# Marshal - CRITICAL
marshal\.loads?\s*\(

# YAML không safe
yaml\.load\s*\((?![^)]*Loader\s*=\s*(yaml\.)?SafeLoader)
# (tìm yaml.load mà KHÔNG kèm SafeLoader)

# dill/jsonpickle
dill\.loads?\s*\(
jsonpickle\.decode\s*\(

# shelve
shelve\.open\s*\(

# eval/exec với khả năng L1
\beval\s*\(\s*(request\.|input\(|sys\.argv)
\bexec\s*\(\s*(request\.|input\(|sys\.argv)
compile\s*\([^)]*\)\s*\)\s*\)?[^;]*\bexec
__import__\s*\(\s*request\.

# Celery cấu hình pickle
task_serializer\s*=\s*["']pickle["']
accept_content\s*=\s*\[[^\]]*["']pickle["']
result_serializer\s*=\s*["']pickle["']

# Django session với pickle
SESSION_SERIALIZER\s*=\s*["'][^"']*PickleSerializer["']

# Flask session pickle hoặc itsdangerous unsafe
session_interface\s*=\s*[^J][^S][^O][^N]
```

## Examples

### CRITICAL — flag

```python
# Flask + pickle từ request body — RCE
@app.post('/import')
def import_data():
    data = pickle.loads(request.data)  # L1 → RCE
    return jsonify(ok=True)
# Exploit payload tạo bằng pickle.dumps(obj với __reduce__ chạy os.system)
```

```python
# Django + yaml.load không safe
def upload_config(request):
    config = yaml.load(request.FILES['config'].read())  # CRITICAL
    # Attacker upload YAML: !!python/object/apply:os.system ["rm -rf /"]
    return JsonResponse(config)
```

```python
# Cache pickle từ Redis không HMAC
def get_user_cache(user_id):
    raw = redis.get(f"user:{user_id}")  # L2 — kẻ tấn công ghi vào Redis
    if raw:
        return pickle.loads(raw)  # RCE nếu Redis bị compromise
```

```python
# FastAPI eval từ request
@app.post('/calc')
async def calc(expr: str):  # L1
    return {"result": eval(expr)}
# Exploit: expr = "__import__('os').system('id')"
```

```python
# jsonpickle decode mặc định cho phép class
@app.post('/restore')
def restore():
    obj = jsonpickle.decode(request.data.decode())  # py/object → RCE
    return jsonify(state=str(obj))
```

```python
# Celery với pickle serializer
# celery_config.py
task_serializer = 'pickle'  # CRITICAL nếu broker chia sẻ
accept_content = ['pickle', 'json']
# Bất kỳ ai publish vào queue đều có thể RCE worker
```

### NOT critical — không flag

```python
# yaml.safe_load — SAFE
data = yaml.safe_load(request.files['config'].read())

# Hoặc explicit SafeLoader
data = yaml.load(stream, Loader=yaml.SafeLoader)
```

```python
# ast.literal_eval thay cho eval — SAFE cho literal
import ast
result = ast.literal_eval(request.json['expr'])
# Chỉ parse được str/int/float/list/dict/tuple/None/bool
```

```python
# JSON serializer — SAFE
data = json.loads(request.data)
```

```python
# Pickle với HMAC verify — chấp nhận nếu key bí mật
data = request.data
sig = request.headers['X-Sig']
expected = hmac.new(SECRET, data, 'sha256').hexdigest()
if hmac.compare_digest(sig, expected):
    obj = pickle.loads(data)  # OK vì verify integrity
```

## Fix recommendation

1. **Thay pickle bằng JSON** cho mọi data đi qua network/storage không tin cậy:
   ```python
   # BAD
   pickle.dumps(obj) → pickle.loads(bytes)
   # GOOD
   json.dumps(obj.__dict__) → json.loads(s)
   # Hoặc msgpack, protobuf, flatbuffers cho hiệu năng
   ```
2. **YAML** — luôn dùng `safe_load`:
   ```python
   # BAD
   yaml.load(stream)
   # GOOD
   yaml.safe_load(stream)
   ```
3. **eval/exec** — không bao giờ với input user. Thay bằng:
   ```python
   import ast
   ast.literal_eval(s)  # cho literal
   # Cho expression toán: dùng asteval, simpleeval (sandboxed)
   ```
4. **Celery** — bắt buộc JSON:
   ```python
   task_serializer = 'json'
   accept_content = ['json']
   result_serializer = 'json'
   ```
5. **Django session** — KHÔNG dùng pickle serializer (default đã là JSON từ Django 1.6+):
   ```python
   SESSION_SERIALIZER = 'django.contrib.sessions.serializers.JSONSerializer'
   ```
6. **Nếu BẮT BUỘC pickle** (vd: ML model giữa trusted services) — kèm HMAC:
   ```python
   def safe_pickle_load(data: bytes, sig: bytes, key: bytes):
       expected = hmac.new(key, data, 'sha256').digest()
       if not hmac.compare_digest(sig, expected):
           raise ValueError("Signature mismatch")
       return pickle.loads(data)
   ```
7. **ML model loading**: nếu load model từ HuggingFace/internet → ưu tiên format `safetensors` thay pickle/torch `.pt`.

## Cross-references

- Python `21-command-injection`: `eval`/`exec`/`__import__` là biến thể RCE qua deserialization
- Generic `01-hardcoded-secret`: HMAC key cho pickle verify không được hardcode
- Generic `20-outdated-dependency`: PyYAML <5.1 có CVE-2017-18342, dill cũ có CVE
