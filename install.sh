#!/usr/bin/env bash
set -eu

UUID='focus-monitor@local'
SOURCE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/$UUID" && pwd)
DATA_DIR=${XDG_DATA_HOME:-$HOME/.local/share}
TARGET_DIR="$DATA_DIR/gnome-shell/extensions/$UUID"

[ -f "$SOURCE_DIR/metadata.json" ]
[ -f "$SOURCE_DIR/extension.js" ]

if [ -e "$TARGET_DIR" ] || [ -L "$TARGET_DIR" ]; then
    printf 'Refusing to overwrite existing extension: %s\n' "$TARGET_DIR" >&2
    exit 1
fi

install -d "$TARGET_DIR"
install -m 0644 "$SOURCE_DIR/metadata.json" "$TARGET_DIR/metadata.json"
install -m 0644 "$SOURCE_DIR/extension.js" "$TARGET_DIR/extension.js"
touch "$TARGET_DIR/.focus-monitor-installed"

enabled=$(gsettings get org.gnome.shell enabled-extensions)
case "$enabled" in
    *"'$UUID'"*) ;;
    *) gsettings set org.gnome.shell enabled-extensions "${enabled%]}, '$UUID']" ;;
esac

printf 'Installed files at %s\n' "$TARGET_DIR"
printf 'Enabled for the next GNOME Shell login: %s\n' "$UUID"
