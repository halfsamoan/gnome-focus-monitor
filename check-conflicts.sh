#!/usr/bin/env bash
set -u

printf '%s\n' 'Checking exact bindings: <Shift><Super>O and <Shift><Super>P'

schemas=(
    org.gnome.desktop.wm.keybindings
    org.gnome.mutter.keybindings
    org.gnome.mutter.wayland.keybindings
    org.gnome.shell.keybindings
    org.gnome.settings-daemon.plugins.media-keys
)

found=0
for schema in "${schemas[@]}"; do
    while IFS= read -r line; do
        case "$line" in
            *"'<Shift><Super>O'"*|*"'<Super><Shift>O'"*|*"'<Shift><Super>o'"*|*"'<Super><Shift>o'"*|\
            *"'<Shift><Super>P'"*|*"'<Super><Shift>P'"*|*"'<Shift><Super>p'"*|*"'<Super><Shift>p'"*)
                printf '%s\n' "$line"
                found=1
                ;;
        esac
    done < <(gsettings list-recursively "$schema" 2>/dev/null || true)
done

custom_paths=$(gsettings get org.gnome.settings-daemon.plugins.media-keys custom-keybindings 2>/dev/null || true)
while IFS= read -r path; do
    [ -n "$path" ] || continue
    schema="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$path"
    binding=$(gsettings get "$schema" binding 2>/dev/null || true)
    case "$binding" in
        *"'<Shift><Super>O'"*|*"'<Super><Shift>O'"*|*"'<Shift><Super>o'"*|*"'<Super><Shift>o'"*|\
        *"'<Shift><Super>P'"*|*"'<Super><Shift>P'"*|*"'<Shift><Super>p'"*|*"'<Super><Shift>p'"*)
            printf '%s binding=%s\n' "$path" "$binding"
            found=1
            ;;
    esac
done < <(printf '%s\n' "$custom_paths" | tr -d "[]'" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

if [ "$found" -eq 0 ]; then
    printf '%s\n' 'No exact conflict found.'
    exit 0
fi

printf '%s\n' 'Exact conflict found; do not enable the extension until the binding is changed.'
exit 2
