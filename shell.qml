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
        IPC.initialize = true;
        IPC.root = root;
        //Globals.mainSettings = JSON.parse(Globals.settingsInst.mainSettings)
        let a = DesktopEntries.applications;
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

    ShellSettings { id: defaultSettings }
    SettingsUI { id: settingsui }
    LayoutSwitcher { id: layoutSwitcher }
    Background { id: bg }
    OSD { id: osd1 }

    property var settings_ui: settingsui
    property var layout_switcher: layoutSwitcher
    property var background: bg
    property var osd: osd1


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

            FileView {
                path: Qt.resolvedUrl(Globals.settings.theme)
                blockLoading: true
                watchChanges: true
                onLoaded: {
                    let a = JSON.parse(this.text());
                    for (let i of Object.entries(a)) {
                        if (Globals.theme.hasOwnProperty(i[0])) Globals.theme[i[0]] = i[1]
                    }
                }
                onFileChanged: {
                    let a = JSON.parse(this.text());
                    for (let i of Object.entries(a)) {
                        if (Globals.theme.hasOwnProperty(i[0])) Globals.theme[i[0]] = i[1]
                    }
                }
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
            PKAgent {}
            NotifyDaemon {}
        }
    }
}
