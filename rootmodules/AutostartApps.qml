pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import QtCore
import QtQuick
import QtQuick.Shapes
import qs.core
import qs

PanelWindow {
    id: root
    property bool addMode: false
    visible: false
    implicitWidth: 600
    implicitHeight: 400
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    Connections {
        target: ToplevelManager
        enabled: root.visible
        function onActiveToplevelChanged() {
            if (!!ToplevelManager.activeToplevel)
                root.visible = false;
        }
    }

    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Globals.theme.bgcol
        radius: 10
        border {
            width: 1
            color: Qt[Globals.theme.dark ? "lighter" : "darker"](color)
        }
    }

    property var apps: []

    Process {
        id: getAutostartItems
        command: ["ls", Quickshell.env("HOME") + "/.config/autostart"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let x = this.text.trim();
                if (!!x)
                    apps = x.split("\n");
                else
                    apps = [];
            }
        }
    }
    Panel {}

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 10
        }
        radius: 10
        height: parent.height - bottomRow.height - title_text.height - 35
        color: (Globals.theme.dark ? Qt.lighter : Qt.darker)(Globals.theme.bgcol, 1.2)
        ListView {
            anchors.fill: parent
            model: ScriptModel {
                values: root.addMode ? DesktopEntries.applications.values.filter(x => x.name.toLowerCase().includes(filterInput.text.toLowerCase())) : root.apps
            }
            spacing: 5
            clip: true
            delegate: Rectangle {
                id: lv_rc
                required property var modelData
                width: root.width - 20
                height: 40
                color: (Globals.theme.dark ? Qt.lighter : Qt.darker)(Globals.theme.bgcol, 2)
                radius: 5

                property var cmd: root.addMode ? modelData.command : []
                property var name: root.addMode ? modelData.name : ""
                property var icon: root.addMode ? modelData.icon : ""

                FileView {
                    id: fv
                    path: root.addMode ? null : Quickshell.env("HOME") + "/.config/autostart/" + lv_rc.modelData
                    onLoaded: {
                        for (let a of this.text().trim().split("\n")) {
                            let b = a.split(/^([^=]+)=/).slice(1);
                            if (b.length == 0)
                                continue;
                            if (b[0] == "Exec")
                                lv_rc.cmd = ["sh", "-c", b[1]];
                            if (b[0] == "Name")
                                lv_rc.name = b[1];
                            if (b[0] == "Icon")
                                lv_rc.icon = b[1];
                        }
                    }
                }

                Process {
                    id: deleteProc
                    command: ["rm", Quickshell.env("HOME") + "/.config/autostart/" + lv_rc.modelData]
                    onExited: getAutostartItems.running = true
                }

                Process {
                    id: addProc
                    command: ["cp", new URL(StandardPaths.locate(StandardPaths.ApplicationsLocation, lv_rc.modelData?.id + ".desktop")).pathname, Quickshell.env("HOME") + "/.config/autostart/"]
                    onExited: {
                        root.addMode = false;
                        getAutostartItems.running = true;
                    }
                }

                MouseArea {
                    id: ma
                    onClicked: {
                        if (root.addMode)
                            addProc.running = true;
                        else
                            deleteProc.running = true;
                    }
                    anchors.fill: parent
                    hoverEnabled: true

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        IconImage {
                            source: Quickshell.iconPath(lv_rc.icon, true)
                            implicitSize: 25
                        }
                        NText {
                            text: lv_rc.name
                            color: ma.containsMouse ? Globals.theme[root.addMode ? "success" : "fail"] : Globals.theme.text_fg

                            anchors.verticalCenter: parent.verticalCenter
                            fontSize: 17
                            font.underline: ma.containsMouse
                        }
                    }
                    Row {
                        id: buttonRow
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        layoutDirection: Qt.RightToLeft
                        IconBtn {
                            enabled: false
                            _size: 20
                            lines: root.addMode ? [[10, 2.5, 10, 17.5], [2.5, 10, 17.5, 10]] : [[5, 5, 15, 15], [5, 15, 15, 5]]
                            color: ma.containsMouse ? Globals.theme[root.addMode ? "success" : "fail"] : Globals.theme.text_fg
                        }
                    }
                }
            }
        }
    }
    NText {
        id: title_text
        text: `${root.addMode ? "Add" : "View"}ing Autostart Apps`
        font.underline: true
        bold: true
        font.italic: true
        anchors.bottom: bottomRow.top
        anchors.margins: 5
        anchors.horizontalCenter: parent.horizontalCenter
    }
    Row {
        id: bottomRow
        height: 50
        anchors.margins: 10
        spacing: 10
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: 300
            height: 40
            radius: 10
            color: root.addMode ? Globals.theme.accent : Qt[Globals.theme.dark ? "lighter" : "darker"](Globals.theme.bgcol)
            Row {
                spacing: 5
                anchors.fill: parent
                anchors.margins: 10
                IconBtn {
                    anchors.verticalCenter: parent.verticalCenter
                    // Search icon
                    _size: 20
                    circles: [[7.5, 7.5, 5, 5]]
                    lines: [[12.5, 12.5, 17.5, 17.5]]
                }

                NInput {
                    id: filterInput
                    focus: true
                    Keys.onEscapePressed: root.visible = false
                    width: parent.width - 25
                    height: parent.height
                    bgcolor: "transparent"
                }
            }
        }
        IconBtn {
            _size: 20
            lines: root.addMode ? [[2.5, 2.5, 17.5, 17.5], [17.5, 2.5, 2.5, 17.5]] : [[0, 10, 20, 10], [10, 0, 10, 20]]
            anchors.verticalCenter: parent.verticalCenter
            onClicked: root.addMode = !root.addMode
        }
    }
}
