pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.common
import qs

Singleton {
    id: root
    property bool showPowerMenu: false
    IpcHandler {
        function show() {
            root.showPowerMenu = true
        }
        function hide() {
            root.showPowerMenu = false
        }
        function toggle() {
            root.showPowerMenu = !root.showPowerMenu
        }
        target: "powermenu"
    }

    PanelWindow {
        id: mainwin
        anchors {
            left: true
            right: true
            bottom: true
            top: true
        }
        color: "#aa000000"
        MouseArea {
            focus: true
            Keys.onEscapePressed: mainwin.showConfirmation = root.showPowerMenu = false
            anchors.fill: parent
            propagateComposedEvents: false
            onClicked: mainwin.showConfirmation = root.showPowerMenu = false
        }
        visible: root.showPowerMenu
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        property bool showConfirmation: false
        property string action: ""
        property list<string> cmd: []

        WrapperMouseArea {
            anchors.centerIn: parent
            visible: mainwin.showConfirmation
            propagateComposedEvents: true
            Rectangle {
                implicitWidth: 200
                implicitHeight: 100
                color: Globals.settings.grey2
                radius: 10
                border {
                    width: 1
                    color: Globals.settings.grey4
                }

                Column {
                    anchors.centerIn: parent
                    width: parent.width * 0.8
                    spacing: 5
                    NText {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: `Are you sure you want to ${mainwin.action}?`
                        wrapMode: Text.WordWrap
                    }
                    Row {
                        spacing: parent.width * 0.05
                        width: parent.width
                        anchors.horizontalCenter: parent.horizontalCenter
                        NButton {
                            contentItem: NText {
                                text: "Yes"
                                horizontalAlignment: Text.AlignHCenter
                            }
                            width: parent.width * 0.475
                            onClicked: {
                                root.showPowerMenu = mainwin.showConfirmation = false
                                Quickshell.execDetached(mainwin.cmd)
                            }
                        }
                        NButton {
                            contentItem: NText {
                                text: "No"
                                horizontalAlignment: Text.AlignHCenter
                            }
                            onClicked: root.showPowerMenu = mainwin.showConfirmation = false
                            width: parent.width * 0.475
                        }
                    }
                }
            }
        }

        WrapperMouseArea {
            anchors.centerIn: parent
            visible: !mainwin.showConfirmation
            Rectangle {
                id: mainrect
                implicitWidth: 400
                implicitHeight: 50 * rep1.count + 125
                radius: 10
                color: Globals.settings.grey2
                border {
                    width: 1
                    color: Globals.settings.grey4
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 12.5
                    NText {
                        text: "Power Menu"
                        fontSize: 16
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    property var model: [
                        ["Lock", ["loginctl", "lock-session"], "system-lock-screen-symbolic"],
                        ["Suspend", ["systemctl", "suspend", "-i"], "system-suspend-symbolic"],
                        ["Reboot", ["systemctl", "reboot", "-i"], "system-reboot-symbolic"],
                        ["Shutdown", ["systemctl", "poweroff", "-i"], "system-shutdown-symbolic"],
                        ["Log Out", ["niri", "msg", "action", "quit", "-s"], "system-log-out-symbolic"],
                    ]
                    ListView {
                        height: parent.model.length * 60 - 10
                        width: mainrect.width - 40
                        spacing: 10
                        acceptedButtons: Qt.NoButton
                        id: rep1
                        model: parent.model
                        delegate: MouseArea {
                            id: ma
                            required property var modelData
                            width: mainrect.width - 40
                            height: 50
                            hoverEnabled: true
                            onClicked: {
                                //root.showPowerMenu = false
                                mainwin.showConfirmation = true
                                mainwin.action = modelData[0].toLowerCase()
                                mainwin.cmd = modelData[1]
                            }
                            Rectangle {
                                anchors.fill: parent
                                radius: 10
                                color: ma.containsMouse ? Globals.settings.grey6 : Globals.settings.grey4

                                Row {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 5
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 10
                                    Rectangle {
                                        width: 40
                                        height: 40
                                        radius: height / 2
                                        color: "#fff"
                                        IconImage {
                                            source: Quickshell.iconPath(modelData[2])
                                            implicitSize: 40
                                        }
                                    }
                                    NText {
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData[0]
                                        fontSize: 16
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
