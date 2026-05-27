import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.common

Repeater {
    model: SystemTray.items
    MouseArea {
    	required property var modelData

        implicitWidth: trayIcon.width + 5
        implicitHeight: trayIcon.height + 4
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
            color: parent.containsMouse ? Styles.grey5 : "transparent"
            radius: height / 2
        }
        Image {
            id: trayIcon
            mipmap: true
            anchors.centerIn: parent
            source: modelData.icon
            width: 24
            height: 24
        }
        QsMenuAnchor {
            id: trayMenu
            anchor.item: trayIcon
            anchor.margins.bottom: 30
            menu: modelData.menu
        }
    }
}
