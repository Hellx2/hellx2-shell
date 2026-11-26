pragma ComponentBehavior: Bound

import Quickshell

Scope {
    id: root
    property int callerX
    property bool isOnTop
    property int menuHeight: 600
    property int menuWidth: 400
    property bool alwaysLoaded: false

    LazyLoader {
        active: root.alwaysLoaded || MenuManager.isLoaded
        PanelWindow {
            height: root.menuHeight
            width: root.menuWidth
            anchors {
                left: true
                bottom: true
            }
        }
    }
}
