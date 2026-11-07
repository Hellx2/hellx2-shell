import qs.modules

Bar {
    topOfScreen: true

    leftHeight: 20
    leftSpacing: 10

    leftModules: [
        {
            "type": "launcher",
            "props": {
                "useLaunchpad": true
            }
        },
        "workspaces", "currentWindow"]
    rightModules: ["tray", "pomodoro", "volume", "spacer", "tailscale", "network", "bluetooth", "spacer", "battery", "spacer", "clock"]
}
