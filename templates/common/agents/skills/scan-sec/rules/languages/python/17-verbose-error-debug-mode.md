---
id: VERBOSE-ERROR-DEBUG-MODE
severity_max: HIGH
applies_to: python
---

# Verbose Error & Debug Mode — Python Specialization

> Override cho rule chung `rules/generic/17-verbose-error-debug-mode.md`. Áp dụng khi `primary_language: python`.

## Intent (Python-specific)

Đây là **lỗi cực kỳ phổ biến với vibe code Python** vì khung Django/Flask/FastAPI đều có flag debug đơn giản → vibe code copy ví dụ "hello world" có `debug=True` rồi deploy thẳng prod.

- **Flask `debug=True`** = bật Werkzeug debugger console tại `/console` — cho phép **arbitrary Python execution**. PIN bypass đã được public hóa nhiều lần (CVE-2022-29361 và cách derive PIN từ username+machine-id). Nếu rò endpoint debug → **full RCE**.
- **Django `DEBUG = True`** = error page hiển thị: full traceback + source code + tất cả settings (gồm `SECRET_KEY`, `DATABASES.PASSWORD`) + env vars + SQL queries + cookies → CRITICAL leak.
- **FastAPI `debug=True`** = traceback trong response body.
- **SQLAlchemy `echo=True`** = log mọi câu SQL (gồm value) ra stderr.

## Khi nào HIGH (cap)

- `app.run(debug=True)` Flask trong file `main.py`, `app.py`, `wsgi.py` được deploy
- `app.config['DEBUG'] = True` mà không có guard `if os.environ.get('FLASK_ENV') != 'production'`
- `DEBUG = True` trong `settings.py` không có guard env
- Django `ALLOWED_HOSTS = ['*']` kèm `DEBUG = True`
- `FastAPI(debug=True)` mà không guard env
- Exception handler tự return `traceback.format_exc()` trong response body
- `SQLALCHEMY_ECHO = True` / `engine = create_engine(url, echo=True)` không guard env
- `pdb.set_trace()` / `breakpoint()` left in committed code
- Django `django-debug-toolbar` enable trong settings prod (`INTERNAL_IPS = ['*']`)
- Flask `werkzeug.debug.DebuggedApplication` wrap trên prod
- Logging có `traceback.format_exc()` vào response (không phải log file)

## Khi nào MEDIUM (giảm cấp)

- `DEBUG` lấy từ env: `DEBUG = os.environ.get('DEBUG', 'False') == 'True'` — SAFE (mặc định False)
- Traceback chỉ log vào file/Sentry, không return response
- Custom exception handler trả error code generic (`{"error": "internal"}`)

## Cách reasoning

1. **Grep** sink: `debug\s*=\s*True`, `DEBUG\s*=\s*True`, `app\.run\(`, `traceback\.format_exc`, `\.set_trace\(\)`, `breakpoint\(\)`, `echo\s*=\s*True`
2. **Read** file context — đây có phải config/entry point production không?
3. **Check guard**:
   - Có `if __name__ == '__main__'` block không (chỉ chạy local)?
   - Có lấy từ env không?
   - File có pattern prod (gunicorn, uwsgi config) hay local script?
4. **Verify**:
   - `ALLOWED_HOSTS` Django = `['*']` + DEBUG=True → CRITICAL (Django chỉ show debug page nếu request từ ALLOWED_HOSTS hoặc INTERNAL_IPS, nhưng `*` cho phép mọi host)
   - PIN của Werkzeug có hay không (`use_evalex=True/False`)
5. **Cross-check** `01-hardcoded-secret`: nếu `SECRET_KEY` hardcode + `DEBUG=True` → key lộ qua error page

## Search patterns

```
# Flask debug
app\.run\s*\([^)]*debug\s*=\s*True
\.config\[['"]DEBUG['"]\]\s*=\s*True
\.config\.from_(object|pyfile)  # check object có DEBUG=True

# Django debug
^DEBUG\s*=\s*True
DEBUG\s*=\s*True\s*$
ALLOWED_HOSTS\s*=\s*\[\s*['"]\*['"]\s*\]
INTERNAL_IPS\s*=\s*\[\s*['"]\*['"]
DEBUG_PROPAGATE_EXCEPTIONS\s*=\s*True

# FastAPI debug
FastAPI\s*\([^)]*debug\s*=\s*True\s*[,)]

# Werkzeug debugger explicit
DebuggedApplication\s*\(
use_debugger\s*=\s*True
use_reloader\s*=\s*True  # info only

# SQL echo
create_engine\s*\([^)]*echo\s*=\s*True
SQLALCHEMY_ECHO\s*=\s*True

# Traceback in response
return\s+.*traceback\.format_exc
jsonify\s*\([^)]*traceback\.format_exc
HttpResponse\s*\([^)]*traceback\.format_exc
JSONResponse\s*\([^)]*traceback\.format_exc

# Debugger left in code
\.set_trace\s*\(\s*\)
^[^#]*\bbreakpoint\s*\(\s*\)
import\s+pdb\s*;\s*pdb

# Debug toolbar prod
django_debug_toolbar
DEBUG_TOOLBAR_CONFIG

# Sensitive print
print\s*\(\s*request\.headers
print\s*\(\s*os\.environ
print\s*\(\s*settings\.
```

## Examples

### HIGH — flag

```python
# Flask debug=True — Werkzeug console RCE
# app.py
from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return 'hi'

if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)  # CRITICAL trên prod
# /console → Werkzeug debugger, bypass PIN → RCE
```

```python
# Django settings.py
DEBUG = True
SECRET_KEY = 'django-insecure-abc123'  # leak qua error page
ALLOWED_HOSTS = ['*']  # cho phép mọi host trigger error page
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'prod',
        'USER': 'admin',
        'PASSWORD': 'RealProdPassword',  # lộ luôn
        ...
    }
}
```

```python
# FastAPI debug + leak trace
app = FastAPI(debug=True)  # tracebacks vào response

@app.exception_handler(Exception)
async def handler(request, exc):
    import traceback
    return JSONResponse({
        "error": str(exc),
        "trace": traceback.format_exc(),  # CRITICAL — leak ENV var, path
    }, status_code=500)
```

```python
# SQLAlchemy echo log SQL value
engine = create_engine(
    os.environ['DATABASE_URL'],
    echo=True,  # log mọi query + binding ra stderr → log aggregation lưu
)
```

```python
# breakpoint() / pdb left over
def process(data):
    breakpoint()  # CRITICAL — request hang, dev shell trên prod
    return data
```

```python
# Django debug-toolbar bật trên prod
INSTALLED_APPS = [..., 'debug_toolbar']
MIDDLEWARE = [..., 'debug_toolbar.middleware.DebugToolbarMiddleware']
INTERNAL_IPS = ['*']  # leak SQL queries, settings cho mọi user
```

### NOT critical — không flag

```python
# Flask debug guard env
import os
if __name__ == '__main__':
    app.run(
        host='0.0.0.0',
        debug=os.environ.get('FLASK_ENV') == 'development',
    )
```

```python
# Django DEBUG từ env
import os
DEBUG = os.environ.get('DJANGO_DEBUG', 'False').lower() == 'true'
ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', '').split(',')
SECRET_KEY = os.environ['DJANGO_SECRET_KEY']  # required
```

```python
# Exception handler generic, log vào Sentry
import sentry_sdk

@app.exception_handler(Exception)
async def handler(request, exc):
    sentry_sdk.capture_exception(exc)  # detail vào Sentry
    return JSONResponse({"error": "Internal server error"}, status_code=500)
```

```python
# SQLAlchemy echo only dev
engine = create_engine(
    DATABASE_URL,
    echo=os.environ.get('SQL_ECHO') == '1',
)
```

## Fix recommendation

1. **Flask**:
   ```python
   # config.py
   class ProdConfig:
       DEBUG = False
       TESTING = False
   class DevConfig:
       DEBUG = True

   app.config.from_object('config.ProdConfig' if os.environ.get('ENV') == 'prod' else 'config.DevConfig')

   # KHÔNG bao giờ app.run(debug=True) trên prod
   # Prod chạy: gunicorn app:app -w 4 -b 0.0.0.0:8000
   ```
2. **Django**:
   ```python
   DEBUG = os.environ.get('DJANGO_DEBUG', 'False').lower() == 'true'
   ALLOWED_HOSTS = os.environ['DJANGO_ALLOWED_HOSTS'].split(',')
   SECRET_KEY = os.environ['DJANGO_SECRET_KEY']  # NO default, raise nếu thiếu
   ```
3. **FastAPI**:
   ```python
   app = FastAPI(debug=False)  # mặc định, không bật trên prod
   # Custom exception handler trả generic
   @app.exception_handler(Exception)
   async def handler(req, exc):
       logger.exception(exc)  # vào log file, không vào response
       return JSONResponse({"error": "internal"}, status_code=500)
   ```
4. **SQLAlchemy** — `echo=False` prod, log qua proper logger nếu cần.
5. **Pre-commit hook**: chặn `breakpoint()`, `pdb.set_trace()`, `print(`:
   ```yaml
   # .pre-commit-config.yaml
   - repo: https://github.com/pre-commit/pre-commit-hooks
     hooks:
       - id: debug-statements
   ```
6. **Werkzeug** — nếu BẮT BUỘC remote debug (KHÔNG NÊN): set `use_evalex=False` để vô hiệu console, kèm `PIN` complex.
7. **Sentry / structured logging**: đẩy stack trace lên dịch vụ riêng, không vào response body.
8. **CI gate**: lint config bằng `bandit` để bắt `Flask(debug=True)`, `subprocess shell=True`, `pickle.loads`.

## Cross-references

- Generic `01-hardcoded-secret`: Django `DEBUG=True` + `SECRET_KEY` hardcode = lộ secret qua error page
- Python `14-jwt-none-algorithm`: `JWT_SECRET` lộ qua Django debug page → forge token
- Python `02-sql-injection`: `echo=True` log câu SQL bị inject → leak data thêm
- Generic `20-outdated-dependency`: Werkzeug cũ có CVE PIN derivation
