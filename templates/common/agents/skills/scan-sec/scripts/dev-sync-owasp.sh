#!/usr/bin/env bash
# dev-sync-owasp.sh
# ⚠️ DEVELOPER-ONLY UTILITY — Syncs official OWASP Top 10 documents to local skill references

set -e

# Path configurations (absolute and relative)
WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../" && pwd)"
OWASP_SRC_DIR="${WORKSPACE_DIR}/Resources/references/github.com/OWASP/Top10"
TARGET_OWASP_DIR="${WORKSPACE_DIR}/.agents/skills/scan-sec/references/owasp"

echo "=== scan-sec OWASP Sync Utility (Dev Mode) ==="

# 1. Verify source repository exists
if [ ! -d "${OWASP_SRC_DIR}" ]; then
  echo "❌ Error: Official OWASP Top 10 repository not found in references at: ${OWASP_SRC_DIR}"
  echo "Please make sure the repo is cloned under resources first."
  exit 1
fi

# 2. Run sync for 2021 (English version)
YEAR="2021"
SRC_EN_DIR="${OWASP_SRC_DIR}/${YEAR}/docs/en"
DEST_EN_DIR="${TARGET_OWASP_DIR}/${YEAR}/en"

if [ ! -d "${SRC_EN_DIR}" ]; then
  echo "❌ Error: English docs folder not found in ${SRC_EN_DIR}"
  exit 1
fi

echo "📁 Creating target directories..."
mkdir -p "${DEST_EN_DIR}"

echo "🔄 Syncing core category files (A01 - A10)..."
for filepath in "${SRC_EN_DIR}"/A[0-9][0-9]_2021-*.md; do
  if [ -f "${filepath}" ]; then
    filename=$(basename "${filepath}")
    
    # Normalize filename: e.g., A01_2021-Broken_Access_Control.md -> a01-broken-access-control.md
    normalized_name=$(echo "${filename}" | sed -E 's/^A([0-9][0-9])_2021-(.*)\.md$/a\1-\2/g' | tr '_' '-' | tr '[:upper:]' '[:lower:]')
    normalized_name="${normalized_name}.md"
    
    echo "  📄 Copying ${filename} -> ${normalized_name}"
    
    # Copy & sanitize markdown content: remove site-specific frontmatter headers if needed
    # We strip any Docusaurus/MkDocs specific layout variables or HTML links
    cat "${filepath}" | sed -E 's/\{\%[^\%]*\%\}//g' > "${DEST_EN_DIR}/${normalized_name}"
  fi
done

# 3. Create/update mappings.json
MAPPINGS_FILE="${TARGET_OWASP_DIR}/mappings.json"
echo "⚙️ Generating mappings.json..."

cat <<EOF > "${MAPPINGS_FILE}"
{
  "OWASP_VERSION": "2021",
  "mappings": {
    "HARDCODED-SECRET": [
      {
        "owasp_id": "A02",
        "owasp_title": "Cryptographic Failures",
        "local_path": "references/owasp/2021/en/a02-cryptographic-failures.md"
      },
      {
        "owasp_id": "A05",
        "owasp_title": "Security Misconfiguration",
        "local_path": "references/owasp/2021/en/a05-security-misconfiguration.md"
      }
    ],
    "SQL-INJECTION": [
      {
        "owasp_id": "A03",
        "owasp_title": "Injection",
        "local_path": "references/owasp/2021/en/a03-injection.md"
      }
    ],
    "XSS": [
      {
        "owasp_id": "A03",
        "owasp_title": "Injection",
        "local_path": "references/owasp/2021/en/a03-injection.md"
      }
    ],
    "IDOR": [
      {
        "owasp_id": "A01",
        "owasp_title": "Broken Access Control",
        "local_path": "references/owasp/2021/en/a01-broken-access-control.md"
      }
    ],
    "BROKEN-ACCESS-CONTROL": [
      {
        "owasp_id": "A01",
        "owasp_title": "Broken Access Control",
        "local_path": "references/owasp/2021/en/a01-broken-access-control.md"
      }
    ],
    "CSRF": [
      {
        "owasp_id": "A01",
        "owasp_title": "Broken Access Control",
        "local_path": "references/owasp/2021/en/a01-broken-access-control.md"
      }
    ],
    "WEAK-PASSWORD-HASHING": [
      {
        "owasp_id": "A02",
        "owasp_title": "Cryptographic Failures",
        "local_path": "references/owasp/2021/en/a02-cryptographic-failures.md"
      }
    ],
    "JWT-NONE-ALGORITHM": [
      {
        "owasp_id": "A02",
        "owasp_title": "Cryptographic Failures",
        "local_path": "references/owasp/2021/en/a02-cryptographic-failures.md"
      }
    ],
    "SSRF": [
      {
        "owasp_id": "A10",
        "owasp_title": "Server-Side Request Forgery (SSRF)",
        "local_path": "references/owasp/2021/en/a10-server-side-request-forgery-(ssrf).md"
      }
    ],
    "PATH-TRAVERSAL": [
      {
        "owasp_id": "A01",
        "owasp_title": "Broken Access Control",
        "local_path": "references/owasp/2021/en/a01-broken-access-control.md"
      }
    ],
    "CORS-MISCONFIG": [
      {
        "owasp_id": "A05",
        "owasp_title": "Security Misconfiguration",
        "local_path": "references/owasp/2021/en/a05-security-misconfiguration.md"
      }
    ],
    "VERBOSE-ERROR-DEBUG-MODE": [
      {
        "owasp_id": "A05",
        "owasp_title": "Security Misconfiguration",
        "local_path": "references/owasp/2021/en/a05-security-misconfiguration.md"
      }
    ],
    "INSECURE-DESERIALIZATION": [
      {
        "owasp_id": "A08",
        "owasp_title": "Software and Data Integrity Failures",
        "local_path": "references/owasp/2021/en/a08-software-and-data-integrity-failures.md"
      }
    ],
    "OUTDATED-DEPENDENCY": [
      {
        "owasp_id": "A06",
        "owasp_title": "Vulnerable and Outdated Components",
        "local_path": "references/owasp/2021/en/a06-vulnerable-and-outdated-components.md"
      }
    ],
    "COMMAND-INJECTION": [
      {
        "owasp_id": "A03",
        "owasp_title": "Injection",
        "local_path": "references/owasp/2021/en/a03-injection.md"
      }
    ],
    "SLOPSQUATTING": [
      {
        "owasp_id": "A06",
        "owasp_title": "Vulnerable and Outdated Components",
        "local_path": "references/owasp/2021/en/a06-vulnerable-and-outdated-components.md"
      }
    ],
    "MISSING-RATE-LIMIT": [
      {
        "owasp_id": "A05",
        "owasp_title": "Security Misconfiguration",
        "local_path": "references/owasp/2021/en/a05-security-misconfiguration.md"
      }
    ],
    "RACE-CONDITION": [
      {
        "owasp_id": "A04",
        "owasp_title": "Insecure Design",
        "local_path": "references/owasp/2021/en/a04-insecure-design.md"
      }
    ]
  }
}
EOF

echo "✅ Sync complete! Documents copied to references/owasp/ and mappings.json generated successfully."
