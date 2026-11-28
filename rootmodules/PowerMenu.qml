pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.core

Panel {
    id: mainwin
    panelName: "powerMenu"
    property var model: [["Lock", ["loginctl", "lock-session"], "system-lock-screen", "L"], ["Suspend", ["systemctl", "suspend", "-i"], "system-suspend", "S"], ["Log Out", ["niri", "msg", "action", "quit", "-s"], "system-log-out", "E"], ["Reboot", ["systemctl", "reboot", "-i"], "system-reboot", "R"], ["Shutdown", ["systemctl", "poweroff", "-i"], "system-shutdown", "P"],]

    implicitWidth: 400
    implicitHeight: model.length * 60 - 10 + txt1.height + 32.5
    MouseArea {
        id: keysArea
        focus: true
        anchors.fill: parent

        property var menuKeyFunctions: []
        Keys.onEscapePressed: PanelManager.clearActivePanel()
        Keys.onPressed: ev => {
            for (let i of menuKeyFunctions)
                i(ev);
        }
    }

    property bool showConfirmation: false
    property string action: ""
    property list<string> cmd: []
    Column {
        anchors.centerIn: parent
        spacing: 12.5
        NText {
            id: txt1
            text: "Power Menu"
            fontSize: 16
            anchors.horizontalCenter: parent.horizontalCenter
        }
        ListBox {
            id: rep1
            bgradius: 5
            fontSize: 16
            iconSize: 35
            height: mainwin.model.length * 55 - 10
            width: mainwin.width - 40
            spacing: 10
            acceptedButtons: Qt.NoButton
            model: mainwin.model.map(x => ({
                        "text": `[${x[3]}] ${x[0]}`,
                        "icon": x[2],
                        "data": x[1]
                    }))
            focus: true
            Component.onCompleted: {
                for (let i = 0; i < mainwin.model.length; i++) {
                    keysArea.menuKeyFunctions.push(ev => {
                        if (ev.key == mainwin.model[i][3].charCodeAt()) {
                            PanelManager.clearActivePanel();
                            Quickshell.execDetached(mainwin.model[i][1]);
                        }
                    });
                }
            }
        }
    }
}
