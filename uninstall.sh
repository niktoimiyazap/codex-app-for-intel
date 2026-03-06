#!/usr/bin/env bash
set -euo pipefail

BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
STATE_DIR="${STATE_DIR:-$HOME/.codex-intel-updater}"
LABEL="${LAUNCHD_LABEL:-com.codex-intel-updater}"
PLIST_PATH="$HOME/Library/LaunchAgents/$LABEL.plist"

launchctl unload "$PLIST_PATH" >/dev/null 2>&1 || true
rm -f "$PLIST_PATH"
rm -f "$BIN_DIR/codex-intel-update" "$BIN_DIR/codex-intel-status"

if [[ "${1:-}" == "--purge" ]]; then
  rm -rf "$STATE_DIR"
fi

echo "Uninstalled $LABEL."
if [[ "${1:-}" != "--purge" ]]; then
  echo "State directory preserved: $STATE_DIR"
  echo "Run with --purge to remove logs/backups."
fi
