import QtQuick
import QtQuick.Shapes
import Quickshell.Services.UPower
import qs.common
import qs

// TODO: Make this open a more advanced menu when clicked that shows
//       battery remaining, full battery life, and some kind of control
//       over auto-cpufreq or power profiles.

NButton {
    id: root
    property var device: UPower.devices.values.filter(x => x.isLaptopBattery)[0]
    property bool timeMode: false
    onClicked: timeMode = !timeMode
    width: 20 + txt1.width + 10
    contentItem: Row {
        anchors.left: parent.left
        anchors.leftMargin: 3.75
        clip: true
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Shape {
            id: shape1
            width: 20
            height: 20
            layer.enabled: true
            layer.samples: 5
            anchors.verticalCenter: parent.verticalCenter

            // NOTE: main rect height: 14; top rect height: 2
            // main rect part: 14 / 16 or 87.5% of battery level
            // top rect part:  02 / 16 or 12.5% of battery level

            ShapePath {
                strokeColor: "transparent"
                fillColor: Globals.theme.dark ? Qt.lighter(root.bgcolor) : Qt.darker(root.bgcolor)
                startX: 5; startY: 18

                PathLine { x: 15; y: 18 }
                PathLine { x: 15; y: 4 }
                PathLine { x: 13; y: 4 }
                PathLine { x: 13; y: 2 }
                PathLine { x: 7; y: 2 }
                PathLine { x: 7; y: 4 }
                PathLine { x: 5; y: 4 }
            }
            ShapePath {
                strokeColor: "transparent"
                fillColor: Qt.darker(Globals.theme.accent1, 1.2)
                startX: 5; startY: 18

                PathLine { x: 15; y: 18 }
                PathLine { x: 15; y: 4 + Math.max(0.875 - root.device.percentage, 0) / 0.875 * 14 }
                PathLine { x: 5; y: 4 + Math.max(0.875 - root.device.percentage, 0) / 0.875 * 14 }
            }
            ShapePath {
                strokeColor: "transparent"
                fillColor: Qt.darker(Globals.theme.accent1, 1.2)
                startX: 7; startY: 4
                PathLine { x: 13; y: 4 }
                PathLine { x: 13; y: 2 + (1 - Math.max(root.device.percentage - 0.875, 0) / 0.125) * 2 }
                PathLine { x: 7; y: 2 + (1 - Math.max(root.device.percentage - 0.875, 0) / 0.125) * 2 }
            }
        }

        NText {
            id: txt1
            //visible: root.hovered
            anchors.bottom: parent.bottom
            text: (UPower.onBattery ? '-' : '+') + ' ' + (root.timeMode ? `(${UPower.onBattery
                ? Math.floor(device.timeToEmpty / 3600) : Math.floor(device.timeToFull / 3600)}`
                    + `:${String(Math.floor(UPower.onBattery ? device.timeToEmpty / 60 % 60
                    : device.timeToFull / 60 % 60)).padStart(2, 0)})`
                : `${Math.round(device.percentage * 100)}%`)
        }
    }
    Behavior on width {
        SmoothedAnimation {
            duration: 200
        }
    }
}
