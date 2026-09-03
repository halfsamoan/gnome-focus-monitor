import Meta from 'gi://Meta';
import Shell from 'gi://Shell';

import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

const LEFT = 'left';
const RIGHT = 'right';

const ACCELERATORS = [
    {accelerator: '<Shift><Super>o', side: LEFT},
    {accelerator: '<Shift><Super>p', side: RIGHT},
];

function isSelectableWindow(window) {
    if (!window || window.is_override_redirect())
        return false;

    if (window.minimized || !window.mapped || window.is_hidden())
        return false;

    if (!window.showing_on_its_workspace() || window.is_skip_taskbar())
        return false;

    return window.get_window_type() === Meta.WindowType.NORMAL;
}

export default class FocusMonitorExtension extends Extension {
    enable() {
        this._display = global.display;
        this._actions = new Map();
        this._acceleratorActivatedId = this._display.connect(
            'accelerator-activated',
            (_display, action, _deviceId, timestamp) => this._onAccelerator(action, timestamp));

        for (const binding of ACCELERATORS)
            this._grab(binding);
    }

    disable() {
        if (this._acceleratorActivatedId) {
            this._display.disconnect(this._acceleratorActivatedId);
            this._acceleratorActivatedId = 0;
        }

        for (const [action, binding] of this._actions) {
            try {
                Main.wm.allowKeybinding(binding.name, Shell.ActionMode.NONE);
            } catch (error) {
                console.error(`[${this.uuid}] failed to block ${binding.name}: ${error}`);
            }

            try {
                this._display.ungrab_accelerator(action);
            } catch (error) {
                console.error(`[${this.uuid}] failed to ungrab ${binding.accelerator}: ${error}`);
            }
        }

        this._actions.clear();
        this._display = null;
    }

    _grab(binding) {
        try {
            const action = this._display.grab_accelerator(binding.accelerator, 0);
            if (action === Meta.KeyBindingAction.NONE) {
                console.error(`[${this.uuid}] unavailable: ${binding.accelerator}`);
                return;
            }

            const name = Meta.external_binding_name_for_action(action);
            Main.wm.allowKeybinding(name, Shell.ActionMode.ALL);
            this._actions.set(action, {...binding, name});
        } catch (error) {
            console.error(`[${this.uuid}] failed to register ${binding.accelerator}: ${error}`);
        }
    }

    _onAccelerator(action, timestamp) {
        const binding = this._actions.get(action);
        if (!binding)
            return;

        const monitor = this._getTargetMonitor(binding.side);
        if (!monitor) {
            console.warn(`[${this.uuid}] ${binding.side} monitor is unavailable`);
            return;
        }

        const workspace = global.workspace_manager.get_active_workspace();
        const windows = this._display.get_tab_list(Meta.TabList.NORMAL, workspace);
        const window = windows.find(candidate =>
            isSelectableWindow(candidate) && candidate.get_monitor() === monitor.index);

        if (!window) {
            console.debug(`[${this.uuid}] no selectable window on ${binding.side} monitor`);
            return;
        }

        try {
            window.activate(timestamp || global.get_current_time());
            console.debug(
                `[${this.uuid}] activated ${window.get_title() || '(untitled)'} on ${binding.side} monitor`);
        } catch (error) {
            console.error(`[${this.uuid}] failed to activate target window: ${error}`);
        }
    }

    _getTargetMonitor(side) {
        const monitors = [];
        const count = this._display.get_n_monitors();

        for (let index = 0; index < count; index++) {
            const geometry = this._display.get_monitor_geometry(index);
            if (geometry)
                monitors.push({index, x: geometry.x, y: geometry.y});
        }

        monitors.sort((a, b) => a.x - b.x || a.y - b.y);
        if (monitors.length < 2)
            return null;

        return side === LEFT ? monitors[0] : monitors[monitors.length - 1];
    }
}
