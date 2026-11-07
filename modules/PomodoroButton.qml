import QtQuick
import QtQuick.Shapes
import Quickshell
import qs.core
import qs.rootmodules
import qs

MouseArea {
    id: btn1
    hoverEnabled: true
    enabled: Pomodoro.buttonEnabled
    clip: true
    height: 30
    width: 30 + (containsMouse ? txt2.width : 0)
    onClicked: {
        let onTopBar = QsWindow.window.anchors.top;
        if (Pomodoro.onTopBar != onTopBar) {
            Pomodoro.onTopBar = onTopBar;
            Pomodoro.showPomodoro = true;
        } else
            Pomodoro.showPomodoro = !Pomodoro.showPomodoro;
    }
    Rectangle {
        anchors.fill: parent
        color: Globals.theme.button_bg
        radius: height / 2
    }

    Row {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 5
        width: parent.width - 10
        clip: true
        layer.enabled: true
        layer.samples: 5
        Shape {
            width: 20
            height: 20

            ShapePath {
                strokeColor: Pomodoro.col
                strokeWidth: 3
                fillColor: "transparent"
                PathAngleArc {
                    centerX: 10
                    centerY: 10
                    radiusX: 8
                    radiusY: 8
                    startAngle: 0
                    sweepAngle: 360
                }
            }
            ShapePath {
                startX: 10
                startY: 2
                strokeColor: Pomodoro.col
                //strokeWidth: 2
                fillColor: Pomodoro.col
                PathLine {
                    x: 10
                    y: 10
                }
                PathAngleArc {
                    moveToStart: false
                    radiusX: 8
                    radiusY: 8
                    centerX: 10
                    centerY: 10
                    // Start at top rather than 90 degrees after top.
                    startAngle: -90
                    // Invert arc width as arc width reduces rather than increases
                    // over time.
                    sweepAngle: (1 - Pomodoro.arcWidth / 100) * 360
                }
                PathLine {
                    x: 10
                    y: 10
                }
                /*PathLine {
                    x: 10 + 10 * Math.cos(2 * Math.PI * (1 - Pomodoro.arcWidth / 100) - Math.PI / 2);
                    y: 10 + 10 * Math.sin(2 * Math.PI * (1 - Pomodoro.arcWidth / 100) - Math.PI / 2);
                }*/
            }
        }
        NText {
            id: txt2
            color: Pomodoro.col
            visible: btn1.containsMouse
            text: " " + String((Pomodoro.countdown - Pomodoro.countdown % 3600) / 3600).padStart(2, 0) + ":" + String((Pomodoro.countdown % 3600 - Pomodoro.countdown % 60) / 60).padStart(2, 0) + ":" + String(Pomodoro.countdown % 60).padStart(2, 0)
        }
    }

    Behavior on width {
        SmoothedAnimation {
            duration: 200
        }
    }
}
