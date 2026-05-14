#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────
# launchpad.sh — rejilla de apps estilo macOS Launchpad, via Walker.
#
# Lo dispara el clic en el boton del lobo (arriba-izquierda de Waybar),
# ver `custom/omarchy` en ~/.config/waybar/config.jsonc. Tambien sirve
# para un atajo de teclado si lo quieres.
#
# Usa el tema "launchpad" (~/.config/walker/themes/launchpad/) que pone
# la lista en rejilla (GtkGridView max_columns=5), iconos grandes y una
# animacion de zoom-in al abrir. -m desktopapplications => SOLO apps.
#
# Walker como servicio hace toggle: si ya esta abierto, otra invocacion
# lo cierra. Tambien Esc lo cierra.
# ──────────────────────────────────────────────────────────────────────

# Walker necesita el daemon "elephant" para listar aplicaciones.
if ! pgrep -x elephant >/dev/null; then
  setsid uwsm-app -- elephant >/dev/null 2>&1 &
fi
# Servicio de Walker (arranque instantaneo). Si no esta, lo levantamos.
if ! pgrep -f 'walker --gapplication-service' >/dev/null; then
  setsid uwsm-app -- env GSK_RENDERER=cairo walker --gapplication-service >/dev/null 2>&1 &
  sleep 0.25
fi

exec walker \
  --theme launchpad \
  --provider desktopapplications \
  --placeholder "  Aplicaciones" \
  --width 1280 --maxheight 820 --minheight 240
