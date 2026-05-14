# Aurora Twilight — Hyprland Desktop

> Premium glassmorphism desktop environment for CachyOS / Arch Linux.
> Hyprland 0.55 + Cairo-Dock + Waybar with custom plugins, inspired by macOS and Compiz.

![status](https://img.shields.io/badge/status-BETA-ff006e?style=flat-square)
![hyprland](https://img.shields.io/badge/hyprland-0.55-00d9ff?style=flat-square)
![distro](https://img.shields.io/badge/distro-CachyOS%20%2F%20Arch-b8b8ff?style=flat-square)
![license](https://img.shields.io/badge/license-MIT-1a1b3a?style=flat-square)

---

## ✨ Highlights

- **Glassmorphism Waybar** with the Aurora Twilight palette and real Hyprland blur underneath
- **Dual-monitor Cairo-Dock** — one instance per display, auto-hide, custom icons with hover glow
- **Custom minimize bridge** — Hyprland has no native minimize; this daemon parks each window in its own special workspace so restoring one never drags the others
- **Hyprexpo plugin** for Mission Control-style workspace overview (`Super + Tab` / `Super + ` `` ` ``)
- **System-wide GTK theming** — every menu and popover follows the Aurora palette; long submenus (GMenu "Other") get a `max-height` cap so they never overflow above the screen
- **60% keyboard optimized** — every binding is reachable without F-keys or numpad
- **Walker** app launcher with two themes (Aurora Twilight + Launchpad)

## 🎨 Aurora Twilight palette

| Token   | Hex       | Use                                          |
| ------- | --------- | -------------------------------------------- |
| base    | `#1a1b3a` | Backgrounds, terminal, bar                   |
| magenta | `#ff006e` | Primary accent — hover, glow, badges         |
| cyan    | `#00d9ff` | Active state, focus, indicators              |
| lavanda | `#b8b8ff` | Secondary text, subtle borders, tooltips     |

## 📸 Screenshots

> Coming in v0.2 — overview, dock close-up, expose, lock screen, terminal.

---

## 🧱 What's in here

| Path                                 | Purpose                                                                |
| ------------------------------------ | ---------------------------------------------------------------------- |
| `hypr/*.conf`                        | Monitors, bindings, autostart, animations, blur, shadow, plugin config |
| `hypr/scripts/`                      | Minimize bridge, dock toggle/refresh, launchpad helper                 |
| `waybar/`                            | Status bar config and glassmorphism CSS                                |
| `cairo-dock/`, `cairo-dock-dp1/`     | Dual-instance dock (main + DP-1 monitor)                               |
| `alacritty/`                         | Terminal with Aurora colors and 90% opacity                            |
| `gtk-3.0/`, `gtk-4.0/`               | System-wide menus and popovers — Aurora palette + max-height fix       |
| `walker/`                            | App launcher config + two themes                                       |
| `local/icons/`                       | Custom SVGs: `aurora-apps-folder`, `aurora-launchpad`, `vscode`        |
| `local/applications/`                | Custom `.desktop` entries (e.g. `claude-desktop` with dock toggle)     |
| `CLAUDE.md`                          | Project vision, design palette, and per-phase implementation log       |

---

## ⚙️ Install (CachyOS / Arch)

### 1. Dependencies

```bash
yay -S --needed \
    hyprland hypridle hyprlock hyprpicker hyprsunset \
    waybar cairo-dock walker alacritty \
    ttf-jetbrains-mono-nerd ttf-inter-variable \
    bibata-cursor-theme papirus-icon-theme \
    socat jq grimblast wl-clipboard
```

### 2. Clone & copy

```bash
git clone https://github.com/deglozbusiness-debug/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Configs
cp -r hypr waybar alacritty gtk-3.0 gtk-4.0 walker \
      cairo-dock cairo-dock-dp1 ~/.config/

# Custom icons + .desktop entries
mkdir -p ~/.local/share/icons ~/.local/share/applications
cp -r local/icons/.    ~/.local/share/icons/
cp -r local/applications/. ~/.local/share/applications/
update-desktop-database ~/.local/share/applications/
```

### 3. Hyprland plugin (Mission Control overview)

```bash
hyprpm update
hyprpm add  https://github.com/hyprwm/hyprland-plugins
hyprpm enable hyprexpo
hyprpm reload
```

> ⚠️ Do **not** add `hyprspace` — it is incompatible with Hyprland 0.55. Stick to `hyprexpo`.

### 4. Reload

```bash
hyprctl reload
# Open the dock manually first time if it didn't autostart:
cairo-dock -o -L -a -t &
```

### 5. Per-user adjustments

- **Monitors** — edit `~/.config/hypr/monitors.conf` to match your displays. Mine is dual 1920×1080: `DP-1 @ 180 Hz` + `HDMI-A-1 @ 144 Hz`.
- **`local/applications/claude-desktop.desktop`** — references `/home/deglozdev/...` paths. Change them to your `$HOME` or remove if you don't use Claude Desktop.

---

## ⌨️ Selected keybindings

The complete map lives in `hypr/bindings.conf`. Highlights:

### Windows
| Combo                   | Action                              |
| ----------------------- | ----------------------------------- |
| `Super + Q`             | Close window                        |
| `Super + H`             | Minimize focused window             |
| `Super + Shift + H`     | Restore all minimized               |
| `Super + Tab`           | Hyprexpo overview                   |
| `` Super + ` ``         | Hyprexpo workspace grid             |

### Launch
| Combo                   | Action                              |
| ----------------------- | ----------------------------------- |
| `Super + Return`        | Terminal                            |
| `Super + A`             | Claude Desktop (launch / focus)     |
| `Super + Shift + Return`| Browser (Thorium)                   |
| `Super + Shift + F`     | File manager (Nautilus)             |
| `Super + Shift + N`     | Editor                              |
| `Super + Shift + W`     | Typora                              |

### Workspaces
| Combo                | Action                |
| -------------------- | --------------------- |
| `Super + 1..9`       | Switch workspace      |
| `Super + Shift + 1..9` | Move window to ws   |

---

## 🛠️ Troubleshooting

| Symptom                                          | Diagnosis                                                                              | Fix                                                                                          |
| ------------------------------------------------ | -------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| Dock icon shows ✖ broken                          | `Icon=` in `.desktop` points to a missing path                                          | `grep ^Icon= *.desktop` and edit; run `gtk-update-icon-cache`                                |
| Click on dock app does nothing                   | `minimize-bridge.sh` not running                                                       | `pgrep -af minimize-bridge` should return two PIDs; if not, `hyprctl dispatch exec ~/.config/hypr/scripts/minimize-bridge.sh` |
| Claude Desktop opens gray / invisible             | Stale `SingletonLock` from a crashed instance                                          | `pkill -f claude-desktop-bin && rm -f ~/.config/Claude/Singleton*`                            |
| GMenu "Other" submenu cut off at the top         | GTK auto-positions popups upward when the dock is at the bottom                        | `gtk-3.0/gtk.css` already enforces `max-height: 600px` — adjust if you have a taller monitor |
| Hyprexpo missing after `hyprpm update`           | `hyprpm update` rebuilds from upstream and can drop plugins                            | `hyprpm add https://github.com/hyprwm/hyprland-plugins && hyprpm enable hyprexpo && hyprpm reload` |
| Waybar without blur                              | `layerrule = blur on, match:namespace waybar` missing                                  | Already in `hypr/looknfeel.conf`; ensure your `hyprland.conf` sources it                     |

---

## 📐 Hardware tested on

- **CPU** AMD Ryzen 7 5700U (Vega 8 integrated)
- **Display 1** Acer KG251Q P3 — 1920×1080 @ 180 Hz on `DP-1`
- **Display 2** KTC W2722SE — 1920×1080 @ 144 Hz on `HDMI-A-1`
- **Keyboard** 60% layout (no F-keys, no numpad — bindings reflect this)
- **GPU budget tuning** — `blur.passes = 2` (not 3) and `blur.popups = false` to keep frame budget in check on integrated graphics with two high-refresh displays

---

## 🗺️ Project status

Currently **BETA**. The visual layer is locked; remaining work tracked in [`CLAUDE.md`](./CLAUDE.md):

- [ ] Animated wallpaper via `swww` with per-workspace rotation
- [ ] `hyprlock` themed with the Aurora palette
- [ ] `swaync` notification center integration
- [ ] Screenshot showcase for the README

---

## 📜 License

MIT — fork it, learn from it, adapt it. If you ship something cool with it, a star or a mention is appreciated but not required.

## 🙏 Credits

- [Omarchy](https://omarchy.org/) — the Hyprland distribution this builds on
- [hyprwm](https://github.com/hyprwm) — Hyprland itself and the plugin ecosystem
- [Cairo-Dock](https://www.glx-dock.org/) — for the macOS-style zoom-on-hover dock
- Bibata Modern Ice cursor, Papirus icons, JetBrains Mono Nerd Font, Inter
- Visual references: macOS Sonoma, Compiz desktop cube, GNOME 46 overview

---

Built and maintained by [DeglozDev](https://github.com/deglozbusiness-debug).
