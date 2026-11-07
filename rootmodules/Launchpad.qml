pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Shapes
import qs.core
import qs

Singleton {
    id: root
    property bool showLaunchpad: false
    property var model: [...DesktopEntries.applications.values].sort((a, b) => {
        let A = a.name.toUpperCase();
        let B = b.name.toUpperCase();
        if (A < B)
            return -1;
        else if (A > B)
            return 1;
        return 0;
    })

    property var x: 20
    property var y: 20
    function run(command) {
        Quickshell.execDetached(command);
        showLaunchpad = false;
    }
    PanelWindow {
        id: mainwin
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        WlrLayershell.namespace: "launchpad"
        visible: root.showLaunchpad
        onVisibleChanged: {
            mainInput.text = "";
            gv.currentIndex = 0;
            mainInput.focus = true;
        }

        anchors {
            left: true
            bottom: true
            right: true
            top: true
        }

        color: "transparent"
        Rectangle {
            id: bg
            color: Globals.theme.dark ? "#dd000000" : "#99cccccc"
            anchors.fill: parent
        }

        Column {
            width: parent.width - root.x * 2
            height: parent.height - root.y * 2 - 70
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: root.y
            spacing: 20

            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: mainwin.width
                    height: mainwin.height
                    radius: 10
                }
            }
            Rectangle {
                id: topRow
                height: 50
                width: parent.width / 4
                radius: height / 2
                color: Globals.theme.input_bg
                border {
                    width: 1
                    color: Globals.theme.dark ? Qt.lighter(color) : Qt.darker(color)
                }
                anchors.horizontalCenter: parent.horizontalCenter
                Row {
                    anchors.leftMargin: 5
                    anchors.rightMargin: 5
                    spacing: 5
                    anchors.fill: parent
                    IconImage {
                        source: Quickshell.iconPath("edit-find", true)
                        implicitSize: 24
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    NInput {
                        id: mainInput
                        focus: true
                        font.bold: false
                        width: parent.width - 30
                        fontSize: 18
                        height: parent.height
                        Keys.onDownPressed: gv.moveCurrentIndexDown()
                        Keys.onUpPressed: gv.moveCurrentIndexUp()
                        Keys.onLeftPressed: gv.moveCurrentIndexLeft()
                        Keys.onRightPressed: gv.moveCurrentIndexRight()
                        Keys.onEscapePressed: root.showLaunchpad = false
                        font.family: "Red Hat Display"
                        bgcolor: "transparent"

                        onAccepted: root.run(gv.model.values[gv.currentIndex].command)
                    }
                }
            }

            GridView {
                id: gv
                ScrollBar.vertical: ScrollBar {}
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: gv.width
                        height: gv.height
                        radius: 20
                    }
                }
                cellWidth: width / 12
                cellHeight: cellWidth
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - 10
                height: parent.height - 75

                model: ScriptModel {
                    values: root.model.filter(x => x.id.toLowerCase().includes(mainInput.text.toLowerCase()) || x.name.toLowerCase().includes(mainInput.text.toLowerCase()))
                    onValuesChanged: gv.currentIndex = 0
                }
                keyNavigationEnabled: true
                delegate: Column {
                    id: col
                    required property var modelData
                    required property var index
                    width: GridView.view.cellWidth
                    height: GridView.view.cellHeight
                    NButton {
                        bgradius: 0
                        anchors.horizontalCenter: parent.horizontalCenter
                        background: Rectangle {
                            border {
                                color: (Globals.theme.dark ? Qt.lighter : Qt.darker)(color)
                                width: 1
                            }
                            radius: 20
                            color: col.GridView.isCurrentItem ? (Globals.theme.dark ? Qt.lighter : Qt.darker)(Globals.theme.active_item, parent.hovered ? 1.8 : 1.5) : (parent.hovered ? Globals.theme.button_bg_hover : Globals.theme.button_bg)
                            opacity: 0.7
                        }
                        onClicked: root.run(modelData.command)
                        contentItem: IconImage {
                            id: icon
                            source: Quickshell.iconPath(modelData.icon, true)
                            implicitSize: col.width * 3 / 4
                        }
                    }
                    NText {
                        text: modelData.name
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 100
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        fontSize: 16
                    }
                }
            }
        }
    }
}
