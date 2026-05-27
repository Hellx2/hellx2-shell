import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import qs.modules
import qs.common

Scope {
    id: root

    property var screen: null
    PanelWindow {
        implicitHeight: 40
        exclusiveZone: 45
        screen: root.screen
        anchors { bottom: true; }
        margins { bottom: 10; }
        implicitWidth: 1000
        color: "transparent"

        Rectangle {
            color: Styles.bgcol
            height: 40
            width: parent.width
            radius: 5
        }
        RowLayout {
            height: 40
            anchors.bottom: parent.bottom
            spacing: 5

            Launcher {}
            Row {
                spacing: 5
                Workspaces { output: root.screen.name }
                Windows { screen: root.screen.name }
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
                    spacing: 6
                    id: mainrow

                    Tray {}

                    Volume {}
                    Battery {}
                    SystemClock { id: clock; precision: SystemClock.Minutes }
                    NButton { content: Qt.formatDateTime(clock.date, "hh:mm") }
                    NText { text: " " }
                }
            }
        }
    }
}
