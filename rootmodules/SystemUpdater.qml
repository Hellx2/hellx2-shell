pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
	id: root
	property bool needsUpdate: false
	property bool updateChecking: true
    property list<string> packageUpdates: []

    Process {
        id: mainProc
        // Note: This does *NOT* refresh the repos before checking.
        // Refreshing the repos requires root privileges.
        command: ["pacman", "-Qqu"]
        running: true
        onExited: (c) => {
            root.needsUpdate = (c == 0)
        }
        stdout: StdioCollector {
            onStreamFinished: {
                //console.warn(this.text.trim().split("\n"))
                root.packageUpdates = this.text.trim().split("\n")
            }
        }
    }

	Timer {
		interval: 300000
		repeat: true
		running: root.updateChecking
		onTriggered: mainProc.running = true
	}
}
