import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.common
import qs

Row {
	id: root
	property bool showTray: false
	spacing: 5
	layoutDirection: Qt.RightToLeft
	visible: SystemTray.items.values.length > 0
	width: root.showTray ? SystemTray.items.values.length * 32.5 - 2.5 + 35 : 30

	NButton {
		id: btn1
		onClicked: root.showTray = !root.showTray
		contentItem: NText {
			text: root.showTray ? "<" : ">"
			fontSize: 16
			anchors.left: parent.left
			anchors.leftMargin: 10
		}
		height: 30
		width: 30
	}

	Loader {
		active: root.showTray
		sourceComponent: Rectangle {
			id: mainrect
			height: 28
			width: SystemTray.items.values.length * (30 + 2.5) - 2.5
			color: Globals.settings.grey3
			radius: height / 2
			
			Row {
				spacing: 2.5
				anchors.fill: parent
				Repeater {
					id: mainRepeater
				    model: SystemTray.items
				    MouseArea {
				    	required property var modelData

				        implicitWidth: 30
				        implicitHeight: 30
				        acceptedButtons: Qt.LeftButton | Qt.RightButton
				        hoverEnabled: true
				        onClicked: m => {
				            if (m.button == Qt.RightButton || modelData.onlyMenu) {
				                trayMenu.open();
				            } else {
				                modelData.activate();
				            }
				        }
				        Rectangle {
				            anchors.fill: parent
				            color: parent.containsMouse ? Globals.settings.grey5 : "transparent"
				            radius: height / 2
				        }
				        Image {
				            id: trayIcon
				            mipmap: true
				            anchors.centerIn: parent
				            source: console.warn(modelData.icon), modelData.icon
				            width: 25
				            height: 25
				        }
				        QsMenuAnchor {
				            id: trayMenu
				            anchor.item: trayIcon
				            anchor.margins.bottom: 30
				            menu: modelData.menu
				        }
				    }
				}
			}
		}
	}
}
