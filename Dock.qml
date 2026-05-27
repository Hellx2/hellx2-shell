import Quickshell
import QtQuick

import qs.common

PanelWindow {
    id: root
    margins.bottom: 10
    margins.top: 10
    anchors.bottom: true
    color: "transparent"
    implicitWidth: Math.max(NiriService.windows.length * 60, 60)
    implicitHeight: 70
    visible: NiriService.windows.length > 0

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 200
        }
    }

    Rectangle {
        anchors.left: root.left
        id: rect
        color: Styles.bgcol
        radius: height / 2
        width: parent.width
        height: parent.height

        Row {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: rect.left
            anchors.leftMargin: 5

            Repeater {
                model: NiriService.windows
                delegate: MouseArea {
                    required property var modelData
                    width: 60
                    height: root.height
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        Image {
                            id: img
                            opacity: modelData.is_focused ? 1.0 : 0.6
                            source: Quickshell.iconPath(DesktopEntries.byId(modelData.app_id)?.icon, true)
                            width: 50
                            height: 50
                        }
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            color: modelData.is_focused ? Styles.blue : Styles.white
                            width: modelData.is_focused ? 20 : 7.5
                            height: 4
                            radius: height / 2
                            //visible: modelData.is_focused || modelData.is_urgent
                        }
                    }
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                    onClicked: m => {
                    	if (m.button == Qt.LeftButton)
                    		NiriService.focusWindow(modelData.id)
                    	else
                    		NiriService.closeWindow(modelData.id)
                    }
                }
            }
        }
    }
}
