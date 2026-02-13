# Contributing to PARA Workspace

Thank you for your interest in contributing to PARA Workspace!

## How to Contribute

### Reporting Issues

- Use GitHub Issues to report bugs or suggest features
- Include your kernel version (`cat VERSION`)

### Making Changes

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/my-feature`
3. Make your changes
4. Ensure test vectors pass (see `kernel/examples/`)
5. Submit a Pull Request

### Change Categories

| Change Type       | Process Required        | Version Impact |
| ----------------- | ----------------------- | -------------- |
| Kernel invariants | RFC in `docs/rfcs/`     | MAJOR bump     |
| Kernel heuristics | PR + review             | MINOR/PATCH    |
| New workflow      | PR + kernel_compat      | MINOR          |
| New profile       | PR + preset.yaml + test | MINOR          |
| CLI bug fix       | PR                      | PATCH          |
| Documentation     | PR                      | PATCH          |

### Commit Convention

```
feat(kernel): add decision-plan schema validation
fix(cli): resolve init.sh path detection on macOS
docs: update migration guide for v1.4
refactor(templates): restructure profile presets
```

### RFC Process (for Invariant Changes)

1. Create an RFC document in `docs/rfcs/`
2. Title: `RFC-XXXX: <title>`
3. Include: motivation, proposal, alternatives, migration impact
4. Allow community review period
5. If accepted: implement, update test vectors, bump MAJOR version

## Code of Conduct

Be respectful, constructive, and inclusive in all interactions.
