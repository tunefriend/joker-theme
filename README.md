# Joker Theme for GNOME (Debian)

Dark Joker-inspired desktop theme pack: **void black**, **royal purple**, and **toxic green**.

Includes wallpapers, GTK3/GTK4 CSS, GNOME settings helpers, Plymouth boot splash, GDM login styling, and a Brave browser theme.

## Install (Debian / Ubuntu / similar)

```bash
sudo apt install ./joker-theme_1.0.0_all.deb
```

Or download the `.deb` from [Releases](https://github.com/tunefriend/joker-theme/releases).

### Apply the theme

```bash
joker-theme                 # desktop (green + geometry wallpaper)
joker-theme --purple
joker-theme --wallpaper chaos
joker-theme-revert

joker-brave-theme --force-quit
joker-brave-theme-remove --force-quit
```

## Package contents

| Item | Location |
|------|----------|
| Theme data | `/usr/share/joker-theme/` |
| Wallpapers | `/usr/share/backgrounds/joker/` |
| Plymouth | `/usr/share/plymouth/themes/joker/` |
| GDM drop-in | `/usr/share/gdm/dconf/95-joker-theme` |
| GTK theme | `/usr/share/themes/Joker/` |

System pieces (Plymouth/GDM) are configured on package install. Desktop and Brave need the user commands above.

## Dependencies

- **Depends:** `dconf-cli`, `gsettings-desktop-schemas`, `python3`
- **Recommends:** `plymouth`, `plymouth-label`, `gdm3`, `gnome-terminal`, `rsync`
- **Suggests:** `brave-browser`, `gnome-shell`

## Rebuild the `.deb` from this repo

```bash
# From the repo root, rebuild using the staged tree:
rm -rf /tmp/joker-build
mkdir -p /tmp/joker-build
cp -a src/usr /tmp/joker-build/
mkdir -p /tmp/joker-build/DEBIAN
cp debian/control debian/postinst debian/postrm debian/prerm /tmp/joker-build/DEBIAN/
chmod 755 /tmp/joker-build/DEBIAN/postinst /tmp/joker-build/DEBIAN/postrm /tmp/joker-build/DEBIAN/prerm
dpkg-deb --build /tmp/joker-build joker-theme_1.0.0_all.deb
```

## License

MIT — see [debian/copyright](debian/copyright).

Made with 🃏 by friends of TuneFriend.
