//@ pragma NativeTextRendering
//@ pragma UseQApplication
//@ pragma Env QS_DROP_EXPENSIVE_FONTS = 1
//@ pragma Env QS_NO_RELOAD_POPUP = 1

import QtCore
import QtQuick
import Quickshell
import Quickshell.Io

import qs.bars

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
        interval: 100
        running: true
        repeat: false
        onTriggered: root.loadApp = true
    }

    // "home" | "school" | "game"
    property string mode: "school"
    Settings {
        property alias mode: root.mode
    }

    IpcHandler {
        target: "shell"
        function setMode(mode: string) {
            if (["home", "school", "game"].includes(mode))
                root.mode = mode;
            else
                console.error(`Unknown mode '${mode}', ignoring.`);
        }
        function getMode(): string {
            return root.mode;
        }
    }
    LazyLoader {
        active: root.loadApp
        Scope {
            Loader {
                active: root.mode == "school"
                sourceComponent: Variants {
                    model: Quickshell.screens
                    delegate: BottomBar {
                        required property var modelData
                        screen: modelData
                    }
                }
            }
            Loader {
                active: root.mode == "home"
                sourceComponent: Scope {
                    Dock {}
                    Variants {
                        model: Quickshell.screens
                        delegate: TopBar {
                            required property var modelData
                            screen: modelData
                        }
                    }
                }
            }
            Loader {
                active: root.mode == "game"
                sourceComponent: Variants {
                    model: Quickshell.screens
                    delegate: GameBar {
                        required property var modelData
                        screen: modelData
                    }
                }
            }
            OSD {}
            PKAgent {}
            NotifyDaemon {}
            Variants {
                model: Quickshell.screens
                delegate: Wallpaper {
                    required property var modelData
                    screen: modelData
                }
            }
        }
    }
}
