import Quickshell
import Quickshell.Io
import QtQuick

import qs.common
import qs

PanelWindow {
    id: root
    implicitWidth: 600
    implicitHeight: 400

    visible: false

    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Globals.theme.bgcol
        radius: 12
    }

    property var themes: []

    Process {
        command: ["ls", Quickshell.shellPath("themes/")]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                console.warn("hi: ", this.text)
                root.themes = this.text.trim().split("\n")
                console.warn("themes: ", root.themes)
            }
        }
    }
    Rectangle {
        width: parent.width
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 5
        height: 50
        color: (Globals.theme.dark ? Qt.lighter : Qt.darker)(Globals.theme.bgcol, 1.2)
        border {
            width: 1
            color: (Globals.theme.dark ? Qt.lighter : Qt.darker)(color, 1.2)
        }
        radius: 10
        NText {
            text: "Themes"
            font.underline: true
            bold: true
            anchors.centerIn: parent
            fontSize: 20
            padding: 5
        }
        z: 5
    }

    ListView {
        model: root.themes
        spacing: 5
        anchors.margins: 5
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: parent.height - 70
        delegate: MouseArea {
            required property var modelData
            property bool active: Globals.settings.theme == Quickshell.shellPath("themes/") + modelData
            width: root.width - 10
            height: 30
            onClicked: Globals.settings.theme = Quickshell.shellPath("themes/") + modelData
            Rectangle {
                anchors.fill: parent
                color: active ? Globals.theme.active_item : Globals.theme.inactive_item
                radius: 10

                NText {
                    text: (active ? "[*] " : "") + "themes/" + modelData
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 5
                    width: parent.width
                    elide: Text.ElideLeft
                }
                Component.onCompleted: {
                    console.warn("ModelData:", modelData)
                }
            }
        }
    }
}
