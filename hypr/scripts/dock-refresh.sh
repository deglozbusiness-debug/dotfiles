#!/usr/bin/env bash
# dock-refresh.sh — reinicia la instancia de Cairo-Dock en DP-1.
# Cairo-Dock cachea launchers e iconos en memoria; al agregar/quitar/reordenar
# o re-categorizar .desktop files, a veces no detecta el cambio en vivo.
# Este atajo lo fuerza.
pkill cairo-dock 2>/dev/null
sleep 0.6
nohup cairo-dock -o -L -a -t -d "$HOME/.config/cairo-dock-dp1" >/dev/null 2>&1 & disown
