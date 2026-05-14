#!/usr/bin/env bash
# dock-refresh.sh — reinicia las dos instancias de Cairo-Dock (HDMI + DP-1).
# El symlink `cairo-dock-dp1/.../launchers` -> `cairo-dock/.../launchers` ya
# sincroniza el contenido, pero a veces (al agregar/quitar/reordenar iconos)
# Cairo-Dock no detecta el cambio en vivo. Este atajo lo fuerza.
pkill cairo-dock 2>/dev/null
sleep 0.6
nohup cairo-dock -o -L -a -t >/dev/null 2>&1 & disown
nohup cairo-dock -o -L -a -t -d "$HOME/.config/cairo-dock-dp1" >/dev/null 2>&1 & disown
