#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
STATE_DIR="${STATE_DIR:-$HOME/.codex-intel-updater}"
LABEL="${LAUNCHD_LABEL:-com.codex-intel-updater}"
PLIST_PATH="$HOME/Library/LaunchAgents/$LABEL.plist"

mkdir -p "$BIN_DIR" "$STATE_DIR/logs" "$STATE_DIR/backups" "$HOME/Library/LaunchAgents"

install -m 755 "$SCRIPT_DIR/bin/codex-intel-update" "$BIN_DIR/codex-intel-update"
install -m 755 "$SCRIPT_DIR/bin/codex-intel-status" "$BIN_DIR/codex-intel-status"

PROGRAM_PATH="$BIN_DIR/codex-intel-update"

sed \
  -e "s|__LABEL__|$LABEL|g" \
  -e "s|__PROGRAM__|$PROGRAM_PATH|g" \
  -e "s|__STATE_DIR__|$STATE_DIR|g" \
  "$SCRIPT_DIR/launchd/com.codex-intel-updater.plist.template" > "$PLIST_PATH"

launchctl unload "$PLIST_PATH" >/dev/null 2>&1 || true
launchctl load "$PLIST_PATH"

"$BIN_DIR/codex-intel-update" --quiet || true

cat <<MSG
Installed successfully.

Commands:
  codex-intel-status
  codex-intel-update

LaunchAgent:
  $PLIST_PATH
MSG
