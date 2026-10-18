//@ pragma NativeTextRendering
//@ pragma UseQApplication
//@ pragma Env QS_DROP_EXPENSIVE_FONTS = 1
//@ pragma AppId io.github.hellx2.hellx2shell

import QtCore
import QtQuick
import Quickshell
import Quickshell.Io

import qs.bars
import qs.modules
import qs.rootmodules

Scope {
    id: root

    Binding {
        target: Application
        property: "organization"
        value: "Hellx2"
        delayed: false
    }
    Binding {
        target: Application
        property: "domain"
        value: "io.github.hellx2"
        delayed: false
    }

    property bool loadApp: false
    Timer {
        interval: 1000
        running: true
        repeat: false
        onTriggered: root.loadApp = true
    }

    Component.onCompleted: {
        let a = DesktopEntries.applications;
        //console.warn(JSON.parse(JSON.stringify(Globals.settings)))
        let settings = JSON.parse(persistentSettings.settings);
        for (let i of Object.entries(settings)) {
            if (Globals.settings[i[0]]) Globals.settings[i[0]] = i[1]
        }
    }

    Settings {
        id: persistentSettings
        property string settings: {
            let a = Object.getOwnPropertyNames(Globals.settings).filter(x => {
                return !x.endsWith("Changed") && x != "objectName" && typeof Globals.settings[x] !== "function"
            })

            let x = {};
            for (let i of a) {
                x[i] = Globals.settings[i];
            }

            return JSON.stringify(x)
        }
    }

    ShellSettings {
        id: defaultSettings
    }

    SettingsUI {
        id: settingsui
    }

    IpcHandler {
        function settingsToggle() {
            settingsui.visible = !settingsui.visible
        }
        target: "ui"
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


    LazyLoader {
        active: root.loadApp
        Scope {
            Component.onCompleted: {
                AppMenu.showAppMenu = false;
                Launchpad.showLaunchpad = false;
                PowerMenu.showPowerMenu = false;
                IdleManager.running = true;
                SystemUpdater.updateChecking = true;
            }

            Loader {
                active: Globals.settings.mode == "school"
                sourceComponent: Variants {
                    model: Quickshell.screens
                    delegate: BottomBar {}
                }
            }
            Loader {
                active: Globals.settings.mode == "home"
                sourceComponent: Scope {
                    Dock {}
                    Variants {
                        model: Quickshell.screens
                        delegate: TopBar {}
                    }
                }
            }
            Loader {
                active: Globals.settings.mode == "game"
                sourceComponent: Variants {
                    model: Quickshell.screens
                    delegate: GameBar {}
                }
            }
            OSD {}
            PKAgent {}
            NotifyDaemon {}
            Background {}
        }
    }
}
