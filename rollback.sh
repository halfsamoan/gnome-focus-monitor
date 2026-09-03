#!/usr/bin/env bash
set -eu

UUID='focus-monitor@local'
DATA_DIR=${XDG_DATA_HOME:-$HOME/.local/share}
TARGET_DIR="$DATA_DIR/gnome-shell/extensions/$UUID"

if [ ! -f "$TARGET_DIR/metadata.json" ] || ! grep -q '"uuid"[[:space:]]*:[[:space:]]*"focus-monitor@local"' "$TARGET_DIR/metadata.json"; then
    printf 'Refusing to remove a directory that is not Focus Monitor: %s\n' "$TARGET_DIR" >&2
    exit 1
fi

gnome-extensions disable "$UUID" >/dev/null 2>&1 || true

enabled=$(gsettings get org.gnome.shell enabled-extensions 2>/dev/null || true)
case "$enabled" in
    *"'$UUID'"*)
        enabled=$(printf '%s\n' "$enabled" | sed "s/, '$UUID'//;s/'$UUID', //;s/\['$UUID'\]/[]/")
        gsettings set org.gnome.shell enabled-extensions "$enabled"
        ;;
esac

rm -rf -- "$TARGET_DIR"
printf 'Removed %s\n' "$TARGET_DIR"
