import QtQuick
import QtQuick.Shapes

import qs

Shape {
    id: root
    property color strokeColor: Globals.theme.spacer
    width: 5
    height: 30
    data: ShapePath {
        fillColor: "transparent"
        strokeColor: root.strokeColor
        strokeWidth: 1.0
        startX: root.width / 2
        startY: root.height * 1 / 8
        PathLine {
            x: root.width / 2
            y: root.height * 7 / 8
        }
    }
}
