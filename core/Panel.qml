import Quickshell
import QtQuick

import qs.rootmodules

Item {
    id: root
    required property string panelName
    Component.onCompleted: PanelManager.register(panelName, this)
    /*LazyLoader {
        active: PanelManager
    }*/
}
