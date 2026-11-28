import Quickshell
import Quickshell.Io
import QtQuick

import qs.core
import qs.rootmodules

Panel {
    id: root
    panelName: "themeSwitcher"

    property var themes: []

    Process {
        id: themesGen
        command: ["ls", Quickshell.shellPath("themes/")]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.themes = this.text.trim().split("\n").map(x => ({
                            "icon": (Globals.settings.theme == Quickshell.shellPath("themes/") + x) ? "cancel" : "",
                            "text": x,
                            "data": x
                        }));
            }
        }
    }
    Rectangle {
        width: parent.width
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 5
        height: 50
        color: (Globals.theme.dark ? Qt.lighter : Qt.darker)(Globals.theme.bgcol, 1.2)
        border {
            width: 1
            color: (Globals.theme.dark ? Qt.lighter : Qt.darker)(color, 1.2)
        }
        radius: 10
        NText {
            text: "Themes"
            font.underline: true
            bold: true
            anchors.centerIn: parent
            fontSize: 20
            padding: 5
        }
        z: 5
    }

    ListBox {
        model: root.themes
        spacing: 5
        anchors.margins: 5
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: parent.height - 70
        onBtnClick: data => {
            PanelManager.clearActivePanel();
            Globals.settings.theme = Quickshell.shellPath("themes/") + JSON.parse(data);
            themesGen.running = true;
        }
    }
}
