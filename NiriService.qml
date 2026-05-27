// (c) AvengeMedia 2025
// Code taken with only minor modifications from DankMaterialShell, all credit goes to them.

pragma Singleton
pragma ComponentBehavior: Bound

import QtCore
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string socketPath: Quickshell.env("NIRI_SOCKET")

    property var workspaces: ({})
    property var allWorkspaces: []

    property var windows: []

    property bool hasInitialConnection: false

    signal windowUrgentChanged

    function setWorkspaces(newMap) {
        root.workspaces = newMap;
        root.allWorkspaces = Object.values(newMap).sort((a, b) => a.idx - b.idx);
    }

    function updateAllWorkspaces() {
        root.allWorkspaces = Object.values(root.workspaces).sort((a,b) => a.idx - b.idx)
    }

    DankSocket {
        id: eventStreamSocket
        path: root.socketPath
        connected: true

        onConnectionStateChanged: {
            if (connected) {
                send('"EventStream"');
            }
        }

        parser: SplitParser {
            onRead: line => {
                try {
                    const event = JSON.parse(line);
                    handleNiriEvent(event);
                } catch (e) {
                    console.warn("NiriService: Failed to parse event:", line, e);
                }
            }
        }
    }

    DankSocket {
        id: requestSocket
        path: root.socketPath
        connected: true
    }

    function sortWindowsByLayout(windowList) {
        const enriched = windowList.map(w => {
            const ws = workspaces[w.workspace_id];
            if (!ws) {
                return {
                    "window": w,
                    "wsIdx": 999999,
                    "col": 999999,
                    "row": 999999
                };
            }

            const pos = w.layout?.pos_in_scrolling_layout;
            const col = (pos && pos.length >= 2) ? pos[0] : 999999;
            const row = (pos && pos.length >= 2) ? pos[1] : 999999;

            return {
                "window": w,
                "wsIdx": ws.idx,
                "col": col,
                "row": row
            };
        });

        enriched.sort((a, b) => {
            if (a.wsIdx !== b.wsIdx)
                return a.wsIdx - b.wsIdx;
            if (a.col !== b.col)
                return a.col - b.col;
            if (a.row !== b.row)
                return a.row - b.row;
            return a.window.id - b.window.id;
        });

        return enriched.map(e => e.window);
    }

    function handleNiriEvent(event) {
        const eventType = Object.keys(event)[0];

        switch (eventType) {
        case 'WorkspacesChanged':
            handleWorkspacesChanged(event.WorkspacesChanged);
            break;
        case 'WorkspaceActivated':
            handleWorkspaceActivated(event.WorkspaceActivated);
            break;
        case 'WorkspaceActiveWindowChanged':
            handleWorkspaceActiveWindowChanged(event.WorkspaceActiveWindowChanged);
            break;
        case 'WindowFocusChanged':
            handleWindowFocusChanged(event.WindowFocusChanged);
            break;
        case 'WindowsChanged':
            handleWindowsChanged(event.WindowsChanged);
            break;
        case 'WindowClosed':
            handleWindowClosed(event.WindowClosed);
            break;
        case 'WindowOpenedOrChanged':
            handleWindowOpenedOrChanged(event.WindowOpenedOrChanged);
            break;
        case 'WindowLayoutsChanged':
            handleWindowLayoutsChanged(event.WindowLayoutsChanged);
            break;
        case 'OutputsChanged':
            handleOutputsChanged(event.OutputsChanged);
            break;
        case 'WorkspaceUrgencyChanged':
            handleWorkspaceUrgencyChanged(event.WorkspaceUrgencyChanged);
            break;
        case 'WindowUrgencyChanged':
            handleWindowUrgencyChanged(event.WindowUrgencyChanged);
            break;
        }
    }

    function handleWorkspacesChanged(data) {
        const newWorkspaces = {};

        for (const ws of data.workspaces) {
            const oldWs = root.workspaces[ws.id];
            newWorkspaces[ws.id] = ws;
            if (oldWs && oldWs.active_window_id !== undefined) {
                newWorkspaces[ws.id].active_window_id = oldWs.active_window_id;
            }
        }

        setWorkspaces(newWorkspaces);
    }

    function handleWorkspaceActivated(data) {
        for (const id in root.workspaces) {
            const workspace = root.workspaces[id];
            const got_activated = root.workspaces[id].id === data.id;
            root.workspaces[id].is_active = got_activated
            if (data.focused) root.workspaces[id].is_focused = got_activated
        }
        updateAllWorkspaces()
    }

    function handleWindowFocusChanged(data) {
        const focusedWindowId = data.id;

        let focusedWindow = null;
        const updatedWindows = [];

        for (var i = 0; i < windows.length; i++) {
            windows[i].is_focused = (windows[i].id === focusedWindowId);
            if (windows[i].is_focused) {
                focusedWindow = windows[i];
            }
        }

        windowsChanged();

        if (focusedWindow) {
            const ws = root.workspaces[focusedWindow.workspace_id];
            if (ws && ws.active_window_id !== focusedWindowId) {
                const updatedWs = {};
                for (let prop in ws) {
                    updatedWs[prop] = ws[prop];
                }
                root.workspaces[focusedWindow.workspace_id].active_window_id = focusedWindowId;

                updateAllWorkspaces()
            }
        }
    }

    function handleWorkspaceActiveWindowChanged(data) {
        const ws = root.workspaces[data.workspace_id];
        if (root.workspaces[data.workspace_id])
            root.workspaces[data.workspace_id].active_window_id = data.active_window_id;

        const updatedWindows = [];

        for (var i = 0; i < windows.length; i++) {
            const w = windows[i];
            const updatedWindow = {};

            for (let prop in w) {
                updatedWindow[prop] = w[prop];
            }

            if (data.active_window_id !== null && data.active_window_id !== undefined) {
                updatedWindow.is_focused = (w.id == data.active_window_id);
            } else {
                updatedWindow.is_focused = w.workspace_id == data.workspace_id ? false : w.is_focused;
            }

            updatedWindows.push(updatedWindow);
        }

        windows = updatedWindows;
    }

    function handleWindowsChanged(data) {
        windows = sortWindowsByLayout(data.windows);
    }

    function handleWindowClosed(data) {
        windows = windows.filter(w => w.id !== data.id);
    }

    function handleWindowOpenedOrChanged(data) {
        if (!data.window)
            return;
        const window = data.window;
        const existingIndex = windows.findIndex(w => w.id === window.id);

        if (existingIndex >= 0) {
            const updatedWindows = [...windows];
            updatedWindows[existingIndex] = window;
            windows = sortWindowsByLayout(updatedWindows);
        } else {
            windows = sortWindowsByLayout([...windows, window]);
        }
    }

    function handleWindowLayoutsChanged(data) {
        if (!data.changes)
            return;
        const updatedWindows = [...windows];
        let hasChanges = false;

        for (const change of data.changes) {
            const windowId = change[0];
            const layoutData = change[1];

            const windowIndex = updatedWindows.findIndex(w => w.id === windowId);
            if (windowIndex < 0)
                continue;
            const updatedWindow = {};
            for (var prop in updatedWindows[windowIndex]) {
                updatedWindow[prop] = updatedWindows[windowIndex][prop];
            }
            updatedWindow.layout = layoutData;
            updatedWindows[windowIndex] = updatedWindow;
            hasChanges = true;
        }

        if (!hasChanges)
            return;
        windows = sortWindowsByLayout(updatedWindows);
    }

    function handleOutputsChanged(data) {
        if (!data.outputs)
            return;
        outputs = data.outputs;
        windows = sortWindowsByLayout(windows);
    }

    function handleWorkspaceUrgencyChanged(data) {
        const ws = root.workspaces[data.id];
        if (!ws)
            return;
        const updatedWs = {};
        for (let prop in ws) {
            updatedWs[prop] = ws[prop];
        }
        updatedWs.is_urgent = data.urgent;

        const updatedWorkspaces = {};
        for (const id in root.workspaces) {
            updatedWorkspaces[id] = id === data.id ? updatedWs : root.workspaces[id];
        }
        setWorkspaces(updatedWorkspaces);

        windowUrgentChanged();
    }

    function handleWindowUrgencyChanged(data) {
        const windowIndex = windows.findIndex(w => w.id === data.id);
        if (windowIndex < 0)
            return;
        const updatedWindows = [...windows];
        const updatedWindow = {};
        for (let prop in updatedWindows[windowIndex]) {
            updatedWindow[prop] = updatedWindows[windowIndex][prop];
        }
        updatedWindow.is_urgent = data.urgent;
        updatedWindows[windowIndex] = updatedWindow;
        windows = updatedWindows;

        windowUrgentChanged();
    }

    function send(request) {
        if (!requestSocket.connected)
            return false;
        requestSocket.send(request);
        return true;
    }

    function switchToWorkspace(workspaceIndex) {
        return send({
            "Action": {
                "FocusWorkspace": {
                    "reference": {
                        "Index": workspaceIndex
                    }
                }
            }
        });
    }

    function focusWindow(windowId) {
        return send({
            "Action": {
                "FocusWindow": {
                    "id": windowId
                }
            }
        });
    }
}
