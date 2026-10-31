import QtQuick
import Quickshell
import Quickshell.Wayland

import qs

Row {
    property var currwin: ToplevelManager.activeToplevel
    height: 20
    spacing: 5
    Image {
    	mipmap: true
        source: Quickshell.iconPath(DesktopEntries.byId(currwin?.appId)?.icon, true)
        width: 20
        height: 20
    }
    Text {
        rightPadding: 2.5
        leftPadding: 2.5
        text: currwin?.title || "Unknown"
        color: Globals.theme.text_fg
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
        width: 200
        elide: Text.ElideRight
    }
    visible: currwin != null
}
