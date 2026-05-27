import QtQuick
import QtQuick.Controls

Slider {
    id: root
    from: 1
    to: 100
    snapMode: Slider.SnapOnRelease
    stepSize: 1.0
    handle: Item {
        Rectangle {
            implicitWidth: 15
            implicitHeight: 15
            x: root.visualPosition * root.width - width / 2
            y: -5
            radius: 1000
            MouseArea {
                id: handleMouse
                anchors.fill: parent
                hoverEnabled: true
            }
        }
        Rectangle {
            width: 20
            height: 20
            x: root.visualPosition * root.width - width / 2
            y: -30
            visible: handleMouse.containsMouse
        }
    }
    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 6
        color: "#0c0c0c"
        radius: 5

        Rectangle {
            width: root.visualPosition * parent.width
            height: parent.height
            color: "#3399ff"
            radius: 2
        }
    }
}

