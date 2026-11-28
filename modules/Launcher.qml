import QtQuick
import Quickshell.Io
import qs.core
import qs.rootmodules

NButton {
    width: 30
    height: 30
    background.width: 30
    contentItem: NText {
        topPadding: -1.5
        leftPadding: 4.5
        fontSize: 17
        text: "᎒᎒᎒"
    }
    bgradius: 100
    onClicked: PanelManager.toggleActivePanel((Globals.settings.layouts[Globals.settings.mode].useLaunchpad ?? false) ? "launchpad" : "appMenu")
}
