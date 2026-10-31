pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick
import qs

Singleton {
    // Not used for anything, just something to set for this
    // singleton to be loaded at startup.
    property bool initialize: false
    property var root

    IpcHandler {
        function settingsToggle() {
            root.settings_ui.visible = !root.settings_ui.visible
        }
        target: "ui"
    }

    IpcHandler {
        target: "layoutSwitcher"
        function open() {
            root.layout_switcher.visible = true
        }
        function close() {
            root.layout_switcher.visible = false
        }
        function toggle() {
            root.layout_switcher.visible = !root.layout_switcher.visible
        }
    }

    IpcHandler {
		function setPrimaryScreen(value: string) {
			Globals.settings.primaryScreen = value;
		}
		function getPrimaryScreen(): string {
			return Globals.settings.primaryScreen;
        }
        function set(prop: string, value: string): string  {
            if (Globals.settings.hasOwnProperty(prop)) {
                if (!prop.startsWith("_") && !prop.endsWith("Changed")
                && prop != "objectName" && typeof Globals.settings[prop] !== "function")
                    Globals.settings[prop] = value;
                else return `Error: Cannot change value ${prop}`
            } else return `Error: Invalid setting '${prop}'!`;
        }
        function get(prop: string): string {
            return Globals.settings[prop];
        }
        function reset(prop: string) {
            if (Globals.settings.hasOwnProperty(prop)) {
                Globals.settings[prop] = defaultSettings[prop];
                return "Success";
            } else return `Error: Invalid setting '${prop}'!`
        }
		/*function setMode(mode: string) {
			if (["home", "school", "game"].includes(mode))
				Globals.settings.mode = mode;
			else
				console.error(`Unknown mode '${mode}', ignoring.`);
		}
		function getMode(): string {
			return Globals.settings.mode;
        }*/
		target: "settings"
    }

    IpcHandler {
        function toggle() {
            AppMenu.showAppMenu = !AppMenu.showAppMenu;
        }
        function open() {
            AppMenu.showAppMenu = true;
        }
        function close() {
            AppMenu.showAppMenu = false;
        }
        target: "apps"
    }
    IpcHandler {
        target: "wallpaper"
        function set(path: string) {
            root.background.backgroundPath = path;
        }
    }

    IpcHandler {
        function toggle() {
            Launchpad.showLaunchpad = !Launchpad.showLaunchpad;
        }
        function open() {
            Launchpad.showLaunchpad = true;
        }
        function close() {
            Launchpad.showLaunchpad = false;
        }
        target: "launchpad"
    }

    IpcHandler {
        function toggle() {
            Pomodoro.showPomodoro = !Pomodoro.showPomodoro;
        }
        target: "pomodoro"
    }

    IpcHandler {
        function show() {
            PowerMenu.showPowerMenu = true
        }
        function hide() {
            PowerMenu.showPowerMenu = false
        }
        function toggle() {
            PowerMenu.showPowerMenu = !PowerMenu.showPowerMenu
        }
        target: "powermenu"
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
            Mpris.players.values[0].togglePlaying()
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
