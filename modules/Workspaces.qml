import QtQuick
import qs.common


Rectangle {
	id: root
   	color: Styles.grey5
   	width: ws.width + 10
   	height: 20
   	radius: height / 2
	property var output: null
    anchors.verticalCenter: parent.verticalCenter

	Row {
		id: ws
	    spacing: 3
	    anchors.left: parent.left
	    anchors.leftMargin: 8

	    Repeater {
	        model: NiriService.allWorkspaces.filter(x => !root.output || x.output == root.output)
	        MouseArea {
		        required property var modelData
		        onClicked: NiriService.switchToWorkspace(modelData.idx)
		        width: modelData.is_active ? 22 : 11
		        height: parent.height
		        Rectangle {
					width: parent.width
		            color: modelData.is_active ? Styles.blue : 
		            	(modelData.idx < NiriService.allWorkspaces.filter(
		            		x => !root.output || x.output == root.output).length ? Styles.white : Styles.grey3)
		            radius: height / 2
		        	y: parent.height / 2 - height / 2
		            height: 11
		        }
	        }
	    }
	    Text {
	        text: " "
	    }
	}
}
