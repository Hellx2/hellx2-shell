pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick
import qs.core

Singleton {
    // Not used for anything, just something to set for this
    // singleton to be loaded at startup.
    property bool initialize: false
    property var root

    IpcHandler {
        function toggle(panelName: string): bool {
            return PanelManager.toggleActivePanel(panelName);
        }
        target: "panel"
    }

    IpcHandler {
        function settingsToggle() {
            root.settings_ui.visible = !root.settings_ui.visible;
        }
        target: "ui"
    }

    IpcHandler {
        function set(prop: string, value: string): string {
            if (Globals.settings.hasOwnProperty(prop)) {
                if (!prop.startsWith("_") && !prop.endsWith("Changed") && prop != "objectName" && typeof Globals.settings[prop] !== "function")
                    Globals.settings[prop] = value;
                else
                    return `Error: Cannot change value ${prop}`;
            } else
                return `Error: Invalid setting '${prop}'!`;
        }
        function get(prop: string): string {
            return Globals.settings[prop];
        }
        function reset(prop: string): string {
            if (Globals.settings.hasOwnProperty(prop)) {
                Globals.settings[prop] = root.default_settings[prop];
                return "Success";
            } else
                return `Error: Invalid setting '${prop}'!`;
        }
        target: "settings"
    }

    IpcHandler {
        target: "wallpaper"
        function set(path: string) {
            root.background.backgroundPath = path;
        }
    }

    IpcHandler {
        function toggle() {
            Pomodoro.showPomodoro = !Pomodoro.showPomodoro;
        }
        target: "pomodoro"
    }

    Timer {
        id: osd_hidetimer
        interval: 1000
        onTriggered: {
            root.osd.currentOsd = 0;
        }
    }

    IpcHandler {
        function playPause() {
            Mpris.players.values[0].togglePlaying();
            root.osd.currentOsd = 2; // Player
            osd_hidetimer.restart();
        }
        function next() {
            if (Mpris.players.values[0].canGoNext) {
                Mpris.players.values[0].next();
                root.osd.currentOsd = 3; // PlayerNext
                osd_hidetimer.restart();
            }
        }
        function prev() {
            if (Mpris.players.values[0].canGoPrevious) {
                Mpris.players.values[0].previous();
                root.osd.currentOsd = 4; // PlayerPrev
                osd_hidetimer.restart();
            }
        }
        target: "players"
    }

    Process {
        id: setBrightnessProc
        property var setBrightnessTo
        command: ["fish", "-c", `brightnessctl s ${setBrightnessTo} &>/dev/null; math "$(brightnessctl g)/$(brightnessctl m)*100"`]

        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                root.osd.currentBrightness = Number(this.text);
                root.osd.currentOsd = 1; // Brightness
                osd_hidetimer.restart();
            }
        }
    }

    IpcHandler {
        function set(brightness: string) {
            setBrightnessProc.setBrightnessTo = brightness;
            setBrightnessProc.running = true;
        }
        target: "brightness"
    }
}
