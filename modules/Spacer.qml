import QtQuick
import QtQuick.Shapes

import qs

Shape {
    id: root
    width: 5
    height: 30
    data: ShapePath {
        fillColor: "transparent"
        strokeColor: Globals.settings.grey4
        strokeWidth: 1.0
        startX: root.width / 2
        startY: root.height * 1 / 8
        PathLine {
            x: root.width / 2
            y: root.height * 7 / 8
        }
    }
}
