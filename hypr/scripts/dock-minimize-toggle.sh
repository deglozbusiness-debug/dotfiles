#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# dock-minimize-toggle.sh — click handler para los .desktop del dock y de
# Walker (~/.local/share/applications/). Logica "toggle minimize directo":
#
#   App NO corre               -> lanzar (uwsm-app -- CMD)
#   App corre, minimizada      -> restaurar (la trae de su workspace especial)
#   App corre, visible         -> minimizar SIEMPRE (sin focus intermedio)
#
# Detecta la ventana POR ADDRESS (no por workspace ni por foco), asi nunca
# arrastra otras ventanas minimizadas. Si hay varias ventanas de la misma
# clase, elige la mas recientemente enfocada (menor focusHistoryID).
#
# IMPORTANTE — sobre Cairo-Dock con `mix launcher appli=true`:
#   Cairo-Dock SOLO ejecuta Exec= cuando la app NO esta corriendo. Los clicks
#   sobre el icono "mezclado" de una app abierta los maneja el propio dock
#   nativamente (envia minimize via wlr-foreign-toplevel-management). Este
#   script no se invoca en ese caso. Si el minimize "click sobre app activa"
#   no funciona, el sospechoso es el evento `minimized>>` -> ver
#   minimize-bridge.sh con MINIMIZE_DEBUG=1.
#
# Uso (los .desktop del dock pasan los args entre espacios; NADA de regex con
# caracteres reservados del Desktop Entry spec — $, &, etc.):
#
#   dock-minimize-toggle.sh <class-exacta> <comando...>
#
# Ejemplos:
#   dock-minimize-toggle.sh Alacritty            alacritty
#   dock-minimize-toggle.sh Typora               typora --enable-wayland-ime
#   dock-minimize-toggle.sh claude               claude-desktop
#   dock-minimize-toggle.sh Thorium-browser      thorium-browser
#   dock-minimize-toggle.sh org.gnome.Nautilus   nautilus
#
# Requiere: jq, hyprctl, uwsm-app, minimize-bridge.sh (mismo directorio).
# ──────────────────────────────────────────────────────────────────────────────
set -u

CLASS="${1:?class requerida}"
shift
CMD=("$@")

RUNTIME="${XDG_RUNTIME_DIR:?XDG_RUNTIME_DIR no definido}/hypr-minimize"
mkdir -p "$RUNTIME"
LOGF="$RUNTIME/toggle.log"
BRIDGE="$(dirname "$(readlink -f "$0")")/minimize-bridge.sh"

log() { printf '%(%H:%M:%S)T  %s\n' -1 "$*" >> "$LOGF" 2>/dev/null || true; }

log "INVOKED class='$CLASS' cmd='${CMD[*]}'"

# Match EXACTO case-insensitive — sin regex, asi evitamos problemas con el
# parser del Desktop Entry (que trata $ como reservado).
addr=$(hyprctl clients -j 2>/dev/null | jq -r --arg c "$CLASS" '
    [ .[] | select(((.class // "") | ascii_downcase) == ($c | ascii_downcase)) ]
    | (sort_by(.focusHistoryID // 9999) | first | .address) // empty
')

# 1) No corre -> lanzar y salir.
if [ -z "$addr" ] || [ "$addr" = "null" ]; then
    log "  -> launch (no window for class '$CLASS')"
    exec uwsm-app -- "${CMD[@]}"
fi

a="${addr#0x}"

# 2) Esta minimizada (el daemon dejo archivo de estado) -> restaurar.
if [ -f "$RUNTIME/$a" ]; then
    log "  -> restore $addr"
    "$BRIDGE" restore-addr "$addr"
    exit 0
fi

# 3) Esta corriendo y visible -> minimizar directo (sin enfocar primero).
log "  -> minimize $addr"
"$BRIDGE" hide-addr "$addr"
