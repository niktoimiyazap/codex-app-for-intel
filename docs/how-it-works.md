# How It Works

The updater follows this sequence:

1. Validate environment (`x86_64`, app path, required commands).
2. Check installed embedded version vs. latest global x64 `@openai/codex` binary.
3. Optionally update global npm package to latest version.
4. Stop `Codex.app` if running.
5. Create timestamped backups of embedded binaries.
6. Replace binaries in:
   - `/Applications/Codex.app/Contents/Resources/codex`
   - `/Applications/Codex.app/Contents/Resources/app.asar.unpacked/codex`
7. Re-sign app bundle ad-hoc (`codesign --force --deep --sign -`).
8. Validate resulting version.
9. On any failure, restore from backups.

A `launchd` agent runs this updater periodically in the background.
