import QtQuick
import Quickshell.WindowManager
import Quickshell
import qs

Rectangle {
	id: root
    color: Globals.settings.grey5
    width: ws.width + 10
    height: 20
    radius: height / 2
    property var output: null
    anchors.verticalCenter: parent.verticalCenter

	Row {
        id: ws
        height: parent.height
	    spacing: 3
	    anchors.left: parent.left
	    anchors.leftMargin: 8

	    Repeater {
	        model: ScriptModel {
	        	values: [...WindowManager.screenProjection(root.output).windowsets].sort((a, b) => a.coordinates[1] - b.coordinates[1])
	        }
	        MouseArea {
		        required property var modelData
		        onClicked: modelData.activate()
		        width: modelData.active ? 22 : 11
		        height: parent.height
		        Rectangle {
					width: parent.width
		            color: modelData.active ? Globals.settings.accent1 : 
		            	(modelData.coordinates[1] < WindowManager.screenProjection(root.output).windowsets.length - 1 ? Globals.settings.white : Globals.settings.grey3)
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
