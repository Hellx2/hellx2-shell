import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import qs.modules
import qs.common

Scope {
    id: root

    property string fontFamily: "Red Hat Display"

    property int memUsage: 0
    property int cpuUsage: 0
    property int lastCpuIdle: 0
    property int lastCpuTotal: 0

    Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;
                var parts = data.trim().split(/\s+/);
                var total = parseInt(parts[1]) || 1;
                var used = parseInt(parts[2]) || 0;
                root.memUsage = Math.round(100 * used / total);
            }
        }
        Component.onCompleted: running = true
    }
    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;
                var p = data.trim().split(/\s+/);
                var idle = parseInt(p[4]) + parseInt(p[5]);
                var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0);
                if (root.lastCpuTotal > 0) {
                    root.cpuUsage = Math.round(100 * (1 - (idle - root.lastCpuIdle) / (total - root.lastCpuTotal)));
                }
                root.lastCpuTotal = total;
                root.lastCpuIdle = idle;
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true;
            memProc.running = true;
        }
    }

    NWindow {
        id: panel1

        anchorTop: true
        anchorLeft: true
        anchorRight: true

        iheight: 30
        exclusiveZone: 40

        Dashboard {
            id: dashboard
        }
        Rectangle {
            width: parent.width * 9 / 16
            height: parent.width * 9 / 16
            anchors.right: parent.right
            rotation: 270
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: "#00000000"
                }
                GradientStop {
                    position: 0.05
                    color: "#252525"
                }
                GradientStop {
                    position: 1.0
                    color: "#252525"
                }
            }
        }
        RowLayout {
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right

            NButton {
                id: nbutton1
                background: Rectangle {
                    anchors.centerIn: parent
                    height: parent.height * 3 / 4
                    width: parent.width
                    radius: 10
                    color: nbutton1.bgcolor
                }
                contentItem: Row {
                    NText {
                        text: " C " + `${root.cpuUsage}`.padStart(2, 0) + "% | M " + `${root.memUsage}`.padStart(2, 0) + "% "
                        fontFamily: "FiraCode Nerd Font"
                        bold: false
                    }
                }
            }
        }
        Rectangle {
            MouseArea {
                id: dashMouse
                anchors.fill: parent
                onClicked: dashboard.dashboardOpen = !dashboard.dashboardOpen // TODO: Make this show dashboard once window created
                hoverEnabled: true
            }
            anchors.centerIn: parent
            color: dashMouse.containsMouse ? "#6c6c6c" : "#4c4c4c"
            radius: 10
            width: 50
            height: parent.height - 10
            Rectangle {
                anchors.centerIn: parent
                width: parent.width * 2 / 3
                height: parent.height / 2
                color: dashMouse.containsMouse ? "#ccc" : "#aaa"
                radius: 10
            }
        }
    }
}
