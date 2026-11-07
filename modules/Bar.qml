pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import QtQuick
import Qt5Compat.GraphicalEffects

import qs.core
import qs
import qs.rootmodules
import qs.modules

PanelWindow {
    id: root
    property int leftHeight
    property int rightHeight
    property int leftSpacing
    property int rightSpacing

    property var components: ({
            "battery": "modules/Battery.qml",
            "bluetooth": "modules/BluetoothButton.qml",
            "clock": "modules/Clock.qml",
            "currentWindow": "modules/CurrentWindow.qml",
            "launcher": "modules/Launcher.qml",
            "network": "modules/Network.qml",
            "player": "modules/PlayerWidget.qml",
            "pomodoro": "modules/PomodoroButton.qml",
            "spacer": "modules/Spacer.qml",
            "tailscale": "modules/Tailscale.qml",
            "tray": "modules/Tray.qml",
            "updateChecker": "modules/UpdateChecker.qml",
            "volume": "modules/Volume.qml",
            "windows": "modules/Windows.qml",
            "workspaces": "modules/Workspaces.qml"
        })

    property var leftModules: ["clock"]
    property var rightModules: ["clock"]

    WlrLayershell.namespace: "bar"
    WlrLayershell.layer: AppMenu.showAppMenu ? WlrLayer.Overlay : WlrLayer.Top

    required property var modelData
    screen: modelData

    property var bgcolor: Globals.theme.bgcol
    property bool fillWidth: true
    property bool topOfScreen: false

    property int padHorizontal: 20
    property int padVertical: 10

    property int radius: 15

    implicitHeight: 40
    color: "transparent"

    anchors {
        left: root.fillWidth
        right: root.fillWidth
        top: root.topOfScreen
        bottom: !root.topOfScreen
    }

    margins {
        bottom: root.topOfScreen ? 0 : root.padVertical
        top: root.topOfScreen ? root.padVertical : 0
        left: root.fillWidth ? root.padHorizontal : 0
        right: root.fillWidth ? root.padHorizontal : 0
    }

    Rectangle {
        id: bgrect
        opacity: 0.9
        anchors.fill: parent
        color: root.bgcolor
        radius: root.radius
    }

    Row {
        id: left
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        spacing: !!root.leftSpacing ? root.leftSpacing : 5
        height: root.leftHeight ?? implicitHeight

        Repeater {
            model: root.leftModules
            Loader {
                required property var modelData
                source: {
                    if (typeof modelData == "string") {
                        return Quickshell.shellPath(root.components[modelData]);
                    } else {
                        return Quickshell.shellPath(root.components[modelData["type"]]);
                    }
                }
                Component.onCompleted: {
                    if (typeof modelData != "string") {
                        for (let i of Object.entries(modelData.props))
                            item[i[0]] = i[1];
                    }
                    this.anchors.verticalCenter = parent.verticalCenter;
                }
            }
        }
    }
    Row {
        id: right
        anchors.verticalCenter: parent.verticalCenter
        spacing: !!root.rightSpacing ? root.rightSpacing : 5
        height: root.rightHeight ?? implicitHeight
        anchors.right: parent.right
        anchors.rightMargin: 10

        Repeater {
            model: root.rightModules
            Loader {
                required property var modelData
                source: {
                    if (typeof modelData == "string") {
                        return Quickshell.shellPath(root.components[modelData]);
                    } else {
                        return Quickshell.shellPath(root.components[modelData["type"]]);
                    }
                }
                Component.onCompleted: {
                    if (typeof modelData != "string") {
                        for (let i of Object.entries(modelData.props))
                            item[i[0]] = i[1];
                    }
                    this.anchors.verticalCenter = parent.verticalCenter;
                }
            }
        }
    }
}
