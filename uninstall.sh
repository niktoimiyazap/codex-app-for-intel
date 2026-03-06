#!/usr/bin/env bash
set -euo pipefail

APP_DEST="${APP_DEST:-/Applications/Codex.app}"

if [[ ! -d "$APP_DEST" ]]; then
  echo "Codex.app is not installed at $APP_DEST"
  exit 0
fi

backup="${APP_DEST}.backup-$(date +%Y%m%d-%H%M%S)"

echo "Moving current app to backup: $backup"
mv "$APP_DEST" "$backup"

echo "Done."
echo "If needed, restore with: mv '$backup' '$APP_DEST'"
