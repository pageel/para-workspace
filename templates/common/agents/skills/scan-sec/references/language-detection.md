# Language Detection

How the primary codebase language is detected in the repository to load the corresponding rules overlay.

## Algorithm

1. **Pre-filtering:** Exclude paths that do not contain original source code:
   ```
   node_modules/, vendor/, dist/, build/, .next/, .nuxt/, target/, .venv/, __pycache__/, .git/,
   *.min.js, *.bundle.js, *.lock, *.lock.json, package-lock.json
   ```

2. **Count by file extension:**

   | Language | Extensions Included | Notes |
   |---|---|---|
   | `go` | `.go` | |
   | `php` | `.php`, `.phtml` | |
   | `python` | `.py`, `.pyw` | Excludes empty `__init__.py` files |
   | `typescript` | `.ts`, `.tsx`, `.js`, `.jsx`, `.mjs`, `.cjs` | Groups JavaScript as well, since runtime patterns and libraries overlap |
   | `ruby` | `.rb` | |
   | `java` | `.java` | |
   | `rust` | `.rs` | |
   | `dotnet` | `.cs`, `.csproj`, `.sln` | ASP.NET Core / EF Core; supplemental markers: `global.json`, `appsettings.json` |
   | `kotlin` | `.kt`, `.kts` | |

3. **Primary Language Resolution:** A language is considered primary if it represents **≥30% of the total code files** within the scan scope.

4. **Multi-language Detection:** If two or more languages exceed the 30% threshold, the repository is classified as multi-language. Apply overlays for ALL languages that meet this criteria.

   Common examples:
   - Go backend + Vue/React frontend → `go` + `typescript`
   - Laravel application → `php` (Blade templates are not counted towards frontends)
   - Django backend + React frontend → `python` + `typescript`

5. **Polyglot Fallback:** If no single language meets the ≥30% threshold, the repository is marked as "polyglot" and runs generic rules only. Note in the report header: `"polyglot — using generic rules only"`.

6. **Overlay Availability Verification:**
   - If `rules/languages/<lang>/` exists → Load overlay.
   - If not → Use generic rules and report generic usage in the report metadata.

## Specialization Coverage

| Language | Version Status | Included Overlays in `rules/languages/<lang>/` |
|---|---|---|
| `go` | ✅ v0.1 | GORM SQLi, command injection (`exec.Command`), slog secret exposure, Colly SSRF |
| `php` | ✅ v0.1 | mysqli/PDO parameterization, `$_GET/$_POST` sinks, dynamic `eval`/`include`, Laravel CSRF, `unserialize` magic methods |
| `typescript` | ✅ v0.2 | Sequelize/Prisma/TypeORM/Mongoose SQLi+NoSQLi, React/Vue/Angular XSS, Express/NestJS/Next.js mass-assignment/SSRF/CSRF/CORS, js-yaml deserialization, child_process injection, JWT none algorithm & verification |
| `python` | ✅ v0.4 | SQLAlchemy `text()` & Django `.raw()`/`.extra()` SQLi, pickle/yaml.load RCE, subprocess shell execution, Flask Werkzeug debugger exposure, Django/FastAPI debug flags, model mass-assignment, PyJWT algorithms validation, CORS wildcards, Django CSRF |
| `dotnet` | ✅ v0.6 | ASP.NET Core model binding, EF Core raw SQL, Newtonsoft TypeNameHandling / legacy formatter deserialization, Process.Start command injection |
| Other | Phase v0.7+ | Ruby, Java, Rust depending on ecosystem usage |

## Frontend Framework Sub-Classification

When the primary language is `javascript` or `typescript`, the framework is sub-classified via package file checks to fine-tune security reasoning:

| Framework | Marker File / Dependency | Influence on Security Rules |
|---|---|---|
| React | `package.json` contains `"react"` | XSS: Focus on `dangerouslySetInnerHTML` (JSX auto-escapes by default) |
| Vue | `package.json` contains `"vue"` | XSS: Focus on `v-html` (Mustache expressions auto-escape) |
| Next.js | `next.config.*` or dependencies | SSRF: Analyze `getServerSideProps` and `getStaticProps` |
| Express | `package.json` contains `"express"` | CORS/CSRF: Review express cors/csurf configuration |
| Fastify | `package.json` contains `"fastify"` | CORS/CSRF: Analyze fastify equivalents |
| NestJS | `package.json` contains `"@nestjs/core"` | Mass Assignment: Check for NestJS DTO validation decorators (`@Body()`, `@Query()`) |

Framework markers are indicators to reduce false positives (e.g. not flagging Mustache templates as XSS in Vue). Generic patterns still apply.

## Pseudocode

```python
def detect_primary_language(files):
    code_files = [f for f in files if not is_vendored(f)]
    total = len(code_files)
    if total == 0:
        return {"primary": None, "multi": [], "overlay_available": []}

    counts = {}
    for f in code_files:
        lang = ext_to_lang(f)
        if lang:
            counts[lang] = counts.get(lang, 0) + 1

    threshold = 0.30
    primaries = [lang for lang, n in counts.items() if n / total >= threshold]

    if not primaries:
        return {"primary": "polyglot", "multi": [], "overlay_available": []}

    overlay_available = [lang for lang in primaries if has_dir(f"rules/languages/{lang}")]

    return {
        "primary": primaries[0] if len(primaries) == 1 else "+".join(primaries),
        "multi": primaries if len(primaries) > 1 else [],
        "overlay_available": overlay_available
    }
```

The LLM agent uses glob pattern matching and metadata reasoning to resolve primary languages rather than running python execution blocks directly.

## Edge Cases

- **Monorepos** (e.g. `apps/web` Next.js + `apps/api` Go): Language detection matches the current target scope. If scanning a sub-folder, detect language settings within that sub-folder only.
- **Generated Code** (e.g. `.pb.go`, `*_pb2.py`): Counted in metrics but noted in reports if generated files represent >50% of the volume.
- **Test Files**: Counted in statistics. Generic rules apply (exposed secrets in test files remain a concern).
- **Configuration Files** (`.yaml`, `.json`, `.toml`, `Dockerfile`): Excluded from language statistics but parsed for specific rules (e.g., exposed secrets, debug settings).
