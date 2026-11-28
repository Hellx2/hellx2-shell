import QtQuick
import Quickshell
import Quickshell.Io
import qs.core

Panel {
    id: root
    panelName: "layoutSwitcher"
    implicitWidth: 650
    implicitHeight: 425

    component Mode: Rectangle {
        id: mode
        property string text
        property string layout
        radius: 10
        width: 192
        height: 108
        color: Qt.lighter(Globals.theme.bgcol, 1.5)
        border {
            color: Qt.lighter(color)
            width: 1
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (!!mode.layout)
                    Globals.settings.mode = mode.layout;
                PanelManager.clearActivePanel();
            }
        }
        NText {
            anchors.centerIn: parent
            text: mode.text ?? ""
            fontSize: 20
            font.italic: true
            color: Qt.lighter(parent.color, 3)
        }
    }

    NText {
        id: txt1
        text: "Layouts"
        fontSize: 24
        anchors.top: parent.top
        anchors.topMargin: (root.height - (108 * 3 + 10 * 3 + 18.5) - height) / 2
        bold: true
        font.underline: true
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Grid {
        anchors.top: txt1.bottom
        columns: 3
        rows: 3
        padding: 18.5
        columnSpacing: 18.5
        rowSpacing: 10
        Repeater {
            model: Object.entries(Globals.settings.layouts)
            Mode {
                id: modeObj
                required property var modelData
                text: {
                    let x = modelData[0].replace(/([A-Z])/, " $1").trim();
                    return `${x[0].toUpperCase()}${x.slice(1)}`
                }
                layout: modelData[0]
                Repeater {
                    model: modeObj.modelData[1].bars
                    Rectangle {
                        required property var modelData
                        radius: console.warn(modelData), 5
                        height: 10
                        color: (Globals.theme.dark ? Qt.lighter : Qt.darker)(modeObj.color, 2)
                        border {
                            width: 0.5
                            color: Qt.lighter(color, 1.1)
                        }
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: modelData.position == "bottom" ? parent.bottom : undefined
                            top: modelData.position == "top" ? parent.top : undefined
                            bottomMargin: 5
                            topMargin: 5
                            rightMargin: !!modelData.width ? (1920 - modelData.width) / 1920 * modeObj.width / 2 : 5
                            leftMargin: !!modelData.width ? (1920 - modelData.width) / 1920 * modeObj.width / 2 : 5
                        }
                    }
                }
                Rectangle {
                    color: (Globals.theme.dark ? Qt.lighter : Qt.darker)(modeObj.color, 2)
                    visible: modeObj.modelData[1]?.extraModules?.includes("dock") ?? false
                    width: modeObj.width / 3
                    height: 15
                    radius: height / 2
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottomMargin: 5
                    border {
                        width: 0.5
                        color: Qt.lighter(color, 1.1)
                    }
                }
            }
        }
    }
}
