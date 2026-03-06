# Codex App for Intel

A simple way to use Codex Desktop on older Intel Macs.

This project distributes a prebuilt Intel-friendly `Codex.app` package via GitHub Releases and provides a one-command installer.

## Support This Project

If this project helps you, you can support development:

- DonationAlerts: https://www.donationalerts.com/r/niktoimiya
- USDT (TRC20): `0xda2EB9c240816d5e555eA17Aa94E26C83a13C210`
- GitHub Sponsors: https://github.com/sponsors/niktoimiyazap

## Super Quick Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/niktoimiyazap/codex-app-for-intel/main/install.sh | bash
```

What it does:

1. Downloads the latest prebuilt release zip from this repository.
2. Backs up your current `/Applications/Codex.app` (if present).
3. Installs the downloaded app to `/Applications/Codex.app`.

## Manual Install

1. Open Releases: `https://github.com/niktoimiyazap/codex-app-for-intel/releases`
2. Download the latest `Codex-App-for-Intel-*.zip`
3. Unzip and move `Codex.app` to `/Applications`

## Maintainer Flow (Build New App Package)

Use this when you want to publish a new prebuilt package.

```bash
git clone https://github.com/niktoimiyazap/codex-app-for-intel.git
cd codex-app-for-intel
./scripts/build-intel-app.sh
```

Output:

- `dist/Codex-App-for-Intel-<app_version>-cli-<cli_version>.zip`

Then upload this zip to a new GitHub Release.

## Requirements (for building)

- Intel macOS (`x86_64`)
- `npm`
- `hdiutil`, `ditto`, `codesign`
- Global `@openai/codex` (or build script will try to update/install)

## Files

- `install.sh` one-command installer from GitHub Releases
- `scripts/build-intel-app.sh` build a patched Intel app zip
- `scripts/install-local-zip.sh` install from a local zip file

## Security Notes

- Always verify the release source and checksums before installing.
- The app bundle is ad-hoc re-signed during build.
- This project is community-maintained and not affiliated with OpenAI.

## License

MIT
