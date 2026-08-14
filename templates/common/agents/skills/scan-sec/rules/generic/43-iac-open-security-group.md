---
id: IAC-OPEN-SECURITY-GROUP
severity_max: HIGH
applies_to: tf, hcl, yaml, json
---

# IaC Open Security Group Ingress & Hardcoded Cloud Credentials

## Intent

Detects Infrastructure as Code (Terraform `.tf`, CloudFormation, Pulumi) security misconfigurations such as exposing administration or database ports (22 SSH, 3389 RDP, 27017 MongoDB, 5432 Postgres, 3306 MySQL) to the entire internet (`0.0.0.0/0`), or hardcoding cloud provider secret keys (`access_key`, `secret_key`) directly inside IaC manifests.

Reference OWASP Cheat Sheet Series: `Infrastructure_as_Code_Security_Cheat_Sheet.md` & `Secrets_Management_Cheat_Sheet.md`.

## When HIGH / CRITICAL

- Security Group ingress rule allows `0.0.0.0/0` on sensitive ports (22, 3389, 5432, 27017, 6379).
- Hardcoded AWS `access_key` / `secret_key` or GCP credentials in Terraform provider blocks.

## When MEDIUM / LOW

- S3 Bucket missing default server-side encryption or block public access settings.

## Search patterns (suggestions)

```hcl
cidr_blocks\s*=\s*\[\s*"0\.0\.0\.0/0"\s*\]
access_key\s*=\s*"AKIA
secret_key\s*=\s*
0\.0\.0\.0/0
```

## Examples

### BAD — Open SSH Port to 0.0.0.0/0 & Hardcoded AWS Keys
```hcl
# BAD: Hardcoded secret keys & SSH port 22 open to the world
provider "aws" {
  region     = "us-east-1"
  access_key = "AKIA1234567890EXAMPLE" # BAD: Hardcoded credentials!
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}

resource "aws_security_group" "allow_ssh" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # BAD: Open SSH to entire internet!
  }
}
```

### GOOD — Environment Variables & Restricted CIDR Ingress
```hcl
# GOOD: Credentials supplied via environment variables; SSH restricted to corporate VPN IP
provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "allow_ssh" {
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["198.51.100.4/32"] # Restrict to specific VPN IP
  }
}
```

## Fix recommendation

1. Restrict ingress rules for management (22, 3389) and database ports to specific corporate IP ranges or VPN gateways.
2. Store cloud credentials in environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`) or use IAM Instance Roles / OIDC Workload Identity.
3. Enforce static IaC security scanning tools (such as Checkov, TFSec, or TFLint) in CI pipelines.
