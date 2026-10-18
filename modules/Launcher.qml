import QtQuick
import Quickshell.Io
import qs.common
import qs.rootmodules

NButton {
    id: root
    property bool useLaunchpad: false
    background.width: 30
    contentItem: NText {
        topPadding: -1.5
        leftPadding: 4.5
        fontSize: 17
        text: "᎒᎒᎒"
    }
    bgradius: 100
    onClicked: {
        if (root.useLaunchpad) Launchpad.showLaunchpad = !Launchpad.showLaunchpad
        else AppMenu.showAppMenu = !AppMenu.showAppMenu
    }
}
