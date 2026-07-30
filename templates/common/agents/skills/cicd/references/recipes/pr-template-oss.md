# Recipe: OSS English-First Pull Request Template

> **Location:** `.github/PULL_REQUEST_TEMPLATE.md`

---

```markdown
## Description

Brief summary of the changes introduced in this pull request.

## Type of Change

- [ ] 🐛 Bug fix (non-breaking change fixing an issue)
- [ ] ✨ New feature (non-breaking change adding functionality)
- [ ] 💥 Breaking change (fix or feature causing existing functionality to change)
- [ ] 📝 Documentation update
- [ ] 🎨 Refactoring / Code quality improvement

## Verification Checklist

- [ ] `npx tsc --noEmit` passed cleanly locally
- [ ] `npx vitest run` passed cleanly locally
- [ ] Code follows existing project style & naming conventions
- [ ] No hardcoded production secrets or credentials included
- [ ] Relevant documentation updated (if applicable)

## Related Issue / Ticket

Fixes #
```
