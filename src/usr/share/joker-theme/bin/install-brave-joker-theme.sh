#!/usr/bin/env bash
# Install the Joker theme into Brave Browser
set -euo pipefail

THEME_ROOT="${JOKER_THEME_ROOT:-/usr/share/joker-theme}"
THEME_SRC="$THEME_ROOT/brave/joker-theme"
EXT_ID_FILE="$THEME_ROOT/brave/extension_id.txt"
BRAVE_PROFILE="${BRAVE_PROFILE:-$HOME/.config/BraveSoftware/Brave-Browser/Default}"
PREFS="$BRAVE_PROFILE/Preferences"
FORCE_QUIT=0
RELAUNCH=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force-quit) FORCE_QUIT=1; shift ;;
    --no-relaunch) RELAUNCH=0; shift ;;
    -h|--help) echo "Usage: joker-brave-theme [--force-quit] [--no-relaunch]"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

[[ -f "$THEME_SRC/manifest.json" ]] || { echo "Theme missing: $THEME_SRC" >&2; exit 1; }
[[ -f "$EXT_ID_FILE" ]] || { echo "Missing extension id" >&2; exit 1; }
[[ -f "$PREFS" ]] || { echo "Brave Preferences not found: $PREFS" >&2; exit 1; }

EXT_ID=$(tr -d '[:space:]' < "$EXT_ID_FILE")
VERSION=$(python3 -c 'import json; print(json.load(open("'"$THEME_SRC"'/manifest.json"))["version"])')
DEST_DIR="$BRAVE_PROFILE/Extensions/$EXT_ID/${VERSION}_0"

brave_running() {
  pgrep -u "$(id -u)" -f '/opt/brave.com/brave/brave' >/dev/null 2>&1
}

if brave_running; then
  if [[ "$FORCE_QUIT" -eq 1 ]]; then
    echo "==> Quitting Brave..."
    pkill -u "$(id -u)" -f '/opt/brave.com/brave/brave' || true
    for _ in $(seq 1 40); do brave_running || break; sleep 0.25; done
    brave_running && { echo "Brave still running; quit it and re-run." >&2; exit 1; }
    sleep 0.5
  else
    echo "Brave is running. Re-run with --force-quit, or quit Brave first." >&2
    exit 2
  fi
fi

echo "==> Installing theme → $DEST_DIR"
mkdir -p "$DEST_DIR"
if command -v rsync >/dev/null; then
  rsync -a --delete "$THEME_SRC/" "$DEST_DIR/"
else
  rm -rf "$DEST_DIR"
  mkdir -p "$DEST_DIR"
  cp -a "$THEME_SRC/." "$DEST_DIR/"
fi

python3 - "$PREFS" "$EXT_ID" "$DEST_DIR" "$VERSION" <<'PY'
import json, sys, time, os, shutil
from pathlib import Path
prefs_path, ext_id, dest_dir, version = sys.argv[1:5]
manifest = json.loads(Path(dest_dir, "manifest.json").read_text())
install_time = str(int((time.time() + 11644473600) * 1_000_000))
bak = prefs_path + ".joker-bak"
if not os.path.exists(bak):
    shutil.copy2(prefs_path, bak)
with open(prefs_path, "r", encoding="utf-8") as f:
    prefs = json.load(f)
ext = prefs.setdefault("extensions", {})
settings = ext.setdefault("settings", {})
settings[ext_id] = {
    "account_extension_type": 0,
    "active_permissions": {"api": [], "explicit_host": [], "manifest_permissions": [], "scriptable_host": []},
    "commands": {},
    "content_settings": [],
    "creation_flags": 1,
    "from_webstore": False,
    "granted_permissions": {"api": [], "explicit_host": [], "manifest_permissions": [], "scriptable_host": []},
    "incognito_content_settings": [],
    "incognito_preferences": {},
    "install_time": install_time,
    "location": 4,
    "manifest": manifest,
    "path": f"{ext_id}/{version}_0",
    "preferences": {},
    "regular_only_preferences": {},
    "state": 1,
    "was_installed_by_default": False,
    "was_installed_by_oem": False,
    "withholding_permissions": False,
}
ext["theme"] = {"id": ext_id, "use_system": False}
tmp = prefs_path + ".tmp"
with open(tmp, "w", encoding="utf-8") as f:
    json.dump(prefs, f, separators=(",", ":"), ensure_ascii=False)
os.replace(tmp, prefs_path)
print(f"Theme activated: {ext_id}")
PY

if [[ "$RELAUNCH" -eq 1 ]]; then
  if command -v brave-browser-stable >/dev/null; then
    nohup brave-browser-stable >/dev/null 2>&1 &
  elif command -v brave-browser >/dev/null; then
    nohup brave-browser >/dev/null 2>&1 &
  fi
fi
echo "Joker Brave theme installed."
