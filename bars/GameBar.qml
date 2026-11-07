import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import qs.modules
import qs

Bar {
    id: root
    implicitHeight: 40
    exclusiveZone: 45
    fillWidth: false
    implicitWidth: 1000
    color: "transparent"

    Rectangle {
        color: Globals.theme.bgcol
        height: parent.height
        width: parent.width
        radius: height / 2
    }
    Row {
        height: parent.height
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: 10
        spacing: 10

        Launcher {
            anchors.verticalCenter: parent.verticalCenter
        }
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 5
            Workspaces {
                output: root.screen
            }
            Windows {
                screen: root.screen.name
            }
        }
    }
    Row {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        width: mainrect.children[0].width
        Rectangle {
            id: mainrect
            height: children[0].height
            width: children[0].width + 5
            color: "transparent"

            property string timeRemaining: ""
            property string chargeText: ""
            property string statusIndicator: ""

            Row {
                id: mainrow
                spacing: 6

                Tray {}
                //ModeSwitcher {}
                Volume {}
                Battery {}
                Clock {}
            }
        }
    }
}
