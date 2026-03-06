# Contributing

Thanks for helping improve Codex App for Intel.

## Development Setup

1. Fork this repository.
2. Create a feature branch from `main`.
3. Make changes with clear commit messages.
4. Run basic checks:
   - `bash -n bin/codex-intel-update bin/codex-intel-status install.sh uninstall.sh`
5. Open a pull request with a concise description and test notes.

## Scope

This project aims to stay:

- Small and maintainable.
- Intel-focused.
- Safe by default (backup + rollback).
- Transparent (plain shell scripts).

## Style

- Keep scripts POSIX-like Bash where practical.
- Prefer readability over clever shortcuts.
- Add comments only where logic is non-obvious.
