import QtQuick
import qs.modules
import qs.common

Bar {
    id: root
    topOfScreen: true

    Row {
        anchors.leftMargin: 10
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        height: 20
        spacing: 10

        Launcher {
            anchors.verticalCenter: parent.verticalCenter
            useLaunchpad: true
        }
        Workspaces {
            id: ws
            output: root.screen
        }
        CurrentWindow {}
    }
    Row {
        anchors.top: parent.top
        height: 40
        anchors.right: parent.right
        width: mainrect.width
        Rectangle {
            id: mainrect
            anchors.verticalCenter: parent.verticalCenter
            height: children[0].height
            width: children[0].width + 5
            color: "transparent"

            Row {
                id: mainrow
                spacing: 6

                //ModeSwitcher {}
                //Spacer {}

                Tray {}
                PomodoroButton {
                    onTopBar: true
                }
                Volume {}

                Spacer {}

                Tailscale {}
                BluetoothButton {
                    x1: mainrect.width - mainrect.mapFromItem(this, this.x, 0).x
                }
                Network {
                    x1: mainrow.width
                }

                Spacer {}

                Battery {}

                Spacer {}
                Clock {}
            }
        }
    }
}
