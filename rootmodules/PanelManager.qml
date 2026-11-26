pragma Singleton

import Quickshell.Wayland
import Quickshell
import QtQuick
import qs.core

Singleton {
    id: root
    property var panels: ({})
    property string activePanel

    Connections {
        target: ToplevelManager
        function onActiveToplevelChanged() {
            if (ToplevelManager.activeToplevel != null)
                root.clearActivePanel();
        }
    }

    function register(name: string, panel: Panel) {
        root.panels[name] = panel;
        //console.warn(Object.keys(root.panels));
    }

    function setActivePanel(name: string): bool {
        if (panels.hasOwnProperty(name)) {
            activePanel = name;
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

    /*Variants {
        model: panels
    }*/
}
