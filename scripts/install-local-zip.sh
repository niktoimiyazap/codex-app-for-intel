#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 /path/to/Codex-App-for-Intel.zip" >&2
  exit 1
fi

ZIP_PATH="$1"
APP_DEST="${APP_DEST:-/Applications/Codex.app}"
TMP_DIR="$(mktemp -d /tmp/codex-intel-local-install.XXXXXX)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

if [[ ! -f "$ZIP_PATH" ]]; then
  echo "File not found: $ZIP_PATH" >&2
  exit 1
fi

unzip -q "$ZIP_PATH" -d "$TMP_DIR"
app_src="$(find "$TMP_DIR" -maxdepth 3 -type d -name 'Codex.app' | head -n1 || true)"
if [[ -z "$app_src" ]]; then
  echo "Codex.app was not found inside zip." >&2
  exit 1
fi

if [[ -d "$APP_DEST" ]]; then
  backup="${APP_DEST}.backup-$(date +%Y%m%d-%H%M%S)"
  echo "Backing up current app to: $backup"
  mv "$APP_DEST" "$backup"
fi

ditto "$app_src" "$APP_DEST"
echo "Installed to $APP_DEST"
open -a "$APP_DEST" || true
