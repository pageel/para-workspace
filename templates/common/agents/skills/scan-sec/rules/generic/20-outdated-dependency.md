---
id: OUTDATED-DEPENDENCY
severity_max: HIGH
applies_to: all
---

# Outdated Dependency (Known CVE)

## Intent

Outdated dependencies with **known public CVEs** represent a major attack vector, as exploit code is often readily available on GitHub. AI-assisted developers frequently copy dependencies from older tutorials without updating them, introducing vulnerabilities like Log4Shell, prototype pollution, RCE, or SSRF into the application.

Since `scan-sec` runs **offline** (without fetching external CVE databases at runtime):
1. It flags a **small static list** of well-known vulnerable packages and versions (defined below).
2. It advises the user to run dedicated audit tools such as `npm audit`, `pip-audit`, `govulncheck`, or `composer audit` to obtain a comprehensive scan.

## When to Flag HIGH

- A package in the static list below is found with a vulnerable version in lockfiles.
- `package-lock.json`, `requirements.txt`, `go.sum`, or `composer.lock` references specific versions with known CVEs.
- The lockfile was last updated >12 months ago (strong signal of outdated dependencies).

## When to Flag MEDIUM

- The package is outdated but has no known critical CVEs.
- It is a dev dependency (only executed during build, not in production).
- Version ranges allow updating (`^1.2.3`), but lockfile has not been resolved yet.

## Reasoning Strategy (DO NOT perform naive pattern-matching)

1. **Scan lockfiles**: `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `requirements.txt`, `Pipfile.lock`, `poetry.lock`, `go.sum`, `composer.lock`, `Gemfile.lock`.
2. **Compare with the static list** below (note: this is a subset, not a complete database).
3. **Verify lockfile age**: Check the last commit date via git commands if available, or warn if outdated.
4. **Recommend tool output**: Direct the user to run official package audit tools.

## Static Vulnerable List (Representative Subset)

### JavaScript / npm

| Package | Vulnerable | Fixed | CVE |
|---|---|---|---|
| `lodash` | `< 4.17.21` | `4.17.21` | CVE-2021-23337 (command injection in template) |
| `jquery` | `< 3.5.0` | `3.5.0` | CVE-2020-11022/11023 (XSS) |
| `axios` | `< 0.21.1` | `0.21.1` | CVE-2020-28168 (SSRF) |
| `axios` | `< 1.6.0` | `1.6.0` | CVE-2023-45857 (CSRF token leak) |
| `node-fetch` | `< 2.6.7` | `2.6.7` | CVE-2022-0235 (info leak) |
| `minimist` | `< 1.2.6` | `1.2.6` | CVE-2021-44906 (prototype pollution) |
| `ws` | `< 7.4.6` | `7.4.6` | CVE-2021-32640 (ReDoS) |
| `tar` | `< 6.1.9` | `6.1.9` | CVE-2021-37701 (arbitrary file write) |
| `serialize-javascript` | `< 3.1.0` | `3.1.0` | CVE-2020-7660 (XSS) |
| `handlebars` | `< 4.7.7` | `4.7.7` | CVE-2021-23369 (RCE) |
| `next` | `< 13.5.1` | `13.5.1` | CVE-2023-46298 (cache poisoning) |
| `express` | `< 4.17.3` | `4.17.3` | CVE-2022-24999 (qs prototype pollution) |

### Python / pip

| Package | Vulnerable | Fixed | CVE |
|---|---|---|---|
| `django` | `< 3.2.25` / `< 4.2.11` | latest | various |
| `flask` | `< 2.2.5` | `2.2.5` | CVE-2023-30861 (session cookie) |
| `requests` | `< 2.31.0` | `2.31.0` | CVE-2023-32681 (proxy auth leak) |
| `pillow` | `< 10.2.0` | `10.2.0` | multiple buffer overflow |
| `pyyaml` | `< 5.4` | `5.4` | CVE-2020-14343 (arbitrary code) |
| `urllib3` | `< 1.26.18` | `1.26.18` | CVE-2023-45803 (request smuggling) |
| `jinja2` | `< 3.1.3` | `3.1.3` | CVE-2024-22195 (XSS) |
| `werkzeug` | `< 3.0.1` | `3.0.1` | CVE-2023-46136 (DoS) |
| `cryptography` | `< 41.0.6` | `41.0.6` | various |

### Java / Maven

| Package | Vulnerable | Fixed | CVE |
|---|---|---|---|
| `log4j-core` | `< 2.17.1` | `2.17.1` | CVE-2021-44228 (Log4Shell — CRITICAL RCE) |
| `spring-core` | `< 5.3.20` | `5.3.20` | CVE-2022-22965 (Spring4Shell RCE) |
| `jackson-databind` | `< 2.13.4` | `2.13.4` | multiple deserialization RCE |
| `fastjson` | `< 1.2.83` | `1.2.83` | CVE-2022-25845 (RCE) |

### PHP / Composer

| Package | Vulnerable | Fixed | CVE |
|---|---|---|---|
| `laravel/framework` | `< 9.52.16` | `9.52.16` | CVE-2024-29291 (SQL injection) |
| `symfony/http-kernel` | `< 5.4.20` | `5.4.20` | various |
| `guzzlehttp/guzzle` | `< 7.4.5` | `7.4.5` | CVE-2022-31091 (cookie leak) |

### Go / Ruby

| Package | Vulnerable | Fixed | CVE |
|---|---|---|---|
| `github.com/gin-gonic/gin` | `< 1.9.0` | `1.9.0` | CVE-2023-26125 (path traversal) |
| `golang.org/x/net` | `< 0.17.0` | `0.17.0` | CVE-2023-39325 (HTTP/2 DoS) |
| `rack` (Ruby) | `< 2.2.6.4` | `2.2.6.4` | CVE-2023-27530 (DoS) |
| `nokogiri` | `< 1.13.10` | `1.13.10` | multiple |

## Search Patterns

### Lockfiles

```
# Node.js
"version":\s*"([\d.]+)"     # in package-lock.json
# Match package name alongside version

# Python
^([a-zA-Z0-9_\-]+)==(.+)$   # in requirements.txt
^([a-zA-Z0-9_\-]+)\s*=\s*"([^"]+)"  # in Pipfile

# Go
go\.mod / go.sum

# PHP
"version":\s*"v?([\d.]+)"   # composer.lock
```

## Examples

### HIGH — flag

```json
// package-lock.json — lodash 4.17.20 vulnerable
{
  "node_modules/lodash": {
    "version": "4.17.20"    // CVE-2021-23337
  }
}
```

```
# requirements.txt
django==3.2.5           # multiple unpatched CVEs
pillow==8.0.0           # buffer overflow CVEs
requests==2.25.1        # CVE-2023-32681
pyyaml==5.3             # CVE-2020-14343
```

```xml
<!-- pom.xml — Log4Shell -->
<dependency>
    <groupId>org.apache.logging.log4j</groupId>
    <artifactId>log4j-core</artifactId>
    <version>2.14.1</version>   <!-- RCE CRITICAL -->
</dependency>
```

### NOT critical

```json
// Latest patched version
{
  "node_modules/lodash": { "version": "4.17.21" }
}
```

```
# requirements.txt — pinned to latest patched
django==4.2.11
requests==2.31.0
```

## Fix Recommendation

1. **Run official audit tools (Highest Priority):**
   ```bash
   # Node
   npm audit fix
   yarn audit
   pnpm audit

   # Python
   pip install pip-audit && pip-audit
   safety check

   # Go
   go install golang.org/x/vuln/cmd/govulncheck@latest
   govulncheck ./...

   # PHP
   composer audit

   # Ruby
   bundle audit check --update

   # Java
   mvn org.owasp:dependency-check-maven:check
   ```
2. **Update** packages to patched versions:
   ```bash
   npm update lodash@^4.17.21
   pip install --upgrade requests
   ```
3. **Enable Automated Dependency Scanning**: Configure Dependabot or Renovate.
4. **Generate SBOM** (Software Bill of Materials) using `syft` or `cyclonedx-bom`.
5. **Commit Lockfiles** to lock resolved dependencies.
6. **Minimize unused dependencies** to decrease the attack surface.
7. **Schedule audits weekly** in the CI pipeline.

## Cross-References

- This list is **not exhaustive** — it only tracks well-known CVEs. Running official audit tools is required.
- Cross-check with `01-hardcoded-secret` (outdated packages might leak data via telemetry).
- Cross-check with `17-verbose-error-debug-mode` (verbose stacks leak versions which makes matching known CVEs easy).
