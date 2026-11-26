import Quickshell
import qs.core
import QtQuick
import QtQuick.Shapes

NButton {
    id: btn1
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
    property bool showDate: false
    onClicked: showDate = !showDate
    contentItem: Row {
        spacing: 5
        Shape {
            id: shp
            layer.enabled: true
            layer.samples: 5
            height: 20
            width: 20
            ShapePath {
                strokeColor: Globals.theme.extreme
                strokeWidth: 2
                capStyle: ShapePath.RoundCap
                startX: Math.cos((clock.hours % 12 + clock.minutes / 60) / 6 * Math.PI - Math.PI / 2) * 3 + 10
                startY: Math.sin((clock.hours % 12 + clock.minutes / 60) / 6 * Math.PI - Math.PI / 2) * 3 + 10
                PathLine {
                    x: 10
                    y: 10
                }
            }
            ShapePath {
                strokeColor: Globals.theme.extreme
                fillColor: "transparent"
                startX: 10
                startY: 10

                PathLine {
                    x: Math.cos((clock.minutes % 60) / 30 * Math.PI - Math.PI / 2) * 6 + 10
                    y: Math.sin((clock.minutes % 60) / 30 * Math.PI - Math.PI / 2) * 6 + 10
                }
            }

            ShapePath {
                strokeColor: Globals.theme.extreme
                fillColor: "transparent"
                strokeWidth: 2
                PathAngleArc {
                    centerX: 10
                    centerY: 10
                    radiusX: 8
                    radiusY: 8
                    startAngle: 0
                    sweepAngle: 360
                }
            }
        }
        NText {
            id: txt1
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            text: Qt.formatDateTime(clock.date, btn1.showDate ? "dd/MM/yy" : "hh:mm")
        }
    }
    width: txt1.implicitWidth + shp.width + 15
    height: 30
}
