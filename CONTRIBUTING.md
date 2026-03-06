# Contributing

Thanks for helping improve Codex App for Intel.

## Development Setup

1. Fork this repository.
2. Create a feature branch from `main`.
3. Make changes with clear commit messages.
4. Run basic checks:
   - `bash -n install.sh scripts/build-intel-app.sh scripts/install-local-zip.sh`
5. Open a pull request with a concise description and test notes.

## Scope

This project aims to stay:

- Simple for end users (one-command install).
- Practical for maintainers (easy release packaging).
- Transparent (plain shell scripts).
- Focused on Intel compatibility.

## Style

- Keep scripts readable and explicit.
- Prefer reliability over clever one-liners.
- Add comments only where logic is non-obvious.
