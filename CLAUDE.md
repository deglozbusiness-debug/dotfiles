# 🌌 AURORA TWILIGHT — The Ultimate Omarchy-on-CachyOS Overview
**Project Vision:** Replicar (y superar) la estética del video de Fedora+GNOME+Compiz en un entorno CachyOS + Hyprland 0.55 + Omarchy, con la paleta Aurora Twilight.

---

## 📸 Referencia Visual (Capturas Analizadas)

### Frame 1 — Overview de Aplicaciones (App Grid)
- **Fondo:** Wallpaper con blur intenso + gradiente magenta/rosa
- **Iconos:** Grid 4x4+ con iconos grandes (~64-72px), redondeados, estilo iOS/macOS
- **Dock inferior:** Visible durante overview, iconos redondeados con badges
- **Barra superior:** Fecha centrada, iconos de sistema a la derecha, estilo glassmorphism
- **Efecto:** Transición suave, ventanas se alejan con blur

### Frame 2 — Exposé / Workspace Switcher
- **Ventanas flotantes:** Todas las ventanas visibles en miniatura, flotando en 3D
- **Fondo:** Wallpaper full con blur pesado (~20px)
- **Transparencia:** Ventanas en miniatura tienen opacidad ~85%
- **Dock:** Persistente abajo, glassmorphism puro

### Frame 3 — Desktop Cube / Workspace 3D
- **Efecto cubo:** Escritorios rotan como un cubo 3D
- **Ventanas en caras del cubo:** Cada workspace es una cara del cubo
- **Reflejo:** Efecto de reflejo/sombra en las caras del cubo
- **Animación:** Smooth, con easing curve tipo `ease-out-back`

### Frame 4 — Magic Lamp / Compiz Window Effects
- **Minimizar:** Ventanas se deforman como una lámpara mágica hacia el dock
- **Transparencia dinámica:** Ventanas se vuelven semitransparentes al mover
- **Wobbly windows:** Ventanas se deforman al arrastrar (ligero, no exagerado)
- **Blur dinámico:** El blur del fondo cambia según el estado de la ventana

---

## 🎨 Paleta Aurora Twilight (Locked)
| Token | Hex | Uso |
|-------|-----|-----|
| `base` | `#1a1b3a` | Fondos principales, terminal, barra |
| `magenta` | `#ff006e` | Acentos primarios, hover, glow, badges |
| `cyan` | `#00d9ff` | Acentos secundarios, focus, activo, links |
| `lavanda` | `#b8b8ff` | Texto secundario, bordes sutiles, tooltips |
| `surface` | `rgba(26,27,58,0.75)` | Glassmorphism base |
| `glow-magenta` | `rgba(255,0,110,0.3)` | Sombras glow |
| `glow-cyan` | `rgba(0,217,255,0.3)` | Sombras glow alternas |

---

## 🏗️ Arquitectura del Sistema

```
┌─────────────────────────────────────────────────────────────┐
│  LAYER 0: Hyprland Core (Compositor)                        │
│  ├── blur { size=12, passes=3 }                             │
│  ├── shadows { enabled, color=base, range=20 }              │
│  ├── animations (bezier curves custom)                      │
│  └── layerrules (blur, ignorealpha, xray)                   │
├─────────────────────────────────────────────────────────────┤
│  LAYER 1: Hyprland Plugins (C++ compiled)                   │
│  ├── hyprspace → Workspace overview (reemplaza Exposé)      │
│  ├── hyprexpo → Desktop grid / cube alternative             │
│  └── hypr-dynamic-cursors → Cursor effects (opcional)         │
├─────────────────────────────────────────────────────────────┤
│  LAYER 2: Top Bar (Waybar)                                  │
│  ├── Glassmorphism total (no background sólido)             │
│  ├── Módulos: workspaces, window, clock, system, tray         │
│  ├── Hover glow magenta/cyan                                │
│  └── Font: JetBrains Mono Nerd Font                         │
├─────────────────────────────────────────────────────────────┤
│  LAYER 3: Dock (nwg-dock-hyprland)                          │
│  ├── Auto-hide, bottom, 48px icons                          │
│  ├── Glassmorphism + border lavanda 1px                       │
│  ├── Hover: scale 1.25 + glow magenta                     │
│  ├── Active app: glow cyan + dot indicator                  │
│  └── Pinned: Alacritty, Thorium, Nautilus, Claude, VS Code, Typora │
├─────────────────────────────────────────────────────────────┤
│  LAYER 4: Terminal (Alacritty)                                │
│  ├── Background: base @ 90% opacity                           │
│  ├── Blur: inherit from Hyprland                            │
│  ├── Font: JetBrains Mono, 12px                             │
│  └── Colors: Aurora Twilight palette                        │
├─────────────────────────────────────────────────────────────┤
│  LAYER 5: Apps & GTK Theme                                    │
│  ├── GTK Theme: Custom Aurora Twilight (gradience)            │
│  ├── Icon Theme: Papirus-Dark + custom icons                │
│  ├── Cursor: Bibata Modern Ice (cyan accent)                │
│  └── Font: Inter (UI), JetBrains Mono (mono)                │
├─────────────────────────────────────────────────────────────┤
│  LAYER 6: Wallpaper & Effects                               │
│  ├── Wallpaper engine: swww (smooth transitions)            │
│  ├── Dynamic wallpaper: Aurora abstract magenta/cyan        │
│  └── Random: cambia cada 30 min o por workspace             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 FASES DE IMPLEMENTACIÓN

---

### ✅ FASE 0: FUNDACIONES (Pre-requisitos)
**Estado:** COMPLETADO (verificar antes de continuar)
**Tiempo estimado:** 0 min (ya hecho)

#### Checklist
- [ ] Sistema actualizado: `sudo pacman -Syu`
- [ ] Git configurado con SSH a GitHub
- [ ] Repo dotfiles clonado/pusheado: `github.com/deglozbusiness-debug/dotfiles`
- [ ] `CLAUDE.md` global en `~/CLAUDE.md`
- [ ] `CLAUDE.md` del proyecto en `~/dotfiles/CLAUDE.md`
- [ ] Copia de seguridad de configs críticas en `~/dotfiles/backup/`

#### Reglas Inmutables
```
1. NUNCA tocar ~/.local/share/omarchy/ (sistema Omarchy)
2. Hyprland 0.55 usa SINTAXIS LUA (no json, no antigua)
3. windowrulev2 está DEPRECATED → usar windowrule con sintaxis nueva
4. Para AUR usar yay (no makepkg manual)
5. Backup ANTES de editar cualquier config crítica
6. Commits estructurados: feat:, fix:, docs:, chore:, style:, refactor:
```

---

### ✅ FASE 1: BACKUP Y VERIFICACIÓN DEL ESTADO ACTUAL
**Estado:** COMPLETADO
**Tiempo estimado:** 5 min

#### Comandos de verificación
```bash
# Verificar versión de Hyprland
hyprctl version | head -5

# Verificar configs activas
ls -la ~/.config/hypr/
ls -la ~/.config/waybar/
ls -la ~/.config/nwg-dock-hyprland/

# Verificar plugins instalados
hyprctl plugins list

# Verificar estado del dock
pgrep -f nwg-dock-hyprland && echo "Dock corriendo" || echo "Dock NO corriendo"

# Capturar estado actual para comparación
mkdir -p ~/dotfiles/backup/pre-aurora-overview-$(date +%Y%m%d)
cp -r ~/.config/hypr ~/dotfiles/backup/pre-aurora-overview-$(date +%Y%m%d)/
cp -r ~/.config/waybar ~/dotfiles/backup/pre-aurora-overview-$(date +%Y%m%d)/
cp -r ~/.config/nwg-dock-hyprland ~/dotfiles/backup/pre-aurora-overview-$(date +%Y%m%d)/
```

---

### ✅ FASE 2: HERRAMIENTAS BASE (Instalación)
**Estado:** COMPLETADO
**Tiempo estimado:** 10 min

#### Paquetes necesarios (verificar instalados)
```bash
# Core
yay -S --needed hyprland hypridle hyprlock hyprpicker

# Plugins (compilar desde AUR o hyprpm)
yay -S --needed hyprspace-git hyprexpo-git
# O usar hyprpm:
# hyprpm update
# hyprpm add hyprspace
# hyprpm add hyprexpo

# Barra y dock
yay -S --needed waybar nwg-dock-hyprland

# Wallpaper engine
yay -S --needed swww

# Fonts
yay -S --needed ttf-jetbrains-mono-nerd ttf-inter-variable

# GTK theming
yay -S --needed gradience-cli papirus-icon-theme

# Utilidades
yay -S --needed wl-clipboard wtype grimblast hyprshot
```

#### Verificación post-instalación
```bash
which waybar && waybar --version
which nwg-dock-hyprland
which swww
fc-list | grep -i "jetbrains" | head -3
fc-list | grep -i "inter" | head -3
```

---

### ✅ FASE 3: WAYBAR — Glassmorphism Total
**Estado:** COMPLETADO (rediseñado)
**Tiempo estimado:** 15 min
**Referencia:** Barra superior del video — glassmorphism puro, fecha centrada, iconos sistema derecha

#### Especificaciones UX/UI
- **Altura:** 34px
- **Fondo:** `rgba(26, 27, 58, 0.55)` (más transparente que el dock)
- **Border:** 1px `rgba(184, 184, 255, 0.15)` en bottom
- **Blur:** Via Hyprland layerrule
- **Font:** JetBrains Mono Nerd Font, 13px
- **Módulos izquierda:** Workspaces (con indicadores glow)
- **Módulos centro:** Window title + Clock (formato: "Mar 12, 07:15")
- **Módulos derecha:** CPU, RAM, Network, Battery, Tray, Power
- **Separadores:** `|` en lavanda @ 30% opacity

#### Efectos hover
- Workspace activo: glow cyan, scale 1.1
- Workspace con ventanas: dot magenta pequeño
- Hover workspace: background `rgba(255,0,110,0.1)`, border-radius 8px
- Hover módulo: glow magenta suave

#### Archivos a editar
- `~/.config/waybar/config` (o config.jsonc)
- `~/.config/waybar/style.css`
- `~/.config/hypr/hyprland.conf` (layerrules para waybar)

#### Layerrules Hyprland
```lua
layerrule = blur, waybar
layerrule = ignorealpha 0.3, waybar
layerrule = xray 0, waybar
```

---

### 🔄 FASE 4: DOCK INFERIOR — Auto-hide Premium
**Estado:** EN PROGRESO (iconos rotos, CSS en mejora)
**Tiempo estimado:** 20 min
**Referencia:** Dock del video — iconos redondeados, glassmorphism, badges, hover scale

#### Especificaciones UX/UI
- **Posición:** Bottom, centrado
- **Altura:** ~64px (iconos 48px + padding)
- **Auto-hide:** Sí, aparece al acercar mouse al borde inferior
- **Fondo:** `rgba(26, 27, 58, 0.75)`, border-radius 24px
- **Border:** 1px `rgba(184, 184, 255, 0.25)`
- **Padding:** 8px vertical, 16px horizontal
- **Margin bottom:** 12px

#### Iconos (6 pinnados)
1. **Alacritty** — Terminal
2. **Thorium** — Navegador
3. **Nautilus** — Files
4. **Claude Desktop** — AI (⚠️ revisar .desktop)
5. **VS Code: (code-oss)** — Editor
6. **Typora** — Markdown

#### Estados visuales
| Estado | Efecto |
|--------|--------|
| Default | Icono 48px, opacidad 0.9 |
| Hover | Scale 1.25, glow magenta `0 0 12px rgba(255,0,110,0.3)`, bg `rgba(255,0,110,0.15)` |
| Active (app enfocada) | Glow cyan `0 0 12px rgba(0,217,255,0.3)`, bg `rgba(0,217,255,0.15)` |
| App abierta (no enfocada) | Dot indicator 4px magenta debajo del icono |
| Launcher (grid) | Border lavanda, hover cyan |

#### Fix de iconos rotos
```bash
# Diagnóstico
hyprctl clients | grep "class:"
cat ~/.cache/nwg-dock-pinned

# Para apps sin icono (ej: Claude Desktop)
# Crear ~/.local/share/applications/claude-desktop.desktop
# Descargar icono PNG/SVG y referenciar en Icon=
# update-desktop-database ~/.local/share/applications/
```

#### CSS objetivo (GTK3-compatible)
```css
#dock {
    background: rgba(26, 27, 58, 0.75);
    border: 1px solid rgba(184, 184, 255, 0.25);
    border-radius: 24px;
    padding: 8px 16px;
}
button:hover image {
    -gtk-icon-transform: scale(1.25);
}
/* Ver FASE 4 detallada en anexo */
```

#### Layerrules Hyprland
```lua
layerrule = blur, gtk-layer-shell
layerrule = ignorealpha 0.2, gtk-layer-shell
layerrule = xray 0, gtk-layer-shell
```

---

### ⏳ FASE 5: HYPRLAND EFFECTS — Blur, Sombras, Animaciones
**Estado:** PENDIENTE
**Tiempo estimado:** 25 min
**Referencia:** Todo el video — blur pesado, sombras largas, animaciones suaves

#### 5.1 Blur Configuration
```lua
decoration {
    rounding = 16
    active_opacity = 0.95
    inactive_opacity = 0.85
    fullscreen_opacity = 1.0

    blur {
        enabled = true
        size = 12
        passes = 3
        new_optimizations = true
        ignore_opacity = true
        xray = false
    }

    shadow {
        enabled = true
        range = 20
        render_power = 3
        color = rgba(26, 27, 58, 0.6)
        color_inactive = rgba(26, 27, 58, 0.3)
    }
}
```

#### 5.2 Animations (Beziers personalizados — estilo Compiz)
```lua
animations {
    enabled = true

    # Bezier curves
    bezier = easeOutBack, 0.34, 1.56, 0.64, 1
    bezier = easeOutQuint, 0.23, 1, 0.32, 1
    bezier = easeInOutCubic, 0.65, 0, 0.35, 1
    bezier = overshoot, 0.34, 1.56, 0.64, 1

    # Window open/close — Magic lamp feel
    animation = windowsIn, 1, 4, easeOutBack, slide
    animation = windowsOut, 1, 3, easeInOutCubic, slide
    animation = windowsMove, 1, 2, easeOutQuint, default

    # Workspace switch — Cube feel
    animation = workspaces, 1, 3, easeOutBack, slidevert
    animation = workspacesIn, 1, 3, easeOutBack, slide
    animation = workspacesOut, 1, 3, easeOutBack, slide

    # Fade
    animation = fadeIn, 1, 2, easeOutQuint
    animation = fadeOut, 1, 2, easeInOutCubic
    animation = fadeSwitch, 1, 2, easeOutQuint
    animation = fadeShadow, 1, 2, easeOutQuint

    # Border
    animation = border, 1, 2, easeOutQuint

    # Layer (dock/bar pop)
    animation = layers, 1, 2, easeOutBack, slide
}
```

#### 5.3 Window Rules (sintaxis Hyprland 0.55 Lua)
```lua
# Opacidad por app
windowrule = opacity 0.95 0.85, Alacritty
windowrule = opacity 0.95 0.85, code-oss
windowrule = opacity 0.95 0.85, thorium-browser
windowrule = opacity 1.0 1.0, ^(gamescope.*)$

# Floating apps
windowrule = float, pavucontrol
windowrule = float, nm-connection-editor
windowrule = float, wofi
windowrule = float, rofi

# Size for floaters
windowrule = size 800 600, pavucontrol
windowrule = center, pavucontrol

# No blur for fullscreen games
windowrule = noblur, ^(gamescope.*)$
windowrule = noblur, ^(steam_app.*)$
```

#### 5.4 Layerrules completas
```lua
# Waybar
layerrule = blur, waybar
layerrule = ignorealpha 0.3, waybar
layerrule = xray 0, waybar

# Dock
layerrule = blur, gtk-layer-shell
layerrule = ignorealpha 0.2, gtk-layer-shell
layerrule = xray 0, gtk-layer-shell

# Notifications
layerrule = blur, notifications
layerrule = ignorealpha 0.2, notifications

# Menus/context (GTK popups)
layerrule = blur, gtk-layer-shell-menu
layerrule = ignorealpha 0.1, gtk-layer-shell-menu

# Lock screen
layerrule = blur, lockscreen
layerrule = ignorealpha 0.2, lockscreen
```

---

### ⏳ FASE 6: PLUGINS — Hyprspace + Hyprexpo (The "Compiz" Effects)
**Estado:** PENDIENTE
**Tiempo estimado:** 30 min
**Referencia:** Frame 2 y 3 del video — Exposé y Desktop Cube

#### 6.1 Hyprspace (Workspace Overview / Exposé)
**Qué hace:** Muestra todas las ventanas de todos los workspaces en una vista tipo macOS Mission Control.

```lua
# Configuración en hyprland.conf
plugin {
    hyprspace {
        # Activación
        bind = SUPER, Tab, overview:toggle

        # Apariencia
        panelColor = rgba(26, 27, 58, 0.85)
        panelBorderColor = rgba(184, 184, 255, 0.3)
        panelBorderWidth = 2
        panelHeight = 280

        # Layout
        workspaceMargin = 16
        windowMargin = 12
        centerAligned = true
        hideTopLayers = true
        hideOverlayLayers = true

        # Animaciones
        animationDuration = 300
        autoDrag = true
        autoScroll = true

        # Efectos
        panelBlur = true
        gaps = true
        gapsIn = 8
        gapsOut = 16
    }
}
```

#### 6.2 Hyprexpo (Desktop Grid / Cube Alternative)
**Qué hace:** Muestra todos los workspaces en una cuadrícula 3D que puedes navegar. Es el equivalente al "Desktop Cube" de Compiz pero en grid.

```lua
plugin {
    hyprexpo {
        # Activación
        bind = SUPER, grave, hyprexpo:expo, toggle

        # Layout
        columns = 3
        gap_size = 16
        bg_col = rgb(1a1b3a)
        workspace_method = center current

        # Efectos
        enable_gesture = true
        gesture_distance = 300
        gesture_positive = true

        # Animación
        animation_duration = 400
        animation_curve = easeOutBack
    }
}
```

#### 6.3 Instalación de plugins (hyprpm)
```bash
# Asegurar que hyprpm esté configurado
hyprpm update

# Instalar hyprspace
hyprpm add hyprspace
hyprpm enable hyprspace

# Instalar hyprexpo
hyprpm add hyprexpo
hyprpm enable hyprexpo

# Verificar
hyprpm list
hyprctl plugins list
```

#### 6.4 Alternativa: hypr-dynamic-cursors (opcional)
```bash
# Efectos de cursor tipo macOS
hyprpm add hypr-dynamic-cursors
hyprpm enable hypr-dynamic-cursors
```

---

### ⏳ FASE 7: WALLPAPER ENGINE — swww + Aurora Theme
**Estado:** PENDIENTE
**Tiempo estimado:** 15 min
**Referencia:** Fondo del video — Aurora abstract, magenta/cyan, blur intenso

#### 7.1 Instalación y setup
```bash
# swww ya instalado en FASE 2
# Crear directorio de wallpapers
mkdir -p ~/Pictures/Wallpapers/Aurora

# Descargar wallpapers Aurora Twilight
# (El AI debe buscar/generar wallpapers que combinen con la paleta)
# O usar los defaults de Omarchy si ya vienen con el tema
```

#### 7.2 Script de inicio
```bash
#!/bin/bash
# ~/.config/hypr/scripts/wallpaper.sh

WALLPAPER_DIR="$HOME/Pictures/Wallpapers/Aurora"

# Si hay wallpapers, elegir uno random
if [ -d "$WALLPAPER_DIR" ] && [ "$(ls -A $WALLPAPER_DIR)" ]; then
    swww img $(find "$WALLPAPER_DIR" -type f | shuf -n 1)         --transition-type grow         --transition-pos bottom-right         --transition-duration 2         --transition-fps 60
else
    # Fallback: color sólido base
    swww clear "#1a1b3a"
fi
```

#### 7.3 Exec-once en hyprland.conf
```lua
exec-once = swww-daemon
exec-once = sleep 1 && ~/.config/hypr/scripts/wallpaper.sh
```

#### 7.4 Cambio de wallpaper por workspace (opcional avanzado)
```bash
# Script para cambiar wallpaper según workspace activo
# Guardar en ~/.config/hypr/scripts/wallpaper-workspace.sh
```

---

### ⏳ FASE 8: TERMINAL — Alacritty Premium
**Estado:** PARCIAL (clipboard arreglado)
**Tiempo estimado:** 10 min
**Referencia:** Terminal del video — transparencia, blur, colores vibrantes

#### 8.1 Configuración Alacritty
```toml
[window]
opacity = 0.9
blur = false  # El blur viene de Hyprland, no de Alacritty
padding = { x = 16, y = 16 }
dynamic_padding = true
decorations = "none"

[font]
normal = { family = "JetBrainsMono Nerd Font", style = "Regular" }
bold = { family = "JetBrainsMono Nerd Font", style = "Bold" }
italic = { family = "JetBrainsMono Nerd Font", style = "Italic" }
size = 12.0

[cursor]
style = { shape = "Beam", blinking = "On" }

[colors.primary]
background = "#1a1b3a"
foreground = "#b8b8ff"

[colors.cursor]
text = "#1a1b3a"
cursor = "#ff006e"

[colors.normal]
black = "#1a1b3a"
red = "#ff006e"
green = "#00d9ff"
yellow = "#b8b8ff"
blue = "#00d9ff"
magenta = "#ff006e"
cyan = "#b8b8ff"
white = "#ffffff"

[colors.bright]
black = "#2a2b4a"
red = "#ff3385"
green = "#33e0ff"
yellow = "#c8c8ff"
blue = "#33e0ff"
magenta = "#ff3385"
cyan = "#c8c8ff"
white = "#ffffff"

[selection]
save_to_clipboard = true
```

#### 8.2 Window rule para Alacritty
```lua
windowrule = opacity 0.9 0.8, Alacritty
windowrule = rounding 16, Alacritty
```

---

### ⏳ FASE 9: GTK THEME + ICONOS + CURSOR
**Estado:** PENDIENTE
**Tiempo estimado:** 20 min
**Referencia:** Apps del video — iconos redondeados tipo iOS, bordes suaves, glassmorphism

#### 9.1 GTK Theme (Gradience + Custom CSS)
```bash
# Instalar gradience si no está
yay -S --needed gradience-cli

# Aplicar paleta Aurora Twilight
# (El AI debe generar un preset de Gradience o usar adw-gtk3)

# Instalar adw-gtk3 como base
yay -S --needed adw-gtk3
```

#### 9.2 Iconos
```bash
# Papirus-Dark ya instalado
# Verificar que esté activo:
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"

# Para iconos más redondeados tipo iOS (opcional):
yay -S --needed colloid-icon-theme-git
# gsettings set org.gnome.desktop.interface icon-theme "Colloid"
```

#### 9.3 Cursor
```bash
# Cursor con acento cyan
yay -S --needed bibata-cursor-theme-bin
# O: yay -S --needed phinger-cursors

# Activar
gsettings set org.gnome.desktop.interface cursor-theme "Bibata-Modern-Ice"
gsettings set org.gnome.desktop.interface cursor-size 24
```

#### 9.4 Font del sistema
```bash
gsettings set org.gnome.desktop.interface font-name "Inter 11"
gsettings set org.gnome.desktop.interface document-font-name "Inter 11"
gsettings set org.gnome.desktop.interface monospace-font-name "JetBrainsMono Nerd Font 10"
```

---

### ⏳ FASE 10: KEYBINDINGS — 60% Keyboard Optimized
**Estado:** PARCIAL
**Tiempo estimado:** 15 min
**Contexto:** Teclado 60% sin F-keys ni numpad

#### 10.1 Core bindings
```lua
# Ventanas
bind = SUPER, Q, killactive
bind = SUPER, M, exit
bind = SUPER, F, fullscreen
bind = SUPER, T, togglefloating
bind = SUPER, G, togglegroup

# Focus
bind = SUPER, H, movefocus, l
bind = SUPER, J, movefocus, d
bind = SUPER, K, movefocus, u
bind = SUPER, L, movefocus, r

# Move
bind = SUPER SHIFT, H, movewindow, l
bind = SUPER SHIFT, J, movewindow, d
bind = SUPER SHIFT, K, movewindow, u
bind = SUPER SHIFT, L, movewindow, r

# Resize
bind = SUPER CTRL, H, resizeactive, -50 0
bind = SUPER CTRL, J, resizeactive, 0 50
bind = SUPER CTRL, K, resizeactive, 0 -50
bind = SUPER CTRL, L, resizeactive, 50 0

# Workspaces (1-9 en 60%, usar números normales)
bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, 2
bind = SUPER, 3, workspace, 3
bind = SUPER, 4, workspace, 4
bind = SUPER, 5, workspace, 5
bind = SUPER, 6, workspace, 6
bind = SUPER, 7, workspace, 7
bind = SUPER, 8, workspace, 8
bind = SUPER, 9, workspace, 9

# Move to workspace
bind = SUPER SHIFT, 1, movetoworkspace, 1
bind = SUPER SHIFT, 2, movetoworkspace, 2
# ... etc

# Overview / Exposé (plugins FASE 6)
bind = SUPER, Tab, overview:toggle        # Hyprspace
bind = SUPER, grave, hyprexpo:expo, toggle # Hyprexpo (grave = `)

# Apps
bind = SUPER, Return, exec, alacritty
bind = SUPER, B, exec, thorium-browser
bind = SUPER, E, exec, nautilus
bind = SUPER, C, exec, code-oss
bind = SUPER, N, exec, typora
bind = SUPER, A, exec, claude-desktop

# Screenshot
bind = SUPER SHIFT, S, exec, grimblast --freeze copysave area
bind = SUPER, Print, exec, grimblast --freeze copysave screen

# Lock
bind = SUPER, X, exec, hyprlock

# Reload
bind = SUPER SHIFT, R, exec, hyprctl reload
```

#### 10.2 Mouse bindings
```lua
bindm = SUPER, mouse:272, movewindow
bindm = SUPER, mouse:273, resizewindow
```

---

### ⏳ FASE 11: NOTIFICACIONES — Mako / Swaync Premium
**Estado:** PENDIENTE
**Tiempo estimado:** 10 min
**Referencia:** Notificaciones del video — glassmorphism, esquinas redondeadas, acentos

#### 11.1 Swaync (recomendado para Hyprland)
```bash
yay -S --needed swaync
```

#### 11.2 Configuración
```bash
# ~/.config/swaync/config.json
# Tema Aurora Twilight con glassmorphism
```

#### 11.3 CSS
```css
/* ~/.config/swaync/style.css */
/* Glassmorphism + paleta Aurora Twilight */
```

---

### ⏳ FASE 12: LOCK SCREEN — Hyprlock Premium
**Estado:** PENDIENTE
**Tiempo estimado:** 10 min
**Referencia:** Pantalla de bloqueo con blur pesado y reloj elegante

#### 12.1 Configuración
```bash
# ~/.config/hypr/hyprlock.conf
# Fondo: wallpaper con blur 20+
# Reloj: JetBrains Mono, 64px, color lavanda
# Input: barra magenta, glassmorphism
```

---

### ⏳ FASE 13: APP LAUNCHER — Wofi / Rofi Premium
**Estado:** PENDIENTE
**Tiempo estimado:** 10 min
**Referencia:** Launcher del video — fondo borroso, iconos grandes, búsqueda centrada

#### 13.1 Wofi (más ligero, mejor para Hyprland)
```bash
yay -S --needed wofi
```

#### 13.2 Configuración
```bash
# ~/.config/wofi/config
# Style: Aurora Twilight
# Ancho: 600px, centrado
# Iconos: 32px
# Fondo: glassmorphism
```

#### 13.3 CSS
```css
/* ~/.config/wofi/style.css */
/* Glassmorphism + paleta Aurora Twilight */
```

---

### ⏳ FASE 14: POLISHING — Micro-ajustes y QA
**Estado:** PENDIENTE
**Tiempo estimado:** 20 min

#### 14.1 Checklist visual
- [ ] Blur consistente en barra, dock, terminal, notificaciones
- [ ] Sombras visibles y suaves en todas las ventanas
- [ ] Animaciones suaves, sin tearing
- [ ] Iconos del dock sin "X" rotos
- [ ] Hover effects consistentes (magenta = hover, cyan = activo)
- [ ] Workspace switch fluido
- [ ] Overview (Hyprspace) muestra todas las ventanas correctamente
- [ ] Hyprexpo grid se ve bien y es navegable
- [ ] Lock screen funciona y se ve premium
- [ ] Launcher se abre rápido y se ve integrado
- [ ] No hay apps con fondo sólido feo (todas tienen glassmorphism o blur)

#### 14.2 Performance check
```bash
# Verificar que no haya lag
hyprctl reload
# Probar: cambiar workspace, abrir overview, mover ventanas
# Si hay lag: reducir blur passes de 3 a 2, o shadow range de 20 a 12
```

#### 14.3 Consistencia de bordes redondeados
```lua
# En hyprland.conf
decoration {
    rounding = 16
}
# Asegurar que todas las apps flotantes también tengan rounding
```

---

### ⏳ FASE 15: DOCUMENTACIÓN + GITHUB COMMIT
**Estado:** PENDIENTE
**Tiempo estimado:** 15 min
**Referencia:** GitHub es tu CV — commits estructurados, README profesional

#### 15.1 Estructura del repo dotfiles
```
dotfiles/
├── README.md              # Overview con screenshots
├── CLAUDE.md              # Este documento
├── .config/
│   ├── hypr/
│   │   ├── hyprland.conf
│   │   ├── hyprlock.conf
│   │   ├── hypridle.conf
│   │   └── scripts/
│   ├── waybar/
│   │   ├── config
│   │   └── style.css
│   ├── nwg-dock-hyprland/
│   │   └── style.css
│   ├── alacritty/
│   │   └── alacritty.toml
│   ├── wofi/
│   │   ├── config
│   │   └── style.css
│   ├── swaync/
│   │   ├── config.json
│   │   └── style.css
│   └── swww/
│       └── wallpapers/
├── .local/
│   └── share/
│       └── applications/   # .desktop files custom
└── screenshots/
    ├── overview.png
    ├── dock.png
    ├── workspace.png
    └── expose.png
```

#### 15.2 Commits estructurados
```bash
# Ejemplos de commits para esta fase:
git add .
git commit -m "feat(hyprland): add blur, shadows, and custom bezier animations"
git commit -m "feat(plugins): install and configure hyprspace + hyprexpo"
git commit -m "feat(dock): fix broken icons, add glow hover effects"
git commit -m "feat(waybar): implement full glassmorphism with Aurora palette"
git commit -m "feat(wallpaper): integrate swww with Aurora theme"
git commit -m "feat(gtk): apply system-wide Aurora Twilight theme"
git commit -m "docs(readme): add overview screenshots and install guide"
```

#### 15.3 README.md template
```markdown
# 🌌 Aurora Twilight — Omarchy on CachyOS

> A premium Hyprland desktop environment inspired by macOS/Compiz aesthetics.

## ✨ Features
- Glassmorphism Waybar & Dock
- Hyprspace Overview (Mission Control)
- Hyprexpo Desktop Grid
- Custom bezier animations (Compiz-like)
- Aurora Twilight color palette
- 60% keyboard optimized

## 📸 Screenshots
[overview] [dock] [workspace] [expose]

## 🚀 Installation
1. Install CachyOS with Hyprland
2. Clone this repo
3. Run `stow .` or copy configs manually
4. Install plugins: `hyprpm update && hyprpm add hyprspace hyprexpo`
5. Reboot

## 🎨 Palette
| Color | Hex |
|-------|-----|
| Base | #1a1b3a |
| Magenta | #ff006e |
| Cyan | #00d9ff |
| Lavanda | #b8b8ff |

## 📦 Dependencies
- hyprland, hypridle, hyprlock
- waybar, nwg-dock-hyprland
- swww, wofi, swaync
- JetBrains Mono Nerd Font, Inter

## 📝 License
MIT — DeglozDev
```

---

## 🧠 ANEXO: Guía para el AI (Claude Code / Kimi Code)

### Cómo usar este documento
1. **Lee todo el documento primero** antes de tocar cualquier archivo
2. **Trabaja fase por fase**, no saltes
3. **Después de cada fase**, verifica que funcione antes de continuar
4. **Haz commit** al final de cada fase
5. **Si algo falla**, vuelve al backup y reintenta

### Comandos de verificación universales
```bash
# Verificar que Hyprland sigue funcionando
hyprctl version

# Verificar que un proceso corre
pgrep -f <nombre>

# Ver logs de Hyprland
journalctl -u hyprland --since "5 minutes ago"

# Recargar config sin reiniciar
hyprctl reload

# Verificar plugins cargados
hyprctl plugins list
```

### Debugging común
| Síntoma | Causa probable | Fix |
|---------|---------------|-----|
| Dock no aparece | nwg-dock-hyprland no corre | Verificar `pgrep`, relanzar con flags |
| Iconos rotos | Class name no coincide | `hyprctl clients \| grep class` |
| Sin blur | Falta layerrule | Agregar `layerrule = blur, gtk-layer-shell` |
| Animaciones lag | blur passes muy alto | Reducir a 2, o shadow range a 12 |
| Plugin no carga | hyprpm no compiló | `hyprpm update && hyprpm reload` |
| Waybar no inicia | Error en config JSON | Validar JSON con `jq` |

### Flags de nwg-dock-hyprland
```bash
nwg-dock-hyprland -d          # Debug mode
nwg-dock-hyprland -i 48       # Icon size 48px
nwg-dock-hyprland -mb 12      # Margin bottom 12px
nwg-dock-hyprland -p bottom   # Position bottom
nwg-dock-hyprland -a          # Auto-hide
nwg-dock-hyprland -n          # No launcher button
```

### Sintaxis Hyprland 0.55 (Lua-style) — RECORDAR
```lua
# CORRECTO (0.55)
windowrule = opacity 0.95 0.85, Alacritty
layerrule = blur, waybar
bind = SUPER, Q, killactive

# INCORRECTO (deprecated)
# windowrulev2 = opacity 0.95 0.85, class:Alacritty
# layerrule = blur, ^(waybar)$
```

---

## 🎯 DEFINICIÓN DE "TERMINADO"

El proyecto se considera COMPLETO cuando:

1. ✅ El dock muestra 6 iconos perfectos, sin X, con hover glow magenta
2. ✅ La barra superior es 100% glassmorphism, sin fondo sólido visible
3. ✅ Al acercar el mouse al dock, aparece con animación suave
4. ✅ Al cambiar de workspace, la transición es fluida (bezier custom)
5. ✅ SUPER+Tab abre el overview (Hyprspace) mostrando todas las ventanas en grid
6. ✅ SUPER+` abre Hyprexpo mostrando todos los workspaces en grid 3D
7. ✅ Las ventanas tienen sombras suaves y bordes redondeados de 16px
8. ✅ El terminal (Alacritty) tiene transparencia 0.9 y se ve el wallpaper detrás
9. ✅ El blur es consistente en TODOS los elementos (barra, dock, terminal, notificaciones)
10. ✅ El wallpaper es Aurora abstract, cambia suavemente con swww
11. ✅ El lock screen muestra reloj grande con blur pesado
12. ✅ El launcher (wofi) se abre con fondo glassmorphism y iconos
13. ✅ Todas las notificaciones usan el tema Aurora
14. ✅ El repo dotfiles tiene README con screenshots y commits estructurados
15. ✅ No hay errores en `hyprctl reload` ni en logs de Hyprland

---

## 📅 Timeline Sugerido

| Fase | Tiempo | Día |
|------|--------|-----|
| 0-2 | 15 min | Hoy (ya hecho) |
| 3 | 15 min | Hoy |
| 4 | 20 min | Hoy (en progreso) |
| 5 | 25 min | Hoy |
| 6 | 30 min | Mañana |
| 7 | 15 min | Mañana |
| 8 | 10 min | Mañana |
| 9 | 20 min | Mañana |
| 10 | 15 min | Mañana |
| 11-13 | 30 min | Día 3 |
| 14-15 | 35 min | Día 3 |
| **TOTAL** | **~3.5 horas** | **3 días** |

---

*Documento generado para DeglozDev (Henry) — CachyOS + Hyprland 0.55 + Omarchy*
*Paleta: Aurora Twilight (#1a1b3a, #ff006e, #00d9ff, #b8b8ff)*
*GitHub: github.com/deglozbusiness-debug/dotfiles*
