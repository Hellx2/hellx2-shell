import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.UPower
import qs.common

// TODO: Make this open a more advanced menu when clicked that shows
//       battery remaining, full battery life, and some kind of control
//       over auto-cpufreq or power profiles.

NButton {
    id: root
    property var device: UPower.devices.values.filter(x => x.isLaptopBattery)[0]
    property bool timeMode: false
    onClicked: timeMode = !timeMode
    //width: 30 + (hovered ? txt1.width : 0)
    width: 30 + txt1.width + 5
    contentItem: Row {
        anchors.left: parent.left
        anchors.leftMargin: 3.75
        clip: true
        anchors.verticalCenter: parent.verticalCenter

        IconImage {
            source: Quickshell.iconPath("battery-level-" + Math.round(device.percentage * 10) * 10 + (UPower.onBattery ? "" : "-charging") + "-symbolic")
            implicitSize: 22.5
        }
        NText {
            id: txt1
            //visible: root.hovered
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 1.25
            text: root.timeMode ? `(${UPower.onBattery ? Math.floor(device.timeToEmpty / 3600) : Math.floor(device.timeToFull / 3600)}`
            + `:${String(Math.floor(UPower.onBattery ? device.timeToEmpty / 60 % 60 : device.timeToFull / 60 % 60)).padStart(2, 0)})`
            : `${Math.round(device.percentage * 100)}%`

        }
    }
    Behavior on width {
        SmoothedAnimation {
            duration: 200
        }
    }
}
