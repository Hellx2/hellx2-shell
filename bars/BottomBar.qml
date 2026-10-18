import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.modules
import qs.common

Bar {
    id: root

    Row {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        spacing: 10

        Launcher {}

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
        anchors.rightMargin: 10
        width: mainrect.children[0].width
        Rectangle {
            id: mainrect
            height: children[0].height
            width: children[0].width + 5
            color: "transparent"

            Row {
                id: mainrow
                spacing: 6

                PlayerWidget {}

                Spacer { visible: !!Mpris.players.values[0] }

				UpdateChecker {}
                Tray {}
                PomodoroButton {}
                Volume {}

                //Spacer {}
                //ModeSwitcher {}
                Spacer {}
                Tailscale {}
                BluetoothButton {
                    x1: () => QsWindow.itemPosition(this).x
                }
                Network {
                    x1: () => QsWindow.itemPosition(this).x
                }

				Spacer {}
                Battery {}
                Spacer {}
                Clock {}
            }
        }
    }
}
