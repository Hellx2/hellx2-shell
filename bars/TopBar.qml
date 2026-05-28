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
        
        Workspaces { id: ws; output: root.screen.name }
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
                spacing: 6
                id: mainrow

                Tray {}
                Pomodoro { onTopBar: true }
                Volume {}
                Battery {}
                Clock {}
            }
        }
    }
}
