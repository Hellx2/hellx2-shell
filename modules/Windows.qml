import QtQuick
import Quickshell

import qs.common

Repeater {
	id: root
	property string screen: "eDP-1"

    model: NiriService.windows.filter(w => NiriService.workspaces[w.workspace_id].is_active
    && NiriService.workspaces[w.workspace_id].output == root.screen).map(x => [x.app_id, x.title, x.is_focused, x.id])

    NButton {
        required property var modelData
        bgcolor: modelData[2] ? Styles.grey6 : Styles.grey4

        contentItem: Row {
            Image {
                source: Quickshell.iconPath(DesktopEntries.byId(modelData[0])?.icon, true)
                width: 20
                height: 20
                mipmap: true
            }
            NText {
                rightPadding: 2.5
                leftPadding: 2.5
                text: modelData[1]
                visible: modelData[2]
                width: Math.min(implicitWidth, 200)
                elide: Text.ElideRight
            }
        }
        onClicked: NiriService.focusWindow(modelData[3])
    }
}
