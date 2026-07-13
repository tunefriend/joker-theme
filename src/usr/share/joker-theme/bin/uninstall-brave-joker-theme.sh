#!/usr/bin/env bash
set -euo pipefail

THEME_ROOT="${JOKER_THEME_ROOT:-/usr/share/joker-theme}"
EXT_ID=$(tr -d '[:space:]' < "$THEME_ROOT/brave/extension_id.txt")
BRAVE_PROFILE="${BRAVE_PROFILE:-$HOME/.config/BraveSoftware/Brave-Browser/Default}"
PREFS="$BRAVE_PROFILE/Preferences"
FORCE_QUIT=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force-quit) FORCE_QUIT=1; shift ;;
    -h|--help) echo "Usage: joker-brave-theme-remove [--force-quit]"; exit 0 ;;
    *) exit 1 ;;
  esac
done

brave_running() { pgrep -u "$(id -u)" -f '/opt/brave.com/brave/brave' >/dev/null 2>&1; }

if brave_running; then
  if [[ "$FORCE_QUIT" -eq 1 ]]; then
    pkill -u "$(id -u)" -f '/opt/brave.com/brave/brave' || true
    for _ in $(seq 1 40); do brave_running || break; sleep 0.25; done
    brave_running && { echo "Brave still running" >&2; exit 1; }
    sleep 0.5
  else
    echo "Quit Brave first or use --force-quit" >&2; exit 2
  fi
fi

python3 - "$PREFS" "$EXT_ID" <<'PY'
import json, sys, os
prefs_path, ext_id = sys.argv[1:3]
with open(prefs_path, "r", encoding="utf-8") as f:
    prefs = json.load(f)
ext = prefs.get("extensions", {})
ext.get("settings", {}).pop(ext_id, None)
theme = ext.get("theme")
if isinstance(theme, dict) and theme.get("id") == ext_id:
    ext["theme"] = {"use_system": True}
tmp = prefs_path + ".tmp"
with open(tmp, "w", encoding="utf-8") as f:
    json.dump(prefs, f, separators=(",", ":"), ensure_ascii=False)
os.replace(tmp, prefs_path)
print("Removed from Preferences")
PY
rm -rf "$BRAVE_PROFILE/Extensions/$EXT_ID"
echo "Joker Brave theme uninstalled."
