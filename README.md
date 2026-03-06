# Codex App for Intel

Keep Codex GUI usable on older Intel Macs. For free.

This project updates the embedded x64 `codex` binary inside `/Applications/Codex.app` with safety-first backups, automatic rollback, and scheduled checks via `launchd`.

## Support This Project

If this helps your daily workflow, you can support development:

<p align="center">
  <a href="https://www.donationalerts.com/r/niktoimiya">
    <img alt="Donate via DonationAlerts" src="https://img.shields.io/badge/Donate-DonationAlerts-ff6b6b?style=for-the-badge&logo=buymeacoffee&logoColor=white">
  </a>
  <img alt="USDT TRC20" src="https://img.shields.io/badge/USDT-TRC20-26A17B?style=for-the-badge&logo=tether&logoColor=white">
</p>

- DonationAlerts: https://www.donationalerts.com/r/niktoimiya
- Crypto (USDT TRC20):
  - Address: `0xda2EB9c240816d5e555eA17Aa94E26C83a13C210`
  - Please double-check network and address details before sending.
- GitHub Sponsors: https://github.com/sponsors/niktoimiyazap

## Why This Exists

Codex Desktop update channels can move quickly and may not always cover every Intel setup cleanly.
This project provides a practical, transparent workaround for Intel Macs by updating the embedded CLI used by the app.

## Features

- Intel-focused (`x86_64`) updater workflow.
- Safe binary replacement with timestamped backups.
- Automatic rollback on failure.
- Ad-hoc re-signing after patching.
- Background auto-check every 6 hours via `launchd`.
- Manual status command and logs for troubleshooting.

## Requirements

- macOS on Intel (`x86_64`)
- `Codex.app` installed at `/Applications/Codex.app`
- `npm` available
- Global `@openai/codex` CLI install

## Quick Start

```bash
git clone https://github.com/niktoimiyazap/codex-app-for-intel.git
cd codex-app-for-intel
./install.sh
```

## Commands

```bash
codex-intel-status
codex-intel-update
```

## Uninstall

```bash
./uninstall.sh
# remove logs and backups as well
./uninstall.sh --purge
```

## File Layout

- `bin/codex-intel-update` updater logic
- `bin/codex-intel-status` diagnostics
- `launchd/com.codex-intel-updater.plist.template` launch agent template
- `install.sh` one-command installer
- `uninstall.sh` cleanup script

## Logs and Backups

- Logs: `~/.codex-intel-updater/logs/update.log`
- Launchd logs: `~/.codex-intel-updater/logs/launchd.out.log`, `launchd.err.log`
- Backups: `~/.codex-intel-updater/backups/`

## Safety Notes

- The updater always creates backups before replacing binaries.
- If validation fails, it restores previous binaries automatically.
- It modifies your local app bundle and re-signs it ad-hoc.
- Use at your own risk, and keep regular backups of your system.

## Contributing

Contributions are welcome. Please read `CONTRIBUTING.md`.

## Security

If you discover a vulnerability, please follow `SECURITY.md`.

## License

MIT — see `LICENSE`.

## Disclaimer

This is an independent community project and is not affiliated with OpenAI.
