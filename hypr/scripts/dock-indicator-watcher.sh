#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# dock-indicator-watcher.sh — pinta un dot cyan sobre los launchers pinneados
# de Cairo-Dock cuya app esta corriendo. Reemplaza el indicador NATIVO que
# Cairo-Dock dibujaria solo si `mix launcher appli=true` o `show applications
# =true`, lo cual rompe la semantica "click = minimize directo" que tenemos.
#
# Como funciona:
#   1. Escucha el socket2.sock de Hyprland (eventos openwindow / closewindow).
#   2. En cada evento, para cada clase pinneada chequea si hay alguna ventana
#      de esa clase via `hyprctl clients`.
#   3. Llama via DBus al metodo SetEmblem de Cairo-Dock con el dot cyan
#      (estado "corriendo") o con string vacio (estado "no corriendo").
#   4. Cachea estado en $XDG_RUNTIME_DIR/dock-indicators/<cd_class> para no
#      spammear DBus con calls redundantes (solo en transicion).
#   5. Un timer paralelo cada 30s fuerza re-aplicar por si Cairo-Dock se
#      reinicio (perderia los emblems al levantarse).
#
# Mapa de clases — Hyprland (WM class case-sensitive) vs Cairo-Dock (siempre
# lowercased StartupWMClass). Si pineas una app nueva, agregala aqui.
#
# Requiere: gdbus, hyprctl, jq, socat.
# ──────────────────────────────────────────────────────────────────────────────
set -u

EMBLEM="$HOME/.config/hypr/scripts/dock-running-dot.png"
POSITION=5   # bottom-center
STATE_DIR="${XDG_RUNTIME_DIR:?XDG_RUNTIME_DIR no definido}/dock-indicators"
mkdir -p "$STATE_DIR"

declare -A CLASS_MAP=(
    ["Alacritty"]="alacritty"
    ["Thorium-browser"]="thorium-browser"
    ["org.gnome.Nautilus"]="org.gnome.nautilus"
    ["claude"]="claude"
    ["code-oss"]="code-oss"
    ["Typora"]="typora"
)

set_emblem() {            # $1 = imagen (vacia para borrar), $2 = cd_class
    gdbus call --session --dest org.cairodock.CairoDock \
        --object-path /org/cairodock/CairoDock \
        --method org.cairodock.CairoDock.SetEmblem \
        "$1" "$POSITION" "class=$2" >/dev/null 2>&1
}

update_class() {          # $1 = hyprland class, $2 = cairo-dock class
    local hl="$1" cd="$2" cur desired
    [ -f "$STATE_DIR/$cd" ] && cur="running" || cur="idle"
    if hyprctl clients -j 2>/dev/null | jq -e --arg c "$hl" 'any(.[]; .class == $c)' >/dev/null 2>&1; then
        desired="running"
    else
        desired="idle"
    fi
    [ "$cur" = "$desired" ] && return
    if [ "$desired" = "running" ]; then
        touch "$STATE_DIR/$cd"
        set_emblem "$EMBLEM" "$cd"
    else
        rm -f "$STATE_DIR/$cd"
        set_emblem "" "$cd"
    fi
}

update_all() {
    local hl
    for hl in "${!CLASS_MAP[@]}"; do
        update_class "$hl" "${CLASS_MAP[$hl]}"
    done
}

force_resync() {
    # Olvida el cache -> proxima update_all re-empuja todo. Util si Cairo-Dock
    # se reinicio y perdio los emblems.
    rm -f "$STATE_DIR"/* 2>/dev/null
    update_all
}

# Espera a que Cairo-Dock acepte DBus calls (puede tardar al login).
for _ in $(seq 1 20); do
    pgrep -x cairo-dock >/dev/null && \
        gdbus call --session --dest org.cairodock.CairoDock \
            --object-path /org/cairodock/CairoDock \
            --method org.cairodock.CairoDock.GetProperties "type=Launcher" \
            >/dev/null 2>&1 && break
    sleep 0.5
done

force_resync

# Timer paralelo: re-aplica cada 30s por si Cairo-Dock se reinicio.
(
    while :; do
        sleep 30
        force_resync
    done
) &
TIMER_PID=$!
trap "kill $TIMER_PID 2>/dev/null" EXIT

# Main loop: escucha el socket2 de Hyprland.
while :; do
    sig="${HYPRLAND_INSTANCE_SIGNATURE:-}"
    sock="${XDG_RUNTIME_DIR}/hypr/$sig/.socket2.sock"
    if [ -z "$sig" ] || [ ! -S "$sock" ]; then sleep 0.5; continue; fi
    socat -U - "UNIX-CONNECT:$sock" 2>/dev/null | while IFS= read -r line; do
        case "$line" in
            openwindow\>\>*|closewindow\>\>*) update_all ;;
        esac
    done
    sleep 0.5
done
