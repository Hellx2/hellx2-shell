pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes
import QtCore

import qs.common

Row {
    id: root
    property bool showPomodoro: false

    IpcHandler {
        function toggle() {
            root.showPomodoro = !root.showPomodoro
        }
        target: "pomodoro"
    }

    NButton {
        content: "🕑 " + root.countdown.map(a => String(a).padStart(2, 0)).join(":")
        fgcolor: root.col
        onClicked: root.showPomodoro = !root.pomodoro.showPomodoro
    }

    property var defaultCountdown: [0, 25, 0]
    property var shortBreak: [0, 5, 0]
    property var longBreak: [0, 15, 0]
    property var countdown: defaultCountdown

    property bool isBreak: false
    property int breakNumber: 0
    property int longBreakOn: 4

    property var col: isBreak ? Styles.red : Styles.blue

    property bool onTopBar: false


    Settings {
        property alias countdown: root.countdown
        property alias isBreak: root.isBreak
        property alias breakNumber: root.breakNumber
    }

    property string notificationText: ""

    Process {
        id: pomodoroNotification
        command: ["notify-send", root.notificationText]
        running: false
    }

    Timer {
        id: countdownTimer
        running: false
        repeat: true
        onTriggered: {
            if (root.countdown[2] == 0) {
                if (root.countdown[1] == 0 && root.countdown[0] == 0) {
                    root.isBreak = !root.isBreak;
                    root.isBreakChanged();
                    if (root.isBreak) {
                        root.breakNumber += 1;
                        root.breakNumberChanged();
                        if (root.breakNumber % root.longBreakOn == 0) {
                            root.notificationText = "Take a long break!";
                            pomodoroNotification.running = true;
                            root.countdown = [...root.longBreak]
                        } else {
                            root.notificationText = "Take a short break!";
                            pomodoroNotification.running = true;
                            root.countdown = [...root.shortBreak]
                        }
                    } else {
                        root.notificationText = "Back to work!";
                        pomodoroNotification.running = true;
                        root.countdown = [...root.defaultCountdown]
                    }
                } else {
                    root.countdown[2] = 59;
                    if (root.countdown[1] == 0) {
                        root.countdown[1] = 59;
                        root.countdown[0] -= 1;
                    } else {
                        root.countdown[1] -= 1;
                    }
                }
            } else {
                root.countdown[2] -= 1;
            }
            root.arcWidth = root.getArcWidth();

            root.countdownChanged();
        }
    }
    function getArcWidth() {
        let current = Number(root.countdown[0] * 3600) + Number(root.countdown[1] * 60) + Number(root.countdown[2]);
        if (root.isBreak)
            if (root.breakNumber % root.longBreakOn == 0) return Math.min(current / (root.longBreak[0] * 3600 + root.longBreak[1] * 60 + root.longBreak[2]) * 100, 100);
            else return Math.min(current / (root.shortBreak[0] * 3600 + root.shortBreak[1] * 60 + root.shortBreak[2]) * 100, 100);
        else return Math.min(current / (root.defaultCountdown[0] * 3600 + root.defaultCountdown[1] * 60 + root.defaultCountdown[2]) * 100, 100);
    }

    property var arcWidth: getArcWidth()

    LazyLoader {
        active: root.showPomodoro
        PanelWindow {
            id: panel1
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            implicitWidth: 400
            implicitHeight: 500
            color: "transparent"
            margins {
                bottom: 10
                top: 10
                right: 10
            }
            Rectangle {
                anchors.fill: parent
                color: Styles.bgcol
                radius: 15
            }
            anchors {
                bottom: !root.onTopBar
                top: root.onTopBar
                right: true
            }

            Item {
                anchors.fill: parent
                layer.enabled: true
                layer.samples: 5
                Shape {
                    width: 200
                    height: 200

                    ShapePath {
                        fillColor: Styles.grey3
                        strokeWidth: 0

                        PathAngleArc {
                            centerX: panel1.width / 2
                            centerY: Math.min(panel1.width / 2, panel1.height / 2)
                            radiusX: Math.min(panel1.width * 5 / 16, panel1.height * 5 / 16)
                            radiusY: Math.min(panel1.width * 5 / 16, panel1.height * 5 / 16)

                            startAngle: -225
                            sweepAngle: 270
                        }
                    }
                }
                Shape {
                    width: Math.min(panel1.width / 2, panel1.height / 2)
                    height: Math.min(panel1.width / 2, panel1.height / 2)

                    ShapePath {
                        fillColor: "transparent"
                        strokeColor: root.col
                        strokeWidth: 1.0 * Math.min(panel1.width / 20, panel1.height / 20)
                        capStyle: ShapePath.RoundCap

                        PathAngleArc {
                            centerX: panel1.width / 2
                            centerY: Math.min(panel1.width / 2, panel1.height / 2)
                            radiusX: Math.min(panel1.width * 5 / 16, panel1.height * 5 / 16)
                            radiusY: Math.min(panel1.width * 5 / 16, panel1.height * 5 / 16)
                            startAngle: -225
                            sweepAngle: root.arcWidth / 100 * 270
                        }
                    }
                }
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    id: timeRow
                    x: 6 / 20 * panel1.width
                    y: 7 / 8 * Math.min(panel1.width / 2, panel1.height / 2)

                    width: 4 / 10 * panel1.width
                    NInput {
                        text: String(root.countdown[0]).padStart(2, 0)
                        onTextEdited: {
                            root.countdown[0] = Number(text);
                            root.countdownChanged();
                            root.arcWidth = root.getArcWidth();
                        }
                        color: root.col
                        fontSize: 2 / 40 * Math.min(panel1.width, panel1.height)
                        horizontalAlignment: Text.AlignHCenter
                        width: timeRow.width / 4
                    }
                    NText {
                        text: ":"
                        color: root.col
                        fontSize: 2 / 40 * Math.min(panel1.width, panel1.height)
                        horizontalAlignment: Text.AlignHCenter
                        width: timeRow.width / 8
                    }
                    NInput {
                        text: String(root.countdown[1]).padStart(2, 0)
                        onTextEdited: {
                            root.countdown[1] = Number(text);
                            root.countdownChanged();
                            root.arcWidth = root.getArcWidth();
                        }
                        color: root.col
                        fontSize: 2 / 40 * Math.min(panel1.width, panel1.height)
                        horizontalAlignment: Text.AlignHCenter
                        width: timeRow.width / 4
                    }
                    NText {
                        text: ":"
                        color: root.col
                        fontSize: 2 / 40 * Math.min(panel1.width, panel1.height)
                        horizontalAlignment: Text.AlignHCenter
                        width: timeRow.width / 8
                    }
                    NInput {
                        property bool alternateSwitch: false
                        text: String(root.countdown[2]).padStart(2, 0)
                        onTextEdited: {
                            if (!alternateSwitch) {
                                root.countdown[2] = Number(text);
                                root.countdownChanged();
                                root.arcWidth = root.getArcWidth();
                            }
                            alternateSwitch = !alternateSwitch;
                        }
                        color: root.col
                        fontSize: 2 / 40 * Math.min(panel1.width, panel1.height)
                        horizontalAlignment: Text.AlignHCenter
                        width: timeRow.width / 4
                    }
                }

                NButton {
                    id: playPauseBtn
                    x: 1 / 5 * panel1.width
                    y: 7 / 8 * Math.min(panel1.width, panel1.height)
                    width: Math.min(panel1.width, panel1.height) / 6
                    height: Math.min(panel1.width, panel1.height) / 6
                    padding: 0
                    contentItem: Item {
                        // Play Button
                        ShapePath {
                            id: path1
                            strokeColor: root.col
                            fillColor: root.col
                            startX: playPauseBtn.width * 5 / 16; startY: playPauseBtn.width * 1 / 4;
                            PathLine { x: playPauseBtn.width * 5 / 16; y: playPauseBtn.width * 3 / 4 }
                            PathLine { x: playPauseBtn.width * 3 / 4; y: playPauseBtn.width * 1 / 2 }
                            PathLine { x: playPauseBtn.width * 5 / 16; y: playPauseBtn.width * 1 / 4 }
                        }

                        // Pause Button pt. 1
                        ShapePath {
                            id: path2
                            strokeColor: root.col
                            fillColor: root.col
                            startX: playPauseBtn.width * 6 / 16; startY: playPauseBtn.width * 5 / 16
                            strokeWidth: playPauseBtn.width * 1 / 8
                            PathLine {
                                x: playPauseBtn.width * 3 / 8
                                y: playPauseBtn.width * 3 / 8 + playPauseBtn.width * 5 / 16
                            }
                        }
                        // Pause Button pt. 2
                        ShapePath {
                            id: path3
                            strokeColor: root.col
                            fillColor: root.col
                            startX: playPauseBtn.width * 5 / 8; startY: playPauseBtn.width * 5 / 16
                            strokeWidth: playPauseBtn.width * 1 / 8
                            PathLine {
                                x: playPauseBtn.width * 5 / 8
                                y: playPauseBtn.width * 3 / 8 + playPauseBtn.width * 5 / 16
                            }
                        }

                        Shape {
                            data: countdownTimer.running ? [path2, path3] : [path1]
                        }
                    }
                    background: Rectangle {
                        color: Styles.grey4
                        radius: parent.height / 2
                    }
                    onClicked: countdownTimer.running = !countdownTimer.running
                }
                NButton {
                    x: 3 / 5 * panel1.width
                    y: 7 / 8 * Math.min(panel1.width, panel1.height)
                    width: Math.min(panel1.width, panel1.height) / 6
                    height: Math.min(panel1.width, panel1.height) / 6
                    contentItem: NText {
                        text: "↺"
                        color: root.col
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        fontSize: 1 / 10 * Math.min(panel1.width, panel1.height)
                    }
                    background: Rectangle {
                        color: Styles.grey4
                        radius: parent.height / 2
                    }
                    onClicked: {
                        countdownTimer.running = false;
                        root.isBreak = false;
                        root.breakNumber = 0;
                        root.countdown = [...root.defaultCountdown]
                        root.countdownChanged();
                    }
                }
            }
        }
    }
}
