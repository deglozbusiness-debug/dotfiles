#!/usr/bin/env bash
# categorize-webapps.sh — add Categories= to Omarchy-generated web app .desktop files.
#
# Why this exists:
#   GMenu (Cairo-Dock plugin) groups apps by their freedesktop Categories=.
#   `omarchy-launch-webapp` generates .desktop entries WITHOUT a Categories=
#   line, so every web app falls into the "Other" submenu. On a 1080p display,
#   30+ items in one submenu overflow the top of the screen — and GtkMenu in
#   Wayland cannot be shrunk by CSS max-height (the popup size is fixed by the
#   xdg_positioner BEFORE the theme applies). The only stable fix is to reduce
#   the number of items per submenu by giving each app a proper category.
#
#   This script applies a curated mapping for the web apps DeglozDev uses,
#   plus a few terminal launchers (Disk Usage, Docker, Fizzy) and Typora.
#
# Idempotent: only adds Categories= to files that lack it. To re-categorize an
# app, delete its Categories= line manually and re-run, or edit the file.
#
# Usage:
#   bash local/scripts/categorize-webapps.sh

set -euo pipefail

APPS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"

declare -A CATEGORIES=(
    ["Basecamp.desktop"]="Office;ProjectManagement;"
    ["ChatGPT.desktop"]="Utility;"
    ["Discord.desktop"]="Network;InstantMessaging;"
    ["Disk Usage.desktop"]="System;Utility;FileTools;"
    ["Docker.desktop"]="Development;System;"
    ["Figma.desktop"]="Graphics;Development;"
    ["Fizzy.desktop"]="System;Utility;"
    ["GitHub.desktop"]="Development;RevisionControl;"
    ["Google Contacts.desktop"]="Office;ContactManagement;"
    ["Google Maps.desktop"]="Utility;Geography;Maps;"
    ["Google Messages.desktop"]="Network;InstantMessaging;"
    ["Google Photos.desktop"]="Graphics;Photography;"
    ["HEY.desktop"]="Office;Email;"
    ["typora.desktop"]="Office;TextEditor;"
    ["WhatsApp.desktop"]="Network;InstantMessaging;"
    ["X.desktop"]="Network;"
    ["YouTube.desktop"]="AudioVideo;Video;"
    ["Zoom.desktop"]="Network;Telephony;"
)

added=0
skipped=0
missing=0

for file in "${!CATEGORIES[@]}"; do
    path="$APPS_DIR/$file"
    if [[ ! -f "$path" ]]; then
        printf "  [miss] %s (not installed)\n" "$file"
        missing=$((missing + 1))
        continue
    fi
    if grep -q "^Categories=" "$path"; then
        skipped=$((skipped + 1))
        continue
    fi
    printf "Categories=%s\n" "${CATEGORIES[$file]}" >> "$path"
    printf "  [add ] %-25s → %s\n" "$file" "${CATEGORIES[$file]}"
    added=$((added + 1))
done

if [[ $added -gt 0 ]]; then
    update-desktop-database "$APPS_DIR" 2>/dev/null || true
    printf "\nDesktop database refreshed.\n"
fi

printf "\nAdded: %d | Skipped: %d (already categorized) | Missing: %d (not installed)\n"     "$added" "$skipped" "$missing"
