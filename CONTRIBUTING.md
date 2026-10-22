# Installation diagnostics and validation

## Prerequisites

Requires GNOME Shell 50 on Wayland, multiple monitors, Bash, `gsettings`, and `gnome-extensions`. Node.js and Python 3 are used by the source checks.

## Source checks

```sh
bash -n check-conflicts.sh install.sh rollback.sh
node --input-type=module --check < focus-monitor@local/extension.js
python3 -m json.tool focus-monitor@local/metadata.json
```

These commands check syntax and metadata only. They do not establish compatibility with a running Mutter/GNOME session.

## Installation

```sh
bash check-conflicts.sh
bash install.sh
```

Log out and back in, then inspect the installed extension:

```sh
gnome-extensions info focus-monitor@local
```

GNOME Shell on Wayland does not reload extension code merely because its files were replaced. Use a new login session after code changes.

## Selection contract

`Shift + Super + O` targets the leftmost monitor; `Shift + Super + P` targets the rightmost. Monitor geometry supplies left/right ordering. The target is the most recently used eligible normal window on the current workspace according to Mutter's tab list.

Desktop, dock, panel, notification, popup, hidden, minimized, unmapped, skipped-taskbar, and non-normal windows are excluded. With no eligible target, the extension does nothing. It does not maintain a separate focus-history database.

## Remove or roll back

```sh
bash rollback.sh
```

The script disables the extension and removes its own per-user installation without changing other enabled extensions or system packages.

## Target-session validation

Test monitor order, workspace changes, empty target monitors, shortcut conflicts, and scaling on GNOME Shell 50. When reporting a failure, include the Shell version, session type, monitor layout, and relevant extension error lines. Exclude private window titles and unrelated desktop logs.
