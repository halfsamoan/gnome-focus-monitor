# GNOME Focus Monitor

A GNOME Shell extension that switches keyboard focus between monitors without moving windows.

## Implementation

- Selects the most recently used eligible application window on the leftmost or rightmost monitor.
- Derives monitor order from Mutter geometry rather than assuming display indices.
- Restricts selection to the current workspace and excludes minimized, hidden, unmapped, and non-application windows.
- Reads the current window list only when a shortcut is pressed, using Mutter's native activation API without a background daemon or polling loop.

[Window selection and activation](focus-monitor@local/extension.js)

## Install

Requires GNOME Shell 50, a Wayland session, and multiple monitors. From the repository root:

```sh
bash check-conflicts.sh
bash install.sh
```

Log out and back in after installation or changes to the extension code.

## Keyboard shortcuts

| Shortcut | Action |
|---|---|
| `Shift + Super + O` | Focus the most recently used window on the leftmost monitor |
| `Shift + Super + P` | Focus the most recently used window on the rightmost monitor |

If the target monitor has no eligible window, focus stays where it is. GNOME versions other than Shell 50 are outside the declared support range.

## Remove

```sh
bash rollback.sh
```

[Installation diagnostics and validation](CONTRIBUTING.md)

## License

[MIT](LICENSE).
