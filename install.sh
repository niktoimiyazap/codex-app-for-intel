#!/usr/bin/env bash
set -euo pipefail

export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH:-}"

APP_DEST="${APP_DEST:-/Applications/Codex.app}"
NPM_PACKAGE="${NPM_PACKAGE:-@openai/codex}"
DMG_URLS="${DMG_URLS:-https://persistent.oaistatic.com/codex-app-prod/Codex.dmg}"
RETRY_COUNT="${RETRY_COUNT:-8}"
CONNECT_TIMEOUT="${CONNECT_TIMEOUT:-20}"
SPEED_TIME="${SPEED_TIME:-30}"
SPEED_LIMIT="${SPEED_LIMIT:-1024}"

TMP_DIR="$(mktemp -d /tmp/codex-intel-install.XXXXXX)"
MOUNT_POINT="$TMP_DIR/mount"
DMG_PATH="$TMP_DIR/Codex.dmg"
APP_BUILD="$TMP_DIR/Codex.app"
mounted=0

cleanup() {
  if [[ "$mounted" -eq 1 ]]; then
    hdiutil detach "$MOUNT_POINT" >/dev/null 2>&1 || true
  fi
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

need_cmd curl
need_cmd hdiutil
need_cmd ditto
need_cmd npm
need_cmd codesign
need_cmd find
need_cmd awk
need_cmd sed
need_cmd sudo

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This installer only supports macOS." >&2
  exit 1
fi

if [[ "$(uname -m)" != "x86_64" ]]; then
  echo "This installer is for Intel Macs (x86_64)." >&2
  exit 1
fi

run_privileged() {
  if [[ -w "/Applications" ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

download_with_curl() {
  local url="$1"
  local out="$2"
  curl --fail --location \
    --continue-at - \
    --retry "$RETRY_COUNT" \
    --retry-all-errors \
    --retry-delay 2 \
    --connect-timeout "$CONNECT_TIMEOUT" \
    --speed-time "$SPEED_TIME" \
    --speed-limit "$SPEED_LIMIT" \
    --user-agent "CodexIntelInstaller/1.0" \
    "$url" -o "$out"
}

download_dmg() {
  local raw_url trimmed
  IFS=',' read -r -a urls <<< "$DMG_URLS"
  for raw_url in "${urls[@]}"; do
    trimmed="$(printf '%s' "$raw_url" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [[ -z "$trimmed" ]] && continue

    echo "Downloading Codex.dmg from: $trimmed"
    if download_with_curl "$trimmed" "$DMG_PATH"; then
      return 0
    fi

    echo "Retrying with HTTP/1.1 strategy..."
    if curl --fail --location --http1.1 \
      --continue-at - \
      --retry "$RETRY_COUNT" \
      --retry-all-errors \
      --retry-delay 2 \
      --connect-timeout "$CONNECT_TIMEOUT" \
      --speed-time "$SPEED_TIME" \
      --speed-limit "$SPEED_LIMIT" \
      --user-agent "CodexIntelInstaller/1.0" \
      "$trimmed" -o "$DMG_PATH"; then
      return 0
    fi

    rm -f "$DMG_PATH"
  done
  return 1
}

get_latest_version() {
  local i latest
  for ((i = 1; i <= RETRY_COUNT; i++)); do
    latest="$(npm view "$NPM_PACKAGE" version 2>/dev/null || true)"
    if [[ -n "$latest" ]]; then
      printf '%s\n' "$latest"
      return 0
    fi
    sleep $((i * 2))
  done
  return 1
}

install_cli_with_retries() {
  local version="$1"
  local i
  for ((i = 1; i <= RETRY_COUNT; i++)); do
    if NPM_CONFIG_FETCH_RETRIES="${NPM_FETCH_RETRIES:-6}" \
      NPM_CONFIG_FETCH_RETRY_FACTOR="${NPM_FETCH_RETRY_FACTOR:-2}" \
      NPM_CONFIG_FETCH_RETRY_MINTIMEOUT="${NPM_FETCH_RETRY_MINTIMEOUT:-2000}" \
      NPM_CONFIG_FETCH_RETRY_MAXTIMEOUT="${NPM_FETCH_RETRY_MAXTIMEOUT:-20000}" \
      npm install -g --no-fund --no-audit "${NPM_PACKAGE}@${version}" >/dev/null 2>&1; then
      return 0
    fi
    sleep $((i * 2))
  done
  return 1
}

mkdir -p "$MOUNT_POINT"

if ! download_dmg; then
  echo "Failed to download Codex.dmg. Set DMG_URLS or HTTPS_PROXY and try again." >&2
  exit 1
fi

echo "Mounting DMG..."
hdiutil attach "$DMG_PATH" -mountpoint "$MOUNT_POINT" -nobrowse -readonly >/dev/null
mounted=1

src_app="$(find "$MOUNT_POINT" -maxdepth 3 -type d -name 'Codex.app' | head -n1 || true)"
if [[ -z "$src_app" ]]; then
  echo "Codex.app was not found inside DMG." >&2
  exit 1
fi

echo "Preparing app bundle..."
ditto "$src_app" "$APP_BUILD"

echo "Resolving latest ${NPM_PACKAGE} version..."
latest_ver="$(get_latest_version || true)"
if [[ -z "$latest_ver" ]]; then
  echo "Failed to resolve latest ${NPM_PACKAGE} version from npm registry." >&2
  exit 1
fi

echo "Installing ${NPM_PACKAGE}@${latest_ver}..."
if ! install_cli_with_retries "$latest_ver"; then
  echo "npm install failed after retries. Check network/proxy and try again." >&2
  exit 1
fi

npm_root="$(npm root -g)"
src_bin=""
for candidate in \
  "$npm_root/$NPM_PACKAGE/node_modules/@openai/codex-darwin-x64/vendor/x86_64-apple-darwin/codex/codex" \
  "/usr/local/lib/node_modules/$NPM_PACKAGE/node_modules/@openai/codex-darwin-x64/vendor/x86_64-apple-darwin/codex/codex" \
  "/opt/homebrew/lib/node_modules/$NPM_PACKAGE/node_modules/@openai/codex-darwin-x64/vendor/x86_64-apple-darwin/codex/codex"
do
  if [[ -x "$candidate" ]]; then
    src_bin="$candidate"
    break
  fi
done

if [[ -z "$src_bin" ]]; then
  echo "Could not find x64 codex binary in global ${NPM_PACKAGE} install." >&2
  exit 1
fi

app_bin_main="$APP_BUILD/Contents/Resources/codex"
app_bin_asar="$APP_BUILD/Contents/Resources/app.asar.unpacked/codex"
if [[ ! -x "$app_bin_main" || ! -x "$app_bin_asar" ]]; then
  echo "Target binaries not found in app bundle." >&2
  exit 1
fi

old_cli="$("$app_bin_main" --version 2>/dev/null | awk '{print $2}')"
new_cli="$("$src_bin" --version 2>/dev/null | awk '{print $2}')"
app_ver=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP_BUILD/Contents/Info.plist" 2>/dev/null || echo "unknown")

echo "Patching embedded CLI: ${old_cli:-unknown} -> ${new_cli:-unknown}"
cp -f "$src_bin" "$app_bin_main"
cp -f "$src_bin" "$app_bin_asar"
chmod 755 "$app_bin_main" "$app_bin_asar"

echo "Re-signing app bundle..."
codesign --force --deep --sign - "$APP_BUILD" >/dev/null 2>&1 || true

if [[ -d "$APP_DEST" ]]; then
  backup="${APP_DEST}.backup-$(date +%Y%m%d-%H%M%S)"
  echo "Backing up existing app to: $backup"
  run_privileged mv "$APP_DEST" "$backup"
fi

echo "Installing app to: $APP_DEST"
run_privileged ditto "$APP_BUILD" "$APP_DEST"

echo "Opening Codex.app..."
open -a "$APP_DEST" || true

echo "Done."
echo "Installed Codex.app ${app_ver} with CLI ${new_cli:-unknown} for Intel macOS."
