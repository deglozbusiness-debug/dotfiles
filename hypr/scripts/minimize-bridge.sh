#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# minimize-bridge.sh — "minimizar de verdad" para Hyprland + Cairo-Dock
#
# Hyprland no tiene el concepto de "ventana minimizada" (es un compositor tiling).
# Truco: cada ventana minimizada se manda a SU PROPIO workspace especial oculto
# `special:min-<dir>`. Como cada una vive sola en su workspace, restaurar una
# NUNCA arrastra a las demas (eso era el bug: con un `special:minimized` unico,
# cuando el dock "activaba" una ventana Hyprland mostraba el workspace entero =
# todas las minimizadas a la vez).
#
# Modos de uso:
#   minimize-bridge.sh                -> daemon (lo lanza autostart.conf)
#   minimize-bridge.sh hide-focused   -> minimiza la ventana enfocada  (Super+H)
#   minimize-bridge.sh hide-addr 0xN  -> minimiza una ventana por direccion
#   minimize-bridge.sh restore-addr 0xN -> restaura una ventana por direccion
#   minimize-bridge.sh restore-all    -> restaura todas las minimizadas (Super+Shift+H)
#
# El daemon escucha el socket de eventos de Hyprland:
#   minimized>>DIR,1   (el dock pide minimizar)      -> esconde DIR
#   minimized>>DIR,0   (el dock pide des-minimizar)  -> restaura DIR
#   activewindowv2>>DIR (Hyprland enfoca DIR; p.ej. Alt+Tab a una minimizada)
#                                                    -> si DIR estaba minimizada, restaura
#   closewindow>>DIR   (se cerro la ventana)         -> limpia el estado de DIR
#
# OJO con el "minimize-then-activate" de Cairo-Dock:
#   Al hacer click sobre la app ACTIVA, Cairo-Dock manda set_minimized(true)
#   seguido casi inmediatamente de un activate request. Hyprland traduce el
#   primero a `minimized>>,1` (bien) y el segundo a `activewindowv2>>` (mal:
#   eso deshacia el minimize). Solucion: en cada minimize escribimos un
#   timestamp en <addr>.min-ts; el listener de activewindowv2 ignora la
#   restauracion si ese timestamp esta a <1500ms (= es el activate-fantasma).
#   Mas alla de esa ventana, activewindowv2 si auto-restaura (Alt+Tab, etc.).
#
# Estado: $XDG_RUNTIME_DIR/hypr-minimize/<dir>         workspace original (texto)
#         $XDG_RUNTIME_DIR/hypr-minimize/<dir>.min-ts  ms epoch del ultimo minimize
# Debug: exporta MINIMIZE_DEBUG=1 antes de lanzarlo -> log en .../hypr-minimize/log
#
# Requiere: socat, jq, hyprctl.
# ──────────────────────────────────────────────────────────────────────────────
set -u

RUNTIME="${XDG_RUNTIME_DIR:?XDG_RUNTIME_DIR no definido}/hypr-minimize"
mkdir -p "$RUNTIME"
LOGF="$RUNTIME/log"

log() { [ -n "${MINIMIZE_DEBUG:-}" ] && printf '%(%H:%M:%S)T  %s\n' -1 "$*" >> "$LOGF"; }

# Nombre del workspace especial de una ventana. $1 = direccion SIN el 0x.
special_name() { printf 'min-%s' "$1"; }

hyprc() { hyprctl "$@" >/dev/null 2>&1; }

# Direccion -> "0x...." (forma que quiere hyprctl) y "...." (forma del estado/eventos).
norm_addr() { printf '%s' "${1#0x}"; }

# Epoch en milisegundos (para detectar el minimize-then-activate del dock).
now_ms() { date +%s%3N; }

# Ventana de supresion: cuantos ms despues de un minimize ignoramos eventos
# `activewindowv2` para esa misma direccion. Cairo-Dock a veces dispara varios
# activates seguidos (no solo uno); por eso mantenemos el .min-ts durante TODA
# la ventana en vez de borrarlo en el primer hit. 3000ms cubre activates
# atrasados sin estorbar a Alt+Tab manuales (uno raramente Alt+Tab vuelve a
# una ventana 3s despues de minimizarla con click en el dock).
SUPPRESS_MS=3000

minimize_window() {                       # $1 = direccion (con o sin 0x), $2 = workspace (opcional, ahorra una llamada a hyprctl)
    local a; a=$(norm_addr "$1"); local full="0x$a"
    [ -f "$RUNTIME/$a" ] && { log "min $a: ya minimizada, skip"; return; }
    local ws="${2:-}"
    if [ -z "$ws" ]; then
        ws=$(hyprctl clients -j | jq -r --arg x "$full" '.[] | select(.address == $x) | .workspace.name' 2>/dev/null)
    fi
    case "$ws" in ""|null|special:*) log "min $a: workspace '$ws' invalido, skip"; return ;; esac
    printf '%s\n' "$ws" > "$RUNTIME/$a"
    # Timestamp ms: el listener de activewindowv2 lo consulta para descartar el
    # activate-fantasma que Cairo-Dock dispara justo despues de set_minimized.
    now_ms > "$RUNTIME/$a.min-ts"
    hyprc dispatch movetoworkspacesilent "special:$(special_name "$a"),address:$full"
    log "min $a: $ws -> special:$(special_name "$a")"
}

restore_window() {                        # $1 = direccion (con o sin 0x)
    local a; a=$(norm_addr "$1"); local full="0x$a"
    local sp; sp=$(special_name "$a")
    local ws=""
    # Restaurar legitimamente cancela cualquier supresion pendiente.
    rm -f "$RUNTIME/$a.min-ts"
    if [ -f "$RUNTIME/$a" ]; then
        ws=$(cat "$RUNTIME/$a" 2>/dev/null)
        rm -f "$RUNTIME/$a"
    else
        # Sin estado: solo restauramos si la ventana esta efectivamente en su
        # workspace especial (p.ej. el daemon se reinicio). Si no, no es asunto nuestro.
        local cur
        cur=$(hyprctl clients -j | jq -r --arg x "$full" '.[] | select(.address == $x) | .workspace.name' 2>/dev/null)
        [ "$cur" = "special:$sp" ] || { log "restore $a: no minimizada, ignore"; return; }
    fi
    case "$ws" in ""|null) ws=$(hyprctl activeworkspace -j | jq -r '.name' 2>/dev/null) ;; esac
    hyprc dispatch movetoworkspacesilent "$ws,address:$full"
    hyprc dispatch focuswindow "address:$full"
    # Si Hyprland llego a mostrar el workspace especial de esta ventana, ocultalo.
    if hyprctl monitors -j | jq -e --arg w "special:$sp" 'any(.[]; .specialWorkspace.name == $w)' >/dev/null 2>&1; then
        hyprc dispatch togglespecialworkspace "$sp"
    fi
    log "restore $a -> $ws"
}

cmd_hide_focused() {
    # Una sola llamada a hyprctl para sacar address + workspace -> minimizar mas rapido.
    local data; data=$(hyprctl activewindow -j 2>/dev/null)
    local a;   a=$(printf '%s' "$data" | jq -r '.address // empty')
    local ws; ws=$(printf '%s' "$data" | jq -r '.workspace.name // empty')
    case "$a" in 0x*) minimize_window "$a" "$ws" ;; *) log "hide-focused: no hay ventana activa" ;; esac
}

cmd_hide_addr() {     # $1 = direccion (con o sin 0x)
    case "${1:-}" in 0x*|*[0-9a-fA-F]*) minimize_window "$1" ;; *) log "hide-addr: '$1' invalida" ;; esac
}

cmd_restore_addr() {  # $1 = direccion (con o sin 0x)
    case "${1:-}" in 0x*|*[0-9a-fA-F]*) restore_window "$1" ;; *) log "restore-addr: '$1' invalida" ;; esac
}

cmd_restore_all() {
    local f a
    for f in "$RUNTIME"/*; do
        [ -e "$f" ] || continue
        a=$(basename "$f")
        # Saltar: logs y archivos auxiliares (.min-ts), solo iteramos los
        # state files puros que son nombres hex de direccion.
        case "$a" in log|toggle.log|*.min-ts) continue ;; esac
        restore_window "$a"
    done
}

cmd_daemon() {
    # Limpia estado viejo (de una sesion anterior de Hyprland: esas ventanas
    # ya no estan minimizadas).
    find "$RUNTIME" -maxdepth 1 -type f ! -name log -delete 2>/dev/null
    log "daemon: iniciado"
    local sig sock line data addr state
    while :; do
        sig="${HYPRLAND_INSTANCE_SIGNATURE:-}"
        sock="${XDG_RUNTIME_DIR}/hypr/$sig/.socket2.sock"
        if [ -z "$sig" ] || [ ! -S "$sock" ]; then sleep 0.5; continue; fi
        log "daemon: conectado a $sock"
        socat -U - "UNIX-CONNECT:$sock" 2>/dev/null | while IFS= read -r line; do
            case "$line" in
                minimized\>\>*)
                    data="${line#minimized>>}"; addr="${data%%,*}"; state="${data##*,}"
                    [ -z "$addr" ] && continue
                    if [ "$state" = "1" ]; then minimize_window "$addr"; else restore_window "$addr"; fi
                    ;;
                activewindowv2\>\>*)
                    addr="${line#activewindowv2>>}"
                    case "$addr" in ""|",") continue ;; esac
                    addr_norm=$(norm_addr "$addr")
                    # Solo nos interesa si la ventana esta marcada como minimizada.
                    [ -f "$RUNTIME/$addr_norm" ] || continue
                    # Supresion: dentro de SUPPRESS_MS ms del minimize ignoramos
                    # CUALQUIER activate para esta direccion (Cairo-Dock dispara
                    # uno o varios "activate fantasma" despues del set_minimized).
                    # Mantenemos el .min-ts durante TODA la ventana — borrarlo en
                    # el primer hit dejaba pasar los siguientes y el minimize "se
                    # revertia a veces si a veces no". El .min-ts solo se limpia
                    # cuando expira la ventana o cuando hay un restore legitimo.
                    if [ -f "$RUNTIME/$addr_norm.min-ts" ]; then
                        ts=$(cat "$RUNTIME/$addr_norm.min-ts" 2>/dev/null || echo 0)
                        now=$(now_ms)
                        if [ "$now" -lt "$((ts + SUPPRESS_MS))" ]; then
                            log "activewindowv2 $addr_norm: supress (minimize hace $((now - ts))ms, ignoro activate del dock)"
                            continue
                        fi
                        # Expiro la ventana de supresion -> limpiar marca y
                        # restaurar normalmente (caso Alt+Tab tardio).
                        rm -f "$RUNTIME/$addr_norm.min-ts"
                    fi
                    restore_window "$addr"
                    ;;
                closewindow\>\>*)
                    addr="${line#closewindow>>}"
                    [ -n "$addr" ] && {
                        addr_norm=$(norm_addr "$addr")
                        rm -f "$RUNTIME/$addr_norm" "$RUNTIME/$addr_norm.min-ts"
                    }
                    ;;
            esac
        done
        log "daemon: socat termino; reintento en 0.5s"
        sleep 0.5
    done
}

case "${1:-daemon}" in
    daemon)        cmd_daemon ;;
    hide-focused)  cmd_hide_focused ;;
    hide-addr)     cmd_hide_addr "${2:-}" ;;
    restore-addr)  cmd_restore_addr "${2:-}" ;;
    restore-all)   cmd_restore_all ;;
    *) echo "uso: ${0##*/} {daemon|hide-focused|hide-addr <addr>|restore-addr <addr>|restore-all}" >&2; exit 1 ;;
esac
