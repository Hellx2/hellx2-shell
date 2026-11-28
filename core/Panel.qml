pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root
    property int bgradius: 10
    property bool ignoreExclusion: true
    required property string panelName

    visible: PanelManager.activePanel == root.panelName

    Component.onCompleted: PanelManager.register(panelName, this)
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.exclusionMode: root.ignoreExclusion ? ExclusionMode.Ignore : ExclusionMode.Normal
    WlrLayershell.layer: WlrLayer.Overlay

    implicitHeight: 400
    implicitWidth: 600

    property bool fillScreen: false

    property bool anchorLeft: false
    property bool anchorBottom: false
    property bool anchorRight: false
    property bool anchorTop: false

    property int marginLeft: 20
    property int marginRight: 20
    property int marginTop: 20
    property int marginBottom: 20

    anchors {
        top: fillScreen || anchorTop
        bottom: fillScreen || anchorBottom
        left: fillScreen || anchorLeft
        right: fillScreen || anchorRight
    }

    margins {
        left: fillScreen ? 0 : marginLeft
        right: fillScreen ? 0 : marginRight
        bottom: fillScreen ? 0 : marginBottom
        top: fillScreen ? 0 : marginTop
    }

    color: "transparent"

    Rectangle {
        color: Globals.theme.bgcol
        anchors.fill: parent
        radius: root.fillScreen ? 0 : root.bgradius

        border {
            width: 1
            color: Globals.theme.border
        }
    }
}
