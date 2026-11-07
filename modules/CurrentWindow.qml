import QtQuick
import Quickshell
import Quickshell.Wayland

import qs

Rectangle {
    height: 27.5
    width: children[0].width + 10
    radius: 10
    anchors.verticalCenter: parent.verticalCenter
    color: Globals.theme.active_item

    Row {
        id: row1
        property var currwin: ToplevelManager.activeToplevel
        anchors.centerIn: parent
        height: 20
        spacing: 5
        anchors.verticalCenter: parent.verticalCenter
        Image {
            mipmap: true
            source: Quickshell.iconPath(DesktopEntries.byId(row1.currwin?.appId)?.icon, true)
            width: 20
            height: 20
        }
        Text {
            rightPadding: 2.5
            leftPadding: 2.5
            text: row1.currwin?.title || "Unknown"
            color: Globals.theme.text_fg
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
            width: 200
            elide: Text.ElideRight
        }
        visible: currwin != null
    }
}
