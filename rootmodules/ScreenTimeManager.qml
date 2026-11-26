pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Wayland

Singleton {
    id: root
    property var screenTime: ({})
    property double lastTime: 0
    property string currApp

    Component.onCompleted: {
        currApp = ToplevelManager.activeToplevel?.appId;
        lastTime = Math.floor(Date.now() / 1000 * 10) / 10;
    }

    Connections {
        target: ToplevelManager
        function onActiveToplevelChanged() {
            let id = root.currApp;
            let now = Math.floor(Date.now() / 1000 * 10) / 10;
            if (!!id && id != "") {
                root.screenTime[id] = (root.screenTime[id] ?? 0) + now - root.lastTime;
                console.warn(JSON.stringify(root.screenTime));
            }
            root.lastTime = now;
            checkTimer.restart();
            root.currApp = ToplevelManager.activeToplevel?.appId ?? "";
        }
    }

    Timer {
        id: checkTimer
        interval: 10000
        repeat: true
        running: true
        onTriggered: {
            let id = root.currApp;
            let now = Math.round(Date.now() / 1000 * 10) / 10;
            if (!!id && id != "") {
                root.screenTime[id] = (root.screenTime[id] ?? 0) + now - root.lastTime;
                console.warn(JSON.stringify(root.screenTime));
            }
            root.lastTime = now;
            root.currApp = ToplevelManager.activeToplevel?.appId ?? "";
        }
    }
}
