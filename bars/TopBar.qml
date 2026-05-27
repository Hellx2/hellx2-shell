import QtQuick
import qs.modules

Bar {
	id: root
	topOfScreen: true

    Row {
    	anchors.leftMargin: 10
    	anchors.left: parent.left
    	anchors.verticalCenter: parent.verticalCenter
    	height: 20
    	spacing: 10
        Rectangle {
        	color: Styles.grey5
        	width: ws.width
        	height: 20
        	radius: height / 2

        	Workspaces { id: ws; anchors.left: parent.left; output: root.screen.name }
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
