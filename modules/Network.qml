pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Wayland
import Quickshell.Widgets
import qs.core
import qs

MouseArea {
    id: root

    property bool showWindow: false
    property var mainDevice: Networking.devices.values.find(x => x instanceof WifiDevice)
    property var networks: []

    property var win: QsWindow.window

    width: 30
    height: 30
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton

    onClicked: m => {
        if (m.button & Qt.LeftButton)
            mainDevice.scannerEnabled = showWindow = !showWindow;
        else
            Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    Timer {
        id: enabledTimer
        interval: 100
        onTriggered: root.enabled = true
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Networking.wifiEnabled ? Globals.theme.accent : Globals.theme.button_bg

        IconImage {
            anchors.centerIn: parent
            source: Quickshell.iconPath(Networking.wifiEnabled ? (root.mainDevice?.state == ConnectionState.Connected ? "nm-signal-" + (Math.round(root.mainDevice.networks.values[0]?.signalStrength * 4) * 25) : (root.mainDevice?.state == ConnectionState.Connecting ? "nm-stage01-connecting01" : "nm-no-connection-symbolic")) : "nm-no-connection-symbolic", true)
            implicitSize: parent.height * 0.8
        }
    }

    LazyLoader {
        active: root.showWindow
        PanelWindow {
            implicitHeight: 500
            implicitWidth: 400

            Connections {
                target: ToplevelManager
                function onActiveToplevelChanged() {
                    if (!!ToplevelManager.activeToplevel)
                        root.showWindow = false;
                    root.enabled = false;
                    enabledTimer.running = true;
                }
            }
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            anchors {
                top: root.win.anchors.top
                bottom: root.win.anchors.bottom
                left: true
            }
            margins {
                left: root.win.mapFromItem(root, 0, 0).x + root.win.margins.left + root.width / 2 - implicitWidth / 2
                bottom: 10
                top: 10
            }
            color: "transparent"
            Rectangle {
                anchors.fill: parent
                color: Globals.theme.bgcol
                radius: 10
                border {
                    width: 1
                    color: Globals.theme.dark ? Qt.lighter(color) : Qt.darker(color)
                }
            }
            Column {
                anchors.fill: parent
                anchors.margins: 5
                spacing: 5
                Row {
                    id: toprow
                    anchors.leftMargin: 5
                    anchors.left: parent.left
                    NText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Networking.wifiEnabled ? "Enabled" : "Disabled"
                    }
                    NSwitch {
                        anchors.verticalCenter: parent.verticalCenter
                        isSwitched: Networking.wifiEnabled
                        onIsSwitchedChanged: {
                            Networking.wifiEnabled = this.isSwitched;
                        }
                    }
                }
                ListView {
                    id: lv
                    visible: Networking.wifiEnabled
                    model: root.mainDevice.networks
                    height: parent.height - toprow.height - 5
                    width: parent.width
                    spacing: 5
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: lv.width
                            height: lv.height
                            radius: 10
                        }
                    }

                    delegate: Row {
                        required property var modelData
                        required property var index

                        width: lv.width
                        Rectangle {
                            height: 27.5
                            width: parent.width
                            radius: 10
                            color: modelData.connected ? Globals.theme.active_item : Globals.theme.inactive_item

                            Row {
                                height: parent.height
                                width: parent.width - rightrow.width - 10
                                anchors.left: parent.left
                                anchors.leftMargin: 5
                                spacing: 5
                                Button {
                                    id: icon1
                                    padding: 1.25
                                    anchors.verticalCenter: parent.verticalCenter
                                    background: Rectangle {
                                        radius: height / 2
                                        color: modelData.connected ? Globals.theme.accent : Globals.theme.bgcol
                                    }
                                    contentItem: IconImage {
                                        anchors.centerIn: parent
                                        source: {
                                            Quickshell.iconPath("nm-signal-" + (Math.round(modelData.signalStrength * 4) * 25), true);
                                        }
                                        implicitSize: 20
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                    onClicked: {
                                        if (modelData.connected)
                                            root.mainDevice.disconnect();
                                        else {
                                            modelData.connect();
                                        }
                                        //if (modelData.paired) modelData.forget()
                                        //else modelData.pair()
                                    }
                                }
                                NText {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - icon1.width - 5
                                    elide: Text.ElideRight
                                    text: `${modelData.name}`
                                }
                            }
                            Row {
                                id: rightrow
                                anchors.right: parent.right
                                anchors.rightMargin: 5
                                anchors.verticalCenter: parent.verticalCenter
                                NText {
                                    text: `(${Math.round(modelData.signalStrength * 100)}%)`
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
