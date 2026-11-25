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
        id: startTimer
        interval: 1000
        running: false
        repeat: false
        onTriggered: root.loadApp = true
    }

    Component.onCompleted: {
        IPC.initialize = true;
        IPC.root = root;
        //Globals.mainSettings = JSON.parse(Globals.settingsInst.mainSettings)
        let a = DesktopEntries.applications;
        let settings = JSON.parse(persistentSettings.settings);
        for (let i of Object.entries(settings)) {
            if (Globals.settings.hasOwnProperty(i[0]))
                Globals.settings[i[0]] = i[1];
        }
        //root.loadApp = true;
        themeTimer.running = true;
        //startTimer.running = true;
    }

    Settings {
        id: persistentSettings
        property string settings: {
            let a = Object.getOwnPropertyNames(Globals.settings).filter(x => {
                return !x.endsWith("Changed") && x != "objectName" && typeof Globals.settings[x] !== "function";
            });

            let x = {};
            for (let i of a) {
                x[i] = Globals.settings[i];
            }

            return JSON.stringify(x);
        }
    }

    Timer {
        id: themeTimer
        interval: 400
        running: false
        onTriggered: {
            themeloader.active = true;
            startTimer.running = true;
        }
    }

    LazyLoader {
        id: themeloader
        active: false
        FileView {
            id: themefile
            path: Qt.resolvedUrl(Globals.settings.theme)
            blockLoading: true
            blockAllReads: true
            watchChanges: true
            onLoaded: {
                let a = JSON.parse(this.text());
                for (let i of Object.entries(a)) {
                    if (Globals.theme.hasOwnProperty(i[0]))
                        Globals.theme[i[0]] = i[1];
                    console.warn(i[0], i[1]);
                }
            }
            onFileChanged: {
                let a = JSON.parse(this.text());
                for (let i of Object.entries(a)) {
                    if (Globals.theme.hasOwnProperty(i[0]))
                        Globals.theme[i[0]] = i[1];
                }
            }
        }
    }

    ShellSettings {
        id: defaultSettings
    }
    SettingsUI {
        id: settingsui
    }
    LayoutSwitcher {
        id: layoutSwitcher
    }
    Background {
        id: bg
    }
    OSD {
        id: osd1
    }
    ThemeSwitcher {
        id: themeSwitcher
    }
    AutostartApps {
        id: autostart
    }

    property var settings_ui: settingsui
    property var layout_switcher: layoutSwitcher
    property var theme_switcher: themeSwitcher
    property var background: bg
    property var osd: osd1
    property var autostartEditor: autostart
    property var modes: ({
            "school": {
                "bars": [
                    {
                        "position": "bottom",
                        "leftModules": ["launcher", "workspaces", "currentWindow", "spacer", "windows"],
                        "rightModules": ["player", "spacer", "tray", "pomodoro", "volume", "spacer", "tailscale", "bluetooth", "network", "spacer", "battery", "spacer", "clock"]
                    }
                ]
            },
            "home": {
                "extraModules": ["dock"],
                "bars": [
                    {
                        "position": "top",
                        "leftModules": [
                            {
                                "type": "launcher",
                                "props": {
                                    "useLaunchpad": true
                                }
                            },
                            "workspaces", "currentWindow"],
                        "rightModules": ["tray", "pomodoro", "volume", "spacer", "tailscale", "network", "bluetooth", "spacer", "battery", "spacer", "clock"]
                    }
                ]
            },
            "game": {
                "bars": [
                    {
                        "position": "bottom",
                        "width": 1000,
                        "leftModules": ["launcher", "workspaces", "windows"],
                        "rightModules": ["tray", "volume", "battery", "clock"]
                    }
                ]
            }
        })

    property var extraModules: ({
            "dock": "rootmodules/Dock.qml"
        })

    LazyLoader {
        active: root.loadApp
        Scope {
            // Preload modules by accessing basic properties
            Component.onCompleted: {
                AppMenu.showAppMenu = false;
                Launchpad.showLaunchpad = false;
                PowerMenu.showPowerMenu = false;
                IdleManager.running = true;
                SystemUpdater.updateChecking = true;
            }

            Variants {
                model: [...(root.modes[Globals.settings.mode]["extraModules"] ?? [])]
                delegate: Loader {
                    required property var modelData
                    source: Quickshell.shellPath(root.extraModules[modelData])
                }
            }

            Variants {
                model: root.modes[Globals.settings.mode]["bars"]
                delegate: Variants {
                    id: v1
                    required property var modelData
                    model: Quickshell.screens
                    delegate: Bar {
                        leftModules: v1.modelData["leftModules"]
                        rightModules: v1.modelData["rightModules"]
                        fillWidth: v1.modelData["width"] == undefined
                        implicitWidth: !!v1.modelData["width"] ? v1.modelData["width"] : implicitWidth
                        topOfScreen: v1.modelData["position"] == "top"
                    }
                }
            }

            PKAgent {}
            NotifyDaemon {}
        }
    }
}
