pragma Singleton

import Quickshell.Wayland
import Quickshell
import QtQuick
import qs.core

Singleton {
    id: root
    property var panels: ({})
    property string activePanel

    // To prevent the toplevel event from triggering and immediately
    // closing the open panel whenever switching to a different panel.
    Timer {
        id: switchTimer
        interval: 100
        onTriggered: tlconn.enabled = true
    }

    Connections {
        id: tlconn
        target: ToplevelManager
        function onActiveToplevelChanged() {
            if (ToplevelManager.activeToplevel != null)
                root.clearActivePanel();
        }
    }

    function register(name: string, panel: Panel) {
        root.panels[name] = panel;
    }

    function setActivePanel(name: string): bool {
        if (panels.hasOwnProperty(name)) {
            tlconn.enabled = false;
            activePanel = name;
            switchTimer.running = true;
            return true;
        } else
            return false;
    }

    function toggleActivePanel(name: string): bool {
        if (activePanel == name) {
            activePanel = "";
            return true;
        } else {
            return setActivePanel(name);
        }
    }

    function clearActivePanel() {
        activePanel = "";
    }
}
