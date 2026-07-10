---
id: UNTRUSTED-BUILD-DEPENDENCY
severity_max: HIGH
applies_to: all
---

# Untrusted Build Dependency / Unverified Download (A03:2025)

## Intent

Downloading and executing packages, binaries, or scripts from the internet during the build or CI/CD process without verifying their integrity (via SHA checksums or GPG signatures) or using insecure protocols (HTTP instead of HTTPS). This exposes the pipeline to Man-in-the-Middle (MitM) attacks or supply chain compromises if the host server is hacked or DNS is spoofed.

Vibe coders often write build script commands like `curl -sSL http://example.com/install.sh | bash` inside Dockerfiles or shell scripts to speed up environment setup, introducing unauthenticated remote code execution vulnerabilities.

## When to Flag HIGH / MEDIUM

- **HIGH**: Automatically executing downloaded files or piping HTTP/HTTPS resources directly to a shell (`sh`, `bash`, `python`) without verifying checksums.
- **MEDIUM**: Fetching dependencies from unofficial mirrors/registries, or configuring repository URLs using plain HTTP.

## Reasoning Strategy

1. **Grep** for downloading utilities like `curl`, `wget`, `fetch`, or `git clone` inside build configurations: `Dockerfile`, `Makefile`, `Jenkinsfile`, `package.json` (scripts), or `build.sh`.
2. **Trace**:
   - Is the download URL using HTTP or HTTPS?
   - Is the downloaded file verified (e.g., using `sha256sum -c` or GPG) before being executed or referenced?
   - Is it piped directly to a shell interpreter (e.g., `curl ... | bash`)?
3. **Verify**:
   - Check if a hardcoded SHA hash or signature verification step exists. If so, it is safe.

## Search Patterns (Examples)

### Shell Scripts / Dockerfile / Makefile
```regex
curl\s+[^|]*http://
wget\s+[^|]*http://
curl\s+[^|]*\|\s*(?:bash|sh)
wget\s+[^|]*-O-\s*\|\s*(?:bash|sh)
pip\s+install\s+[^ ]*--index-url\s+http://
npm\s+install\s+[^ ]*--registry\s+http://
```

## Examples

### HIGH — flag

```dockerfile
# Dockerfile - Downloads installer over HTTP and pipes directly to shell
FROM ubuntu:latest
RUN curl -sSL http://untrusted-source.com/setup.sh | sh
```

```bash
# build.sh - Executes download without checking SHA checksum
wget https://example.com/bin/helper-tool
chmod +x helper-tool
./helper-tool --build
```

### NOT high — no flag (or downgrade)

```dockerfile
# Dockerfile - Verifies SHA256 checksum before executing installer
FROM ubuntu:latest
RUN curl -sSL -o setup.sh https://trusted-source.com/setup.sh \
    && echo "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855  setup.sh" | sha256sum -c - \
    && sh setup.sh
```

## Fix Recommendation

1. **Enforce HTTPS**: Ensure all dependency or tool downloads use HTTPS.
2. **Integrity Verification (Hardcoded Hashes)**: Verify download files with SHA256 checksums before running them:
   ```bash
   curl -sSL -o tool https://example.com/tool && echo "HASH_VAL tool" | sha256sum -c - && ./tool
   ```
3. **Use Official Package Managers**: Prefer installing via standard repositories (`apt`, `apk`, `npm`, `pip`) which natively enforce signature and hash validation.
4. **Use Lockfiles**: Ensure package lockfiles (`package-lock.json`, `poetry.lock`) containing integrity hashes are committed.
