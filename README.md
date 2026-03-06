# Codex App for Intel

Easy way to run Codex Desktop on older Intel Macs.

This project installs and patches `Codex.app` directly on your Intel Mac in one command.
No local repo build and no manual release asset download are required.

## OpenAI Notice

`Codex App` is an official OpenAI product.

This repository is a community-maintained Intel compatibility distribution workflow.  
It is not an official OpenAI release channel.

## Install (One Command)

```bash
curl -fsSL https://raw.githubusercontent.com/niktoimiyazap/codex-app-for-intel/main/install.sh | bash
```

The script may ask for your admin password when writing to `/Applications`.

## Update

Run the same install command again.

## What the Installer Does

1. Downloads official `Codex.dmg`.
2. Extracts `Codex.app`.
3. Installs latest `@openai/codex` and injects x64 CLI into app bundle.
4. Creates backup of current `/Applications/Codex.app` (if present).
5. Installs patched app to `/Applications/Codex.app`.

## Network Reliability Tweaks

If your network is unstable or restricted, run with overrides:

```bash
RETRY_COUNT=12 CONNECT_TIMEOUT=30 SPEED_LIMIT=512 \
curl -fsSL https://raw.githubusercontent.com/niktoimiyazap/codex-app-for-intel/main/install.sh | bash
```

Proxy example:

```bash
HTTPS_PROXY=http://127.0.0.1:7890 \
curl -fsSL https://raw.githubusercontent.com/niktoimiyazap/codex-app-for-intel/main/install.sh | bash
```

Custom DMG source list (comma-separated):

```bash
DMG_URLS="https://persistent.oaistatic.com/codex-app-prod/Codex.dmg,https://your-mirror.example/Codex.dmg" \
curl -fsSL https://raw.githubusercontent.com/niktoimiyazap/codex-app-for-intel/main/install.sh | bash
```

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
