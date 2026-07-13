# Joker Theme for GNOME (Debian package)

Void black · royal purple · toxic green

## Commands

```bash
joker-theme                 # apply desktop (green + geometry)
joker-theme --purple
joker-theme --wallpaper chaos
joker-theme-revert

joker-brave-theme --force-quit
joker-brave-theme-remove --force-quit
```

## Package contents

- Desktop: GTK CSS, wallpapers, GNOME Terminal palette helpers
- Plymouth boot splash (`joker`)
- GDM login wallpaper + banner
- Brave browser Chromium theme

## Paths

| Item | Location |
|------|----------|
| Theme data | `/usr/share/joker-theme/` |
| Wallpapers | `/usr/share/backgrounds/joker/` |
| Plymouth | `/usr/share/plymouth/themes/joker/` |
| GDM drop-in | `/usr/share/gdm/dconf/95-joker-theme` |
| GTK theme | `/usr/share/themes/Joker/` |

System pieces (Plymouth/GDM) are configured on package install.
Desktop + Brave need the user commands above (or are applied once from postinst for the installing user).
