import QtQuick
import QtQuick.Shapes
import qs

MouseArea {
    id: root
    hoverEnabled: true
    acceptedButtons: Qt.MiddleButton | Qt.LeftButton | Qt.RightButton
    onClicked: e => {
        let lastMode = Globals.settings.mode
        if (e.button & Qt.MiddleButton) Globals.settings.mode = (Globals.settings.mode == "game" ? Globals.settings.lastMode : "game")
        else if (e.button & Qt.LeftButton) Globals.settings.mode = (Globals.settings.mode == "home" ? "school" : "home")
        else Globals.settings.mode = (Globals.settings.mode == "school" ? "home" : "school")
        Globals.settings.lastMode = lastMode
    }
    width: 30
    height: 30

    Rectangle {
        radius: height / 2
        color: root.containsMouse ? Globals.settings.button_bg_hover : Globals.settings.button_bg
        anchors.fill: parent

        ShapePath {
            id: homePath
        	joinStyle: ShapePath.MiterJoin
            fillColor: "#ffffff"
            strokeColor: "#ffffff"
            startX: s1.width * 1 / 6; startY: s1.height * 1 / 2
            PathLine { x: s1.width * 1 / 2; y: s1.height * 1 / 6 }
            PathLine { x: s1.width * 5 / 6; y: s1.height * 1 / 2 }
            PathLine { x: s1.width * 17 / 24; y: s1.height * 1 / 2 }
            PathLine { x: s1.width * 17 / 24; y: s1.height * 5 / 6 }
            PathLine { x: s1.width * 7 / 24; y: s1.height * 5 / 6 }
            PathLine { x: s1.width * 7 / 24; y: s1.height * 1 / 2 }
            PathLine { x: s1.width * 1 / 6; y: s1.height * 1 / 2 }
        }

        ShapePath {
            id: gamePath
            fillColor: "#ffffff"
            strokeColor: "#ffffff"
            startX: s1.width * 1 / 6; startY: s1.height * 1 / 2
            PathAngleArc {
                centerX: s1.width * 1 / 3; centerY: s1.height * 2 / 6
                radiusX: s1.height * 1 / 12; radiusY: s1.height * 1 / 12
                startAngle: 180
                sweepAngle: 180
            }
            PathAngleArc {
                centerX: s1.width * 2 / 3; centerY: s1.height * 2 / 6
                radiusX: s1.height * 1 / 12; radiusY: s1.height * 1 / 12
                startAngle: 180
                sweepAngle: 180
            }
            PathLine { x: s1.width * 3 / 12; y: s1.height * 2 / 6 }
            PathLine { x: s1.width * 1 / 6; y: s1.height * 4 / 6 }
            PathLine { x: s1.width * 4 / 12; y: s1.height * 4 / 6 }
            PathLine { x: s1.width * 5 / 12; y: s1.height * 7 / 12 }
            PathLine { x: s1.width * 7 / 12; y: s1.height * 7 / 12 }
            PathLine { x: s1.width * 8 / 12; y: s1.height * 8 / 12 }
            PathLine { x: s1.width * 5 / 6; y: s1.height * 4 / 6 }
            PathLine { x: s1.width * 9 / 12; y: s1.height * 2 / 6 }
            PathAngleArc {
                centerX: s1.width * 9 / 12; centerY: s1.height * 4 / 6
                radiusX: s1.height * 1 / 12; radiusY: s1.height * 1 / 12
                startAngle: 0
                sweepAngle: 180
            }
            PathAngleArc {
                centerX: s1.width * 3 / 12; centerY: s1.height * 4 / 6
                radiusX: s1.height * 1 / 12; radiusY: s1.height * 1 / 12
                startAngle: 0
                sweepAngle: 180
            }
        }

        Shape {
            id: s1
            anchors.centerIn: parent
            data: {
                let a = ({
                    "game": gamePath,
                    "home": homePath,
                    "school": homePath
                })[Globals.settings.mode]
                if (Globals.settings.mode != "school") {
                    a.fillColor = Qt.lighter(Globals.settings.accent)
                    a.strokeColor = Qt.lighter(Globals.settings.accent)
                }
                return a
            }
            width: 25
            height: 25
        }
    }
}
