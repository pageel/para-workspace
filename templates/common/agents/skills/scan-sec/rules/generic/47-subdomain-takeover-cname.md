---
id: SUBDOMAIN-TAKEOVER-CNAME
severity_max: HIGH
applies_to: tf, hcl, yaml, json, zone
---

# Dangling CNAME & Subdomain Takeover Risk

## Intent

Detects DNS configuration or IaC manifests containing dangling CNAME records that point to decommissioned external services (Cloudflare Pages, AWS S3 Buckets, GitHub Pages, Vercel, Heroku). When an organization deletes an edge service instance without removing its corresponding DNS CNAME record, an attacker can register a new service instance under the exact same name on that provider and takeover the subdomain, inheriting session cookies, TLS certificates, and brand trust.

Reference OWASP Cheat Sheet Series: `Subdomain_Takeover_Prevention_Cheat_Sheet.md`.

## When HIGH / CRITICAL

- DNS CNAME record points to an unallocated or deleted third-party Cloudflare/S3/Vercel endpoint.
- Subdomain inherits wildcards or sensitive cookies from the parent domain.

## When MEDIUM / LOW

- Unused subdomains left active in DNS zone files without continuous monitoring.

## Search patterns (suggestions)

```hcl
type\s*=\s*"CNAME"
aws_route53_record
cloudflare_record
\.github\.io
\.s3\.amazonaws\.com
```

## Examples

### BAD — Dangling CNAME in Terraform Manifest
```hcl
# BAD: CNAME points to deleted GitHub Pages site 'old-docs.github.io'
resource "cloudflare_record" "docs" {
  zone_id = var.cloudflare_zone_id
  name    = "docs"
  value   = "old-docs.github.io" # If old-docs is deleted, attacker claims it!
  type    = "CNAME"
  proxied = true
}
```

### GOOD — Decommissioning DNS Record Alongside Service Removal
```hcl
# GOOD: Remove DNS CNAME record immediately when deleting third-party edge instance
# Always verify external endpoint availability before pointing CNAME
resource "cloudflare_record" "docs" {
  zone_id = var.cloudflare_zone_id
  name    = "docs"
  value   = "active-app.pages.dev"
  type    = "CNAME"
  proxied = true
}
```

## Fix recommendation

1. Remove DNS CNAME records *before* or *simultaneously* when deleting external cloud resources (Cloudflare Pages, S3 buckets, Vercel projects).
2. Continuously audit DNS zone records for resolution to non-existent target origins (`NXDOMAIN` or 404 responses from third-party hosting providers).
