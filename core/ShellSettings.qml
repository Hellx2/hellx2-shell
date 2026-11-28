import Quickshell
import Quickshell.Io
import QtQuick
import QtCore

QtObject {
    id: root

    property string primaryScreen: "DP-1"

    property int brightnessTimeout: 10
    property int lockTimeout: 930
    property int screenOffTimeout: 900
    property int suspendTimeout: 1800

    property list<string> _pinnedApps: []

    property string _lastMode: "school"
    property string mode: "school"

    property string theme: Quickshell.shellPath("themes/theme1.json")

    function getPrimaryScreen() {
        return Quickshell.screens.find(x => x.name == root.primaryScreen) || Quickshell.screens[Quickshell.screens.length - 1];
    }

    property var modes: ({
            "school": {
                "bars": [
                    {
                        "position": "bottom",
                        "leftModules": ["launcher", "workspaces", "currentWindow", "spacer", "windows"],
                        "rightModules": ["player", "spacer", "tray", "pomodoro", "volume", "spacer", "tailscale", "bluetooth", "network", "spacer", "battery", "spacer", "clock"]
                    }
                ]
            },
            "home": {
                "extraModules": ["dock"],
                "bars": [
                    {
                        "position": "top",
                        "leftModules": [
                            {
                                "type": "launcher",
                                "props": {
                                    "useLaunchpad": true
                                }
                            },
                            "workspaces", "currentWindow"],
                        "rightModules": ["tray", "pomodoro", "volume", "spacer", "tailscale", "network", "bluetooth", "spacer", "battery", "spacer", "clock"]
                    }
                ]
            },
            "game": {
                "bars": [
                    {
                        "position": "bottom",
                        "width": 1000,
                        "leftModules": ["launcher", "workspaces", "windows"],
                        "rightModules": ["tray", "volume", "battery", "clock"]
                    }
                ]
            }
        })

    /*
	    */
}
