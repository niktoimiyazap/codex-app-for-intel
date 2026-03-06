#!/usr/bin/env bash
set -euo pipefail

REPO="${REPO:-niktoimiyazap/codex-app-for-intel}"
API_URL="https://api.github.com/repos/${REPO}/releases/latest"
ASSET_PATTERN="${ASSET_PATTERN:-Codex-App-for-Intel-.*\\.zip$}"
APP_DEST="${APP_DEST:-/Applications/Codex.app}"
TMP_DIR="$(mktemp -d /tmp/codex-intel-install.XXXXXX)"

cleanup() {
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
need_cmd python3
need_cmd unzip
need_cmd ditto
need_cmd osascript

echo "Fetching latest release metadata from ${REPO}..."
json_file="$TMP_DIR/release.json"
curl -fsSL "$API_URL" -o "$json_file"

asset_url="$TMP_DIR/asset_url.txt"
python3 - "$json_file" "$ASSET_PATTERN" > "$asset_url" <<'PY'
import json, re, sys
p = sys.argv[1]
pattern = re.compile(sys.argv[2])
with open(p, "r", encoding="utf-8") as f:
    data = json.load(f)
assets = data.get("assets", [])
for a in assets:
    name = a.get("name", "")
    if pattern.search(name):
        print(a.get("browser_download_url", ""))
        sys.exit(0)
print("")
sys.exit(1)
PY

url="$(cat "$asset_url")"
if [[ -z "$url" ]]; then
  echo "No release asset matching ${ASSET_PATTERN} was found." >&2
  echo "Open: https://github.com/${REPO}/releases" >&2
  exit 1
fi

zip_path="$TMP_DIR/app.zip"
unpack_dir="$TMP_DIR/unpack"
mkdir -p "$unpack_dir"

echo "Downloading: $url"
curl -fL "$url" -o "$zip_path"

echo "Unpacking app..."
unzip -q "$zip_path" -d "$unpack_dir"
app_src="$(find "$unpack_dir" -maxdepth 3 -type d -name 'Codex.app' | head -n1 || true)"
if [[ -z "$app_src" ]]; then
  echo "Codex.app was not found in release zip." >&2
  exit 1
fi

if [[ -d "$APP_DEST" ]]; then
  backup="${APP_DEST}.backup-$(date +%Y%m%d-%H%M%S)"
  echo "Backing up existing app to: $backup"
  mv "$APP_DEST" "$backup"
fi

echo "Installing app to: $APP_DEST"
ditto "$app_src" "$APP_DEST"

echo "Opening Codex.app..."
open -a "$APP_DEST" || true

echo "Done. Installed from latest release of ${REPO}."
