#!/usr/bin/env bash
# Revert Joker GNOME desktop theme (user session)
set -euo pipefail

rm -f "$HOME/.config/gtk-3.0/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"

gsettings set org.gnome.desktop.interface color-scheme 'default'
gsettings set org.gnome.desktop.interface accent-color 'blue'
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'
gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/images/desktop-base/desktop-background.xml' 2>/dev/null || true
gsettings set org.gnome.desktop.background picture-uri-dark 'file:///usr/share/backgrounds/gnome/adwaita-d.jpg' 2>/dev/null || true
gsettings set org.gnome.desktop.background picture-options 'zoom'
gsettings set org.gnome.desktop.screensaver picture-uri 'file:///usr/share/backgrounds/gnome/adwaita-d.jpg' 2>/dev/null || true

if gsettings list-schemas 2>/dev/null | grep -qx 'org.gnome.Terminal.ProfilesList'; then
  DEFAULT_PROFILE=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
  PROFILE_PATH="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:${DEFAULT_PROFILE}/"
  gsettings set "$PROFILE_PATH" use-theme-colors true
  gsettings set "$PROFILE_PATH" use-transparent-background false 2>/dev/null || true
  gsettings set "$PROFILE_PATH" visible-name 'Default' 2>/dev/null || true
fi

echo "Joker desktop theme reverted to stock GNOME defaults."
