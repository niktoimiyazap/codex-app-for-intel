#!/usr/bin/env bash
set -euo pipefail

export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH:-}"

DMG_URL="${DMG_URL:-https://persistent.oaistatic.com/codex-app-prod/Codex.dmg}"
WORK_DIR="${WORK_DIR:-$(pwd)/.build-work}"
DIST_DIR="${DIST_DIR:-$(pwd)/dist}"
NPM_PACKAGE="${NPM_PACKAGE:-@openai/codex}"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

for c in curl hdiutil ditto codesign npm awk sort unzip mktemp; do
  need_cmd "$c"
done

if [[ "$(uname -m)" != "x86_64" ]]; then
  echo "This build script is intended for Intel macOS (x86_64)." >&2
  exit 1
fi

mkdir -p "$WORK_DIR" "$DIST_DIR"
DMG_PATH="$WORK_DIR/Codex.dmg"
MOUNT_POINT="$WORK_DIR/mount"
APP_BUILD="$WORK_DIR/Codex.app"

rm -rf "$APP_BUILD" "$MOUNT_POINT"
mkdir -p "$MOUNT_POINT"

echo "Downloading Codex.dmg..."
curl -fL "$DMG_URL" -o "$DMG_PATH"

echo "Mounting DMG..."
hdiutil attach "$DMG_PATH" -mountpoint "$MOUNT_POINT" -nobrowse -readonly >/dev/null

cleanup_mount() {
  hdiutil detach "$MOUNT_POINT" >/dev/null 2>&1 || true
}
trap cleanup_mount EXIT

src_app="$(find "$MOUNT_POINT" -maxdepth 3 -type d -name 'Codex.app' | head -n1 || true)"
if [[ -z "$src_app" ]]; then
  echo "Codex.app was not found inside DMG." >&2
  exit 1
fi

echo "Copying app bundle..."
ditto "$src_app" "$APP_BUILD"

echo "Ensuring latest ${NPM_PACKAGE} is installed globally..."
latest_ver="$(npm view "$NPM_PACKAGE" version 2>/dev/null || true)"
if [[ -n "$latest_ver" ]]; then
  npm install -g "$NPM_PACKAGE@$latest_ver" >/dev/null 2>&1 || true
fi

npm_root="$(npm root -g)"
src_bin="$npm_root/$NPM_PACKAGE/node_modules/@openai/codex-darwin-x64/vendor/x86_64-apple-darwin/codex/codex"
if [[ ! -x "$src_bin" ]]; then
  src_bin="/usr/local/lib/node_modules/$NPM_PACKAGE/node_modules/@openai/codex-darwin-x64/vendor/x86_64-apple-darwin/codex/codex"
fi
if [[ ! -x "$src_bin" ]]; then
  echo "Could not find x64 codex binary from ${NPM_PACKAGE}." >&2
  exit 1
fi

app_bin_main="$APP_BUILD/Contents/Resources/codex"
app_bin_asar="$APP_BUILD/Contents/Resources/app.asar.unpacked/codex"

if [[ ! -x "$app_bin_main" || ! -x "$app_bin_asar" ]]; then
  echo "Target binaries not found in copied app bundle." >&2
  exit 1
fi

old_cli="$($app_bin_main --version 2>/dev/null | awk '{print $2}')"
new_cli="$($src_bin --version 2>/dev/null | awk '{print $2}')"
app_ver=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP_BUILD/Contents/Info.plist" 2>/dev/null || echo "unknown")

echo "Patching embedded CLI: ${old_cli:-unknown} -> ${new_cli:-unknown}"
cp -f "$src_bin" "$app_bin_main"
cp -f "$src_bin" "$app_bin_asar"
chmod 755 "$app_bin_main" "$app_bin_asar"

printf "Re-signing app bundle...\n"
codesign --force --deep --sign - "$APP_BUILD" >/dev/null 2>&1

zip_name="Codex-App-for-Intel-${app_ver}-cli-${new_cli}.zip"
zip_path="$DIST_DIR/$zip_name"
rm -f "$zip_path"

echo "Packaging zip: $zip_path"
ditto -c -k --sequesterRsrc --keepParent "$APP_BUILD" "$zip_path"

shasum -a 256 "$zip_path" | awk '{print "SHA256 " $1}'
echo "Build complete: $zip_path"
