#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# dock-add-app.sh — picker Walker para PINEAR una app al dock.
#
# Como funciona:
#   1. Recorre /usr/share/applications, ~/.local/share/applications y los
#      exports de Flatpak (system + user) buscando .desktop validos.
#   2. Te muestra los nombres en Walker --dmenu (via omarchy-launch-walker,
#      que es el wrapper estandar y reusa el elephant/walker-service ya
#      corriendo en la sesion).
#   3. Al seleccionar, genera un launcher .desktop en
#      ~/.config/cairo-dock/current_theme/launchers/ con `Exec=` PLANO (sin
#      envoltorios) para que respete la semantica nativa de Cairo-Dock
#      (`mix launcher appli=true` + `minimize on click=true`). Asi se
#      comporta igual que los launchers que vienen pre-pinneados.
#   4. La carpeta de DP-1 esta symlinkeada a la principal, asi que el
#      cambio se refleja en ambos monitores.
#   5. Reinicia Cairo-Dock para que tome el nuevo .desktop.
#
# Para QUITAR del dock: click derecho sobre el icono -> "Remove this launcher".
#
# Atajo: SUPER ALT + D  (ver ~/.config/hypr/bindings.conf)
# Log:   ~/.cache/dock-add-app.log  (cada invocacion deja huellas para debug)
# ──────────────────────────────────────────────────────────────────────────────
set -u

LOG="$HOME/.cache/dock-add-app.log"
DOCKDIR="$HOME/.config/cairo-dock/current_theme/launchers"

log() { printf '%(%H:%M:%S)T %s\n' -1 "$*" >> "$LOG" 2>/dev/null || true; }

log "=========================== invocado"

# ── Verificaciones rapidas (dependencias). ──────────────────────────────────
for cmd in walker omarchy-launch-walker awk sed jq; do
    command -v "$cmd" >/dev/null || {
        log "FATAL: falta dependencia '$cmd'"
        notify-send -u critical "dock-add-app" "Falta '$cmd' en PATH"
        exit 1
    }
done

[ -d "$DOCKDIR" ] || {
    log "FATAL: no existe $DOCKDIR"
    notify-send -u critical "dock-add-app" "No existe $DOCKDIR"
    exit 1
}

# ── Lee un campo 'Key=Value' del grupo [Desktop Entry] de un .desktop. ──────
read_key() {
    awk -v key="$1" '
        /^\[Desktop Entry\]/ { in_sec = 1; next }
        /^\[/                { in_sec = 0; next }
        in_sec && index($0, key "=") == 1 {
            sub("^" key "=", ""); print; exit
        }
    ' "$2"
}

# ── Construye lista de apps instaladas (deduplicada por basename). ──────────
collect_apps() {
    local f base seen=""
    {
        find /usr/share/applications \
             "$HOME/.local/share/applications" \
             /var/lib/flatpak/exports/share/applications \
             "$HOME/.local/share/flatpak/exports/share/applications" \
             -maxdepth 1 -name '*.desktop' -type f 2>/dev/null
    } | sort -u | while IFS= read -r f; do
        base=$(basename "$f")
        case " $seen " in *" $base "*) continue ;; esac
        seen="$seen $base"

        local hidden nodisplay name exec tryexec
        hidden=$(read_key Hidden "$f")
        nodisplay=$(read_key NoDisplay "$f")
        [ "$hidden" = "true" ] && continue
        [ "$nodisplay" = "true" ] && continue
        name=$(read_key Name "$f")
        [ -z "$name" ] && continue
        exec=$(read_key Exec "$f")
        [ -z "$exec" ] && continue
        tryexec=$(read_key TryExec "$f")
        if [ -n "$tryexec" ] && ! command -v "$tryexec" >/dev/null 2>&1; then
            continue
        fi
        printf '%s\t%s\n' "$name" "$f"
    done | sort -u -f -t $'\t' -k1,1
}

# ── Picker. ────────────────────────────────────────────────────────────────
log "construyendo lista de apps..."
applist=$(collect_apps)
applist_count=$(printf '%s' "$applist" | wc -l)
log "lista construida: $applist_count entradas"

if [ -z "$applist" ]; then
    log "FATAL: lista vacia"
    notify-send -u critical "dock-add-app" "No encontre ninguna app instalada"
    exit 1
fi

log "abriendo Walker --dmenu..."
# omarchy-launch-walker asegura que elephant + walker-service esten arriba.
# Le pasamos solo los nombres (primera columna) por stdin.
selection=$(printf '%s' "$applist" | awk -F'\t' '{print $1}' \
    | omarchy-launch-walker --dmenu -p "Add app to dock…" \
        --width 520 --minheight 240 --maxheight 540 2>>"$LOG")

if [ -z "$selection" ]; then
    log "cancelado por usuario (seleccion vacia)"
    exit 0
fi
log "seleccion: '$selection'"

# Recuperar el .desktop original.
src=$(printf '%s' "$applist" | awk -F'\t' -v n="$selection" '$1 == n {print $2; exit}')
if [ -z "$src" ] || [ ! -f "$src" ]; then
    log "FATAL: no encontre el .desktop para '$selection'"
    notify-send -u critical "dock-add-app" "No encontre el .desktop de '$selection'"
    exit 1
fi
log "src .desktop: $src"

# ── Extraer campos. ────────────────────────────────────────────────────────
appname=$(read_key Name "$src")
appicon=$(read_key Icon "$src")
appexec=$(read_key Exec "$src")
appclass=$(read_key StartupWMClass "$src")

# Si no hay StartupWMClass usar el nombre del archivo como fallback (heuristica).
[ -z "$appclass" ] && appclass=$(basename "$src" .desktop)

# Limpiar field codes del Desktop Entry spec (%u, %F, %i, %c, etc.)
appexec=$(printf '%s' "$appexec" | sed -E 's/%[a-zA-Z]//g; s/[[:space:]]+/ /g; s/[[:space:]]+$//')
log "campos: name='$appname' class='$appclass' exec='$appexec'"

# ── Calcular Order siguiente y nombre de archivo. ──────────────────────────
next_order=$(grep -h "^Order=" "$DOCKDIR"/*.desktop 2>/dev/null \
             | sed 's/^Order=//' | sort -n | tail -1)
next_order=$(( ${next_order:-0} + 1 ))
prefix=$(printf '%02d' "$next_order")

slug=$(printf '%s' "$appclass" | tr '[:upper:]' '[:lower:]' \
       | tr -c '[:alnum:]' '-' | sed -E 's/-+/-/g; s/^-//; s/-$//')
[ -z "$slug" ] && slug=app

out="$DOCKDIR/${prefix}${slug}.desktop"
n=1
while [ -e "$out" ]; do
    out="$DOCKDIR/${prefix}${slug}-${n}.desktop"
    n=$((n+1))
done
log "destino: $out"

# ── Escribir el .desktop (formato identico a los launchers existentes:
#    Exec= PLANO, sin envolver con dock-minimize-toggle.sh, para coherencia
#    con la config nativa de Cairo-Dock que estamos usando). ─────────────
cat > "$out" <<EOF
#3.6.2
[Desktop Entry]
Type=Application
Container=_MainDock_
Name=$appname
Icon=$appicon
Exec=$appexec
StartupWMClass=$appclass
Order=$next_order
Icon Type=0
prevent inhibate=false
Terminal=false
ShowOnViewport=0
EOF

if [ ! -s "$out" ]; then
    log "FATAL: el archivo no se escribio o quedo vacio: $out"
    notify-send -u critical "dock-add-app" "No pude escribir $out"
    exit 1
fi
log "archivo escrito ($(stat -c '%s' "$out") bytes)"

# ── Reiniciar ambas instancias del dock. ──────────────────────────────────
log "reiniciando cairo-dock..."
pkill -x cairo-dock 2>/dev/null
sleep 0.7
( nohup cairo-dock -o -L -a -t                                              </dev/null >/dev/null 2>&1 & disown )
( nohup cairo-dock -o -L -a -t -d "$HOME/.config/cairo-dock-dp1"            </dev/null >/dev/null 2>&1 & disown )
sleep 0.5

log "OK — '$appname' pinneada"
notify-send -u low "Dock" "'$appname' pinneada"
