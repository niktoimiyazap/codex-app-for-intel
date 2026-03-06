# Codex App for Intel

Easy way to run Codex Desktop on older Intel Macs.

This repository provides a prebuilt Intel-friendly `Codex.app` through GitHub Releases and a one-command installer.

## OpenAI Notice

`Codex App` is an official OpenAI product.

This repository is a community-maintained Intel compatibility distribution workflow.  
It is not an official OpenAI release channel.

## Install (One Command)

```bash
curl -fsSL https://raw.githubusercontent.com/niktoimiyazap/codex-app-for-intel/main/install.sh | bash
```

## Update

Run the same install command again. It always pulls the latest release.

## Manual Install

1. Open Releases: https://github.com/niktoimiyazap/codex-app-for-intel/releases
2. Download the latest `Codex-App-for-Intel-*.zip`
3. Unzip and move `Codex.app` to `/Applications`

## What the Installer Does

1. Downloads the latest release zip.
2. Creates a backup of current `/Applications/Codex.app` (if present).
3. Installs the new app to `/Applications/Codex.app`.

## Rollback

If needed, restore your backup app:

```bash
mv /Applications/Codex.app.backup-YYYYMMDD-HHMMSS /Applications/Codex.app
```

## Support This Project

- DonationAlerts: https://www.donationalerts.com/r/niktoimiya
- USDT (TRC20): `0xda2EB9c240816d5e555eA17Aa94E26C83a13C210`
- GitHub Sponsors: https://github.com/sponsors/niktoimiyazap

## Disclaimer

`OpenAI` and `Codex` are trademarks of OpenAI.
This repository is maintained by independent contributors and is not affiliated with, endorsed by, or supported by OpenAI.

## License

MIT
