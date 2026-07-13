#!/usr/bin/env bash
# Apply the Joker GNOME desktop theme (user session)
set -euo pipefail

THEME_ROOT="${JOKER_THEME_ROOT:-/usr/share/joker-theme}"
BG_DIR="${JOKER_BG_DIR:-/usr/share/backgrounds/joker}"
# Prefer system paths; fall back to package share copies
[[ -d "$BG_DIR" ]] || BG_DIR="$THEME_ROOT/wallpapers"

ACCENT="green"
WALLPAPER=""

resolve_wallpaper() {
  case "$1" in
    chaos|joker-chaos)       echo "$BG_DIR/joker-chaos.jpg" ;;
    geometry|joker-geometry) echo "$BG_DIR/joker-geometry.jpg" ;;
    gradient|joker-gradient) echo "$BG_DIR/joker-gradient.jpg" ;;
    login|joker-login)       echo "$BG_DIR/joker-login.jpg" ;;
    *) echo "$1" ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --accent) ACCENT="${2:?}"; shift 2 ;;
    --wallpaper|-w) WALLPAPER=$(resolve_wallpaper "${2:?}"); shift 2 ;;
    --green) ACCENT="green"; WALLPAPER="$BG_DIR/joker-geometry.jpg"; shift ;;
    --purple) ACCENT="purple"; WALLPAPER="$BG_DIR/joker-chaos.jpg"; shift ;;
    -h|--help)
      cat <<EOF
Usage: joker-theme [options] [wallpaper]

  --green              Green accent + geometry wallpaper (default)
  --purple             Purple accent + chaos wallpaper
  --accent green|purple
  --wallpaper chaos|geometry|gradient|login|/path/to.jpg
EOF
      exit 0
      ;;
    -*) echo "Unknown option: $1" >&2; exit 1 ;;
    *) WALLPAPER=$(resolve_wallpaper "$1"); shift ;;
  esac
done

if [[ -z "$WALLPAPER" ]]; then
  WALLPAPER="$BG_DIR/joker-geometry.jpg"
  [[ "$ACCENT" == "purple" ]] && WALLPAPER="$BG_DIR/joker-chaos.jpg"
fi
[[ -f "$WALLPAPER" ]] || { echo "Wallpaper not found: $WALLPAPER" >&2; exit 1; }
[[ "$ACCENT" == "green" || "$ACCENT" == "purple" ]] || { echo "Accent must be green or purple" >&2; exit 1; }

echo "==> GTK CSS overrides"
mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
cp -f "$THEME_ROOT/gtk-3.0/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"
cp -f "$THEME_ROOT/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"

echo "==> GNOME settings (accent=$ACCENT)"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface accent-color "$ACCENT"
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'

URI="file://$WALLPAPER"
gsettings set org.gnome.desktop.background picture-uri "$URI"
gsettings set org.gnome.desktop.background picture-uri-dark "$URI"
gsettings set org.gnome.desktop.background picture-options 'zoom'
gsettings set org.gnome.desktop.background primary-color '#0c0a10'
gsettings set org.gnome.desktop.background secondary-color '#39ff14'
gsettings set org.gnome.desktop.screensaver picture-uri "$URI"
gsettings set org.gnome.desktop.screensaver picture-options 'zoom'
gsettings set org.gnome.desktop.screensaver primary-color '#0c0a10'
gsettings set org.gnome.desktop.screensaver secondary-color '#6b2d8b'

if gsettings list-schemas 2>/dev/null | grep -qx 'org.gnome.Terminal.ProfilesList'; then
  DEFAULT_PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
  PROFILE_PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${DEFAULT_PROFILE}/"
  gsettings set "$PROFILE_PATH" use-theme-colors false
  gsettings set "$PROFILE_PATH" background-color 'rgb(12,10,16)'
  gsettings set "$PROFILE_PATH" foreground-color 'rgb(232,228,240)'
  gsettings set "$PROFILE_PATH" cursor-colors-set true
  gsettings set "$PROFILE_PATH" cursor-background-color 'rgb(57,255,20)'
  gsettings set "$PROFILE_PATH" cursor-foreground-color 'rgb(12,10,16)'
  gsettings set "$PROFILE_PATH" highlight-colors-set true
  if [[ "$ACCENT" == "green" ]]; then
    gsettings set "$PROFILE_PATH" highlight-background-color 'rgb(45,212,15)'
    gsettings set "$PROFILE_PATH" highlight-foreground-color 'rgb(12,10,16)'
  else
    gsettings set "$PROFILE_PATH" highlight-background-color 'rgb(107,45,139)'
    gsettings set "$PROFILE_PATH" highlight-foreground-color 'rgb(255,255,255)'
  fi
  gsettings set "$PROFILE_PATH" use-transparent-background true 2>/dev/null || true
  gsettings set "$PROFILE_PATH" background-transparency-percent 8 2>/dev/null || true
  gsettings set "$PROFILE_PATH" palette "[
    'rgb(12,10,16)', 'rgb(230,57,70)', 'rgb(45,212,15)', 'rgb(230,168,23)',
    'rgb(155,77,202)', 'rgb(192,132,252)', 'rgb(80,250,123)', 'rgb(200,196,210)',
    'rgb(58,42,74)', 'rgb(255,107,117)', 'rgb(57,255,20)', 'rgb(255,214,102)',
    'rgb(192,132,252)', 'rgb(216,180,254)', 'rgb(134,239,172)', 'rgb(248,246,252)'
  ]"
  gsettings set "$PROFILE_PATH" visible-name 'Joker' 2>/dev/null || true
fi

echo "Joker desktop theme applied (accent=$ACCENT, wallpaper=$WALLPAPER)"
echo "Restart apps or log out/in so GTK CSS reloads everywhere."
