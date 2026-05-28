import QtQuick
import qs.modules

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
            Workspaces { output: root.screen.name }
            Windows { screen: root.screen.name }
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
                spacing: 6
                id: mainrow

                Tray {}
                Pomodoro {}
                Volume {}
                Battery {}
                Clock {}
            }
        }
    }
}
