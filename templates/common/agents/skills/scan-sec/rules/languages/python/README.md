# Python Specialization

These rule files override generic rules when scan-sec detects primary language as `python`.

## Language detection scope

Scan-sec treats these as `python`:
- `.py` (Python source)
- `.pyw` (Python script for Windows)

## Files in this folder

| File | Rule ID | What it specializes |
|---|---|---|
| `02-sql-injection.md` | SQL-INJECTION | SQLAlchemy `text()`, Django `.raw()`/`.extra()`, psycopg2, mysql.connector |
| `07-mass-assignment.md` | MASS-ASSIGNMENT | Django `ModelForm` fields=`__all__`, Flask `**request.json`, FastAPI Pydantic `extra="allow"` |
| `08-insecure-deserialization.md` | INSECURE-DESERIALIZATION | `pickle.loads`, `yaml.load` (no SafeLoader), `marshal`, `shelve`, `dill`, `jsonpickle` |
| `09-ssrf.md` | SSRF | `requests`/`urllib`/`httpx`/`aiohttp` with user URL, Flask redirect, Django `is_safe_url()` |
| `11-csrf.md` | CSRF | Django `@csrf_exempt`, Flask-WTF `WTF_CSRF_ENABLED=False`, FastAPI middleware, SameSite cookie |
| `14-jwt-none-algorithm.md` | JWT-NONE-ALGORITHM | PyJWT missing `algorithms`, weak secret, RS256/HS256 confusion, frontend decode |
| `15-cors-misconfig.md` | CORS-MISCONFIG | `flask-cors` no-arg, `CORS_ALLOW_ALL_ORIGINS=True`, FastAPI `CORSMiddleware` wildcard |
| `17-verbose-error-debug-mode.md` | VERBOSE-ERROR-DEBUG-MODE | Flask `debug=True` (Werkzeug RCE), Django `DEBUG=True`, FastAPI `debug=True`, SQLAlchemy `echo=True` |
| `21-command-injection.md` | COMMAND-INJECTION | `subprocess shell=True`, `os.system`, `os.popen`, `eval`/`exec`, Jinja2 template injection |

## Framework coverage

### Web frameworks
- **Django** (forms, ORM, settings, middleware, CSRF)
- **Flask** (routes, request, jsonify, Flask-WTF, flask-cors)
- **FastAPI** (Pydantic, dependencies, CORSMiddleware)
- **Pyramid, Tornado, Bottle** — covered by generic patterns

### ORMs
- **SQLAlchemy** (text(), Core, ORM)
- **Django ORM** (.raw(), .extra(), .filter)
- **psycopg2** (cursor.execute string formats)
- **mysql.connector**

### Templates
- **Jinja2** (Template injection RCE)
- **Django templates** (auto-escape by default, checked for `{% autoescape off %}`)

## Generic rules that apply as-is (no Python-specific override needed)

- `01-hardcoded-secret.md` — env var loading is universal
- `04-idor.md` — logic-level, framework-agnostic
- `05-slopsquatting.md` — PyPI patterns already in generic
- `06-brute-force.md` — rate-limit covered (Flask-Limiter, django-ratelimit)
- `10-path-traversal.md` — `open(user_path)` patterns are universal
- `12-broken-access-control.md` — `@login_required` patterns in generic
- `13-weak-password-hashing.md` — `hashlib.md5/sha1`, recommend `bcrypt`/`argon2-cffi`/`passlib`
- `16-unrestricted-file-upload.md` — Flask `send_from_directory`, Django FileField
- `18-missing-rate-limit.md`, `19-race-condition.md`, `20-outdated-dependency.md` — generic

## Contributing

To improve a Python override:
1. Test on a real Python repo (Django, Flask, or FastAPI vibe app)
2. Run `/scan-sec all` on the repo
3. Verify: did scan-sec catch real issues? Did it flag any false positives?
4. Update the relevant file with new patterns or refined reasoning

To add Python ML/data-science specific patterns (notebook secrets, model `pickle`, `os.environ` in Jupyter cells):
- Add a new section to relevant rule (e.g., `08-insecure-deserialization.md` for model pickle)
- DON'T add a new rule id — map to existing 21 canonical IDs
- If truly novel class, open an issue in the scan-sec ecosystem.
