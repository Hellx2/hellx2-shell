import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
import qs
import qs.common

PanelWindow {
    id: root
    implicitWidth: 650
    implicitHeight: 425
    color: "transparent"
    visible: false

    Rectangle {
        radius: 20
        color: Globals.theme.bgcol
        anchors.fill: parent
        border {
            color: Qt.lighter(color, 2.0)
            width: 1
        }

    }

    component Mode : Rectangle {
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
                if (!!mode.layout) Globals.theme.mode = mode.layout
                root.visible = false
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
        text: "Layouts"
        fontSize: 24
        anchors.top: parent.top
        anchors.topMargin: (root.height - (108 * 3 + 10 * 3 + 18.5) - height) / 2
        bold: true
        font.underline: true
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Grid {
        anchors.bottom: parent.bottom
        columns: 3
        rows: 3
        padding: 18.5
        columnSpacing: 18.5
        rowSpacing: 10
        Mode {
            text: "School"
            layout: "school"
            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    leftMargin: 5
                    rightMargin: 5
                    bottomMargin: 5
                }
                height: 10
                radius: 5
                color: Qt.lighter(parent.color, 2)
                border {
                    color: Qt.lighter(color, 1.1)
                    width: 0.5
                }
            }
        }
        Mode {
            text: "Home"
            layout: "home"
            Rectangle {
                anchors {
                    bottom: parent.bottom
                    bottomMargin: 5
                    horizontalCenter: parent.horizontalCenter
                }
                width: parent.width / 2
                height: 15
                radius: 10
                color: Qt.lighter(parent.color, 2)
                border {
                    color: Qt.lighter(color, 1.1)
                    width: 0.5
                }
            }
            Rectangle {
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    leftMargin: 5
                    rightMargin: 5
                    topMargin: 5
                }
                height: 10
                radius: 5
                color: Qt.lighter(parent.color, 2)
                border {
                    color: Qt.lighter(color, 1.1)
                    width: 0.5
                }
            }

        }
        Mode {
            text: "Game"
            layout: "game"
            Rectangle {
                anchors {
                    bottom: parent.bottom
                    bottomMargin: 5
                    horizontalCenter: parent.horizontalCenter
                }
                width: parent.width / 2
                height: 10
                radius: 10
                color: Qt.lighter(parent.color, 2)
                border {
                    color: Qt.lighter(color, 1.1)
                    width: 0.5
                }
            }
        }
        Mode {}
        Mode {}
        Mode {}
        Mode {}
        Mode {}
        Mode {}
    }
}
