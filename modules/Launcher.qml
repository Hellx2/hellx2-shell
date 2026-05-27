import QtQuick
import Quickshell.Io
import qs.common

Row {
	Process {
        id: appMenuProc
        command: ["/home/red/.config/niri/scripts/menu.fish"]
        running: false
    }
	NButton {
        background.width: 30
        contentItem: NText {
            topPadding: -1.5
            leftPadding: 4.5
            fontSize: 17
            text: "᎒᎒᎒"
        }
        bgradius: 100
        onClicked: appMenuProc.running = true
    }
}
