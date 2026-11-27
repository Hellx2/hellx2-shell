pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.rootmodules
import qs.core

Scope {
    id: root
    required property string panelName
    default property alias data: winInner.data
    property int height: 400
    property int width: 600
    property bool alwaysActive: false

    property bool anchorLeft: false
    property bool anchorBottom: false
    property bool anchorRight: false
    property bool anchorTop: false

    property int marginLeft: 20
    property int marginRight: 20
    property int marginTop: 20
    property int marginBottom: 20

    Component.onCompleted: PanelManager.register(panelName, this)
    PanelWindow {
        visible: PanelManager.activePanel == root.panelName
        id: winInner
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        WlrLayershell.layer: WlrLayer.Overlay
        //Keys.onEscapePressed: PanelManager.clearActivePanel()
        implicitHeight: root.height
        implicitWidth: root.width

        anchors {
            top: root.anchorTop
            bottom: root.anchorBottom
            left: root.anchorLeft
            right: root.anchorRight
        }

        margins {
            left: root.marginLeft
            right: root.marginRight
            bottom: root.marginBottom
            top: root.marginTop
        }

        color: "transparent"

        Rectangle {
            color: Globals.theme.bgcol
            anchors.fill: parent
            radius: 10

            border {
                width: 1
                color: Globals.theme.border
            }
        }
    }
}
