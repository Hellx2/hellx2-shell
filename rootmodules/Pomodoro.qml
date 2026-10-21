pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes
import QtCore

import qs.common
import qs

Singleton {
    id: root
    property bool showPomodoro: false
    property bool buttonEnabled: true

    IpcHandler {
        function toggle() {
            root.showPomodoro = !root.showPomodoro;
        }
        target: "pomodoro"
    }

    property int defaultCountdown: 25 * 60
    property int shortBreak: 5 * 60
    property int longBreak: 15 * 60
    property int countdown: defaultCountdown

    property bool isBreak: false
    property int breakNumber: 0
    property int longBreakOn: 4

    property string col: isBreak ? Globals.settings.red : Globals.settings.blue

    property bool onTopBar: false

    Settings {
        property alias countdown: root.countdown
        property alias isBreak: root.isBreak
        property alias breakNumber: root.breakNumber
        property alias countingDown: countdownTimer.running
    }

    property string notificationText: ""

    Process {
        id: pomodoroNotification
        command: ["notify-send", root.isBreak
        ? `Take a ${root.breakNumber % root.longBreakOn == 0 ? "long" : "short"} break!`
        : "Back to work!"]
        running: false
    }

    Timer {
        id: enabledTimer
        interval: 100
        onTriggered: root.buttonEnabled = true
    }

    Timer {
        id: countdownTimer
        running: false
        repeat: true
        onTriggered: {
            root.countdown -= 1;
            if (root.countdown == 0) {
                root.isBreak = !root.isBreak;
                root.isBreakChanged();
                if (root.isBreak) {
                    root.breakNumber += 1;
                    root.breakNumberChanged();
                    root.countdown = root.breakNumber % root.longBreakOn == 0 ? root.longBreak : root.shortBreak;
                } else root.countdown = root.defaultCountdown;
                pomodoroNotification.running = true;
            }

            root.countdownChanged();
        }
    }

    property var arcWidth: Math.min(root.countdown / (!root.isBreak ? root.defaultCountdown :
        (root.breakNumber % root.longBreakOn == 0 ? root.longBreak : root.shortBreak)) * 100, 100)


    LazyLoader {
        active: root.showPomodoro
        PanelWindow {
            id: panel1
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            Connections {
                target: ToplevelManager
                function onActiveToplevelChanged() {
                    if (!!ToplevelManager.activeToplevel) {
                        root.showPomodoro = false;
                        root.buttonEnabled = false
                        enabledTimer.running = true;
                    }
			    }
			}

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
                color: Globals.settings.bgcol
                radius: 15
                border {
                    width: 1
                    color: "#3c3c3c"
                }
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
                        fillColor: Globals.settings.grey3
                        strokeWidth: 0

                        PathAngleArc {
                            centerX: panel1.width / 2
                            centerY: Math.min(panel1.width, panel1.height) / 2
                            radiusX: Math.min(panel1.width, panel1.height) * 5 / 16
                            radiusY: radiusX

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
                            centerY: Math.min(panel1.width, panel1.height) / 2
                            radiusX: Math.min(panel1.width, panel1.width) * 5 / 16
                            radiusY: radiusX
                            startAngle: -225
                            sweepAngle: root.arcWidth / 100 * 270
                        }
                    }
                }
                Row {
                    id: timeRow
                    anchors.horizontalCenter: parent.horizontalCenter
                    x: 6 / 20 * panel1.width
                    y: 7 / 8 * Math.min(panel1.width / 2, panel1.height / 2)

                    width: 4 / 10 * panel1.width
                    NInput {
                        text: String(Math.floor(root.countdown / 3600)).padStart(2, 0)
                        onTextEdited: root.countdown = Number(text) * 3600 + (root.countdown % 3600);
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
                        text: String(Math.floor((root.countdown % 3600) / 60)).padStart(2, 0)
                        onTextEdited: root.countdown = root.countdown - (root.countdown % 3600)
                            + Number(text) * 60 + (root.countdown % 60);
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
                        text: String(root.countdown % 60).padStart(2, 0)
                        onTextEdited: root.countdown = root.countdown - (root.countdown % 60) + Number(text);
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
                            startX: playPauseBtn.width * 5 / 16
                            startY: playPauseBtn.width * 1 / 4
                            PathLine {
                                x: playPauseBtn.width * 5 / 16
                                y: playPauseBtn.width * 3 / 4
                            }
                            PathLine {
                                x: playPauseBtn.width * 3 / 4
                                y: playPauseBtn.width * 1 / 2
                            }
                            PathLine {
                                x: playPauseBtn.width * 5 / 16
                                y: playPauseBtn.width * 1 / 4
                            }
                        }

                        // Pause Button pt. 1
                        component PauseLine : ShapePath {
                            required property int index
                            strokeColor: root.col
                            fillColor: root.col
                            startX: playPauseBtn.width * (1 + index * 2) / 8
                            startY: playPauseBtn.width * 5 / 16
                            strokeWidth: playPauseBtn.width * 1 / 8
                            PathLine {
                                x: playPauseBtn.width * (1 + index * 2) / 8
                                y: playPauseBtn.width * 3 / 8 + playPauseBtn.width * 5 / 16
                            }
                        }

                        PauseLine { id: path2; index: 1 }
                        PauseLine { id: path3; index: 2 }

                        Shape {
                            data: countdownTimer.running ? [path2, path3] : [path1]
                        }
                    }
                    background: Rectangle {
                        color: Globals.settings.grey4
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
                        color: Globals.settings.grey4
                        radius: parent.height / 2
                    }
                    onClicked: {
                        countdownTimer.running = false;
                        root.isBreak = false;
                        root.breakNumber = 0;
                        //root.countdown = [...root.defaultCountdown];
                        root.countdown = root.defaultCountdown;
                        root.countdownChanged();
                    }
                }
            }
        }
    }
}
