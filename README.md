# GNOME Focus Monitor

**Switch keyboard focus between monitors on GNOME Wayland — without moving windows or reaching for the mouse.**

Focus Monitor is a tiny GNOME Shell extension for dual-monitor workflows. It
activates the most recently used normal application window on the left or right
monitor, while keeping every window exactly where it is.

This is designed for GNOME Shell 50 on Wayland and works with native Wayland
applications such as Firefox, GNOME Terminal, and Visual Studio Code. It does
not use `xdotool`, `wmctrl`, X11 APIs, or a background daemon.

## Shortcuts

| Shortcut | Action |
| --- | --- |
| `Shift` + `Super` + `O` | Focus the most recently used app window on the leftmost monitor |
| `Shift` + `Super` + `P` | Focus the most recently used app window on the rightmost monitor |

“Left” and “right” are determined from the monitors’ Mutter geometry X
coordinates. Monitor numbers are not assumed to be `0` and `1`.

The target is selected from the current workspace in Mutter’s normal-window
MRU order. Desktop, dock, panel, notifications, popups, GNOME Shell UI,
hidden, minimized, unmapped, skipped-taskbar, and non-normal windows are
ignored.

## Why this exists

GNOME’s built-in monitor switching shortcuts can move focus in ways that are
not predictable when several windows share a monitor. This extension provides
two explicit “focus the other screen” keys:

```text
Firefox (left monitor)  <── Shift+Super+O / Shift+Super+P ──>  Terminal (right monitor)
```

The extension calls Mutter’s native `Meta.Window.activate()` API. It does not
move, resize, minimize, or maximize the selected window.

## Requirements

- GNOME Shell 50.x
- A Wayland session
- Two or more monitors
- Bash, `gsettings`, `gnome-extensions`, `node`, and Python 3 for the checks

The code intentionally has no GSettings schema, so there is no
`gschemas.compiled` file to install and no schema lookup failure to diagnose.

## Install

Clone the repository, inspect the shortcut conflicts, validate the files, and
install it for the current user:

```bash
git clone https://github.com/halfsamoan/gnome-focus-monitor.git
cd gnome-focus-monitor
bash check-conflicts.sh
node --input-type=module --check < focus-monitor@local/extension.js
python3 -m json.tool focus-monitor@local/metadata.json >/dev/null
bash install.sh
```

On Wayland, GNOME Shell cannot be restarted in place. Log out and log back in
after the first installation or after changing the extension code. Then verify:

```bash
gnome-extensions info focus-monitor@local
journalctl --user -b _COMM=gnome-shell --since '2 minutes ago' \
  | grep -E 'focus-monitor|schema.*could not|JavaScript Error'
```

If `grep` prints no matching error, the command exits with a non-zero status;
that is normal. `rg` is optional and is not required by this project.

## Uninstall / rollback

From the cloned repository:

```bash
bash rollback.sh
```

This disables the extension, removes only `focus-monitor@local` from GNOME’s
enabled-extension list, and deletes the exact per-user extension directory.
It does not modify system packages or the rest of the GNOME configuration.

## Performance and design

- No polling or timers
- No background process
- No continuous D-Bus calls
- One Mutter accelerator signal while enabled
- Monitor geometry and the current-workspace MRU list are read only when a
  shortcut is pressed
- No window movement or X11/XWayland dependency

## Known limitations

- The extension intentionally targets GNOME Shell 50 only.
- If the target monitor has no selectable normal window on the current
  workspace, the shortcut does nothing.
- “Most recently used” follows Mutter’s normal-window tab list; it is not a
  separately maintained history database.
- The shortcuts must be available to Mutter. Run `bash check-conflicts.sh` before
  installation.

## Development checks

```bash
bash -n check-conflicts.sh install.sh rollback.sh
node --input-type=module --check < focus-monitor@local/extension.js
python3 -m json.tool focus-monitor@local/metadata.json >/dev/null
```

## Contributing

Bug reports and pull requests are welcome. Include:

- GNOME Shell version
- Wayland/X11 session type
- monitor layout and scaling
- the relevant `journalctl --user -b _COMM=gnome-shell` output
- whether the target app is on the current workspace

Please do not include private window titles or other personal data in logs.

## License

MIT. See [LICENSE](LICENSE).

## Search keywords

GNOME Shell extension, GNOME 50, Ubuntu 26.04, Wayland, dual monitor,
multi-monitor, keyboard focus, focus window, switch monitor, native Wayland,
Firefox, GNOME Terminal, VS Code, xdotool alternative, wmctrl alternative.
