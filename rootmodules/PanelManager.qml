pragma Singleton

import Quickshell
import qs.core

Singleton {
    id: root
    property var panels: ({})
    property string activePanel

    function register(name: string, panel: Panel) {
        root.panels[name] = panel;
        console.warn(Object.keys(root.panels));
    }

    /*Variants {
        model: panels
    }*/
}
