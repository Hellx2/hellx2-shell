pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import Quickshell

import qs

MouseArea {
    id: root
    width: _size
    height: _size
    hoverEnabled: true
    layer.enabled: true
    layer.samples: 5
    property var lines: [[0, 0, 20, 20], [0, 20, 20, 0]]
    property var circles: [] //[[0, 0, 5, 5]]
    property color hoverColor: Globals.theme.accent
    property double _size: 20
    property double strokeWidth: 3
    property color color: root.containsMouse ? root.hoverColor : Globals.theme.text_fg
    property bool showBackground: false
    property color bgcolor: Globals.theme.button_bg

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.bgcolor
        visible: root.showBackground
    }

    Shape {
        width: root._size
        height: root._size
        Variants {
            id: vars
            model: root.lines
            delegate: ShapePath {
                required property var modelData
                fillColor: "transparent"
                strokeColor: root.color
                startX: modelData[0]
                startY: modelData[1]
                strokeWidth: root.strokeWidth
                PathLine {
                    x: modelData[2]
                    y: modelData[3]
                }
            }
        }
        Variants {
            id: vars_circles
            model: root.circles
            delegate: ShapePath {
                id: circle
                required property var modelData
                fillColor: "transparent"
                strokeColor: root.color
                strokeWidth: root.strokeWidth
                PathAngleArc {
                    centerX: circle.modelData[0]
                    centerY: circle.modelData[1]
                    radiusX: circle.modelData[2]
                    radiusY: circle.modelData[3]
                    startAngle: 0
                    sweepAngle: 360
                }
            }
        }
        data: [...vars.instances, ...vars_circles.instances]
    }
}
