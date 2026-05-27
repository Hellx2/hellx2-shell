import QtQuick
import qs
import qs.common

Row {
	id: root
    property var output: null

    anchors.verticalCenter: parent.verticalCenter

    spacing: 3
    Text {
        text: " "
    }
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
