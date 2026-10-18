import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects

import qs.common
import qs.modules
import qs

PanelWindow {
    id: root
    WlrLayershell.layer: Launchpad.showLaunchpad ? WlrLayer.Overlay : WlrLayer.Top
    WlrLayershell.namespace: "dock"
    margins.bottom: 10
    margins.top: 10
    anchors.bottom: true
    color: "transparent"
    implicitWidth: (Globals.settings._pinnedApps.length + apps.values.length) * 62.5 + 10 + (spacer.visible ? 5 : 0)
    implicitHeight: 70
    visible: Globals.settings._pinnedApps.length + ToplevelManager.toplevels.values.length > 0
    screen: Globals.settings.getPrimaryScreen()

    ScriptModel {
        id: apps
        values: ToplevelManager.toplevels.values.filter(x => !Globals.settings._pinnedApps.includes(x.appId))
    }
    ScriptModel {
        id: pinnedApps
        values: ToplevelManager.toplevels.values.filter(x => Globals.settings._pinnedApps.includes(x.appId))
    }

    Rectangle {
        id: rect
        anchors.horizontalCenter: root.horizontalCenter
        color: Globals.settings.grey2
        radius: height / 2
        anchors.fill: parent
    }
    Row {
        id: winrow
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: rect.left
        anchors.leftMargin: 5

        Repeater {
            model: Globals.settings._pinnedApps
            MouseArea {
                id: ma2
                required property var modelData
                property int activeWin: windows.findIndex(x => x.activated)
                property var windows: pinnedApps.values.filter(x => x.appId == modelData)
                height: root.height
                width: 62.5
                y: containsMouse ? -(12.5 / 2) : 0
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: m => {
                    if (m.button & Qt.LeftButton)
                        if (windows.length > 0) windows[activeWin + 1 == windows.length ? 0 : activeWin + 1].activate()
                        else Quickshell.execDetached(DesktopEntries.byId(modelData).command)
                    else if (m.button & Qt.RightButton && windows.length > 0) windows[0].close();
                    else if (m.button & Qt.MiddleButton) Globals.settings._pinnedApps.splice(Globals.settings._pinnedApps.indexOf(modelData), 1)
                }
                Behavior on y { NumberAnimation { duration: 100 } }
                IconImage {
                    id: img
                    anchors.centerIn: parent
                    implicitSize: ma2.containsMouse ? 62.5 : 50
                    opacity: ma2.activeWin != -1 ? 1.0 : (ma2.containsMouse ? 0.9 : 0.6)
                    source: Quickshell.iconPath(DesktopEntries.byId(modelData)?.icon, true)
                    Behavior on implicitSize  { NumberAnimation { duration: 100 } }
                    Behavior on opacity { NumberAnimation { duration: 100 } }
                    Rectangle {
                        layer.enabled: true
                        layer.effect: DropShadow {
                            source: indicator
                            horizontalOffset: -2; verticalOffset: 2
                            radius: 8.0
                            color: "#90000000"
                        }
                        id: indicator
                        visible: ma2.windows.length > 0
                        color: '#12b0ff'
                        border { color: Qt.lighter(indicator.color, 1.1); width: 1 }
                        radius: height / 2
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        height: 16
                        width: children[0].text.length > 1 ? 24 : 16
                        NText {
                            fontSize: 12
                            font.family: "Noto Sans"
                            font.bold: true
                            anchors.centerIn: parent
                            text: ma2.windows.length > 9 ? "9+" : `${ma2.windows.length}`
                        }
                    }
                }
                Rectangle {
                    anchors.top: img.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: visible && ma2.activeWin != -1 ? Globals.settings.blue : (ma2.containsMouse ? "#ffffff" : "#888888")
                    width: (ma2.activeWin != -1 ? 20 : 7.5) * (ma2.containsMouse ? 1.5 : 1)
                    height: 4
                    radius: height / 2
                    visible: ma2.windows.length > 0
                    Behavior on width { NumberAnimation { duration: 100 } }
                }
            }
        }

        Shape {
            id: spacer
            width: 5
            visible: Globals.settings._pinnedApps.length > 0 && apps.values.length > 0
            height: root.height - 10
            anchors.verticalCenter: parent.verticalCenter
            data: ShapePath {
                fillColor: "transparent"
                strokeColor: Globals.settings.grey6
                strokeWidth: 1.0
                startX: spacer.width / 2 - 0.5; startY: spacer.height * 1 / 8
                PathLine { x: spacer.width / 2 - 0.5; y: spacer.height * 7 / 8 }
            }
        }

        Repeater {
            model: apps
            MouseArea {
                id: ma1
                required property var modelData
                height: root.height
                width: 62.5
                y: containsMouse ? -(12.5 / 2) : 0
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: m => {
                    if (m.button & Qt.LeftButton) modelData.activate()
                    else if (m.button & Qt.RightButton) modelData.close()
                    else Globals.settings._pinnedApps.push(modelData.appId)
                }
                Behavior on y { NumberAnimation { duration: 100 } }
                IconImage {
                    id: img
                    anchors.centerIn: parent
                    implicitSize: ma1.containsMouse ? 62.5 : 50
                    opacity: modelData.activated ? 1.0 : (ma1.containsMouse ? 0.9 : 0.6)
                    source: Quickshell.iconPath(DesktopEntries.byId(modelData.appId)?.icon, true)
                    Behavior on implicitSize { NumberAnimation { duration: 100 } }
                    Behavior on opacity { NumberAnimation { duration: 100 } }
                }
                Rectangle {
                    anchors.top: img.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: modelData.activated ? Globals.settings.blue : (ma1.containsMouse ? "#ffffff" : "#888888")
                    width: (modelData.activated ? 20 : 7.5) * (ma1.containsMouse ? 1.5 : 1)
                    height: 4
                    radius: height / 2
                    Behavior on width { NumberAnimation { duration: 100 } }
                }
            }
        }
    }
}
